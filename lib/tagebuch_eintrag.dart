class TextFormatData {
  String text;
  bool bold;
  bool italic;
  bool underline;
  String fontFamily;
  int colorValue;

  TextFormatData({
    this.text = '',
    this.bold = false,
    this.italic = false,
    this.underline = false,
    this.fontFamily = 'Roboto',
    this.colorValue = 0xFF000000,
  });

  Map<String, dynamic> toJson() => {
        'text': text,
        'bold': bold,
        'italic': italic,
        'underline': underline,
        'fontFamily': fontFamily,
        'colorValue': colorValue,
      };

  factory TextFormatData.fromJson(Map<String, dynamic> json) {
    final fontFamily = json['fontFamily'] ?? 'Roboto';
    final validFonts = ['Roboto', 'Pacifico', 'Dancing Script', 'Courier Prime', 'Lora'];
    
    return TextFormatData(
      text: json['text'] ?? '',
      bold: json['bold'] ?? false,
      italic: json['italic'] ?? false,
      underline: json['underline'] ?? false,
      fontFamily: validFonts.contains(fontFamily) ? fontFamily : 'Roboto',
      colorValue: json['colorValue'] ?? 0xFF000000,
    );
  }
}

class TagebuchEintrag {
  final String id;
  final TextFormatData titelFormat;
  final String text;
  final DateTime datum;
  final List<String> bildPfade;
  final String emoji;
  final bool textBold;
  final bool textItalic;
  final bool textUnderline;
  final String textFontFamily;
  final int textColorValue;

  TagebuchEintrag({
    required this.id,
    required this.titelFormat,
    required this.text,
    required this.datum,
    required this.bildPfade,
    this.emoji = '📝',
    this.textBold = false,
    this.textItalic = false,
    this.textUnderline = false,
    this.textFontFamily = 'Roboto',
    this.textColorValue = 0xFF000000,
  });

  factory TagebuchEintrag.fromJson(Map<String, dynamic> json) {
    final validFonts = ['Roboto', 'Pacifico', 'Dancing Script', 'Courier Prime', 'Lora'];
    final textFont = json['textFontFamily'] ?? 'Roboto';
    
    return TagebuchEintrag(
      id: json['id'],
      titelFormat: json['titelFormat'] != null
          ? TextFormatData.fromJson(json['titelFormat'])
          : TextFormatData(text: json['titel'] ?? ''),
      text: json['text'],
      datum: DateTime.parse(json['datum']),
      bildPfade: List<String>.from(json['bildPfade'] ?? []),
      emoji: json['emoji'] ?? '📝',
      textBold: json['textBold'] ?? false,
      textItalic: json['textItalic'] ?? false,
      textUnderline: json['textUnderline'] ?? false,
      textFontFamily: validFonts.contains(textFont) ? textFont : 'Roboto',
      textColorValue: json['textColorValue'] ?? 0xFF000000,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titelFormat': titelFormat.toJson(),
      'text': text,
      'datum': datum.toIso8601String(),
      'bildPfade': bildPfade,
      'emoji': emoji,
      'textBold': textBold,
      'textItalic': textItalic,
      'textUnderline': textUnderline,
      'textFontFamily': textFontFamily,
      'textColorValue': textColorValue,
    };
  }

  TagebuchEintrag copyWith({
    String? id,
    TextFormatData? titelFormat,
    String? text,
    DateTime? datum,
    List<String>? bildPfade,
    String? emoji,
    bool? textBold,
    bool? textItalic,
    bool? textUnderline,
    String? textFontFamily,
    int? textColorValue,
  }) {
    return TagebuchEintrag(
      id: id ?? this.id,
      titelFormat: titelFormat ?? this.titelFormat,
      text: text ?? this.text,
      datum: datum ?? this.datum,
      bildPfade: bildPfade ?? this.bildPfade,
      emoji: emoji ?? this.emoji,
      textBold: textBold ?? this.textBold,
      textItalic: textItalic ?? this.textItalic,
      textUnderline: textUnderline ?? this.textUnderline,
      textFontFamily: textFontFamily ?? this.textFontFamily,
      textColorValue: textColorValue ?? this.textColorValue,
    );
  }
}
