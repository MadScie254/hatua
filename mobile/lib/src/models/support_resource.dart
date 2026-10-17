class SupportResource {
  const SupportResource({
    required this.id,
    required this.name,
    required this.description,
    required this.kind,
    required this.county,
    required this.phone,
    required this.websiteUrl,
    required this.locationLabel,
    required this.sourceUrl,
  });

  final String id;
  final String name;
  final String description;
  final String kind;
  final String county;
  final String phone;
  final String websiteUrl;
  final String locationLabel;
  final String sourceUrl;

  factory SupportResource.fromJson(Map<String, dynamic> json) => SupportResource(
        id: json['id'].toString(),
        name: json['name']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        kind: json['kind']?.toString() ?? '',
        county: json['county']?.toString() ?? '',
        phone: json['phone']?.toString() ?? '',
        websiteUrl: json['website_url']?.toString() ?? '',
        locationLabel: json['location_label']?.toString() ?? '',
        sourceUrl: json['source_url']?.toString() ?? '',
      );
}
