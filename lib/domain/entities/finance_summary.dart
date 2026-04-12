/// Resumo financeiro exibido na Home (camada de domínio).
class FinanceSummary {
  const FinanceSummary({
    required this.investedBalance,
    required this.dailyProfit,
    required this.performancePoints,
    this.valorEscondido = false,
  });

  final double investedBalance;
  final double dailyProfit;
  final List<double> performancePoints;
  final bool valorEscondido;
}
