import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../tagebuch_eintrag.dart';
import '../providers/tagebuch_provider.dart';
import 'eintrag_erstellen_screen.dart';
import 'eintrag_detail_screen.dart';

class EintragListeScreen extends StatelessWidget {
  const EintragListeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mein Tagebuch'),
      ),
      body: Consumer<TagebuchProvider>(
        builder: (context, provider, child) {
          if (provider.eintraege.isEmpty) {
            return const Center(
              child: Text(
                'Noch keine Einträge vorhanden.\nTippe auf + um einen Eintrag zu erstellen.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final sortedEintraege = List<TagebuchEintrag>.from(provider.eintraege)
            ..sort((a, b) => b.datum.compareTo(a.datum));

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: sortedEintraege.length,
            itemBuilder: (context, index) {
              final eintrag = sortedEintraege[index];
              return _EintragCard(eintrag: eintrag);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EintragErstellenScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _EintragCard extends StatelessWidget {
  final TagebuchEintrag eintrag;

  const _EintragCard({required this.eintrag});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EintragDetailScreen(eintrag: eintrag),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(eintrag.emoji, style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          eintrag.titelFormat.text,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: eintrag.titelFormat.bold ? FontWeight.bold : FontWeight.normal,
                            fontStyle: eintrag.titelFormat.italic ? FontStyle.italic : FontStyle.normal,
                            decoration: eintrag.titelFormat.underline ? TextDecoration.underline : TextDecoration.none,
                            fontFamily: eintrag.titelFormat.fontFamily,
                            color: Color(eintrag.titelFormat.colorValue),
                          ),
                        ),
                        Text(
                          DateFormat('dd.MM.yyyy HH:mm').format(eintrag.datum),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EintragErstellenScreen(eintrag: eintrag),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      Provider.of<TagebuchProvider>(context, listen: false)
                          .deleteEintrag(eintrag.id);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                eintrag.text.length > 100 
                  ? '${eintrag.text.substring(0, 100)}...' 
                  : eintrag.text,
                style: TextStyle(
                  fontWeight: eintrag.textBold ? FontWeight.bold : FontWeight.normal,
                  fontStyle: eintrag.textItalic ? FontStyle.italic : FontStyle.normal,
                  decoration: eintrag.textUnderline ? TextDecoration.underline : TextDecoration.none,
                  fontFamily: eintrag.textFontFamily,
                  color: Color(eintrag.textColorValue),
                ),
              ),
              if (eintrag.bildPfade.isNotEmpty) ...[
                const SizedBox(height: 8),
                SizedBox(
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: eintrag.bildPfade.length > 3 ? 3 : eintrag.bildPfade.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: kIsWeb
                            ? Image.network(
                                eintrag.bildPfade[index],
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              )
                            : Image.file(
                                File(eintrag.bildPfade[index]),
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                        ),
                      );
                    },
                  ),
                ),
                if (eintrag.bildPfade.length > 3)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '+${eintrag.bildPfade.length - 3} weitere Bilder',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
