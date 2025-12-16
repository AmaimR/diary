import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import '../tagebuch_eintrag.dart';

class EintragDetailScreen extends StatelessWidget {
  final TagebuchEintrag eintrag;

  const EintragDetailScreen({super.key, required this.eintrag});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eintrag Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(eintrag.emoji, style: const TextStyle(fontSize: 48)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        eintrag.titelFormat.text,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: eintrag.titelFormat.bold ? FontWeight.bold : FontWeight.normal,
                          fontStyle: eintrag.titelFormat.italic ? FontStyle.italic : FontStyle.normal,
                          decoration: eintrag.titelFormat.underline ? TextDecoration.underline : TextDecoration.none,
                          fontFamily: eintrag.titelFormat.fontFamily,
                          color: Color(eintrag.titelFormat.colorValue),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('dd.MM.yyyy HH:mm').format(eintrag.datum),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            Text(
              eintrag.text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: eintrag.textBold ? FontWeight.bold : FontWeight.normal,
                fontStyle: eintrag.textItalic ? FontStyle.italic : FontStyle.normal,
                decoration: eintrag.textUnderline ? TextDecoration.underline : TextDecoration.none,
                fontFamily: eintrag.textFontFamily,
                color: Color(eintrag.textColorValue),
              ),
            ),
            if (eintrag.bildPfade.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Text(
                'Bilder',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: eintrag.bildPfade.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => _BildVollansicht(
                            bildPfade: eintrag.bildPfade,
                            initialIndex: index,
                          ),
                        ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: kIsWeb
                        ? Image.network(
                            eintrag.bildPfade[index],
                            fit: BoxFit.cover,
                          )
                        : Image.file(
                            File(eintrag.bildPfade[index]),
                            fit: BoxFit.cover,
                          ),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BildVollansicht extends StatelessWidget {
  final List<String> bildPfade;
  final int initialIndex;

  const _BildVollansicht({
    required this.bildPfade,
    required this.initialIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bild ${initialIndex + 1} von ${bildPfade.length}'),
        backgroundColor: Colors.black,
      ),
      body: PhotoViewGallery.builder(
        itemCount: bildPfade.length,
        builder: (context, index) {
          return PhotoViewGalleryPageOptions(
            imageProvider: kIsWeb
              ? NetworkImage(bildPfade[index]) as ImageProvider
              : FileImage(File(bildPfade[index])),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2,
          );
        },
        scrollPhysics: const BouncingScrollPhysics(),
        backgroundDecoration: const BoxDecoration(color: Colors.black),
        pageController: PageController(initialPage: initialIndex),
      ),
    );
  }
}
