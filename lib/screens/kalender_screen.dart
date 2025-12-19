import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../providers/tagebuch_provider.dart';
import 'eintrag_detail_screen.dart';

class KalenderScreen extends StatefulWidget {
  const KalenderScreen({super.key});

  @override
  State<KalenderScreen> createState() => _KalenderScreenState();
}

class _KalenderScreenState extends State<KalenderScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kalender'),
      ),
      body: Consumer<TagebuchProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              TableCalendar(
                firstDay: DateTime(2020),
                lastDay: DateTime(2030),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                calendarFormat: CalendarFormat.month,
                eventLoader: (day) {
                  return provider.eintraege
                      .where((e) => isSameDay(e.datum, day))
                      .toList();
                },
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const Divider(),
              Expanded(
                child: _buildEintraegeList(provider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEintraegeList(TagebuchProvider provider) {
    if (_selectedDay == null) {
      return const Center(
        child: Text('Wähle ein Datum aus, um Einträge zu sehen.'),
      );
    }

    final eintraegeAmTag = provider.eintraege
        .where((e) => isSameDay(e.datum, _selectedDay))
        .toList()
      ..sort((a, b) => b.datum.compareTo(a.datum));

    if (eintraegeAmTag.isEmpty) {
      return Center(
        child: Text(
          'Keine Einträge am ${DateFormat('dd.MM.yyyy').format(_selectedDay!)}',
          style: const TextStyle(fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: eintraegeAmTag.length,
      itemBuilder: (context, index) {
        final eintrag = eintraegeAmTag[index];
        return Card(
          child: ListTile(
            leading: Text(eintrag.emoji, style: const TextStyle(fontSize: 32)),
            title: Text(eintrag.titelFormat.text),
            subtitle: Text(
              DateFormat('HH:mm').format(eintrag.datum),
              style: const TextStyle(fontSize: 12),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EintragDetailScreen(eintrag: eintrag),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
