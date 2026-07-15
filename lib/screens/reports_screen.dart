import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gpt_markdown/gpt_markdown.dart';

import '../providers/app_providers.dart';
import '../services/database_service.dart';
import '../theme/app_theme.dart';
import '../widgets/coach_widgets.dart';

/// Archive of the coach's weekly report cards and monthly reports.
class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reports = ref.watch(reportsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final messenger = ScaffoldMessenger.of(context);
          messenger.showSnackBar(
              const SnackBar(content: Text('Coach is writing this week\'s report…')));
          final report =
              await ref.read(coachServiceProvider).weeklyReport();
          ref.invalidate(reportsProvider);
          if (report == null) {
            messenger.showSnackBar(const SnackBar(
                content: Text(
                    'Could not generate — check your Gemini key in Settings.')));
          }
        },
        icon: const Icon(Icons.auto_awesome),
        label: const Text('This week\'s card'),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: _MonthProgress(),
          ),
          Expanded(
            child: reports.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Could not load reports: $e')),
              data: (list) => list.isEmpty
                  ? const _Empty()
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) => _ReportTile(report: list[i]),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Proactive AI "how this month is going" line above the report archive.
class _MonthProgress extends ConsumerWidget {
  const _MonthProgress();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CoachInsightCard(
      insight: ref.watch(monthProgressProvider),
      icon: Icons.insights_outlined,
      accent: AppTheme.sky,
      emptyText: 'Add your Gemini key in Settings for a live read on this '
          'month\'s spending.',
    );
  }
}

class _ReportTile extends StatelessWidget {
  final AiInsight report;
  const _ReportTile({required this.report});

  /// Pulls "Grade: B+" off the first line when present.
  String? get _grade {
    final m = RegExp(r'^Grade:\s*([A-F][+\-]?)', caseSensitive: false)
        .firstMatch(report.content.trim());
    return m?.group(1);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWeekly = report.kind == 'weekly';
    final grade = _grade;

    return Panel(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => _ReportDetail(report: report, grade: grade))),
      padding: const EdgeInsets.all(16),
      child: Row(children: [
        if (grade != null)
          Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _gradeColor(grade).withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(grade,
                style: theme.textTheme.titleMedium?.copyWith(
                    color: _gradeColor(grade), fontWeight: FontWeight.w900)),
          )
        else
          Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppTheme.violet.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.calendar_month, color: AppTheme.violet),
          ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(isWeekly ? 'Weekly report card' : 'Monthly report',
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w800)),
            Text(report.periodKey, style: theme.textTheme.bodySmall),
          ]),
        ),
        const Icon(Icons.chevron_right, size: 18),
      ]),
    );
  }

  static Color _gradeColor(String grade) {
    switch (grade[0].toUpperCase()) {
      case 'A':
        return AppTheme.mint;
      case 'B':
        return AppTheme.sky;
      case 'C':
        return AppTheme.amber;
      default:
        return AppTheme.coral;
    }
  }
}

class _ReportDetail extends StatelessWidget {
  final AiInsight report;
  final String? grade;
  const _ReportDetail({required this.report, this.grade});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Strip the grade line — it's rendered as a chip instead.
    var body = report.content.trim();
    if (grade != null) {
      body = body.replaceFirst(RegExp(r'^Grade:.*\n?'), '').trim();
    }
    return Scaffold(
      appBar: AppBar(
          title: Text(report.kind == 'weekly'
              ? 'Week ${report.periodKey}'
              : 'Month ${report.periodKey}')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (grade != null)
            Panel(
              gradient: AppTheme.heroGradient,
              child: Row(children: [
                Text('Grade',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(color: Colors.white70)),
                const Spacer(),
                Text(grade!,
                    style: theme.textTheme.displaySmall?.copyWith(
                        color: _ReportTile._gradeColor(grade!),
                        fontWeight: FontWeight.w900)),
              ]),
            ),
          const SizedBox(height: 16),
          GptMarkdown(body,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.5)),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.receipt_long,
              size: 52, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 12),
          const Text('No reports yet',
              style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          const Text(
            'Weekly report cards appear every Sunday; tap the button below '
            'to generate this week\'s now.',
            textAlign: TextAlign.center,
          ),
        ]),
      ),
    );
  }
}
