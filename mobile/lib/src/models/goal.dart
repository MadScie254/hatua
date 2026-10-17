class Goal {
  const Goal({required this.id, required this.title, required this.isDone});
  final String id;
  final String title;
  final bool isDone;

  Goal copyWith({bool? isDone}) => Goal(
        id: id,
        title: title,
        isDone: isDone ?? this.isDone,
      );

  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'is_done': isDone};

  factory Goal.fromJson(Map<String, dynamic> json) => Goal(
        id: json['id'].toString(),
        title: json['title']?.toString() ?? '',
        isDone: json['is_done'] == true,
      );
}
