/// Resumo financeiro exibido na Home (camada de domínio).
class FinanceSummary {
  const FinanceSummary({
    required this.walletBalance,
    required this.totalInvested,
    required this.totalAccruedInterest,
    required this.dailyProfit,
    required this.performancePoints,
    this.valorEscondido = false,
  });

  final double walletBalance;
  final double totalInvested;
  final double totalAccruedInterest;
  final double dailyProfit;
  final List<double> performancePoints;
  final bool valorEscondido;

  // Compatibilidade legada
  double get investedBalance => walletBalance;
}
