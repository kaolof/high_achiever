// Bridges a [TokenBackup] to/from a JSON file the user controls: export via
// the system share sheet, import via the file picker. Keeping the plugin
// plumbing here leaves the codec (domain) and repository free of platform deps.
import 'dart:convert';
import 'dart:io';
import 'dart:ui' show Rect;

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../domain/token_backup.dart';
import '../domain/token_date.dart';

class TokenBackupService {
  static const _exportPrefix = 'high_achiever_tokens_';

  /// Writes [backup] to a temp `.json` file and opens the share sheet so the
  /// user can save it to Drive / email it to themselves / store it in Files —
  /// somewhere that survives uninstalling the app.
  ///
  /// [sharePositionOrigin] must be provided on iPad: the share sheet is a
  /// popover there and share_plus throws without an anchor rect. It's ignored
  /// on other platforms.
  Future<void> exportToShare(
    TokenBackup backup, {
    required DateTime now,
    Rect? sharePositionOrigin,
  }) async {
    final json = encodeTokenBackup(backup, exportedAt: now);
    final dir = await getTemporaryDirectory();
    // Best-effort: drop any previous export so temp files don't accumulate.
    await _purgeOldExports(dir);
    final file = File(p.join(dir.path, '$_exportPrefix${_stamp(now)}.json'));
    await file.writeAsString(json);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'application/json')],
        subject: 'High Achiever — tokens backup',
        sharePositionOrigin: sharePositionOrigin,
      ),
    );
  }

  /// Opens the file picker and decodes the chosen backup. Returns null if the
  /// user cancels. Throws [TokenBackupFormatException] on an unreadable or
  /// invalid file.
  Future<TokenBackup?> pickAndDecode() async {
    final result = await FilePicker.pickFiles(withData: true);
    if (result == null || result.files.isEmpty) return null;
    final picked = result.files.single;
    final bytes =
        picked.bytes ??
        (picked.path != null ? await File(picked.path!).readAsBytes() : null);
    if (bytes == null) {
      throw const TokenBackupFormatException('Could not read the chosen file.');
    }
    final String text;
    try {
      text = utf8.decode(bytes);
    } on FormatException {
      // Honour pickAndDecode's contract: an unreadable file surfaces as a
      // TokenBackupFormatException, not a bare FormatException.
      throw const TokenBackupFormatException('The file is not readable text.');
    }
    return decodeTokenBackup(text);
  }

  /// Removes any previously exported backup files left in the temp directory.
  Future<void> _purgeOldExports(Directory dir) async {
    try {
      await for (final entry in dir.list()) {
        if (entry is File && p.basename(entry.path).startsWith(_exportPrefix)) {
          try {
            await entry.delete();
          } catch (_) {
            // A file still held by a previous share is fine to skip.
          }
        }
      }
    } catch (_) {
      // Cleanup is best-effort; never let it block an export.
    }
  }

  /// "20260711_1430" — filesystem-safe and sorts chronologically. Reuses
  /// [dayKey] for the date portion so day formatting has a single source.
  String _stamp(DateTime t) =>
      '${dayKey(t).replaceAll('-', '')}_'
      '${t.hour.toString().padLeft(2, '0')}'
      '${t.minute.toString().padLeft(2, '0')}';
}
