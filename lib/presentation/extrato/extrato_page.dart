import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/wallet_transaction_dto.dart';
import '../../data/services/statement_service.dart';

class ExtratoPage extends StatefulWidget {
  const ExtratoPage({super.key});

  @override
  State<ExtratoPage> createState() => ExtratoPageState();
}

class ExtratoPageState extends State<ExtratoPage> {
  List<WalletTransactionDto> _transactions = [];
  bool _loading = false;
  String? _error;

  DateTime _from = DateTime.now().subtract(const Duration(days: 30));
  DateTime _to = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void reload() => _load();

  Future<void> _load() async {
    if (!mounted) return;
    setState(() { _loading = true; _error = null; });
    try {
      final result = await context.read<StatementService>().getStatement(
            from: _from,
            to: _to,
          );
      if (mounted) setState(() => _transactions = result);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isFrom ? _from : _to,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.neonCyan,
            onPrimary: AppColors.background,
            surface: AppColors.surface,
            onSurface: AppColors.textPrimary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked == null || !mounted) return;
    setState(() {
      if (isFrom) {
        _from = picked;
        if (_from.isAfter(_to)) _to = _from;
      } else {
        _to = picked;
        if (_to.isBefore(_from)) _from = _to;
      }
    });
    _load();
  }

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  String _fmt(double v) =>
      'R\$ ${v.toStringAsFixed(2).replaceAll('.', ',')}';

  double get _totalCredits => _transactions
      .where((t) => t.isCredit)
      .fold(0.0, (s, t) => s + t.amount);

  double get _totalDebits => _transactions
      .where((t) => !t.isCredit)
      .fold(0.0, (s, t) => s + t.amount);

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.neonCyan,
      onRefresh: _load,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _buildHeader()),
          if (_loading)
            const SliverFillRemaining(
              child: Center(
                  child: CircularProgressIndicator(color: AppColors.neonCyan)),
            )
          else if (_error != null)
            SliverFillRemaining(child: _buildError())
          else if (_transactions.isEmpty)
            const SliverFillRemaining(
              child: Center(
                child: Text(
                  'Nenhuma transação encontrada\nneste período.',
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
                  (ctx, i) => _TransactionItem(tx: _transactions[i]),
                  childCount: _transactions.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date pickers
          Row(
            children: [
              Expanded(child: _DateButton(
                label: 'De',
                date: _fmtDate(_from),
                onTap: () => _pickDate(isFrom: true),
              )),
              const SizedBox(width: 12),
              Expanded(child: _DateButton(
                label: 'Até',
                date: _fmtDate(_to),
                onTap: () => _pickDate(isFrom: false),
              )),
            ],
          ),
          const SizedBox(height: 14),
          // Summary
          if (!_loading && _transactions.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: AppColors.neonCyan.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _SummaryItem(
                      label: 'Entradas',
                      value: _fmt(_totalCredits),
                      color: AppColors.neonGreen,
                      icon: Icons.arrow_downward_rounded,
                    ),
                  ),
                  Container(
                      width: 1,
                      height: 36,
                      color: AppColors.neonCyan.withValues(alpha: 0.15)),
                  Expanded(
                    child: _SummaryItem(
                      label: 'Saídas',
                      value: _fmt(_totalDebits),
                      color: Colors.redAccent,
                      icon: Icons.arrow_upward_rounded,
                    ),
                  ),
                  Container(
                      width: 1,
                      height: 36,
                      color: AppColors.neonCyan.withValues(alpha: 0.15)),
                  Expanded(
                    child: _SummaryItem(
                      label: 'Transações',
                      value: '${_transactions.length}',
                      color: AppColors.neonCyan,
                      icon: Icons.receipt_long_outlined,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 40),
            const SizedBox(height: 12),
            Text(_error!,
                textAlign: TextAlign.center,
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
}

// ── Date button ────────────────────────────────────────────────────────────────

class _DateButton extends StatelessWidget {
  const _DateButton(
      {required this.label, required this.date, required this.onTap});

  final String label;
  final String date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: AppColors.neonCyan.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined,
                color: AppColors.neonCyan, size: 16),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        color: AppColors.textMuted.withValues(alpha: 0.7),
                        fontSize: 10)),
                Text(date,
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Summary item ───────────────────────────────────────────────────────────────

class _SummaryItem extends StatelessWidget {
  const _SummaryItem(
      {required this.label,
      required this.value,
      required this.color,
      required this.icon});

  final String label;
  final String value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                color: color, fontSize: 13, fontWeight: FontWeight.w800)),
        Text(label,
            style: TextStyle(
                color: AppColors.textMuted.withValues(alpha: 0.8),
                fontSize: 10)),
      ],
    );
  }
}

// ── Transaction item ───────────────────────────────────────────────────────────

class _TransactionItem extends StatelessWidget {
  const _TransactionItem({required this.tx});

  final WalletTransactionDto tx;

  String _fmt(double v) =>
      'R\$ ${v.toStringAsFixed(2).replaceAll('.', ',')}';

  String _fmtDateTime(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final isCredit = tx.isCredit;
    final color = isCredit ? AppColors.neonGreen : Colors.redAccent;
    final sign = isCredit ? '+' : '-';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isCredit
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              color: color,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx.typeLabel,
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13)),
                const SizedBox(height: 2),
                Text(_fmtDateTime(tx.createdAt),
                    style: TextStyle(
                        color: AppColors.textMuted.withValues(alpha: 0.7),
                        fontSize: 11)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$sign${_fmt(tx.amount)}',
                style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w800,
                    fontSize: 14),
              ),
              const SizedBox(height: 2),
              Text(
                'Saldo: ${_fmt(tx.balanceAfter)}',
                style: TextStyle(
                    color: AppColors.textMuted.withValues(alpha: 0.7),
                    fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
