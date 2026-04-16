import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/family_profile.dart';
import '../models/parent_profile.dart';
import '../scoring/municipality.dart';

/// flutter_secure_storage を使った暗号化ストレージラッパー
class SecureStorage {
  SecureStorage._();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  // ストレージキー
  static const _keyFather = 'father_profile';
  static const _keyMother = 'mother_profile';
  static const _keyFamily = 'family_profile';
  static const _keyMunicipality = 'selected_municipality';

  // ---------------------------------------------------------------------------
  // 父プロファイル
  // ---------------------------------------------------------------------------

  static Future<void> saveFather(ParentProfile profile) async {
    await _storage.write(
      key: _keyFather,
      value: jsonEncode(profile.toJson()),
    );
  }

  static Future<ParentProfile> loadFather() async {
    final raw = await _storage.read(key: _keyFather);
    if (raw == null) return const ParentProfile.initial();
    return ParentProfile.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );
  }

  // ---------------------------------------------------------------------------
  // 母プロファイル
  // ---------------------------------------------------------------------------

  static Future<void> saveMother(ParentProfile profile) async {
    await _storage.write(
      key: _keyMother,
      value: jsonEncode(profile.toJson()),
    );
  }

  static Future<ParentProfile> loadMother() async {
    final raw = await _storage.read(key: _keyMother);
    if (raw == null) return const ParentProfile.initial();
    return ParentProfile.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );
  }

  // ---------------------------------------------------------------------------
  // 世帯プロファイル（父母は含まない）
  // ---------------------------------------------------------------------------

  static Future<void> saveFamily(FamilyProfile profile) async {
    await _storage.write(
      key: _keyFamily,
      value: jsonEncode(profile.toJson()),
    );
  }

  static Future<FamilyProfile> loadFamily() async {
    final raw = await _storage.read(key: _keyFamily);
    if (raw == null) return FamilyProfile.initial();
    return FamilyProfile.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );
  }

  // ---------------------------------------------------------------------------
  // 選択中の自治体
  // ---------------------------------------------------------------------------

  static Future<void> saveMunicipality(Municipality municipality) async {
    await _storage.write(key: _keyMunicipality, value: municipality.name);
  }

  static Future<Municipality> loadMunicipality() async {
    final raw = await _storage.read(key: _keyMunicipality);
    if (raw == null) return Municipality.naha;
    try {
      return Municipality.values.byName(raw);
    } on ArgumentError {
      return Municipality.naha;
    }
  }

  // ---------------------------------------------------------------------------
  // 全削除
  // ---------------------------------------------------------------------------

  static Future<void> deleteAll() async {
    await _storage.deleteAll();
  }
}
