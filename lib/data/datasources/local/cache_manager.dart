import 'dart:convert';
import 'package:hive/hive.dart';

class CacheManager {
  static const String _boxName = 'cache';
  late Box<String> _box;

  Future<void> init() async {
    _box = await Hive.openBox<String>(_boxName);
  }

  Future<void> set<T>(
    String key,
    T value, {
    Duration duration = const Duration(minutes: 5),
  }) async {
    final expiryTime = DateTime.now().add(duration).millisecondsSinceEpoch;
    final cacheData = {
      'data': value,
      'expiry': expiryTime,
    };
    await _box.put(key, jsonEncode(cacheData));
  }

  T? get<T>(String key) {
    final cachedString = _box.get(key);
    if (cachedString == null) return null;

    try {
      final cacheData = jsonDecode(cachedString);
      final expiry = cacheData['expiry'] as int;

      if (DateTime.now().millisecondsSinceEpoch > expiry) {
        _box.delete(key);
        return null;
      }

      return cacheData['data'] as T;
    } catch (e) {
      return null;
    }
  }

  Future<void> delete(String key) async {
    await _box.delete(key);
  }

  Future<void> clear() async {
    await _box.clear();
  }

  bool has(String key) {
    final value = get(key);
    return value != null;
  }
}
