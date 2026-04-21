class Investment {
  const Investment({
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

  bool get isActive => status == 'ACTIVE';
  bool get isMatured => status == 'MATURED';
}
