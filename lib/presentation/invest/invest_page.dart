import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../domain/entities/investment.dart';
import '../../domain/repositories/investment_repository.dart';
import 'invest_notifier.dart';

class InvestPage extends StatefulWidget {
  const InvestPage({super.key});

  @override
  State<InvestPage> createState() => _InvestPageState();
}

class _InvestPageState extends State<InvestPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InvestNotifier>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<InvestNotifier>(
      builder: (context, notifier, _) {
        if (notifier.loading && notifier.investments.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.neonCyan),
          );
        }
        return RefreshIndicator(
          color: AppColors.neonCyan,
          onRefresh: () => notifier.load(),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _buildSummary(notifier)),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => _InvestmentCard(
                      investment: notifier.investments[i],
                      onWithdraw: () => _withdraw(context, notifier, notifier.investments[i]),
                    ),
                    childCount: notifier.investments.length,
                  ),
                ),
              ),
              if (notifier.investments.isEmpty)
                const SliverFillRemaining(
                  child: Center(
                    child: Text(
                      'Nenhum investimento ativo.\nContrate um plano para começar.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummary(InvestNotifier notifier) {
    final totalInvested = notifier.investments
        .where((i) => i.isActive)
        .fold(0.0, (s, i) => s + i.principal);
    final totalInterest = notifier.investments
        .where((i) => i.isActive)
        .fold(0.0, (s, i) => s + i.accruedInterest);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: _SummaryTile(
              label: 'Total Investido',
              value: 'R\$ ${totalInvested.toStringAsFixed(2).replaceAll('.', ',')}',
              color: AppColors.neonCyan,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _SummaryTile(
              label: 'Juros Acumulados',
              value: 'R\$ ${totalInterest.toStringAsFixed(2).replaceAll('.', ',')}',
              color: AppColors.neonGreen,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _withdraw(
      BuildContext context, InvestNotifier notifier, Investment inv) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Resgatar Lucro',
            style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
          'Deseja resgatar R\$ ${inv.accruedInterest.toStringAsFixed(2).replaceAll('.', ',')} de lucro para sua conta?',
          style: const TextStyle(color: AppColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar',
                style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.neonGreen,
              foregroundColor: Colors.black,
            ),
            child: const Text('Resgatar'),
          ),
        ],
      ),
    );

    if (ok == true && context.mounted) {
      final error = await notifier.withdrawInterest(inv.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'Lucro resgatado com sucesso!'),
            backgroundColor: error != null ? Colors.redAccent : AppColors.neonGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }
}

// ── Tile de resumo ─────────────────────────────────────────────────────────────

class _SummaryTile extends StatelessWidget {
  const _SummaryTile(
      {required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3)),
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
                  color: color, fontSize: 16, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

// ── Card de investimento ───────────────────────────────────────────────────────

class _InvestmentCard extends StatelessWidget {
  const _InvestmentCard(
      {required this.investment, required this.onWithdraw});

  final Investment investment;
  final VoidCallback onWithdraw;

  String _fmt(double v) =>
      'R\$ ${v.toStringAsFixed(2).replaceAll('.', ',')}';

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    final isActive = investment.isActive;
    final accentColor =
        isActive ? AppColors.neonCyan : AppColors.textMuted;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accentColor.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
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
            // Valores
            Row(
              children: [
                Expanded(
                  child: _InfoItem(
                      label: 'Valor Investido',
                      value: _fmt(investment.principal)),
                ),
                Expanded(
                  child: _InfoItem(
                    label: 'Juros Acumulados',
                    value: _fmt(investment.accruedInterest),
                    valueColor: AppColors.neonGreen,
                  ),
                ),
              ],
            ),
            if (investment.withdrawnInterest > 0) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _InfoItem(
                      label: 'Juros Resgatados',
                      value: _fmt(investment.withdrawnInterest),
                      valueColor: AppColors.neonCyan,
                    ),
                  ),
                  Expanded(
                    child: _InfoItem(
                      label: 'Total Ganho',
                      value: _fmt(investment.totalInterestEarned),
                      valueColor: AppColors.neonGreen.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 10),
            // Projeção de juros
            LinearProgressIndicator(
              value: investment.projectedTotalInterest > 0
                  ? (investment.accruedInterest /
                          investment.projectedTotalInterest)
                      .clamp(0.0, 1.0)
                  : 0,
              backgroundColor: AppColors.neonGreen.withValues(alpha: 0.15),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.neonGreen),
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 4),
            Text(
              '${_fmt(investment.accruedInterest)} / ${_fmt(investment.projectedTotalInterest)} projetado',
              style: TextStyle(
                  color: AppColors.textMuted.withValues(alpha: 0.8),
                  fontSize: 11),
            ),
            const SizedBox(height: 12),
            const Divider(color: Color(0xFF1E2D45), height: 1),
            const SizedBox(height: 12),
            // Datas
            Row(
              children: [
                Expanded(
                  child: _DateItem(
                    label: 'Contratado',
                    date: _fmtDate(investment.contractedAt),
                    icon: Icons.calendar_today_outlined,
                  ),
                ),
                Expanded(
                  child: _DateItem(
                    label: 'Resgate (D+15)',
                    date: _fmtDate(investment.interestWithdrawalDate),
                    icon: Icons.lock_open_outlined,
                    highlight: investment.interestWithdrawable,
                  ),
                ),
                Expanded(
                  child: _DateItem(
                    label: 'Término (D+35)',
                    date: _fmtDate(investment.maturityDate),
                    icon: Icons.flag_outlined,
                  ),
                ),
              ],
            ),
            // Botão resgatar
            if (investment.interestWithdrawable) ...[
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onWithdraw,
                  icon: const Icon(Icons.savings_outlined, size: 18),
                  label: const Text('Resgatar Lucro'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.neonGreen,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  const _InfoItem(
      {required this.label, required this.value, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

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
        Text(value,
            style: TextStyle(
                color: valueColor ?? AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _DateItem extends StatelessWidget {
  const _DateItem(
      {required this.label,
      required this.date,
      required this.icon,
      this.highlight = false});

  final String label;
  final String date;
  final IconData icon;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final color = highlight ? AppColors.neonGreen : AppColors.textMuted;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 11, color: color),
            const SizedBox(width: 3),
            Text(label,
                style: TextStyle(
                    color: color.withValues(alpha: 0.8), fontSize: 10)),
          ],
        ),
        const SizedBox(height: 2),
        Text(date,
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
