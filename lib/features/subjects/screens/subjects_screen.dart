import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mi_app/core/router/app_router.dart';        // 👈 nuevo
import '../models/subject.dart';
import '../providers/subjects_providers.dart';

class SubjectsScreen extends ConsumerStatefulWidget {
  const SubjectsScreen({super.key});

  @override
  ConsumerState<SubjectsScreen> createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends ConsumerState<SubjectsScreen> {
  String _searchQuery = '';
  bool _reloading = false;

  @override
  Widget build(BuildContext context) {
    final subjectsMap = ref.watch(subjectsProvider);
    final subjects = subjectsMap.values.toList();
    final filtered = _applyFilter(subjects);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Materias'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRouter.dashboard),   // 👈 vuelve al inicio
        ),
        actions: [
          IconButton(
            tooltip: 'Recargar',
            icon: _reloading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
            onPressed: _reloading
                ? null
                : () async {
                    setState(() => _reloading = true);
                    try {
                      await ref.read(subjectsProvider.notifier).loadSubjects();
                    } finally {
                      if (mounted) setState(() => _reloading = false);
                    }
                  },
          ),
        ],
      ),

      // 🔹 ÚNICO botón para crear materia
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showSubjectDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Nueva materia'),
      ),

      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            _buildStatsHeader(subjects),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildSearchField(),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: filtered.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final s = filtered[index];
                        return _SubjectCard(
                          subject: s,
                          onTap: () {
                            context.goNamed(
                              'subject_detail',
                              pathParameters: {'id': s.id},
                              extra: s,
                            );
                          },
                          onEdit: () => _showSubjectDialog(existing: s),
                          onDelete: () => _confirmDeleteSubject(s),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),

      // 👇 MENÚ INFERIOR IGUAL QUE EN DASHBOARD / CALENDARIO
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 1, // 0: Inicio, 1: Materias, 2: Calendario, 3: Perfil
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
              context.go(AppRouter.dashboard);
              break;
            case 1:
              // ya estamos en materias
              break;
            case 2:
              context.go(AppRouter.calendar);
              break;
            case 3:
              context.go(AppRouter.profile);
              break;
          }
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // FILTRO Y BUSCADOR
  // ---------------------------------------------------------------------------

  List<Subject> _applyFilter(List<Subject> subjects) {
    final q = _searchQuery.trim().toLowerCase();
    if (q.isEmpty) return subjects;

    return subjects.where((s) {
      final teacher = (s.teacher ?? '').toLowerCase();
      final schedule = (s.schedule ?? '').toLowerCase();
      return s.name.toLowerCase().contains(q) ||
          teacher.contains(q) ||
          schedule.contains(q);
    }).toList();
  }

  Widget _buildSearchField() {
    return TextField(
      decoration: const InputDecoration(
        prefixIcon: Icon(Icons.search),
        hintText: 'Buscar por nombre, docente u horario…',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      onChanged: (value) {
        setState(() => _searchQuery = value);
      },
    );
  }

  // ---------------------------------------------------------------------------
  // HEADER (banner azul)
  // ---------------------------------------------------------------------------

  Widget _buildStatsHeader(List<Subject> subjects) {
    final total = subjects.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.indigo.shade500,
              Colors.indigo.shade700,
            ],
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¡Hola, estudiante! 👋',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              'Tienes $total materia${total == 1 ? '' : 's'} registradas',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // ESTADO VACÍO (sin botón, solo texto)
  // ---------------------------------------------------------------------------

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.menu_book_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No tienes materias aún',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Usa el botón “Nueva materia” para agregar tu primera materia.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // CREAR / EDITAR / ELIMINAR
  // ---------------------------------------------------------------------------

  void _showSubjectDialog({Subject? existing}) {
    showDialog(
      context: context,
      builder: (context) => _SubjectDialog(
        existing: existing,
        onSave: (draft) async {
          final notifier = ref.read(subjectsProvider.notifier);

          if (existing == null) {
            await notifier.createSubject(draft);
          } else {
            await notifier.updateSubject(draft.copyWith(id: existing.id));
          }
        },
      ),
    );
  }

  Future<void> _confirmDeleteSubject(Subject subject) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar materia'),
        content: Text(
          '¿Seguro que deseas eliminar la materia "${subject.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(subjectsProvider.notifier).deleteSubject(subject.id);
    }
  }
}

// ---------------------------------------------------------------------------
// CARD DE MATERIA
// ---------------------------------------------------------------------------

class _SubjectCard extends StatelessWidget {
  final Subject subject;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _SubjectCard({
    required this.subject,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          color: subject.color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: subject.color.withValues(alpha: 0.2),
                child: Icon(Icons.school, color: subject.color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subject.teacher != null &&
                        subject.teacher!.trim().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        subject.teacher!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                    if (subject.schedule != null &&
                        subject.schedule!.trim().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        subject.schedule!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: subject.progress.clamp(0, 1),
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    onEdit();
                  } else if (value == 'delete') {
                    onDelete();
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'edit',
                    child: Text('Editar'),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text('Eliminar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// DIÁLOGO DE CREAR / EDITAR
// ---------------------------------------------------------------------------

class _SubjectDialog extends StatefulWidget {
  final Subject? existing;
  final Future<void> Function(Subject subject) onSave;

  const _SubjectDialog({
    required this.onSave,
    this.existing,
  });

  @override
  State<_SubjectDialog> createState() => _SubjectDialogState();
}

class _SubjectDialogState extends State<_SubjectDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _teacherController;
  late TextEditingController _scheduleController;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.existing?.name ?? '');
    _teacherController =
        TextEditingController(text: widget.existing?.teacher ?? '');
    _scheduleController =
        TextEditingController(text: widget.existing?.schedule ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _teacherController.dispose();
    _scheduleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;

    return AlertDialog(
      title: Text(isEdit ? 'Editar materia' : 'Nueva materia'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la materia',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingresa un nombre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _teacherController,
                decoration: const InputDecoration(
                  labelText: 'Docente (opcional)',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _scheduleController,
                decoration: const InputDecoration(
                  labelText: 'Horario (opcional)',
                  hintText: 'Ej. Lun y Mié 9:00–10:40',
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _saving ? null : _handleSave,
          child: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(isEdit ? 'Guardar cambios' : 'Crear'),
        ),
      ],
    );
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    final draft = Subject(
      id: widget.existing?.id ?? '',
      name: _nameController.text.trim(),
      teacher: _teacherController.text.trim().isEmpty
          ? null
          : _teacherController.text.trim(),
      schedule: _scheduleController.text.trim().isEmpty
          ? null
          : _scheduleController.text.trim(),
    );

    try {
      await widget.onSave(draft);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar materia: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
