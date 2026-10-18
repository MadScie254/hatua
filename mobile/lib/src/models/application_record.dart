import 'opportunity.dart';

/// Private, user-supplied application progress. Never inferred from opening a link.
/// Serialized only inside the same Android Keystore-encrypted vault as private goals.
enum ApplicationStage { interested, applied, interview, offered, closed }

class ApplicationRecord {
  const ApplicationRecord({
    required this.opportunityId,
    required this.title,
    required this.organisation,
    required this.stage,
    required this.updatedAt,
  });

  final String opportunityId;
  final String title;
  final String organisation;
  final ApplicationStage stage;
  final DateTime updatedAt;

  factory ApplicationRecord.fromOpportunity(Opportunity op, DateTime now) =>
      ApplicationRecord(
        opportunityId: op.id,
        title: op.title,
        organisation: op.organisation,
        stage: ApplicationStage.interested,
        updatedAt: now.toUtc(),
      );

  ApplicationRecord copyWith({ApplicationStage? stage, DateTime? updatedAt}) =>
      ApplicationRecord(
        opportunityId: opportunityId,
        title: title,
        organisation: organisation,
        stage: stage ?? this.stage,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  Map<String, dynamic> toJson() => {
        'opportunity_id': opportunityId,
        'title': title,
        'organisation': organisation,
        'stage': stage.name,
        'updated_at': updatedAt.toIso8601String(),
      };

  factory ApplicationRecord.fromJson(Map<String, dynamic> json) {
    final code = json['stage']?.toString();
    final stage = ApplicationStage.values.where((s) => s.name == code).firstOrNull;
    final id = json['opportunity_id']?.toString() ?? '';
    final date = DateTime.tryParse(json['updated_at']?.toString() ?? '');
    if (stage == null || id.isEmpty || date == null) {
      throw const FormatException('Invalid encrypted application record');
    }
    return ApplicationRecord(
      opportunityId: id,
      title: json['title']?.toString() ?? '',
      organisation: json['organisation']?.toString() ?? '',
      stage: stage,
      updatedAt: date,
    );
  }
}
