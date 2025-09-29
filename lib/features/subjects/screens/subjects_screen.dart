import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SubjectsScreen extends StatefulWidget {
  const SubjectsScreen({super.key});

  @override
  State<SubjectsScreen> createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends State<SubjectsScreen> {
  final List<Subject> _subjects = [
    Subject(
      id: '1',
      name: 'Matemáticas',
      color: Colors.blue,
      teacher: 'Prof. García',
      schedule: 'Lun, Mié, Vie - 8:00 AM',
      progress: 0.75,
    ),
    Subject(
      id: '2',
      name: 'Física',
      color: Colors.green,
      teacher: 'Prof. López',
      schedule: 'Mar, Jue - 10:00 AM',
      progress: 0.60,
    ),
    Subject(
      id: '3',
      name: 'Química',
      color: Colors.orange,
      teacher: 'Prof. Martínez',
      schedule: 'Lun, Mié - 2:00 PM',
      progress: 0.45,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Materias'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
      ),
      body: _subjects.isEmpty ? _buildEmptyState() : _buildSubjectsList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSubjectDialog(),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 1,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Materias',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendario',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/dashboard');
              break;
            case 1:
              // Ya estamos en materias
              break;
            case 2:
              // TODO: Implementar calendario
              break;
            case 3:
              context.go('/profile');
              break;
          }
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.school_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No tienes materias aún',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Agrega tu primera materia para comenzar\na organizar tus estudios',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => _showAddSubjectDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Agregar Materia'),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectsList() {
    return Column(
      children: [
        // Stats header
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary,
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_subjects.length}',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Materias activas',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.trending_up,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ],
          ),
        ),

        // Subjects list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _subjects.length,
            itemBuilder: (context, index) {
              final subject = _subjects[index];
              return _SubjectCard(
                subject: subject,
                onTap: () => _showSubjectDetails(subject),
                onEdit: () => _showEditSubjectDialog(subject),
                onDelete: () => _confirmDeleteSubject(subject),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showAddSubjectDialog() {
    showDialog(
      context: context,
      builder: (context) => _SubjectDialog(
        onSave: (subject) {
          setState(() {
            _subjects.add(subject);
          });
        },
      ),
    );
  }

  void _showEditSubjectDialog(Subject subject) {
    showDialog(
      context: context,
      builder: (context) => _SubjectDialog(
        subject: subject,
        onSave: (updatedSubject) {
          setState(() {
            final index = _subjects.indexWhere((s) => s.id == subject.id);
            if (index != -1) {
              _subjects[index] = updatedSubject;
            }
          });
        },
      ),
    );
  }

  void _confirmDeleteSubject(Subject subject) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Materia'),
        content: Text('¿Estás seguro de que quieres eliminar "${subject.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _subjects.removeWhere((s) => s.id == subject.id);
              });
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showSubjectDetails(Subject subject) {
    context.go('/subjects/${subject.id}', extra: subject);
  }
}

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
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
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
                    child: Icon(
                      Icons.book,
                      color: subject.color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subject.name,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          subject.teacher,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        onEdit();
                      } else if (value == 'delete') {
                        onDelete();
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit),
                            SizedBox(width: 8),
                            Text('Editar'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Eliminar', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    subject.schedule,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progreso',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        '${(subject.progress * 100).toInt()}%',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: subject.progress,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(subject.color),
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

class _SubjectDialog extends StatefulWidget {
  final Subject? subject;
  final Function(Subject) onSave;

  const _SubjectDialog({
    this.subject,
    required this.onSave,
  });

  @override
  State<_SubjectDialog> createState() => _SubjectDialogState();
}

class _SubjectDialogState extends State<_SubjectDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _teacherController;
  late TextEditingController _scheduleController;
  Color _selectedColor = Colors.blue;

  final List<Color> _colors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.red,
    Colors.teal,
    Colors.pink,
    Colors.amber,
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.subject?.name ?? '');
    _teacherController = TextEditingController(text: widget.subject?.teacher ?? '');
    _scheduleController = TextEditingController(text: widget.subject?.schedule ?? '');
    _selectedColor = widget.subject?.color ?? Colors.blue;
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
    return AlertDialog(
      title: Text(widget.subject == null ? 'Agregar Materia' : 'Editar Materia'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre de la materia',
                prefixIcon: Icon(Icons.book),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa el nombre';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _teacherController,
              decoration: const InputDecoration(
                labelText: 'Profesor',
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa el profesor';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _scheduleController,
              decoration: const InputDecoration(
                labelText: 'Horario',
                prefixIcon: Icon(Icons.schedule),
                hintText: 'Ej: Lun, Mié - 8:00 AM',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa el horario';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Color',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: _colors.map((color) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedColor = color;
                        });
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(8),
                          border: _selectedColor == color
                              ? Border.all(color: Colors.grey[800]!, width: 3)
                              : null,
                        ),
                        child: _selectedColor == color
                            ? const Icon(Icons.check, color: Colors.white)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _saveSubject,
          child: const Text('Guardar'),
        ),
      ],
    );
  }

  void _saveSubject() {
    if (!_formKey.currentState!.validate()) return;

    final subject = Subject(
      id: widget.subject?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      teacher: _teacherController.text,
      schedule: _scheduleController.text,
      color: _selectedColor,
      progress: widget.subject?.progress ?? 0.0,
    );

    widget.onSave(subject);
    Navigator.of(context).pop();
  }
}

class Subject {
  final String id;
  final String name;
  final String teacher;
  final String schedule;
  final Color color;
  final double progress;

  Subject({
    required this.id,
    required this.name,
    required this.teacher,
    required this.schedule,
    required this.color,
    required this.progress,
  });
}