import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mi_app/features/subjects/providers/subjects_providers.dart';
import 'package:mi_app/features/subjects/models/subject.dart';

/// Devuelve cuántas materias hay cargadas en subjectsProvider.
final subjectsCountProvider = Provider<int>((ref) {
  final Map<String, Subject> subjectsMap = ref.watch(subjectsProvider);
  return subjectsMap.length;
});
