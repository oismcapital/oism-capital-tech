import '../../domain/entities/investment.dart';

class InvestmentDto {
  const InvestmentDto({
    required this.id,
    required this.planId,
    required this.planName,
    required this.principal,
    required this.accruedInterest,
    required this.projectedTotalInterest,
    required this.status,
    required this.contractedAt,
    required this.interestWithdrawalDate,
    required this.maturityDate,
    required this.interestWithdrawable,
  });

  factory InvestmentDto.fromJson(Map<String, dynamic> json) => InvestmentDto(
        id: json['id'] as int,
        planId: json['planId'] as String,
        planName: json['planName'] as String,
        principal: _d(json['principal']),
        accruedInterest: _d(json['accruedInterest']),
        projectedTotalInterest: _d(json['projectedTotalInterest']),
        status: json['status'] as String,
        contractedAt: DateTime.parse(json['contractedAt'] as String),
        interestWithdrawalDate: DateTime.parse(json['interestWithdrawalDate'] as String),
        maturityDate: DateTime.parse(json['maturityDate'] as String),
        interestWithdrawable: json['interestWithdrawable'] as bool? ?? false,
      );

  static double _d(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

  final int id;
  final String planId;
  final String planName;
  final double principal;
  final double accruedInterest;
  final double projectedTotalInterest;
  final String status;
  final DateTime contractedAt;
  final DateTime interestWithdrawalDate;
  final DateTime maturityDate;
  final bool interestWithdrawable;

  Investment toEntity() => Investment(
        id: id,
        planId: planId,
        planName: planName,
        principal: principal,
        accruedInterest: accruedInterest,
        projectedTotalInterest: projectedTotalInterest,
        status: status,
        contractedAt: contractedAt,
        interestWithdrawalDate: interestWithdrawalDate,
        maturityDate: maturityDate,
        interestWithdrawable: interestWithdrawable,
      );
}
