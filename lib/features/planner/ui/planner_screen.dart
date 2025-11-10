import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../providers/planner_providers.dart';
import 'package:mi_app/core/auth/auth_token_provider.dart';

class PlannerScreen extends ConsumerStatefulWidget {
  const PlannerScreen({super.key});
  @override
  ConsumerState<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends ConsumerState<PlannerScreen> {
  final _titleCtrl = TextEditingController();
  final _durationCtrl = TextEditingController();
  String _priority = 'MEDIA';
  String _difficulty = 'INTERMEDIA';
  DateTime _selectedDate = DateTime.now();

  final _startCtrl = TextEditingController(text: '08:00');
  final _endCtrl   = TextEditingController(text: '18:00');
  final _focusCtrl = TextEditingController(text: '50');
  final _breakCtrl = TextEditingController(text: '10');

  @override
  void initState() {
    super.initState();
    _ensureJwt(ref); // fire-and-forget
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _durationCtrl.dispose();
    _startCtrl.dispose();
    _endCtrl.dispose();
    _focusCtrl.dispose();
    _breakCtrl.dispose();
    super.dispose();
  }

  Future<void> _ensureJwt(WidgetRef ref) async {
    final s = const FlutterSecureStorage();
    final existing = await s.read(key: 'jwt');
    if (existing == null || existing.isEmpty) {
      // Tu token válido de pruebas (el mismo de Postman)
      const t = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJmNmNmODQ0MC04ZTQ0LTQ3NTYtOTQ2Ni02MzhmYWY4ZThkMTEiLCJlbWFpbCI6ImRhbmlAZXhhbXBsZS5jb20iLCJyb2xlIjoiU1RVREVOVCIsImlhdCI6MTc2Mjc1ODkxOSwiZXhwIjoxNzYyNzU5ODE5fQ.dBGXOT3Rm6YGDce-Sb4rYT_M9i9C_AHTYCLkFY7-NMo';
      await s.write(key: 'jwt', value: t);
      await ref.read(authTokenProvider.notifier).set(t);
    } else {
      await ref.read(authTokenProvider.notifier).set(existing);
    }
  }

  Future<void> _onAdd() async {
    // Garantiza token inmediatamente antes de llamar repo
    await _ensureJwt(ref);

    final title = _titleCtrl.text.trim();
    final duration = int.tryParse(_durationCtrl.text.trim()) ?? 0;
    if (title.isEmpty || duration <= 0) return;

    await ref.read(plannerActivitiesProvider.notifier).addActivity(
      title: title,
      durationMin: duration,
      priority: _priority,
      difficulty: _difficulty,
      date: _selectedDate,
    );

    _titleCtrl.clear();
    _durationCtrl.clear();
  }

  Future<void> _onGenerate() async {
    await _ensureJwt(ref);

    final start = _startCtrl.text.trim();
    final end   = _endCtrl.text.trim();
    final focus = int.tryParse(_focusCtrl.text.trim()) ?? 50;
    final brk   = int.tryParse(_breakCtrl.text.trim()) ?? 10;

    await ref.read(plannerScheduleProvider.notifier).generate(
      date: _selectedDate,
      start: start,
      end: end,
      focusMin: focus,
      breakMin: brk,
    );
  }

  @override
  Widget build(BuildContext context) {
    final activitiesState = ref.watch(plannerActivitiesProvider);
    final scheduleState   = ref.watch(plannerScheduleProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Planificador')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Nueva actividad', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(controller: _titleCtrl, decoration: const InputDecoration(labelText: 'Título')),
          const SizedBox(height: 12),
          TextField(
            controller: _durationCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Duración (min)'),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _priority,
                  items: const [
                    DropdownMenuItem(value: 'BAJA', child: Text('BAJA')),
                    DropdownMenuItem(value: 'MEDIA', child: Text('MEDIA')),
                    DropdownMenuItem(value: 'ALTA', child: Text('ALTA')),
                  ],
                  onChanged: (v) => setState(() => _priority = v ?? 'MEDIA'),
                  decoration: const InputDecoration(labelText: 'Prioridad'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _difficulty,
                  items: const [
                    DropdownMenuItem(value: 'FACIL', child: Text('FACIL')),
                    DropdownMenuItem(value: 'INTERMEDIA', child: Text('INTERMEDIA')),
                    DropdownMenuItem(value: 'DIFICIL', child: Text('DIFICIL')),
                  ],
                  onChanged: (v) => setState(() => _difficulty = v ?? 'INTERMEDIA'),
                  decoration: const InputDecoration(labelText: 'Dificultad'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: _onAdd, child: const Text('+ Agregar')),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 12),
          const Text('Generar horario', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: TextField(controller: _startCtrl, decoration: const InputDecoration(labelText: 'Inicio (HH:mm)'))),
              const SizedBox(width: 12),
              Expanded(child: TextField(controller: _endCtrl, decoration: const InputDecoration(labelText: 'Fin (HH:mm)'))),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: TextField(controller: _focusCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Foco (min)'))),
              const SizedBox(width: 12),
              Expanded(child: TextField(controller: _breakCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Descanso (min)'))),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: _onGenerate, child: const Text('Generar')),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 12),
          const Text('Actividades', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          activitiesState.when(
            data: (list) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: list.map<Widget>((a) => ListTile(
                title: Text(a.title),
                subtitle: Text('${a.durationMin} min • ${a.priority} • ${a.difficulty}'),
              )).toList(),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Error: $e'),
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 12),
          const Text('Horario generado', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          scheduleState.when(
            data: (slots) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: slots.isEmpty
                  ? <Widget>[const Text('Sin bloques generados')]
                  : slots.map<Widget>((s) => ListTile(
                      title: Text(s.title),
                      subtitle: Text('${s.start.toLocal()} - ${s.end.toLocal()}'),
                      trailing: s.isBreak ? const Text('Break') : null,
                    )).toList(),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Error: $e'),
          ),
        ],
      ),
    );
  }
}
