import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../domain/learning.dart';

/// Serialized atomic writes keep the previous valid file as a recovery copy.
class LearningStore extends ChangeNotifier {
  final Directory directory;
  List<Learner> profiles = [];
  String? selectedId;
  String language = 'de';
  String? error;
  bool recovered = false;
  Future<void> _pending = Future.value();
  LearningStore(this.directory);
  bool get en => language == 'en';
  String tr(String de, String english) => en ? english : de;
  Learner? get current => profiles.where((p) => p.id == selectedId).firstOrNull;
  File get file => File('${directory.path}/learning-v1.json');
  File get backup => File('${directory.path}/learning-v1.backup.json');

  Future<void> load() async {
    await directory.create(recursive: true);
    for (final candidate in [file, backup]) {
      if (!await candidate.exists()) continue;
      try {
        final data =
            jsonDecode(await candidate.readAsString()) as Map<String, dynamic>;
        if (data['schema'] != 1) {
          throw const FormatException('Unsupported schema');
        }
        final parsed = (data['profiles'] as List)
            .map((p) => Learner.fromJson(Map<String, dynamic>.from(p as Map)))
            .toList();
        profiles = parsed;
        selectedId = data['selected'] as String?;
        language = data['language'] == 'en' ? 'en' : 'de';
        recovered = candidate.path == backup.path;
        error = null;
        // Preserve damaged source for diagnosis, rather than silently overwrite it.
        if (recovered && await file.exists()) {
          await file.rename(
            '${file.path}.damaged-${DateTime.now().millisecondsSinceEpoch}',
          );
        }
        notifyListeners();
        return;
      } catch (_) {
        error = 'load';
      }
    }
    notifyListeners();
  }

  Future<void> save() {
    final snapshot = jsonEncode({
      'schema': 1,
      'language': language,
      'selected': selectedId,
      'profiles': profiles.map((p) => p.toJson()).toList(),
    });
    _pending = _pending.then((_) async {
      try {
        await directory.create(recursive: true);
        final temp = File('${file.path}.tmp');
        await temp.writeAsString(snapshot, flush: true);
        if (await file.exists()) await file.copy(backup.path);
        await temp.rename(file.path);
        error = null;
      } catch (_) {
        error = 'save';
      }
      notifyListeners();
    });
    return _pending;
  }

  Future<void> get flushed => _pending;
  Future<void> setLanguage(String value) {
    language = value;
    notifyListeners();
    return save();
  }

  Future<void> select(String id) {
    if (!profiles.any((p) => p.id == id)) {
      throw ArgumentError('Unknown profile');
    }
    selectedId = id;
    notifyListeners();
    return save();
  }

  Future<void> add(String name) async {
    name = name.trim();
    if (name.isEmpty || name.length > 30) {
      throw ArgumentError('Name must contain 1–30 characters');
    }
    final id = '${DateTime.now().microsecondsSinceEpoch}-${profiles.length}';
    profiles.add(Learner(id, name));
    selectedId = id;
    notifyListeners();
    await save();
  }

  Future<void> rename(Learner p, String name) {
    name = name.trim();
    if (name.isEmpty || name.length > 30) {
      throw ArgumentError('Name must contain 1–30 characters');
    }
    p.name = name;
    notifyListeners();
    return save();
  }

  Future<void> remove(Learner p) async {
    profiles.removeWhere((x) => x.id == p.id);
    if (selectedId == p.id) selectedId = profiles.firstOrNull?.id;
    notifyListeners();
    await save();
    // Update backup too, so profile deletion does not leave an old recoverable profile.
    await save();
  }

  Future<bool> feed(Learner p, Level l) async {
    if (!p.unlocked.contains(l.id) || p.points < 5) return false;
    p.points -= 5;
    p.feedings[l.id] = (p.feedings[l.id] ?? 0) + 1;
    notifyListeners();
    await save();
    return true;
  }
}
