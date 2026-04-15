class PixDeposit {
  const PixDeposit({
    required this.transactionId,
    required this.planId,
    required this.planName,
    required this.amount,
    required this.copyAndPaste,
    required this.qrCodeBase64,
    required this.status,
    required this.expiresAt,
  });

  final String transactionId;
  final String planId;
  final String planName;
  final double amount;
  final String copyAndPaste;
  final String qrCodeBase64;
  final String status;
  final String expiresAt;
}
