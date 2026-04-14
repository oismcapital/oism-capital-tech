import 'dart:math' as math;
import 'package:flutter/material.dart';
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

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  bool _hideBalance = false;
  FinanceSummary? _summary;
  bool _loading = true;
  late final AnimationController _robotAnim;

  @override
  void initState() {
    super.initState();
    _robotAnim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _robotAnim.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() => _loading = true);
    try {
      final s = await context.read<FinanceRepository>().getSummary();
      if (!mounted) return;
      setState(() {
        _summary = s;
        _hideBalance = s.valorEscondido;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _fmt(double v) =>
      'R\$${v.toStringAsFixed(2).replaceAll('.', ',').replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+,)'), (m) => '${m[1]}.')}';

  String _fmtPct(double v) {
    final sign = v >= 0 ? '+' : '';
    return '$sign${v.toStringAsFixed(2).replaceAll('.', ',')}%';
  }

  double _pct() {
    final s = _summary;
    if (s == null || s.investedBalance == 0) return 0;
    return (s.dailyProfit / s.investedBalance) * 100;
  }

  List<double> _points() {
    final s = _summary;
    if (s != null && s.performancePoints.length > 1) return s.performancePoints;
    return List.generate(20, (i) => 80 + math.pow(i * 0.6, 1.6).toDouble());
  }

  @override
  Widget build(BuildContext context) {
    final s = _summary;
    return RefreshIndicator(
      color: AppColors.neonCyan,
      onRefresh: _load,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _buildContent(s)),
        ],
      ),
    );
  }

  Widget _buildContent(FinanceSummary? s) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildMainCard(s),
          const SizedBox(height: 16),
          _buildRobotStatus(),
          const SizedBox(height: 14),
          _buildButtons(),
          const SizedBox(height: 20),
          _buildChartCard(),
        ],
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.neonCyan, width: 2),
            color: AppColors.surface,
          ),
          child: const Icon(Icons.currency_bitcoin,
              color: AppColors.neonCyan, size: 18),
        ),
        const SizedBox(width: 10),
        RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'OISM ',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
              TextSpan(
                text: 'Capital Tech',
                style: TextStyle(
                  color: AppColors.neonCyan,
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.notifications_outlined,
              color: AppColors.neonCyan, size: 26),
        ),
      ],
    );
  }

  // ── Main card (saldo + robô) ─────────────────────────────────────────────────
  Widget _buildMainCard(FinanceSummary? s) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            const Color(0xFF0D1B35),
            const Color(0xFF091428),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: AppColors.neonCyan.withValues(alpha: 0.3),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.neonCyan.withValues(alpha: 0.12),
            blurRadius: 24,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Glow de fundo
          Positioned(
            right: -20,
            bottom: -20,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.neonCyan.withValues(alpha: 0.06),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 12, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Lado esquerdo — saldo
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Saldo Investido',
                            style: TextStyle(
                              color: AppColors.textMuted.withValues(alpha: 0.9),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Valor + botão olho
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.neonCyan.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.neonCyan.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_loading)
                              const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.neonCyan,
                                ),
                              )
                            else
                              Text(
                                s == null
                                    ? '—'
                                    : _hideBalance
                                        ? '••••••'
                                        : _fmt(s.investedBalance),
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                final v = !_hideBalance;
                                setState(() => _hideBalance = v);
                                context
                                    .read<FinanceService>()
                                    .updatePreferences(valorEscondido: v)
                                    .ignore();
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: AppColors.neonCyan.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Icon(
                                  _hideBalance
                                      ? Icons.visibility_off_rounded
                                      : Icons.visibility_rounded,
                                  color: AppColors.neonCyan,
                                  size: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Value Hidden label
                      Row(
                        children: [
                          Icon(
                            _hideBalance
                                ? Icons.visibility_off_outlined
                                : Icons.trending_up_rounded,
                            color: AppColors.neonGreen,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _hideBalance
                                ? 'Value Hidden'
                                : (s == null
                                    ? '—'
                                    : 'Lucro do dia ${_fmtPct(_pct())}'),
                            style: TextStyle(
                              color: _hideBalance
                                  ? AppColors.textMuted
                                  : AppColors.neonGreen,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              shadows: _hideBalance
                                  ? []
                                  : [
                                      Shadow(
                                        color: AppColors.neonGreen
                                            .withValues(alpha: 0.6),
                                        blurRadius: 8,
                                      ),
                                    ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Lado direito — robô
                SizedBox(
                  width: 130,
                  height: 120,
                  child: const RobotTraderIllustration(size: 110),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Robô em operação ────────────────────────────────────────────────────────
  Widget _buildRobotStatus() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          RotationTransition(
            turns: _robotAnim,
            child: const Icon(
              Icons.sync_rounded,
              color: AppColors.neonCyan,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Robô em operação...',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              Text(
                'Gerando rendimento automático',
                style: TextStyle(
                  color: AppColors.textMuted.withValues(alpha: 0.8),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Botões ───────────────────────────────────────────────────────────────────
  Widget _buildButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: widget.onDepositar,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.neonCyan,
              foregroundColor: AppColors.background,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
              shadowColor: AppColors.neonCyan.withValues(alpha: 0.4),
            ),
            child: const Text(
              'Depositar',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textMuted,
              side: BorderSide(
                  color: AppColors.textMuted.withValues(alpha: 0.35)),
              backgroundColor: AppColors.surface,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: const Icon(Icons.lock_rounded, size: 16),
            label: const Text(
              'Sacar',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  // ── Gráfico ──────────────────────────────────────────────────────────────────
  Widget _buildChartCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1B35),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: AppColors.neonCyan.withValues(alpha: 0.06),
            blurRadius: 16,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rendimentos',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          PerformanceLineChart(
            points: _points(),
            bottomAxisLabels: const [
              'Mês 1',
              'Mês 2',
              'Mês 3',
              'Mês 4',
              'Mês 5',
            ],
          ),
        ],
      ),
    );
  }
}
