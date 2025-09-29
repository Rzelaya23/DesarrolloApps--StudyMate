import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mi_app/features/subjects/screens/subjects_screen.dart';

class SubjectDetailScreen extends StatefulWidget {
  final Subject subject;
  const SubjectDetailScreen({super.key, required this.subject});

  @override
  State<SubjectDetailScreen> createState() => _SubjectDetailScreenState();
}

class _SubjectDetailScreenState extends State<SubjectDetailScreen> {
  // Estado local
  final _descriptionController = TextEditingController();
  final Set<int> _selectedDays = {}; // 1..7 -> Lun..Dom
  final List<Unit> _units = [];

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.subject.color;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subject.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/subjects'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Encabezado con info rápida
            _HeaderCard(subject: widget.subject),
            const SizedBox(height: 16),

            // Botón para asignar días de clase
            _buildClassDaysCard(color),
            const SizedBox(height: 16),

            // Descripción general
            _buildDescriptionCard(color),
            const SizedBox(height: 16),

            // Unidades
            _buildUnitsSection(color),
          ],
        ),
      ),
    );
  }

  Widget _buildClassDaysCard(Color color) {
    final dayNames = const ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.event_available, color: color),
                const SizedBox(width: 8),
                Text(
                  'Días de clase',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _openDaysPicker,
                  icon: const Icon(Icons.edit_calendar),
                  label: const Text('Asignar días'),
                )
              ],
            ),
            const SizedBox(height: 8),
            if (_selectedDays.isEmpty)
              Text(
                'Aún no has asignado días de clase',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              )
            else
              Wrap(
                spacing: 8,
                children: (_selectedDays.toList()..sort())
                    .map((d) => Chip(label: Text(dayNames[d - 1])))
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }

  void _openDaysPicker() {
    final dayNames = const ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
    final tempSelected = {..._selectedDays};

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.edit_calendar),
                      const SizedBox(width: 8),
                      Text('Selecciona los días', style: Theme.of(context).textTheme.titleMedium),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      )
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(7, (index) {
                      final dayIndex = index + 1; // 1..7
                      final selected = tempSelected.contains(dayIndex);
                      return FilterChip(
                        label: Text(dayNames[index]),
                        selected: selected,
                        onSelected: (val) {
                          setModalState(() {
                            if (val) {
                              tempSelected.add(dayIndex);
                            } else {
                              tempSelected.remove(dayIndex);
                            }
                          });
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() => _selectedDays
                          ..clear()
                          ..addAll(tempSelected));
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.save),
                      label: const Text('Guardar días'),
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDescriptionCard(Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.description_outlined, color: color),
                const SizedBox(width: 8),
                Text(
                  'Descripción general',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              maxLines: null,
              minLines: 3,
              decoration: const InputDecoration(
                hintText: 'Describe los objetivos, contenidos y forma de evaluación de la materia...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Descripción guardada')),
                  );
                },
                icon: const Icon(Icons.check),
                label: const Text('Guardar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnitsSection(Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.view_module_outlined, color: color),
            const SizedBox(width: 8),
            Text('Unidades', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: _addUnitDialog,
              icon: const Icon(Icons.add),
              label: const Text('Agregar unidad'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_units.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Aún no hay unidades. Agrega tu primera unidad para organizar temas y materiales.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Column(
            children: _units
                .map((u) => _UnitCard(
                      unit: u,
                      onAddTopic: () => _addTopicDialog(u),
                      onAddFile: () => _showUploadDesign(u),
                      onDelete: () => setState(() => _units.remove(u)),
                    ))
                .toList(),
          ),
      ],
    );
  }

  void _addUnitDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nueva unidad'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Título de la unidad',
            prefixIcon: Icon(Icons.title),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isEmpty) return;
              setState(() {
                _units.add(Unit(id: DateTime.now().millisecondsSinceEpoch.toString(), title: controller.text.trim()));
              });
              Navigator.pop(context);
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  void _addTopicDialog(Unit unit) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar tema'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Nombre del tema',
            prefixIcon: Icon(Icons.topic_outlined),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isEmpty) return;
              setState(() {
                unit.topics.add(controller.text.trim());
              });
              Navigator.pop(context);
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  void _showUploadDesign(Unit unit) {
    // Solo diseño: mostramos bottom sheet con opciones simuladas
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.upload_file),
                const SizedBox(width: 8),
                Text('Subir archivo a "${unit.title}"', style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                )
              ],
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
              title: const Text('Archivo PDF'),
              subtitle: const Text('Seleccionar desde el dispositivo'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Diseño de subida de archivos (PDF/TXT) — por implementar')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.description, color: Colors.blueGrey),
              title: const Text('Archivo de texto'),
              subtitle: const Text('Seleccionar desde el dispositivo'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Diseño de subida de archivos (PDF/TXT) — por implementar')),
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final Subject subject;
  const _HeaderCard({required this.subject});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: subject.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.book, color: subject.color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subject.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.person, size: 16),
                          const SizedBox(width: 4),
                          Text(subject.teacher, style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Progreso', style: Theme.of(context).textTheme.bodySmall),
                Text('${(subject.progress * 100).toInt()}%', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 6),
            LinearProgressIndicator(
              value: subject.progress,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(subject.color),
            ),
          ],
        ),
      ),
    );
  }
}

class Unit {
  final String id;
  final String title;
  final List<String> topics;
  final List<Attachment> files;

  Unit({
    required this.id,
    required this.title,
    List<String>? topics,
    List<Attachment>? files,
  })  : topics = topics ?? [],
        files = files ?? [];
}

class Attachment {
  final String id;
  final String name;
  final String type; // 'pdf' | 'txt'

  Attachment({required this.id, required this.name, required this.type});
}

class _UnitCard extends StatelessWidget {
  final Unit unit;
  final VoidCallback onAddTopic;
  final VoidCallback onAddFile; // Diseño solamente
  final VoidCallback onDelete;

  const _UnitCard({
    required this.unit,
    required this.onAddTopic,
    required this.onAddFile,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    unit.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (v) {
                    if (v == 'delete') onDelete();
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'delete', child: Text('Eliminar unidad')),
                  ],
                )
              ],
            ),
            const SizedBox(height: 12),
            // Temas
            Text('Temas', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 8),
            if (unit.topics.isEmpty)
              Text('Aún no hay temas agregados', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]))
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: unit.topics.map((t) => Chip(label: Text(t))).toList(),
              ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: onAddTopic,
                icon: const Icon(Icons.add),
                label: const Text('Agregar tema'),
              ),
            ),
            const SizedBox(height: 16),
            // Archivos
            Text('Materiales (PDF/TXT)', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 8),
            if (unit.files.isEmpty)
              Text('Aún no hay archivos cargados', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]))
            else
              Column(
                children: unit.files
                    .map((f) => ListTile(
                          leading: Icon(
                            f.type == 'pdf' ? Icons.picture_as_pdf : Icons.description,
                            color: f.type == 'pdf' ? Colors.red : Colors.blueGrey,
                          ),
                          title: Text(f.name),
                          subtitle: Text(f.type.toUpperCase()),
                          trailing: const Icon(Icons.more_vert),
                        ))
                    .toList(),
              ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: onAddFile,
                icon: const Icon(Icons.upload_file),
                label: const Text('Subir archivo (PDF/TXT)'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
