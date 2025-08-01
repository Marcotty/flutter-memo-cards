class FullCard {
  final String theme;
  final String title;
  final String description;

  FullCard({required this.theme, required this.title, required this.description});

  bool get isNotEmpty => title.isNotEmpty && description.isNotEmpty;
}