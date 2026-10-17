class Opportunity {
  const Opportunity({
    required this.id,
    required this.title,
    required this.organisation,
    required this.summary,
    required this.category,
    required this.county,
    required this.eligibility,
    required this.costLabel,
    required this.applicationUrl,
    required this.sourceUrl,
    required this.deadline,
  });

  final String id;
  final String title;
  final String organisation;
  final String summary;
  final String category;
  final String county;
  final String eligibility;
  final String costLabel;
  final String applicationUrl;
  final String sourceUrl;
  final DateTime? deadline;

  factory Opportunity.fromJson(Map<String, dynamic> json) {
    final date = json['deadline']?.toString();
    return Opportunity(
      id: json['id'].toString(),
      title: json['title']?.toString() ?? '',
      organisation: json['organisation']?.toString() ?? '',
      summary: json['summary']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      county: json['county']?.toString() ?? '',
      eligibility: json['eligibility']?.toString() ?? '',
      costLabel: json['cost_label']?.toString() ?? '',
      applicationUrl: json['application_url']?.toString() ?? '',
      sourceUrl: json['source_url']?.toString() ?? '',
      deadline: date == null || date.isEmpty ? null : DateTime.tryParse(date),
    );
  }
}
