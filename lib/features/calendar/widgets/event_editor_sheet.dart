import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/calendar_models.dart';
import '../providers/calendar_providers.dart';

class EventEditorSheet extends ConsumerStatefulWidget {
  const EventEditorSheet({
    super.key,
    this.event,
    this.initialDay,
  });

  final CalendarEvent? event;
  final DateTime? initialDay;

  @override
  ConsumerState<EventEditorSheet> createState() => _EventEditorSheetState();
}

class _EventEditorSheetState extends ConsumerState<EventEditorSheet> {
  late TextEditingController _title;
  late TextEditingController _notes;
  late DateTime _start;
  late DateTime _end;
  String? _subjectId;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.event;
    final baseDay = widget.initialDay ?? DateTime.now();

    _title = TextEditingController(text: e?.title ?? '');
    _notes = TextEditingController(text: e?.notes ?? '');
    _start = e?.start ??
        DateTime(baseDay.year, baseDay.month, baseDay.day, 9, 0);
    _end = e?.end ??
        DateTime(baseDay.year, baseDay.month, baseDay.day, 10, 0);
    _subjectId = e?.subjectId;
  }

  @override
  void dispose() {
    _title.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickStart() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _start,
      firstDate: DateTime(2019),
      lastDate: DateTime(2035),
    );
    if (!mounted || d == null) return;

    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_start),
    );
    if (!mounted || t == null) return;

    setState(
      () => _start = DateTime(d.year, d.month, d.day, t.hour, t.minute),
    );
    if (!_end.isAfter(_start)) {
      setState(() => _end = _start.add(const Duration(minutes: 30)));
    }
  }

  Future<void> _pickEnd() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _end,
      firstDate: DateTime(2019),
      lastDate: DateTime(2035),
    );
    if (!mounted || d == null) return;

    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_end),
    );
    if (!mounted || t == null) return;

    setState(
      () => _end = DateTime(d.year, d.month, d.day, t.hour, t.minute),
    );
    if (!_end.isAfter(_start)) {
      setState(() => _start = _end.subtract(const Duration(minutes: 30)));
    }
  }

  Future<void> _onSave() async {
    if (_title.text.trim().isEmpty || _subjectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa Título y Materia')),
      );
      return;
    }

    final notifier = ref.read(eventsProvider.notifier);

    final draft = CalendarEvent(
      id: widget.event?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      subjectId: _subjectId!,
      title: _title.text.trim(),
      start: _start,
      end: _end,
      notes:
          _notes.text.trim().isEmpty ? null : _notes.text.trim(),
    );

    setState(() => _saving = true);

    try {
      if (widget.event == null) {
        await notifier.createEvent(draft);
      } else {
        await notifier.updateEvent(draft);
      }

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final subjects = ref.watch(subjectsProvider);

    // Construimos la lista de items del dropdown
    final subjectItems = subjects.entries.map((e) {
      return DropdownMenuItem<String>(
        value: e.key,
        child: Row(
          children: [
            CircleAvatar(
              radius: 6,
              backgroundColor: e.value.color,
            ),
            const SizedBox(width: 8),
            Text(e.value.name),
          ],
        ),
      );
    }).toList();

    // Si el subjectId actual no existe en la lista de materias,
    // dejamos el combo sin selección para evitar el crash.
    final initialSubjectId = (_subjectId != null &&
            subjects.containsKey(_subjectId))
        ? _subjectId
        : null;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 5,
              decoration: BoxDecoration(
                color: cs.outlineVariant,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  widget.event == null
                      ? 'Nueva actividad'
                      : 'Editar actividad',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                if (widget.event != null)
                  IconButton(
                    tooltip: 'Eliminar',
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () async {
                      try {
                        await ref
                            .read(eventsProvider.notifier)
                            .deleteEvent(widget.event!.id);
                        if (!mounted) return;
                        Navigator.of(context).pop(true);
                      } catch (e) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error al eliminar: $e')),
                        );
                      }
                    },
                  ),
              ],
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _title,
              decoration: const InputDecoration(
                labelText: 'Título',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            // Materia
            DropdownButtonFormField<String>(
              initialValue: initialSubjectId,
              decoration: const InputDecoration(
                labelText: 'Materia',
                border: OutlineInputBorder(),
              ),
              items: subjectItems,
              onChanged: (v) => setState(() => _subjectId = v),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _DateTimeButton(
                    label: 'Inicio',
                    value: _fmt(_start),
                    onTap: _pickStart,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _DateTimeButton(
                    label: 'Fin',
                    value: _fmt(_end),
                    onTap: _pickEnd,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _notes,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Notas',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check),
                label: Text(_saving ? 'Guardando...' : 'Guardar'),
                onPressed: _saving ? null : _onSave,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')} '
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}

class _DateTimeButton extends StatelessWidget {
  const _DateTimeButton({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding:
            const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        side: BorderSide(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 2),
          Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
