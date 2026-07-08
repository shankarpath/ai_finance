import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_providers.dart';

/// Shown until SMS permission is granted. Explains *why* the app needs SMS
/// access and what stays on-device — important for a finance app.
class PermissionScreen extends ConsumerWidget {
  const PermissionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(permissionProvider);
    final theme = Theme.of(context);
    final denied = state.status == PermissionStatus.denied;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.account_balance_wallet,
                  size: 72, color: theme.colorScheme.primary),
              const SizedBox(height: 24),
              Text('Read your bank SMS',
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text(
                'The app reads bank transaction SMS to build your spending '
                'dashboard automatically.',
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              const _PrivacyPoint(
                icon: Icons.lock_outline,
                text: 'Everything is processed and stored on this phone.',
              ),
              const _PrivacyPoint(
                icon: Icons.cloud_off,
                text: 'No messages or data are sent to any server.',
              ),
              const _PrivacyPoint(
                icon: Icons.password,
                text: 'No banking passwords or OTPs are ever used.',
              ),
              const SizedBox(height: 32),
              if (denied)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    'Permission was denied. Enable SMS access in system '
                    'settings to continue.',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: theme.colorScheme.error),
                  ),
                ),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: state.syncing
                      ? null
                      : () => ref.read(permissionProvider.notifier).requestAndSync(),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: state.syncing
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(denied ? 'Try again' : 'Allow SMS access'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrivacyPoint extends StatelessWidget {
  final IconData icon;
  final String text;
  const _PrivacyPoint({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: Theme.of(context).textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
