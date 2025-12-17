import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import '../tagebuch_eintrag.dart';
import '../providers/tagebuch_provider.dart';

class EintragErstellenScreen extends StatefulWidget {
  final TagebuchEintrag? eintrag;

  const EintragErstellenScreen({super.key, this.eintrag});

  @override
  State<EintragErstellenScreen> createState() => _EintragErstellenScreenState();
}

class _EintragErstellenScreenState extends State<EintragErstellenScreen> {
  final _titelController = TextEditingController();
  final _textController = TextEditingController();
  final List<String> _bildPfade = [];
  String _selectedEmoji = '😊';
  bool _showEmojiPicker = false;
  
  bool _titelBold = false;
  bool _titelItalic = false;
  bool _titelUnderline = false;
  String _titelFontFamily = 'Roboto';
  Color _titelColor = Colors.black;
  
  bool _textBold = false;
  bool _textItalic = false;
  bool _textUnderline = false;
  String _textFontFamily = 'Roboto';
  Color _textColor = Colors.black;

  static const List<Color> colors = [
    Colors.black, Colors.blue, Colors.red, Colors.green, Colors.purple,
    Colors.orange, Colors.pink, Colors.teal, Colors.brown, Colors.indigo,
  ];

  static const List<String> fonts = [
    'Roboto',
    'Pacifico',
    'Dancing Script',
    'Courier Prime',
    'Lora',
  ];

