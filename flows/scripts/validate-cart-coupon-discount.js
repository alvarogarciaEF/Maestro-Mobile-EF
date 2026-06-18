function digitsOnly(text) {
  return (
    Number(
      String(text || "")
        .split("")
        .filter(function (c) {
          return c >= "0" && c <= "9";
        })
        .join("")
    ) || 0
  );
}

var subtotal = digitsOnly(output.couponSubtotalText);
var discount = digitsOnly(output.couponDiscountText);
var expected = Math.round(subtotal * 0.15);
var tolerance = Math.max(2, expected * 0.05);

output.couponDiscountOk =
  subtotal > 0 &&
  discount > 0 &&
  Math.abs(discount - expected) <= tolerance;

console.log(
  "Coupon discount: subtotal=" +
    subtotal +
    " discount=" +
    discount +
    " expected=" +
    expected +
    " ok=" +
    output.couponDiscountOk
);
