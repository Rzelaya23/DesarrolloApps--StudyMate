import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mi_app/core/providers/theme_provider.dart';
import 'package:mi_app/core/router/app_router.dart';
import 'package:mi_app/features/profile/data/profile_service.dart';

// ⬇️ mismo provider que usas en el Dashboard
import 'package:mi_app/features/dashboard/providers/dashboard_stats_providers.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  ProfileDto? _profile;
  bool _loading = false;
  String? _error;

  // Datos de ejemplo del usuario (se sobreescriben con lo del backend)
  String userName = 'Roland Zelaya';
  String userEmail = 'rzelaya@estudiante.edu.sv';
  String userCareer = 'Ingeniería en Sistemas';

  // Eventos y horas siguen siendo dummy por ahora
  int totalEvents = 5;
  double studyHours = 24.5;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final service = ref.read(profileServiceProvider);
      final me = await service.getProfile();
      setState(() {
        _profile = me;
        userName = me.name;
        userEmail = me.email;
      });
    } catch (e) {
      setState(() {
        _error = 'Error cargando perfil: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showEditProfileDialog(),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollScrollViewWithError(
              error: _error,
              child: Column(
                children: [
                  _buildProfileHeader(),
                  const SizedBox(height: 16),
                  _buildStatsCards(),
                  const SizedBox(height: 16),
                  _buildConfigurationSection(),
                  const SizedBox(height: 16),
                  _buildAchievementsSection(),
                  const SizedBox(height: 16),
                  _buildActionButtons(),
                  const SizedBox(height: 100), // Espacio para bottom nav
                ],
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        key: const ValueKey('profile_bottom_nav'),
        type: BottomNavigationBarType.fixed,
        currentIndex: 3, // Perfil está en índice 3
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
          if (mounted) {
            switch (index) {
              case 0:
                context.go('/dashboard');
                break;
              case 1:
                context.go('/subjects');
                break;
              case 2:
                context.go('/calendar');
                break;
              case 3:
                // Ya estamos en perfil
                break;
            }
          }
        },
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: const Icon(
                Icons.person,
                size: 50,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Nombre
          Text(
            userName,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),

          // Email
          Text(
            userEmail,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
          ),
          const SizedBox(height: 4),

          // Carrera
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              userCareer,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  /// Stats (Materias / Eventos / Horas)
  /// Materias se toma del mismo provider que el Dashboard.
  Widget _buildStatsCards() {
    final subjectsCount = ref.watch(subjectsCountProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              icon: Icons.school,
              label: 'Materias',
              value: subjectsCount.toString(), // 👈 dinámico
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              icon: Icons.event,
              label: 'Eventos',
              value: totalEvents.toString(), // por ahora fijo
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              icon: Icons.access_time,
              label: 'Horas',
              value: '${studyHours.toInt()}h',
              color: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Card(
      key: ValueKey('stat_card_$label'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigurationSection() {
    final isDark =
        ref.watch(themeNotifierProvider).isDarkmode;

    return Card(
      key: const ValueKey('config_section_card'),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Configuración',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          _buildConfigTile(
            icon: Icons.brightness_6,
            title: 'Tema',
            subtitle: isDark ? 'Oscuro' : 'Claro',
            onTap: () {
              ref.read(themeNotifierProvider.notifier).toggleDarkmode();
            },
          ),
          _buildConfigTile(
            icon: Icons.notifications,
            title: 'Notificaciones',
            subtitle: 'Activadas',
            onTap: () => _showNotificationSettings(),
          ),
          _buildConfigTile(
            icon: Icons.language,
            title: 'Idioma',
            subtitle: 'Español',
            onTap: () => _showLanguageSettings(),
          ),
          _buildConfigTile(
            icon: Icons.security,
            title: 'Privacidad',
            subtitle: 'Configurar',
            onTap: () => _showPrivacySettings(),
          ),
        ],
      ),
    );
  }

  Widget _buildConfigTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      key: ValueKey('config_tile_$title'),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
          size: 20,
        ),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildAchievementsSection() {
    return Card(
      key: const ValueKey('achievements_section_card'),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.emoji_events,
                  color: Colors.amber,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Logros',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color:
                    Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.2),
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.workspace_premium,
                    size: 48,
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Próximamente',
                    style:
                        Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'El sistema de logros llegará pronto',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              key: const ValueKey('edit_profile_button'),
              onPressed: () => _showEditProfileDialog(),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('Editar Perfil'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              key: const ValueKey('logout_button'),
              onPressed: () => _confirmLogout(),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                foregroundColor: Colors.red,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout),
                  SizedBox(width: 8),
                  Text('Cerrar Sesión'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog() {
    if (_profile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cargando perfil, inténtalo en un momento.')),
      );
      return;
    }
    if (!mounted) return;

    final nameController = TextEditingController(text: userName);
    final emailController = TextEditingController(text: userEmail);
    final careerController = TextEditingController(text: userCareer);
    final avatarController =
        TextEditingController(text: _profile?.avatarUrl ?? '');
    final tzController = TextEditingController(text: _profile?.timezone ?? '');

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Editar Perfil'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre completo',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Email (solo lectura)',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: avatarController,
                decoration: const InputDecoration(
                  labelText: 'Avatar URL',
                  prefixIcon: Icon(Icons.image),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: tzController,
                decoration: const InputDecoration(
                  labelText: 'Zona horaria',
                  prefixIcon: Icon(Icons.schedule),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: careerController,
                decoration: const InputDecoration(
                  labelText: 'Carrera',
                  prefixIcon: Icon(Icons.school),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final service = ref.read(profileServiceProvider);
                final updated = await service.updateProfile(
                  UpdateProfilePayload(
                    name: nameController.text,
                    avatarUrl: avatarController.text.isEmpty
                        ? null
                        : avatarController.text,
                    timezone:
                        tzController.text.isEmpty ? null : tzController.text,
                  ),
                );
                if (!mounted) return;
                setState(() {
                  _profile = updated;
                  userName = updated.name;
                  userEmail = updated.email;
                });
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Perfil actualizado')),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error al actualizar: $e')),
                );
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showNotificationSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Configuración de notificaciones próximamente'),
      ),
    );
  }

  void _showLanguageSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Configuración de idioma próximamente'),
      ),
    );
  }

  void _showPrivacySettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Configuración de privacidad próximamente'),
      ),
    );
  }

  void _confirmLogout() {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content:
            const Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.go(AppRouter.login);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }
}

/// Wrapper sencillo para mostrar error arriba del contenido si existe.
class SingleChildScrollScrollViewWithError extends StatelessWidget {
  final String? error;
  final Widget child;

  const SingleChildScrollScrollViewWithError({
    super.key,
    required this.error,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          if (error != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: MaterialBanner(
                content: Text(error!),
                backgroundColor: Colors.red.withOpacity(0.1),
                leading: const Icon(Icons.error, color: Colors.red),
                actions: [
                  TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context)
                          .hideCurrentMaterialBanner();
                    },
                    child: const Text('Cerrar'),
                  ),
                ],
              ),
            ),
          child,
        ],
      ),
    );
  }
}
