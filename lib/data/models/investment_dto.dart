import '../../domain/entities/investment.dart';

class InvestmentDto {
  const InvestmentDto({
    required this.id,
    required this.planId,
    required this.planName,
    required this.principal,
    required this.accruedInterest,
    required this.withdrawnInterest,
    required this.projectedTotalInterest,
    required this.status,
    required this.contractedAt,
    required this.interestWithdrawalDate,
    required this.maturityDate,
    required this.interestWithdrawable,
  });

  factory InvestmentDto.fromJson(Map<String, dynamic> json) => InvestmentDto(
        id: (json['id'] as num).toInt(),
        planId: json['planId'] as String,
        planName: json['planName'] as String,
        principal: _d(json['principal']),
        accruedInterest: _d(json['accruedInterest']),
        withdrawnInterest: _d(json['withdrawnInterest']),
        projectedTotalInterest: _d(json['projectedTotalInterest']),
        status: json['status'] as String,
        contractedAt: _parseDate(json['contractedAt']),
        interestWithdrawalDate: _parseDate(json['interestWithdrawalDate']),
        maturityDate: _parseDate(json['maturityDate']),
        interestWithdrawable: json['interestWithdrawable'] as bool? ?? false,
      );

  static double _d(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

  static DateTime _parseDate(dynamic v) {
    if (v == null) return DateTime.now();
    final s = v.toString();
    // LocalDate comes as "2026-04-21", LocalDateTime as "2026-04-21T17:15:30"
    if (s.length == 10) return DateTime.parse('${s}T00:00:00');
    return DateTime.parse(s);
  }

  final int id;
  final String planId;
  final String planName;
  final double principal;
  final double accruedInterest;
  final double withdrawnInterest;
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
        withdrawnInterest: withdrawnInterest,
        projectedTotalInterest: projectedTotalInterest,
        status: status,
        contractedAt: contractedAt,
        interestWithdrawalDate: interestWithdrawalDate,
        maturityDate: maturityDate,
        interestWithdrawable: interestWithdrawable,
      );
}
