import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../providers/app_providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _keyController = TextEditingController();
  bool _obscure = true;
  bool _consent = false;
  bool _hasSavedKey = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final s = ref.read(settingsServiceProvider);
    final key = await s.getApiKey();
    final consent = await s.hasConsent();
    if (!mounted) return;
    setState(() {
      _hasSavedKey = key != null;
      _consent = consent;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  Future<void> _saveKey() async {
    final text = _keyController.text.trim();
    if (text.isEmpty) return;
    await ref.read(settingsServiceProvider).setApiKey(text);
    ref.invalidate(aiReadyProvider);
    _keyController.clear();
    if (!mounted) return;
    setState(() => _hasSavedKey = true);
    _snack('API key saved securely.');
  }

  Future<void> _clearKey() async {
    await ref.read(settingsServiceProvider).clearApiKey();
    ref.invalidate(aiReadyProvider);
    if (!mounted) return;
    setState(() => _hasSavedKey = false);
    _snack('API key removed.');
  }

  Future<void> _setConsent(bool value) async {
    await ref.read(settingsServiceProvider).setConsent(value);
    ref.invalidate(aiReadyProvider);
    if (!mounted) return;
    setState(() => _consent = value);
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  bool _reprocessing = false;
  bool _exporting = false;

  Future<void> _exportCsv() async {
    setState(() => _exporting = true);
    try {
      final file = await ref.read(exportServiceProvider).exportCsv();
      await SharePlus.instance.share(ShareParams(
        files: [XFile(file.path, mimeType: 'text/csv')],
        subject: 'Transaction export',
      ));
    } catch (_) {
      if (mounted) _snack('Export failed.');
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _reprocess() async {
    setState(() => _reprocessing = true);
    _snack('Reprocessing transactions…');
    try {
      await ref.read(transactionRepositoryProvider).reprocessAll();
      if (mounted) _snack('Done — merchants normalized and re-categorized.');
    } catch (_) {
      if (mounted) _snack('Reprocess failed.');
    } finally {
      if (mounted) setState(() => _reprocessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('AI Assistant', style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            'The assistant uses Google Gemini. Bring your own free API key from '
            'Google AI Studio (aistudio.google.com/apikey).',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),

          // API key field
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _keyController,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    labelText:
                        _hasSavedKey ? 'Replace API key' : 'Gemini API key',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                          _obscure ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(onPressed: _saveKey, child: const Text('Save')),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                _hasSavedKey ? Icons.check_circle : Icons.info_outline,
                size: 18,
                color: _hasSavedKey ? Colors.green : theme.disabledColor,
              ),
              const SizedBox(width: 6),
              Text(_hasSavedKey ? 'Key stored securely' : 'No key stored yet',
                  style: theme.textTheme.bodySmall),
              const Spacer(),
              if (_hasSavedKey)
                TextButton(onPressed: _clearKey, child: const Text('Remove')),
            ],
          ),
          const Divider(height: 32),

          // Consent
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Enable cloud AI'),
            subtitle: const Text(
                'Required to use the AI Chat. You can turn this off anytime.'),
            value: _consent,
            onChanged: _setConsent,
          ),
          const SizedBox(height: 12),

          // Data disclosure
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.privacy_tip_outlined, size: 18),
                    const SizedBox(width: 6),
                    Text('What leaves your device',
                        style: theme.textTheme.titleSmall),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'When you ask the assistant a question, the app sends a '
                  'summary to Google Gemini:\n'
                  '•  Category totals and merchant names\n'
                  '•  Transaction amounts and dates\n\n'
                  'It never sends: your SMS text, account numbers, or balances. '
                  'Nothing is sent unless you ask a question.',
                ),
              ],
            ),
          ),

          const Divider(height: 32),
          Text('Data', style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            'Re-run the latest parsing, merchant normalization and '
            'categorization over all stored transactions.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _reprocessing ? null : _reprocess,
            icon: _reprocessing
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.auto_fix_high),
            label: const Text('Reprocess transactions'),
          ),
          const SizedBox(height: 16),
          Text(
            'Export every transaction as a CSV file (amounts, merchants, '
            'categories, statuses — never the raw SMS text).',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _exporting ? null : _exportCsv,
            icon: _exporting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.ios_share),
            label: const Text('Export data (CSV)'),
          ),
        ],
      ),
    );
  }
}
