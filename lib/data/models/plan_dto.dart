import '../../domain/entities/plan.dart';

class PlanDto {
  const PlanDto({
    required this.id,
    required this.name,
    required this.amount,
    required this.description,
  });

  factory PlanDto.fromJson(Map<String, dynamic> json) => PlanDto(
        id: json['id'] as String,
        name: json['name'] as String,
        amount: (json['amount'] as num).toDouble(),
        description: json['description'] as String? ?? '',
      );

  final String id;
  final String name;
  final double amount;
  final String description;

  Plan toEntity() => Plan(
        id: id,
        name: name,
        amount: amount,
        description: description,
      );
}
