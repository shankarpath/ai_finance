import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'database_service.dart';

/// Writes the full transaction history to a CSV file the user can share.
///
/// Raw SMS bodies are deliberately NOT exported: the CSV is meant to leave the
/// device (mail, Drive, spreadsheets) and the original messages may contain
/// account details beyond the masked last-4.
class ExportService {
  final AppDatabase _db;
  ExportService(this._db);

  static const _header = 'date,merchant,category,type,status,amount,'
      'payment_method,account_last4,reference_no,confidence,category_source,'
      'subscription';

  Future<File> exportCsv() async {
    final txns = await _db.allTransactions();
    final buffer = StringBuffer()..writeln(_header);
    for (final t in txns) {
      buffer.writeln([
        t.date.toIso8601String(),
        _field(t.merchantCanonical ?? t.merchant),
        _field(t.category),
        t.transactionType,
        t.status,
        t.amount.toStringAsFixed(2),
        _field(t.paymentMethod ?? ''),
        t.accountLast4 ?? '',
        _field(t.referenceNo ?? ''),
        '${t.confidence ?? ''}',
        t.categorySource ?? '',
        t.isSubscription ? 'yes' : 'no',
      ].join(','));
    }

    final dir = await getApplicationDocumentsDirectory();
    final stamp = DateTime.now().toIso8601String().split('T').first;
    final file = File(p.join(dir.path, 'transactions_$stamp.csv'));
    await file.writeAsString(buffer.toString());
    return file;
  }

  /// RFC-4180 quoting for values that contain a comma, quote, or newline.
  String _field(String v) {
    if (v.contains(',') || v.contains('"') || v.contains('\n')) {
      return '"${v.replaceAll('"', '""')}"';
    }
    return v;
  }
}
