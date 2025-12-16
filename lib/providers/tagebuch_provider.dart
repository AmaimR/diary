import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../tagebuch_eintrag.dart';

class TagebuchProvider with ChangeNotifier {
  List<TagebuchEintrag> _eintraege = [];
  static const String _storageKey = 'tagebuch_eintraege';

  List<TagebuchEintrag> get eintraege => [..._eintraege];

  // Alle Bilder aus allen Einträgen für die Galerie
  List<String> get alleBilder {
    List<String> bilder = [];
    for (var eintrag in _eintraege) {
      bilder.addAll(eintrag.bildPfade);
    }
    return bilder;
  }

  TagebuchProvider() {
    _ladeEintraege();
  }

  // Einträge aus SharedPreferences laden
  Future<void> _ladeEintraege() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? datenString = prefs.getString(_storageKey);

      if (datenString != null) {
        final List<dynamic> datenListe = json.decode(datenString);
        _eintraege = datenListe
            .map((item) => TagebuchEintrag.fromJson(item))
            .toList();
        
        // Nach Datum sortieren (neueste zuerst)
        _eintraege.sort((a, b) => b.datum.compareTo(a.datum));
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Fehler beim Laden der Einträge: $e');
    }
  }

  // Einträge in SharedPreferences speichern
  Future<void> _speichereEintraege() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String datenString = json.encode(
        _eintraege.map((eintrag) => eintrag.toJson()).toList(),
      );
      await prefs.setString(_storageKey, datenString);
    } catch (e) {
      debugPrint('Fehler beim Speichern der Einträge: $e');
    }
  }

  // Neuen Eintrag hinzufügen
  Future<void> addEintrag(TagebuchEintrag eintrag) async {
    _eintraege.insert(0, eintrag);
    notifyListeners();
    await _speichereEintraege();
  }

  // Eintrag aktualisieren
  Future<void> updateEintrag(TagebuchEintrag eintrag) async {
    final index = _eintraege.indexWhere((e) => e.id == eintrag.id);
    if (index != -1) {
      _eintraege[index] = eintrag;
      _eintraege.sort((a, b) => b.datum.compareTo(a.datum));
      notifyListeners();
      await _speichereEintraege();
    }
  }

  // Eintrag löschen
  Future<void> deleteEintrag(String id) async {
    _eintraege.removeWhere((eintrag) => eintrag.id == id);
    notifyListeners();
    await _speichereEintraege();
  }

  // Einzelnen Eintrag nach ID finden
  TagebuchEintrag? findeEintragNachId(String id) {
    try {
      return _eintraege.firstWhere((eintrag) => eintrag.id == id);
    } catch (e) {
      return null;
    }
  }
}
