import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../domain/entities/finance_summary.dart';
import '../../domain/repositories/finance_repository.dart';
import '../widgets/performance_line_chart.dart';
import '../widgets/robot_trader_illustration.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _hideBalance = false;
  FinanceSummary? _summary;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repo = context.read<FinanceRepository>();
      final s = await repo.getSummary();
      if (!mounted) return;
      setState(() {
        _summary = s;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  String _formatMoney(double v) {
    return 'R\$ ${v.toStringAsFixed(2).replaceFirst('.', ',')}';
  }

  List<double> _chartPoints() {
    final s = _summary;
    if (s != null && s.performancePoints.length > 1) {
      return s.performancePoints;
    }
    return List<double>.generate(12, (i) => 100 + i * 18 + (i * i).toDouble() * 0.4);
  }

  @override
  Widget build(BuildContext context) {
    final summary = _summary;

    return RefreshIndicator(
      color: AppColors.neonCyan,
      onRefresh: _load,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'OISM Capital Tech',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 22,
                          color: AppColors.textPrimary,
                          shadows: [
                            Shadow(
                              color: AppColors.neonCyan.withValues(alpha: 0.35),
                              blurRadius: 18,
                            ),
                          ],
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Inteligência e performance em um só lugar',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textMuted.withValues(alpha: 0.95)),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Saldo investido',
                                  style: TextStyle(
                                    color: AppColors.textMuted.withValues(alpha: 0.95),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () => setState(() => _hideBalance = !_hideBalance),
                                icon: Icon(
                                  _hideBalance ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                  color: AppColors.neonCyan,
                                ),
                                tooltip: _hideBalance ? 'Mostrar valor' : 'Ocultar valor',
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          if (_loading)
                            const LinearProgressIndicator(minHeight: 2)
                          else
                            Text(
                              summary == null
                                  ? '—'
                                  : _hideBalance
                                      ? '••••••'
                                      : _formatMoney(summary.investedBalance),
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.2,
                              ),
                            ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Text(
                                'Lucro do dia',
                                style: TextStyle(
                                  color: AppColors.textMuted.withValues(alpha: 0.95),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  summary == null
                                      ? '—'
                                      : _hideBalance
                                          ? '••••'
                                          : _formatMoney(summary.dailyProfit),
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                    color: AppColors.neonGreen,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    shadows: [
                                      Shadow(
                                        color: AppColors.neonGreen,
                                        blurRadius: 14,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Não foi possível carregar os dados da API.\n$_error',
                      style: TextStyle(color: Colors.redAccent.withValues(alpha: 0.9), fontSize: 12),
                    ),
                  ],
                  const SizedBox(height: 18),
                  const Center(child: RobotTraderIllustration(size: 210)),
                  const SizedBox(height: 18),
                  Text(
                    'Rendimento (curva)',
                    style: TextStyle(
                      color: AppColors.textMuted.withValues(alpha: 0.95),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  PerformanceLineChart(points: _chartPoints()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
