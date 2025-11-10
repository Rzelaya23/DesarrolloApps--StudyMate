import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:go_router/go_router.dart';                           // 👈 nuevo
import 'package:mi_app/core/router/app_router.dart';                 // 👈 nuevo

import 'package:mi_app/features/calendar/models/calendar_models.dart';
import 'package:mi_app/features/calendar/providers/calendar_providers.dart';
import 'package:mi_app/features/calendar/widgets/event_editor_sheet.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(eventsFromBackendProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendario'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ───────────── Calendario ─────────────
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: eventsAsync.when(
                loading: () => const SizedBox(
                  height: 260,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => SizedBox(
                  height: 260,
                  child: Center(
                    child: Text(
                      'Error al cargar eventos:\n$e',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                data: (events) {
                  final Map<DateTime, List<CalendarEvent>> eventsByDay = {};
                  for (final event in events) {
                    final dayKey = _dateOnly(event.start);
                    eventsByDay.putIfAbsent(dayKey, () => []);
                    eventsByDay[dayKey]!.add(event);
                  }

                  return TableCalendar<CalendarEvent>(
                    locale: 'es_ES',
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    calendarFormat: _calendarFormat,
                    selectedDayPredicate: (day) =>
                        _dateOnly(day) == _dateOnly(_selectedDay),
                    eventLoader: (day) =>
                        eventsByDay[_dateOnly(day)] ?? const [],
                    startingDayOfWeek: StartingDayOfWeek.monday,
                    headerStyle: HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                    calendarStyle: const CalendarStyle(
                      outsideDaysVisible: false,
                    ),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    },
                    onPageChanged: (focusedDay) {
                      _focusedDay = focusedDay;
                    },
                    onFormatChanged: (format) {
                      setState(() {
                        _calendarFormat = format;
                      });
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 8),

            // ───────────── Lista de actividades del día ─────────────
            Expanded(
              child: eventsAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Text(
                    'Error al cargar eventos:\n$e',
                    textAlign: TextAlign.center,
                  ),
                ),
                data: (events) {
                  final selectedEvents = events
                      .where((e) =>
                          _dateOnly(e.start) == _dateOnly(_selectedDay))
                      .toList()
                    ..sort((a, b) => a.start.compareTo(b.start));

                  if (selectedEvents.isEmpty) {
                    return const Center(
                      child: Text('No hay actividades para este día'),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    itemCount: selectedEvents.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final e = selectedEvents[index];
                      final timeRange =
                          '${TimeOfDay.fromDateTime(e.start).format(context)} – '
                          '${TimeOfDay.fromDateTime(e.end).format(context)}';

                      return Card(
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ListTile(
                          title: Text(e.title),
                          subtitle: Text(timeRange),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () async {
                            final changed =
                                await showModalBottomSheet<bool>(
                              context: context,
                              isScrollControlled: true,
                              builder: (ctx) => Padding(
                                padding: EdgeInsets.only(
                                  bottom:
                                      MediaQuery.of(ctx).viewInsets.bottom,
                                ),
                                child: EventEditorSheet(event: e),
                              ),
                            );

                            if (changed == true) {
                              ref.invalidate(eventsFromBackendProvider);
                            }
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // ───────────── Botón "Nueva actividad" ─────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Nueva actividad'),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () async {
                    final changed = await showModalBottomSheet<bool>(
                      context: context,
                      isScrollControlled: true,
                      builder: (ctx) => Padding(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(ctx).viewInsets.bottom,
                        ),
                        child: EventEditorSheet(
                          initialDay: _selectedDay,
                        ),
                      ),
                    );

                    if (changed == true) {
                      ref.invalidate(eventsFromBackendProvider);
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),

      // ───────────── BottomNavigationBar para volver a Inicio ─────────────
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 2, // 0: Inicio, 1: Materias, 2: Calendario, 3: Perfil
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Materias'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today), label: 'Calendario'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              context.go(AppRouter.dashboard); // 👈 vuelve al dashboard
              break;
            case 1:
              context.go(AppRouter.subjects);
              break;
            case 2:
              // ya estamos en calendario
              break;
            case 3:
              context.go(AppRouter.profile);
              break;
          }
        },
      ),
    );
  }
}
