import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../domain/entities/investment.dart';
import '../../domain/repositories/investment_repository.dart';

class GanhosPage extends StatefulWidget {
  const GanhosPage({super.key});

  @override
  State<GanhosPage> createState() => GanhosPageState();
}

class GanhosPageState extends State<GanhosPage> {
  void reload() => _load();
  List<Investment> _investments = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() { _loading = true; _error = null; });
    try {
      final all = await context.read<InvestmentRepository>().listAll();
      if (mounted) setState(() => _investments = all);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _fmt(double v) =>
      'R\$ ${v.toStringAsFixed(2).replaceAll('.', ',')}';

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.neonCyan));
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.redAccent, size: 40),
              const SizedBox(height: 12),
              Text(_error!, textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textMuted)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _load,
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.neonCyan,
                    foregroundColor: AppColors.background),
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    final totalInterest = _investments.fold(
        0.0, (s, i) => s + (i.isMatured ? i.projectedTotalInterest : i.accruedInterest));
    final totalPrincipal = _investments.fold(0.0, (s, i) => s + i.principal);

    return RefreshIndicator(
      color: AppColors.neonCyan,
      onRefresh: _load,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryCard(totalPrincipal, totalInterest),
                  const SizedBox(height: 20),
                  Text(
                    'Meus Contratos (${_investments.length})',
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
          if (_investments.isEmpty)
            const SliverFillRemaining(
              child: Center(
                child: Text(
                  'Nenhum contrato encontrado.\nInvista em um plano para começar.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textMuted),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) => _ContractCard(investment: _investments[i]),
                  childCount: _investments.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(double principal, double interest) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D1B35), Color(0xFF091428)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.neonGreen.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Resumo de Ganhos',
                  style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 15)),
              Icon(Icons.bar_chart_rounded,
                  color: AppColors.neonGreen.withValues(alpha: 0.8)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _SummaryTile(
                  label: 'Total Aportado',
                  value: _fmt(principal),
                  color: AppColors.neonCyan,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryTile(
                  label: 'Total em Juros',
                  value: _fmt(interest),
                  color: AppColors.neonGreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Summary tile ───────────────────────────────────────────────────────────────

class _SummaryTile extends StatelessWidget {
  const _SummaryTile(
      {required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  color: AppColors.textMuted.withValues(alpha: 0.9),
                  fontSize: 11)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  color: color, fontSize: 15, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

// ── Contract card ──────────────────────────────────────────────────────────────

class _ContractCard extends StatelessWidget {
  const _ContractCard({required this.investment});

  final Investment investment;

  String _fmt(double v) =>
      'R\$ ${v.toStringAsFixed(2).replaceAll('.', ',')}';

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    final isActive = investment.isActive;
    final accentColor = isActive ? AppColors.neonCyan : AppColors.textMuted;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accentColor.withValues(alpha: 0.25)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header — plano + status
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Plano ${investment.planName}',
                    style: TextStyle(
                        color: accentColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 13),
                  ),
                ),
                const Spacer(),
                _StatusBadge(status: investment.status),
              ],
            ),
            const SizedBox(height: 14),

            // Valores — aplicação e rendimento
            Row(
              children: [
                Expanded(
                  child: _ValueItem(
                    label: 'Valor Aplicado',
                    value: _fmt(investment.principal),
                    color: AppColors.textPrimary,
                  ),
                ),
                Expanded(
                  child: _ValueItem(
                    label: 'Rendimento Atual',
                    value: _fmt(investment.accruedInterest),
                    color: AppColors.neonGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _ValueItem(
                    label: 'Juros Resgatados',
                    value: _fmt(investment.withdrawnInterest),
                    color: AppColors.neonCyan,
                  ),
                ),
                Expanded(
                  child: _ValueItem(
                    label: 'Total Ganho',
                    value: _fmt(investment.totalInterestEarned),
                    color: AppColors.neonGreen.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),

            // Barra de progresso do rendimento
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: investment.projectedTotalInterest > 0
                  ? (investment.accruedInterest /
                          investment.projectedTotalInterest)
                      .clamp(0.0, 1.0)
                  : 0,
              backgroundColor: AppColors.neonGreen.withValues(alpha: 0.12),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.neonGreen),
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 4),
            Text(
              '${_fmt(investment.accruedInterest)} de ${_fmt(investment.projectedTotalInterest)} projetado',
              style: TextStyle(
                  color: AppColors.textMuted.withValues(alpha: 0.7),
                  fontSize: 11),
            ),

            const SizedBox(height: 14),
            const Divider(color: Color(0xFF1E2D45), height: 1),
            const SizedBox(height: 14),

            // Datas
            _DateRow(
              icon: Icons.calendar_today_outlined,
              label: 'Data de início',
              value: _fmtDate(investment.contractedAt),
            ),
            const SizedBox(height: 8),
            _DateRow(
              icon: Icons.lock_open_outlined,
              label: 'Saque de juros disponível',
              value: _fmtDate(investment.interestWithdrawalDate),
              highlight: !DateTime.now()
                  .isBefore(investment.interestWithdrawalDate),
              highlightLabel: isActive &&
                      !DateTime.now()
                          .isBefore(investment.interestWithdrawalDate)
                  ? 'Disponível'
                  : null,
            ),
            const SizedBox(height: 8),
            _DateRow(
              icon: Icons.flag_outlined,
              label: 'Data de término',
              value: _fmtDate(investment.maturityDate),
            ),
          ],
        ),
      ),
    );
  }
}

class _ValueItem extends StatelessWidget {
  const _ValueItem(
      {required this.label,
      required this.value,
      required this.color,
      this.suffix});

  final String label;
  final String value;
  final Color color;
  final String? suffix;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                color: AppColors.textMuted.withValues(alpha: 0.8),
                fontSize: 11)),
        const SizedBox(height: 2),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: value,
                style: TextStyle(
                    color: color,
                    fontSize: 15,
                    fontWeight: FontWeight.w700),
              ),
              if (suffix != null)
                TextSpan(
                  text: suffix,
                  style: TextStyle(
                      color: color.withValues(alpha: 0.6), fontSize: 11),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DateRow extends StatelessWidget {
  const _DateRow({
    required this.icon,
    required this.label,
    required this.value,
    this.highlight = false,
    this.highlightLabel,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool highlight;
  final String? highlightLabel;

  @override
  Widget build(BuildContext context) {
    final color = highlight ? AppColors.neonGreen : AppColors.textMuted;
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Text(label,
            style: TextStyle(
                color: AppColors.textMuted.withValues(alpha: 0.8),
                fontSize: 12)),
        const Spacer(),
        if (highlightLabel != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.neonGreen.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(highlightLabel!,
                style: const TextStyle(
                    color: AppColors.neonGreen,
                    fontSize: 10,
                    fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 6),
        ],
        Text(value,
            style: TextStyle(
                color: highlight ? AppColors.neonGreen : AppColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      'ACTIVE' => ('Ativo', AppColors.neonGreen),
      'MATURED' => ('Encerrado', AppColors.textMuted),
      _ => ('Resgatado', AppColors.textMuted),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }
}
