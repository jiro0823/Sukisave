import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../models/app_user.dart';
import 'app_database.dart';

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  static const String _sessionUserIdKey = 'session_user_id';
  static const String _sessionRoleKey = 'session_role';

  final Map<String, AppUser> _cacheByEmail = {};
  AppUser? currentUser;

  Future<void> _ensureReady() async {
    await AppDatabase.instance.database;
  }

  Future<AppUser> registerUser({
    required String role,
    required String name,
    required String email,
    required String password,
    String? phone,
    String? address,
    String? dob,
    String? businessType,
    String? region,
    String? city,
    String? logoPath,
  }) async {
    await _ensureReady();
    final Database db = await AppDatabase.instance.database;
    final String normalizedEmail = email.trim().toLowerCase();

    final existing = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [normalizedEmail],
      limit: 1,
    );
    if (existing.isNotEmpty) {
      throw AuthException('Email already registered.');
    }

    final String salt = _generateSalt();
    final String passwordHash = _hashPassword(password, salt);
    final String createdAt = DateTime.now().toIso8601String();

    final int id = await db.insert('users', {
      'role': role,
      'name': name,
      'email': normalizedEmail,
      'phone': phone,
      'address': address,
      'dob': dob,
      'business_type': businessType,
      'region': region,
      'city': city,
      'logo_path': logoPath,
      'password_salt': salt,
      'password_hash': passwordHash,
      'created_at': createdAt,
    });

    final AppUser user = AppUser(
      id: id,
      role: role,
      name: name,
      email: normalizedEmail,
      phone: phone,
      address: address,
      dob: dob,
      businessType: businessType,
      region: region,
      city: city,
      logoPath: logoPath,
      passwordSalt: salt,
      passwordHash: passwordHash,
      createdAt: createdAt,
    );

    _cacheByEmail[normalizedEmail] = user;
    await _setSession(user);
    return user;
  }

  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    await _ensureReady();
    final String normalizedEmail = email.trim().toLowerCase();
    AppUser? user = _cacheByEmail[normalizedEmail];

    if (user == null) {
      final db = await AppDatabase.instance.database;
      final result = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [normalizedEmail],
        limit: 1,
      );
      if (result.isEmpty) {
        throw AuthException('Account not found.');
      }
      user = AppUser.fromMap(result.first);
      _cacheByEmail[normalizedEmail] = user;
    }

    final String candidateHash = _hashPassword(password, user.passwordSalt);
    if (candidateHash != user.passwordHash) {
      throw AuthException('Incorrect password.');
    }

    await _setSession(user);
    return user;
  }

  Future<AppUser?> restoreSession() async {
    await _ensureReady();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int? userId = prefs.getInt(_sessionUserIdKey);
    if (userId == null) return null;

    final db = await AppDatabase.instance.database;
    final result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
      limit: 1,
    );
    if (result.isEmpty) return null;
    final AppUser user = AppUser.fromMap(result.first);
    _cacheByEmail[user.email] = user;
    currentUser = user;
    return user;
  }

  Future<void> logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionUserIdKey);
    await prefs.remove(_sessionRoleKey);
    currentUser = null;
  }

  Future<void> deleteCurrentUser() async {
    await _ensureReady();
    AppUser? user = currentUser ?? await restoreSession();
    if (user == null) return;

    final db = await AppDatabase.instance.database;
    await db.delete('users', where: 'id = ?', whereArgs: [user.id]);
    _cacheByEmail.remove(user.email);
    await logout();
  }

  Future<void> _setSession(AppUser user) async {
    currentUser = user;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_sessionUserIdKey, user.id);
    await prefs.setString(_sessionRoleKey, user.role);
  }

  String _generateSalt() {
    final Random random = Random.secure();
    final List<int> bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64UrlEncode(bytes);
  }

  String _hashPassword(String password, String salt) {
    final List<int> bytes = utf8.encode('$salt$password');
    return sha256.convert(bytes).toString();
  }
}

class AuthException implements Exception {
  final String message;

  AuthException(this.message);

  @override
  String toString() => message;
}
