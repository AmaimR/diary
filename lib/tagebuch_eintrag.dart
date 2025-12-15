class TagebuchEintrag {
  final String id;
  final String titel;
  final String text;
  final DateTime datum;
  final List<String> bildPfade;

  TagebuchEintrag({
    required this.id,
    required this.titel,
    required this.text,
    required this.datum,
    required this.bildPfade,
  });
}