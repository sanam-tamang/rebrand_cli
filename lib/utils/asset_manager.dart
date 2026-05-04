import 'dart:convert';
import 'dart:io';

enum AssetType {
  launcherIcon,
  splashScreen,
}

class AssetManager {
  static const String manifestFile = '.rebrand_manifest.json';

  /// Removes a top-level key (and its content) from pubspec.yaml
  static Future<void> removeFromPubspec(String key) async {
    final file = File('pubspec.yaml');
    if (!file.existsSync()) return;

    final lines = await file.readAsLines();
    final newLines = <String>[];
    bool skipping = false;
    int? indentLevel;

    for (final line in lines) {
      if (line.trim().startsWith('$key:')) {
        skipping = true;
        // Calculate indent level to know when the block ends
        indentLevel = _getIndentLevel(line);
        continue;
      }

      if (skipping) {
        if (line.trim().isEmpty) {
          newLines.add(line);
          continue;
        }
        final currentIndent = _getIndentLevel(line);
        if (indentLevel != null && currentIndent > indentLevel) {
          // Still inside the block
          continue;
        } else {
          // Block ended
          skipping = false;
        }
      }

      newLines.add(line);
    }

    await file.writeAsString(newLines.join('\n'));
  }

  static int _getIndentLevel(String line) {
    return line.length - line.trimLeft().length;
  }

  /// Track a generated asset in the manifest
  static Future<void> trackAsset(AssetType type, String path) async {
    final manifest = await _readManifest();
    final assets = manifest['assets'] as List<dynamic>? ?? [];
    
    // Avoid duplicates
    if (!assets.any((a) => a['path'] == path)) {
      assets.add({
        'type': type.name,
        'path': path,
        'timestamp': DateTime.now().toIso8601String(),
      });
    }

    manifest['assets'] = assets;
    await _writeManifest(manifest);
  }

  /// Get assets of a specific type
  static Future<List<String>> getAssets(AssetType type) async {
    final manifest = await _readManifest();
    final assets = manifest['assets'] as List<dynamic>? ?? [];
    return assets
        .where((a) => a['type'] == type.name)
        .map((a) => a['path'] as String)
        .toList();
  }

  /// Remove all assets of a specific type and update manifest
  static Future<void> removeAssetType(AssetType type) async {
    final manifest = await _readManifest();
    final assets = manifest['assets'] as List<dynamic>? ?? [];
    final toRemove = assets.where((a) => a['type'] == type.name).toList();
    final toKeep = assets.where((a) => a['type'] != type.name).toList();

    for (final asset in toRemove) {
      final file = File(asset['path']);
      if (file.existsSync()) {
        file.deleteSync();
      }
    }

    manifest['assets'] = toKeep;
    if (toKeep.isEmpty) {
      await clearManifest();
    } else {
      await _writeManifest(manifest);
    }
  }

  static Future<void> clearManifest() async {
    final file = File(manifestFile);
    if (file.existsSync()) {
      await file.delete();
    }
  }

  static Future<Map<String, dynamic>> _readManifest() async {
    final file = File(manifestFile);
    if (!file.existsSync()) return {'assets': []};
    try {
      final content = await file.readAsString();
      return jsonDecode(content) as Map<String, dynamic>;
    } catch (_) {
      return {'assets': []};
    }
  }

  static Future<void> _writeManifest(Map<String, dynamic> manifest) async {
    final file = File(manifestFile);
    const encoder = JsonEncoder.withIndent('  ');
    await file.writeAsString(encoder.convert(manifest));
  }
}
