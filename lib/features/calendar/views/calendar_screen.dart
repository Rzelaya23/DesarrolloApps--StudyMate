import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:mi_app/core/router/app_router.dart';
import '../models/calendar_models.dart';
import '../providers/calendar_providers.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final eventsByDay = ref.watch(eventsByDayProvider);
    final subjects = ref.watch(subjectsProvider);

    List<CalendarEvent> loader(DateTime day) {
      final key = DateTime(day.year, day.month, day.day);
      return eventsByDay[key] ?? const [];
    }

    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendario'),
        centerTitle: false,
        // ⬇️ SIEMPRE mostramos la flecha
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              context.pop();                       // venías con push → vuelve
            } else {
              context.go(AppRouter.dashboard);     // venías desde bottom → ir a Inicio
            }
          },
        ),
      ),

      // (opcional) barra inferior como en el dashboard, con Calendario seleccionado
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 2, // 0=Inicio, 1=Materias, 2=Calendario, 3=Perfil
        onTap: (index) {
          switch (index) {
            case 0:
              context.go(AppRouter.dashboard);
              break;
            case 1:
              context.go(AppRouter.subjects);
              break;
            case 2:
              break; // ya estás en Calendario
            case 3:
            // TODO: context.go(AppRouter.profile);
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Materias'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Calendario'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: abrir hoja/modal para crear actividad
        },
        label: const Text('Nueva actividad'),
        icon: const Icon(Icons.add),
      ),

      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(12),
            elevation: 0,
            color: cs.surfaceContainerHighest,
            child: TableCalendar<CalendarEvent>(
              focusedDay: _focusedDay,
              firstDay: DateTime.utc(2019, 1, 1),
              lastDay: DateTime.utc(2035, 12, 31),
              locale: 'es_ES',
              startingDayOfWeek: StartingDayOfWeek.monday,
              headerStyle: HeaderStyle(
                titleCentered: true,
                formatButtonVisible: false,
                titleTextStyle: textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                leftChevronIcon: Icon(Icons.chevron_left, color: cs.onSurface),
                rightChevronIcon: Icon(Icons.chevron_right, color: cs.onSurface),
              ),
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: cs.primaryContainer,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: cs.primary,
                  shape: BoxShape.circle,
                ),
                markerDecoration: BoxDecoration(
                  color: cs.secondary,
                  shape: BoxShape.circle,
                ),
                markersAnchor: 1.2,
              ),
              eventLoader: loader,
              selectedDayPredicate: (day) =>
              _selectedDay != null &&
                  day.year == _selectedDay!.year &&
                  day.month == _selectedDay!.month &&
                  day.day == _selectedDay!.day,
              onDaySelected: (sel, foc) {
                setState(() {
                  _selectedDay = sel;
                  _focusedDay = foc;
                });
              },
              onPageChanged: (foc) => _focusedDay = foc,
            ),
          ),
          Expanded(
            child: _DayEventsList(
              day: _selectedDay ?? DateTime.now(),
              events: loader(_selectedDay ?? DateTime.now()),
              subjects: subjects,
            ),
          ),
        ],
      ),
    );
  }
}

class _DayEventsList extends StatelessWidget {
  final DateTime day;
  final List<CalendarEvent> events;
  final Map<String, Subject> subjects;

  const _DayEventsList({
    required this.day,
    required this.events,
    required this.subjects,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: events.isEmpty
          ? Center(
        child: Text(
          'No hay actividades para este día',
          style: textTheme.bodyMedium?.copyWith(color: cs.outline),
        ),
      )
          : ListView.separated(
        itemCount: events.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final e = events[i];
          final subj = subjects[e.subjectId];
          final time = '${_fmt(e.start)} – ${_fmt(e.end)}';
          return Card(
            elevation: 0,
            color: cs.surfaceContainerHigh,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: CircleAvatar(
                radius: 12,
                backgroundColor: subj?.color ?? cs.secondary,
              ),
              title: Text(e.title, style: textTheme.titleMedium),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(time, style: textTheme.bodySmall),
                  if (subj != null) ...[
                    const SizedBox(height: 6),
                    _Chip(subject: subj),
                  ],
                  if (e.notes != null && e.notes!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      e.notes!,
                      style: textTheme.bodySmall
                          ?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ],
              ),
              onTap: () {
                // TODO: ver detalle / editar
              },
            ),
          );
        },
      ),
    );
  }

  static String _fmt(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}

class _Chip extends StatelessWidget {
  final Subject subject;
  const _Chip({required this.subject});

  @override
  Widget build(BuildContext context) {
    final on = ThemeData.estimateBrightnessForColor(subject.color) ==
        Brightness.dark
        ? Colors.white
        : Colors.black87;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: subject.color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        subject.name,
        style: Theme.of(context)
            .textTheme
            .labelSmall
            ?.copyWith(color: on, fontWeight: FontWeight.w600),
      ),
    );
  }
}
