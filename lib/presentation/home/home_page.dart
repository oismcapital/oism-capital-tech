import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../data/services/finance_service.dart';
import '../../domain/entities/finance_summary.dart';
import '../../domain/repositories/finance_repository.dart';
import '../widgets/performance_line_chart.dart';
import '../widgets/robot_trader_illustration.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.onDepositar});

  final VoidCallback? onDepositar;

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
        _hideBalance = s.valorEscondido;
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

  String _formatPercent(double v) {
    final sign = v >= 0 ? '+' : '';
    return '$sign${v.toStringAsFixed(2).replaceFirst('.', ',')}%';
  }

  double _dailyProfitPct(FinanceSummary s) {
    if (s.investedBalance == 0) return 0;
    return (s.dailyProfit / s.investedBalance) * 100;
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
                    'Oism Capital Tech',
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
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.notifications_none_rounded,
                          color: AppColors.neonCyan,
                        ),
                        tooltip: 'Notificações',
                      ),
                      const Spacer(),
                      const Text(
                        '13:58',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.neonCyan.withValues(alpha: 0.14),
                          blurRadius: 26,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.surface.withValues(alpha: 0.48),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.neonCyan.withValues(alpha: 0.28),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Saldo Investido',
                                        style: TextStyle(
                                          color: AppColors.textMuted.withValues(alpha: 0.95),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        final newVal = !_hideBalance;
                                        setState(() => _hideBalance = newVal);
                                        context.read<FinanceService>().updatePreferences(valorEscondido: newVal).ignore();
                                      },
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
                                                : _formatPercent(_dailyProfitPct(summary)),
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
                  const SizedBox(height: 8),
                  const Text(
                    'Robô em operação... Gerando rendimento automático',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.neonCyan,
                            foregroundColor: AppColors.background,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () {
                            widget.onDepositar?.call();
                          },
                          child: const Text(
                            'Depositar',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textMuted,
                            side: BorderSide(color: AppColors.textMuted.withValues(alpha: 0.4)),
                            backgroundColor: AppColors.surface.withValues(alpha: 0.55),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () {},
                          icon: const Icon(Icons.lock_outline_rounded, size: 18),
                          label: const Text(
                            'Sacar',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Gráfico de Rendimentos',
                    style: TextStyle(
                      color: AppColors.textMuted.withValues(alpha: 0.95),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  PerformanceLineChart(
                    points: _chartPoints(),
                    leftAxisLabel: 'R\$100',
                    bottomAxisLabels: const ['Mês 1', 'Mês 2', 'Mês 3'],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
