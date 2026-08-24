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

regular_files = flow_files.reject do |file|
  Pathname.new(file).relative_path_from(root).to_s.start_with?("flows/special/")
end
special_files = flow_files.select do |file|
  Pathname.new(file).relative_path_from(root).to_s.start_with?("flows/special/")
end

max_depth = flow_files.map { |file| depth.call(file) }.max || 0
regular_max_depth = regular_files.map { |file| depth.call(file) }.max || 0
special_max_depth = special_files.map { |file| depth.call(file) }.max || 0
max_allowed_depth = 5
max_allowed_special_depth = 6
if regular_max_depth > max_allowed_depth
  errors << "profundidad maxima #{regular_max_depth}; limite #{max_allowed_depth}"
end
if special_max_depth > max_allowed_special_depth
  errors << "profundidad special maxima #{special_max_depth}; limite #{max_allowed_special_depth}"
end

unless errors.empty?
  warn errors.join("\n")
  exit 1
end

call_count = edges.values.map(&:length).inject(0, :+)
puts "#{call_count} llamadas; profundidad maxima #{max_depth} (regular #{regular_max_depth}, special #{special_max_depth}); sin referencias rotas, ciclos ni reusables huerfanos"
