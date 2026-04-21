class FinanceSummaryDto {
  FinanceSummaryDto({
    required this.walletBalance,
    required this.totalInvested,
    required this.totalAccruedInterest,
    required this.dailyProfit,
    this.performancePoints,
    this.valorEscondido = false,
  });

  factory FinanceSummaryDto.fromJson(Map<String, dynamic> json) {
    final rawPoints = json['performancePoints'] ?? json['points'] ?? json['chart'];
    List<double>? points;
    if (rawPoints is List) {
      points = rawPoints.map((e) => (e as num).toDouble()).toList();
    }
    return FinanceSummaryDto(
      walletBalance: _readDouble(json['walletBalance'] ?? json['investedBalance'] ?? json['saldo']),
      totalInvested: _readDouble(json['totalInvested']),
      totalAccruedInterest: _readDouble(json['totalAccruedInterest']),
      dailyProfit: _readDouble(json['dailyProfit'] ?? json['lucroDia'] ?? json['profit']),
      performancePoints: points,
      valorEscondido: json['valorEscondido'] as bool? ?? false,
    );
  }

  static double _readDouble(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

  final double walletBalance;
  final double totalInvested;
  final double totalAccruedInterest;
  final double dailyProfit;
  final List<double>? performancePoints;
  final bool valorEscondido;
}
