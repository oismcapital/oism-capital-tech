class FinanceSummaryDto {
  FinanceSummaryDto({
    required this.investedBalance,
    required this.dailyProfit,
    this.performancePoints,
  });

  factory FinanceSummaryDto.fromJson(Map<String, dynamic> json) {
    final rawPoints = json['performancePoints'] ?? json['points'] ?? json['chart'];
    List<double>? points;
    if (rawPoints is List) {
      points = rawPoints.map((e) => (e as num).toDouble()).toList();
    }
    return FinanceSummaryDto(
      investedBalance: _readDouble(json['investedBalance'] ?? json['balance'] ?? json['saldo']),
      dailyProfit: _readDouble(json['dailyProfit'] ?? json['lucroDia'] ?? json['profit']),
      performancePoints: points,
    );
  }

  static double _readDouble(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

  final double investedBalance;
  final double dailyProfit;
  final List<double>? performancePoints;
}
