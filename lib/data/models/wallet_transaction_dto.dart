class WalletTransactionDto {
  const WalletTransactionDto({
    required this.id,
    required this.type,
    required this.amount,
    required this.balanceBefore,
    required this.balanceAfter,
    required this.createdAt,
    this.metadataJson,
  });

  factory WalletTransactionDto.fromJson(Map<String, dynamic> json) =>
      WalletTransactionDto(
        id: (json['id'] as num).toInt(),
        type: json['type'] as String,
        amount: _d(json['amount']),
        balanceBefore: _d(json['balanceBefore']),
        balanceAfter: _d(json['balanceAfter']),
        createdAt: DateTime.parse(json['createdAt'] as String),
        metadataJson: json['metadataJson'] as String?,
      );

  static double _d(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

  final int id;
  final String type;
  final double amount;
  final double balanceBefore;
  final double balanceAfter;
  final DateTime createdAt;
  final String? metadataJson;

  bool get isCredit => const {
        'DEPOSIT',
        'PIX_CREDIT',
        'INTEREST_WITHDRAWAL',
        'PLAN_MATURITY',
      }.contains(type);

  String get typeLabel => switch (type) {
        'DEPOSIT' => 'Depósito',
        'WITHDRAW' => 'Saque',
        'PIX_CREDIT' => 'PIX Recebido',
        'YIELD' => 'Rendimento',
        'PLAN_PURCHASE' => 'Investimento',
        'INTEREST_WITHDRAWAL' => 'Resgate de Juros',
        'PLAN_MATURITY' => 'Encerramento de Plano',
        _ => type,
      };
}
