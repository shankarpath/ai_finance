import 'package:flutter/material.dart';

import '../services/auth_service.dart';

/// Gates the whole app behind device biometrics / credentials.
///
/// If the device has no security set up (`isSupported() == false`) the gate
/// stays open rather than locking the user out.
class AppLockGate extends StatefulWidget {
  final Widget child;
  const AppLockGate({super.key, required this.child});

  @override
  State<AppLockGate> createState() => _AppLockGateState();
}

enum _LockState { checking, locked, unlocked }

class _AppLockGateState extends State<AppLockGate> {
  final _auth = AuthService();
  _LockState _state = _LockState.checking;
  bool _authInProgress = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final supported = await _auth.isSupported();
    if (!mounted) return;
    if (!supported) {
      setState(() => _state = _LockState.unlocked);
      return;
    }
    setState(() => _state = _LockState.locked);
    _unlock();
  }

  Future<void> _unlock() async {
    if (_authInProgress) return;
    _authInProgress = true;
    final ok = await _auth.authenticate();
    _authInProgress = false;
    if (!mounted) return;
    if (ok) setState(() => _state = _LockState.unlocked);
  }

  @override
  Widget build(BuildContext context) {
    switch (_state) {
      case _LockState.unlocked:
        return widget.child;
      case _LockState.checking:
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      case _LockState.locked:
        return _LockedView(onUnlock: _unlock);
    }
  }
}

class _LockedView extends StatelessWidget {
  final VoidCallback onUnlock;
  const _LockedView({required this.onUnlock});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock, size: 64, color: theme.colorScheme.primary),
            const SizedBox(height: 20),
            Text('App locked', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('Authenticate to view your finances',
                style: theme.textTheme.bodyMedium),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onUnlock,
              icon: const Icon(Icons.fingerprint),
              label: const Text('Unlock'),
            ),
          ],
        ),
      ),
    );
  }
}
