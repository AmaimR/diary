import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import '../providers/tagebuch_provider.dart';

class GalerieScreen extends StatelessWidget {
  const GalerieScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Galerie'),
      ),
      body: Consumer<TagebuchProvider>(
        builder: (context, provider, child) {
          final List<String> alleBilder = [];
          for (final eintrag in provider.eintraege) {
            alleBilder.addAll(eintrag.bildPfade);
          }

          if (alleBilder.isEmpty) {
            return const Center(
              child: Text(
                'Noch keine Bilder vorhanden.',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: alleBilder.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => _BildVollansicht(
                        bildPfade: alleBilder,
                        initialIndex: index,
                      ),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: kIsWeb
                    ? Image.network(
                        alleBilder[index],
                        fit: BoxFit.cover,
                      )
                    : Image.file(
                        File(alleBilder[index]),
                        fit: BoxFit.cover,
                      ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _BildVollansicht extends StatefulWidget {
  final List<String> bildPfade;
  final int initialIndex;

  const _BildVollansicht({
    required this.bildPfade,
    required this.initialIndex,
  });

  @override
  State<_BildVollansicht> createState() => _BildVollansichtState();
}

class _BildVollansichtState extends State<_BildVollansicht> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${_currentIndex + 1} / ${widget.bildPfade.length}'),
        backgroundColor: Colors.black,
      ),
      body: PhotoViewGallery.builder(
        itemCount: widget.bildPfade.length,
        builder: (context, index) {
          return PhotoViewGalleryPageOptions(
            imageProvider: kIsWeb
              ? NetworkImage(widget.bildPfade[index]) as ImageProvider
              : FileImage(File(widget.bildPfade[index])),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2,
          );
        },
        scrollPhysics: const BouncingScrollPhysics(),
        backgroundDecoration: const BoxDecoration(color: Colors.black),
        pageController: _pageController,
        onPageChanged: (index) {
          setState(() => _currentIndex = index);
        },
      ),
    );
  }
}
