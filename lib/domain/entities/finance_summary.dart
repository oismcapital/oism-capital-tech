/// Resumo financeiro exibido na Home (camada de domínio).
class FinanceSummary {
  const FinanceSummary({
    required this.investedBalance,
    required this.dailyProfit,
    required this.performancePoints,
  });

  final double investedBalance;
  final double dailyProfit;

  /// Pontos normalizados para o gráfico (ex.: rendimento acumulado).
  final List<double> performancePoints;
}
