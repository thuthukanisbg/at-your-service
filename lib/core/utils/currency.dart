/// Formats an amount as South African Rand, e.g. `formatRand(1250)` -> `R1,250`.
/// No space after `R` — matches the design handoff's convention exactly
/// (`R600`, `R1,200`, `R24.5k`, never `R 600`).
String formatRand(num amount) {
  final isNegative = amount < 0;
  final whole = amount.abs().truncate();
  final cents = ((amount.abs() - whole) * 100).round();

  final digits = whole.toString();
  final grouped = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i != 0 && (digits.length - i) % 3 == 0) grouped.write(',');
    grouped.write(digits[i]);
  }

  final centsSuffix = cents > 0 ? '.${cents.toString().padLeft(2, '0')}' : '';
  return '${isNegative ? '-' : ''}R$grouped$centsSuffix';
}
