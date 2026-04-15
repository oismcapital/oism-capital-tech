import '../../domain/entities/pix_deposit.dart';

class GeneratePixResponseDto {
  const GeneratePixResponseDto({
    required this.transactionId,
    required this.planId,
    required this.planName,
    required this.amount,
    required this.copyAndPaste,
    required this.qrCodeBase64,
    required this.status,
    required this.expiresAt,
  });

  factory GeneratePixResponseDto.fromJson(Map<String, dynamic> json) =>
      GeneratePixResponseDto(
        transactionId: json['transactionId'] as String,
        planId: json['planId'] as String,
        planName: json['planName'] as String,
        amount: (json['amount'] as num).toDouble(),
        copyAndPaste: json['copyAndPaste'] as String,
        qrCodeBase64: json['qrCodeBase64'] as String,
        status: json['status'] as String,
        expiresAt: json['expiresAt'] as String,
      );

  final String transactionId;
  final String planId;
  final String planName;
  final double amount;
  final String copyAndPaste;
  final String qrCodeBase64;
  final String status;
  final String expiresAt;

  PixDeposit toEntity() => PixDeposit(
        transactionId: transactionId,
        planId: planId,
        planName: planName,
        amount: amount,
        copyAndPaste: copyAndPaste,
        qrCodeBase64: qrCodeBase64,
        status: status,
        expiresAt: expiresAt,
      );
}