  static const List<String> stimmungsEmojis = [
    '😊', '😃', '😁', '😬', '😆', '😂', '🤣', '😅', '🙂', '😐',
    '😢', '😭', '😠',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.eintrag != null) {
      _titelController.text = widget.eintrag!.titelFormat.text;
      _textController.text = widget.eintrag!.text;
      _bildPfade.addAll(widget.eintrag!.bildPfade);
      _selectedEmoji = widget.eintrag!.emoji;
      
      _titelBold = widget.eintrag!.titelFormat.bold;
      _titelItalic = widget.eintrag!.titelFormat.italic;
      _titelUnderline = widget.eintrag!.titelFormat.underline;
      _titelFontFamily = widget.eintrag!.titelFormat.fontFamily;
      _titelColor = Color(widget.eintrag!.titelFormat.colorValue);
      
      _textBold = widget.eintrag!.textBold;
      _textItalic = widget.eintrag!.textItalic;
      _textUnderline = widget.eintrag!.textUnderline;
      _textFontFamily = widget.eintrag!.textFontFamily;
      _textColor = Color(widget.eintrag!.textColorValue);
    }
  }

  @override
  void dispose() {
    _titelController.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _bildHinzufuegen() async {
    if (_bildPfade.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maximal 3 Bilder pro Eintrag erlaubt'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _bildPfade.add(image.path));
    }
  }

  void _speichern() {
    if (_titelController.text.isEmpty || _textController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte Titel und Text eingeben')),
      );
      return;
    }

    final provider = Provider.of<TagebuchProvider>(context, listen: false);
    final eintrag = TagebuchEintrag(
      id: widget.eintrag?.id ?? DateTime.now().toString(),
      titelFormat: TextFormatData(
        text: _titelController.text,
        bold: _titelBold,
        italic: _titelItalic,
        underline: _titelUnderline,
        fontFamily: _titelFontFamily,
        colorValue: _titelColor.value,
      ),
      text: _textController.text,
      datum: widget.eintrag?.datum ?? DateTime.now(),
      bildPfade: _bildPfade,
      emoji: _selectedEmoji,
      textBold: _textBold,
      textItalic: _textItalic,
      textUnderline: _textUnderline,
      textFontFamily: _textFontFamily,
      textColorValue: _textColor.value,
    );

    if (widget.eintrag != null) {
      provider.updateEintrag(eintrag);
    } else {
      provider.addEintrag(eintrag);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.eintrag != null ? 'Eintrag bearbeiten' : 'Neuer Eintrag'),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _speichern),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _showEmojiPicker = !_showEmojiPicker),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[800] : Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_selectedEmoji, style: const TextStyle(fontSize: 32)),
                          const SizedBox(width: 8),
                          const Text('Stimmung'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Titel-Formatierung:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _buildFormatToolbar(true),
                  const SizedBox(height: 8),
                  TextField(
                    key: ValueKey('title_$_titelFontFamily'),
                    controller: _titelController,
                    style: GoogleFonts.getFont(
                      _titelFontFamily,
                      fontWeight: _titelBold ? FontWeight.bold : FontWeight.normal,
                      fontStyle: _titelItalic ? FontStyle.italic : FontStyle.normal,
                      decoration: _titelUnderline ? TextDecoration.underline : TextDecoration.none,
                      color: _titelColor,
                      fontSize: 18,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Titel',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Text-Formatierung:', style: TextStyle(fontWeight: FontWeight.bold)),
                      TextButton.icon(
                        onPressed: () => _showTextEmojiPicker(),
                        icon: const Icon(Icons.emoji_emotions),
                        label: const Text('Emoji'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildFormatToolbar(false),
                  const SizedBox(height: 8),
                  TextField(
                    key: ValueKey('text_$_textFontFamily'),
                    controller: _textController,
                    maxLines: 10,
                    style: GoogleFonts.getFont(
                      _textFontFamily,
                      fontWeight: _textBold ? FontWeight.bold : FontWeight.normal,
                      fontStyle: _textItalic ? FontStyle.italic : FontStyle.normal,
                      decoration: _textUnderline ? TextDecoration.underline : TextDecoration.none,
                      color: _textColor,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Text',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Bilder:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ..._bildPfade.map((pfad) => Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: kIsWeb 
                              ? Image.network(pfad, width: 100, height: 100, fit: BoxFit.cover)
                              : Image.file(File(pfad), width: 100, height: 100, fit: BoxFit.cover),
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: IconButton(
                              icon: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(4),
                                child: const Icon(Icons.close, color: Colors.white, size: 16),
                              ),
                              onPressed: () => setState(() => _bildPfade.remove(pfad)),
                            ),
                          ),
                        ],
                      )),
                      if (_bildPfade.length < 3)
                        InkWell(
                          onTap: _bildHinzufuegen,
                          child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.add_photo_alternate, size: 40, color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (_showEmojiPicker)
            Container(
              height: 200,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                border: Border(
                  top: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Wähle deine Stimmung:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: stimmungsEmojis.length,
                      itemBuilder: (context, index) {
                        final emoji = stimmungsEmojis[index];
                        final isSelected = _selectedEmoji == emoji;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedEmoji = emoji;
                              _showEmojiPicker = false;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.blue.shade100 : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected ? Colors.blue : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                emoji,
                                style: const TextStyle(fontSize: 32),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFormatToolbar(bool isTitle) {
    final bold = isTitle ? _titelBold : _textBold;
    final italic = isTitle ? _titelItalic : _textItalic;
    final underline = isTitle ? _titelUnderline : _textUnderline;
    final color = isTitle ? _titelColor : _textColor;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.format_bold, color: bold ? Colors.blue : null),
                  onPressed: () {
                    setState(() {
                      if (isTitle) _titelBold = !_titelBold; else _textBold = !_textBold;
                    });
                  },
                ),
                IconButton(
                  icon: Icon(Icons.format_italic, color: italic ? Colors.blue : null),
                  onPressed: () {
                    setState(() {
                      if (isTitle) _titelItalic = !_titelItalic; else _textItalic = !_textItalic;
                    });
                  },
                ),
                IconButton(
                  icon: Icon(Icons.format_underline, color: underline ? Colors.blue : null),
                  onPressed: () {
                    setState(() {
                      if (isTitle) _titelUnderline = !_titelUnderline; else _textUnderline = !_textUnderline;
                    });
                  },
                ),
                const Spacer(),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.font_download),
                  tooltip: 'Schriftart',
                  onSelected: (font) {
                    setState(() {
                      if (isTitle) {
                        _titelFontFamily = font;
                      } else {
                        _textFontFamily = font;
                      }
                    });
                  },
                  itemBuilder: (context) => fonts
                      .map((font) => PopupMenuItem(
                            value: font,
                            child: Text(
                              font,
                              style: GoogleFonts.getFont(font, fontSize: 14),
                            ),
                          ))
                      .toList(),
                ),
                PopupMenuButton<Color>(
                  icon: Icon(Icons.palette, color: color),
                  tooltip: 'Farbe',
                  onSelected: (selectedColor) {
                    setState(() {
                      if (isTitle) _titelColor = selectedColor; else _textColor = selectedColor;
                    });
                  },
                  itemBuilder: (context) => colors
                      .map((c) => PopupMenuItem(
                            value: c,
                            child: Row(
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: c,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.grey),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if (c == color) const Icon(Icons.check, size: 16),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showTextEmojiPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Emoji einfügen'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: stimmungsEmojis.length,
            itemBuilder: (context, index) {
              final emoji = stimmungsEmojis[index];
              return GestureDetector(
                onTap: () {
                  final currentText = _textController.text;
                  final selection = _textController.selection;
                  final newText = currentText.substring(0, selection.start) +
                      emoji +
                      currentText.substring(selection.end);
                  _textController.text = newText;
                  _textController.selection = TextSelection.collapsed(
                    offset: selection.start + emoji.length,
                  );
                  Navigator.pop(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Center(
                    child: Text(emoji, style: const TextStyle(fontSize: 28)),
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Schließen'),
          ),
        ],
      ),
    );
  }
}
