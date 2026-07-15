import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/app_providers.dart';
import 'screens/home_shell.dart';
import 'screens/lock_screen.dart';
import 'screens/permission_screen.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final notifications = NotificationService();
  await notifications.init();
  runApp(
    ProviderScope(
      overrides: [
        notificationServiceProvider.overrideWithValue(notifications),
      ],
      child: const AiFinanceApp(),
    ),
  );
}

class AiFinanceApp extends StatelessWidget {
  const AiFinanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FinCoach',
      debugShowCheckedModeBanner: false,
      // Dark-first: dark is the brand look, light derives from the same tokens.
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.dark,
      // Biometric lock wraps everything; inside it, the SMS-permission gate.
      home: const AppLockGate(child: _PermissionGate()),
    );
  }
}

/// Routes between the permission screen and the main app based on whether
/// SMS access has been granted.
class _PermissionGate extends ConsumerWidget {
  const _PermissionGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(permissionProvider).status;
    if (status == PermissionStatus.granted) {
      return const HomeShell();
    }
    return const PermissionScreen();
  }
}
