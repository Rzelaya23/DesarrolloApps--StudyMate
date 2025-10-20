import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mi_app/features/auth/screens/login_screen.dart';
import 'package:mi_app/features/auth/screens/register_screen.dart';
import 'package:mi_app/features/auth/screens/splash_screen.dart';
import 'package:mi_app/features/dashboard/screens/dashboard_screen.dart';
import 'package:mi_app/features/subjects/screens/subjects_screen.dart';
import 'package:mi_app/features/subjects/screens/subject_detail_screen.dart';
import 'package:mi_app/features/calendar/views/calendar_screen.dart';
import 'package:mi_app/features/profile/screens/profile_screen.dart';
import 'package:mi_app/features/ai_chat/ui/ai_chat_screen.dart'; 
import 'package:mi_app/features/planner/ui/planner_screen.dart';

class AppRouter {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String dashboard = '/dashboard';
  static const String subjects = '/subjects';
  static const String calendar = '/calendar';
  static const String profile = '/profile';
  static const String ai = '/ai';
  static const String planner = '/planner';


  static final GoRouter router = GoRouter(
    initialLocation: splash,
    routes: [
      // Splash Screen
      GoRoute(
        path: splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Auth Routes
      GoRoute(
        path: login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: register,
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // Calendar routes
      GoRoute(
        path: calendar,
        name: 'calendar',
        builder: (context, state) => const CalendarScreen(),
      ),

      // Profile routes
      GoRoute(
        path: profile,
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),

      // Main App Routes
      GoRoute(
        path: dashboard,
        name: 'dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: subjects,
        name: 'subjects',
        builder: (context, state) => const SubjectsScreen(),
      ),
      GoRoute(
        path: '/subjects/:id',
        name: 'subject_detail',
        builder: (context, state) {
          final extra = state.extra;
          if (extra is Subject) {
            return SubjectDetailScreen(subject: extra);
          }
          return Scaffold(
            appBar: AppBar(title: const Text('Materia')),
            body: const Center(child: Text('Materia no encontrada')),
          );
        },
      ),
      GoRoute(
        path: '/ai',
        name: 'ai',
        builder: (context, state) => const AiChatScreen(),
      ),
      GoRoute(
        path: planner,
        name: 'planner',
        builder: (ctx, st) => const PlannerScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Página no encontrada',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'La ruta "${state.uri}" no existe',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(splash),
              child: const Text('Volver al inicio'),
            ),
          ],
        ),
      ),
    ),
  );
}