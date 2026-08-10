# frozen_string_literal: true

require "pathname"
require "yaml"

root = Pathname.new(File.expand_path("..", __dir__))
flow_files = Dir.glob(root.join("flows/**/*.yaml")).sort.map { |file| File.expand_path(file) }
edges = Hash.new { |hash, key| hash[key] = [] }

walk = nil
walk = lambda do |node, source|
  case node
  when Array
    node.each { |child| walk.call(child, source) }
  when Hash
    node.each do |key, value|
      if key == "runFlow"
        target =
          if value.is_a?(String)
            value
          elsif value.is_a?(Hash)
            value["file"]
          end

        edges[source] << File.expand_path(target, File.dirname(source)) if target
      end

      walk.call(value, source)
    end
  end
end

flow_files.each do |file|
  YAML.load_stream(File.read(file)).each { |document| walk.call(document, file) }
end

errors = []

edges.each do |source, targets|
  targets.each do |target|
    next if File.file?(target)

    errors << "#{Pathname.new(source).relative_path_from(root)} referencia #{Pathname.new(target).relative_path_from(root)}"
  end
end

visiting = {}
visited = {}

visit = nil
visit = lambda do |node, path|
  if visiting[node]
    cycle = path[path.index(node)..] + [node]
    errors << "ciclo: #{cycle.map { |file| Pathname.new(file).relative_path_from(root) }.join(" -> ")}"
    return
  end
  return if visited[node]

  visiting[node] = true
  edges[node].each { |target| visit.call(target, path + [node]) if File.file?(target) }
  visiting.delete(node)
  visited[node] = true
end

flow_files.each { |file| visit.call(file, []) }

incoming = Hash.new(0)
edges.values.flatten.each { |target| incoming[target] += 1 }

Dir.glob(root.join("flows/reusable/*.yaml")).sort.each do |file|
  absolute = File.expand_path(file)
  next if incoming[absolute].positive?

  errors << "reusable sin consumidor: #{Pathname.new(absolute).relative_path_from(root)}"
end

if errors.any? { |error| error.start_with?("ciclo:") }
  warn errors.join("\n")
  exit 1
end

depth_cache = {}
depth = nil
depth = lambda do |node|
  return depth_cache[node] if depth_cache.key?(node)

  children = edges[node].select { |target| File.file?(target) }
  depth_cache[node] = children.empty? ? 0 : 1 + children.map { |child| depth.call(child) }.max
end

max_depth = flow_files.map { |file| depth.call(file) }.max || 0
# 6 contempla que los flows special/ viven un nivel por encima de regression y componen
# reusables encadenados (p. ej. setup-cart -> add-product -> open-search -> ensure-home).
max_allowed_depth = 6
errors << "profundidad maxima #{max_depth}; limite #{max_allowed_depth}" if max_depth > max_allowed_depth

unless errors.empty?
  warn errors.join("\n")
  exit 1
end

call_count = edges.values.map(&:length).inject(0, :+)
puts "#{call_count} llamadas; profundidad maxima #{max_depth}; sin referencias rotas, ciclos ni reusables huerfanos"
