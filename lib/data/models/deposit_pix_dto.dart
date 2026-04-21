class DepositPixDto {
  const DepositPixDto({
    required this.transactionId,
    required this.amount,
    required this.copyAndPaste,
    required this.qrCodeBase64,
    required this.status,
    required this.expiresAt,
  });

  factory DepositPixDto.fromJson(Map<String, dynamic> json) => DepositPixDto(
        transactionId: json['transactionId'] as String,
        amount: _d(json['amount']),
        copyAndPaste: json['copyAndPaste'] as String,
        qrCodeBase64: json['qrCodeBase64'] as String,
        status: json['status'] as String,
        expiresAt: json['expiresAt'] as String,
      );

  static double _d(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

  final String transactionId;
  final double amount;
  final String copyAndPaste;
  final String qrCodeBase64;
  final String status;
  final String expiresAt;
}
