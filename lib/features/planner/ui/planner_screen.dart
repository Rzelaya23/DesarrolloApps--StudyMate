import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/planner_models.dart';
import '../providers/planner_provider.dart';

class PlannerScreen extends ConsumerStatefulWidget {
  const PlannerScreen({super.key});

  @override
  ConsumerState<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends ConsumerState<PlannerScreen> with SingleTickerProviderStateMixin {
  final _titleCtrl = TextEditingController();
  final _minsCtrl = TextEditingController();
  Priority _prio = Priority.media;
  Difficulty _diff = Difficulty.intermedia;

  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    // <<< agregado: fuerza rebuild al cambiar de pestaña para mostrar/ocultar el FAB >>>
    _tab.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _minsCtrl.dispose();
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(plannerProvider);
    final notifier = ref.read(plannerProvider.notifier);

    // <<< agregado: saber si estamos en la pestaña "Horario" (índice 1) >>>
    final bool isScheduleTab = _tab.index == 1;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Planificador'),
        actions: [
          IconButton(
            tooltip: 'Generar horario',
            onPressed: state.actividades.isEmpty ? null : () {
              notifier.generar();
              _tab.animateTo(1);
            },
            // Antes: Icon(Icons.auto_schedule)
            icon: const Icon(Icons.schedule),
          ),
        ],

        bottom: TabBar(
          controller: _tab,
          tabs: const [
            Tab(text: 'Actividades'),
            Tab(text: 'Horario'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          // --- Tab Actividades ---
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Nueva actividad', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              TextField(
                controller: _titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _minsCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Duración (min)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<Priority>(
                      value: _prio,
                      items: Priority.values.map((p) =>
                        DropdownMenuItem(value: p, child: Text(p.name.toUpperCase()))
                      ).toList(),
                      onChanged: (v) => setState(() => _prio = v ?? _prio),
                      decoration: const InputDecoration(
                        labelText: 'Prioridad',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<Difficulty>(
                      value: _diff,
                      items: Difficulty.values.map((d) =>
                        DropdownMenuItem(value: d, child: Text(d.name.toUpperCase()))
                      ).toList(),
                      onChanged: (v) => setState(() => _diff = v ?? _diff),
                      decoration: const InputDecoration(
                        labelText: 'Dificultad',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              FilledButton.icon(
                onPressed: () {
                  final title = _titleCtrl.text.trim();
                  final mins = int.tryParse(_minsCtrl.text.trim() );
                  if (title.isEmpty || mins == null || mins <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Completa título y minutos (>0)'))
                    );
                    return;
                  }
                  ref.read(plannerProvider.notifier).addActividad(
                    titulo: title,
                    minutos: mins,
                    prioridad: _prio,
                    dificultad: _diff,
                  );
                  _titleCtrl.clear();
                  _minsCtrl.clear();
                },
                icon: const Icon(Icons.add),
                label: const Text('Agregar'),
              ),
              const SizedBox(height: 20),
              Text('Actividades del día', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              ...state.actividades.map((a) => Card(
                child: ListTile(
                  title: Text(a.titulo),
                  subtitle: Text('${a.minutos} min • ${a.prioridad.name} • ${a.dificultad.name}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => notifier.removeActividad(a.id),
                  ),
                ),
              )),
              const SizedBox(height: 24),
              Text('Parámetros', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _TimeField(
                    label: 'Inicio',
                    value: state.settings.start,
                    onPick: (dt) => notifier.setVentana(dt, state.settings.end),
                  )),
                  const SizedBox(width: 10),
                  Expanded(child: _TimeField(
                    label: 'Fin',
                    value: state.settings.end,
                    onPick: (dt) => notifier.setVentana(state.settings.start, dt),
                  )),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _NumberField(
                    label: 'Foco (min)',
                    initial: state.settings.focoMin,
                    onChanged: (v) => notifier.setParametros(focoMin: v),
                  )),
                  const SizedBox(width: 10),
                  Expanded(child: _NumberField(
                    label: 'Descanso (min)',
                    initial: state.settings.breakMin,
                    onChanged: (v) => notifier.setParametros(breakMin: v),
                  )),
                ],
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: state.actividades.isEmpty
                    ? null
                    : () {
                        notifier.generar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Horario generado ✅')),
                        );
                        _tab.animateTo(1); // pasa automáticamente a la pestaña "Horario"
                      },
                icon: const Icon(Icons.schedule),
                label: const Text('Generar horario'),
              ),
            ],
          ),

          // --- Tab Horario ---
          Builder(
            builder: (_) {
              final r = state.resultado;
              if (r.isEmpty) {
                return const Center(child: Text('Genera tu horario para ver el resultado'));
              }
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: r.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final b = r[i];
                  final tStart = TimeOfDay.fromDateTime(b.start).format(context);
                  final tEnd = TimeOfDay.fromDateTime(b.end).format(context);
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: b.isBreak
                          ? Colors.teal.withOpacity(0.15)
                          : Theme.of(context).colorScheme.primary.withOpacity(0.15),
                      child: Icon(
                        b.isBreak ? Icons.coffee : Icons.task_alt,
                        color: b.isBreak ? Colors.teal : Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    title: Text(b.titulo),
                    subtitle: Text('$tStart — $tEnd'),
                  );
                },
              );
            },
          ),
        ],
      ),

      // <<< agregado: FAB visible solo en la pestaña "Horario" y si hay actividades >>>
      floatingActionButton: isScheduleTab && state.actividades.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () {
                notifier.generar();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Horario generado ✅')),
                );
              },
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Generar horario'),
            )
          : null,
    );
  }
}

class _TimeField extends StatelessWidget {
  final String label;
  final DateTime value;
  final ValueChanged<DateTime> onPick;
  const _TimeField({required this.label, required this.value, required this.onPick, super.key});

  @override
  Widget build(BuildContext context) {
    final time = TimeOfDay.fromDateTime(value);
    return TextField(
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        suffixIcon: const Icon(Icons.schedule),
      ),
      controller: TextEditingController(text: time.format(context)),
      onTap: () async {
        final picked = await showTimePicker(context: context, initialTime: time);
        if (picked != null) {
          final now = value;
          onPick(DateTime(now.year, now.month, now.day, picked.hour, picked.minute));
        }
      },
    );
  }
}

class _NumberField extends StatefulWidget {
  final String label;
  final int initial;
  final ValueChanged<int> onChanged;
  const _NumberField({required this.label, required this.initial, required this.onChanged, super.key});

  @override
  State<_NumberField> createState() => _NumberFieldState();
}

class _NumberFieldState extends State<_NumberField> {
  late final TextEditingController _c;
  @override
  void initState() { super.initState(); _c = TextEditingController(text: widget.initial.toString()); }
  @override
  void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _c,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: widget.label, border: const OutlineInputBorder()),
      onChanged: (v) { final n = int.tryParse(v); if (n != null) widget.onChanged(n); },
    );
  }
}
