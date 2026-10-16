import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/api_client.dart';
import '../api/api_config.dart';
import '../models/member.dart';

class AppDb {
  AppDb._();
  static final i = AppDb._();

  static const defaultAppName = 'RTS GYM MANAGEMENT';

  final tick = ValueNotifier<int>(0);
  void notifyChanged() => tick.value++;

  String get baseUrl => ApiConfig.baseUrl;

  Future<dynamic> _get(String path) => ApiClient.i.get(path);
  Future<dynamic> _send(String method, String path, [Object? body]) =>
      ApiClient.i.request(method, path, body: body);

  String _appNameKey(SharedPreferences prefs) =>
      'app_name_${prefs.getString('admin_id') ?? 'default'}';

  Future<String> appName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_appNameKey(prefs)) ?? defaultAppName;
  }

  Future<void> setAppName(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('App name cannot be empty.');
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_appNameKey(prefs), trimmed);
    notifyChanged();
  }

  Map<String, Object?> _map(dynamic value) =>
      Map<String, Object?>.from(value as Map);

  Map<String, Object?> _memberMap(dynamic value) {
    final member = _map(value);
    final photo = member['photo'];
    if (photo is String && photo.isNotEmpty) {
      member['photo'] = base64Decode(photo);
    } else {
      member['photo'] = null;
    }
    return member;
  }

  Future<Map<String, Object?>?> login(String email, String password) async {
    final data = _map(
      await _send('POST', '/auth/login', {
        'email': email.trim().toLowerCase(),
        'password': password,
      }),
    );
    final user = _map(data['user']);
    if (user['type'] != 'online') {
      throw StateError('Offline accounts are no longer supported.');
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('account_type');
    await prefs.setString('api_token', data['token'] as String);
    return user;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('api_token');
    await prefs.remove('account_type');
    await prefs.remove('admin_name');
    await prefs.remove('admin_email');
    await prefs.remove('admin_id');
    await prefs.remove('admin_phone');
    await prefs.setBool('login', false);
  }

  Future<bool> hasSession() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('login') == false) return false;
    return (prefs.getString('api_token') ?? '').isNotEmpty;
  }

  Future<Map<String, Object?>> currentAdmin() async =>
      _map(await _get('/auth/profile'));

  Future<void> updateAdminName(String name) async {
    final trimmed = name.trim();
    final admin = _map(
      await _send('PATCH', '/auth/profile', {'name': trimmed}),
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('admin_name', (admin['name'] as String?) ?? trimmed);
    notifyChanged();
  }

  Future<void> changeAdminPassword(
    String currentPassword,
    String newPassword,
  ) async {
    await _send('PUT', '/auth/password', {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    });
  }

  Future<List<Member>> members() async => ((await _get('/members')) as List)
      .map((value) => Member.fromMap(_memberMap(value)))
      .toList();

  Future<Member?> member(int id) async {
    try {
      return Member.fromMap(_memberMap(await _get('/members/$id')));
    } catch (_) {
      return null;
    }
  }

  Future<bool> keycardTaken(String code, {int? exceptMemberId}) async {
    final trimmed = code.trim();
    if (trimmed.isEmpty) return false;
    final query =
        '?code=${Uri.encodeQueryComponent(trimmed)}${exceptMemberId == null ? '' : '&except=$exceptMemberId'}';
    return (await _get('/members/keycard/check$query'))['taken'] == true;
  }

  Map<String, Object?> _memberBody(Member member) {
    final body = member.toMap();
    body.remove('id');
    body.remove('photo');
    return body;
  }

  Future<int> addMember(Member member, {String method = 'Cash'}) async {
    final body = _memberBody(member)..['method'] = method;
    final result = _map(await _send('POST', '/members', body));
    final id = (result['id'] as num).toInt();
    if (member.photo != null && member.photo!.isNotEmpty) {
      await setPhoto(id, member.photo!);
    }
    notifyChanged();
    return id;
  }

  Future<bool> updateMember(Member member) async {
    if (member.id == null) throw ArgumentError('Member ID required');
    final response = _map(
      await _send('PUT', '/members/${member.id}', _memberBody(member)),
    );
    final result = response['transactionUpdated'];
    if (result is! bool) {
      throw StateError('The server returned an invalid member update result.');
    }
    notifyChanged();
    return result;
  }

  Future<void> renew(
    Member member,
    String plan,
    int months,
    double amount, {
    String method = 'Cash',
  }) async {
    await _send('POST', '/members/${member.id}/renew', {
      'plan': plan,
      'months': months,
      'amount': amount,
      'method': method,
    });
    notifyChanged();
  }

  Future<void> addAdjustment(
    Member member,
    double amount,
    String note, {
    String method = 'Cash',
  }) async {
    await _send('POST', '/members/${member.id}/adjustment', {
      'amount': amount,
      'note': note,
      'method': method,
    });
    notifyChanged();
  }

  Future<void> setStatus(int id, bool active) async {
    await _send('PATCH', '/members/$id/status', {'active': active});
    notifyChanged();
  }

  Future<void> setPr(int id, double kg) async {
    await _send('PATCH', '/members/$id/pr', {'kg': kg});
    notifyChanged();
  }

  Future<void> setPhoto(int id, Uint8List bytes) async {
    await ApiClient.i.uploadBytes(
      '/members/$id/photo',
      'photo',
      bytes,
      filename: 'member_$id.jpg',
    );
    notifyChanged();
  }

  Future<void> deleteMember(int id) async {
    await _send('DELETE', '/members/$id');
    notifyChanged();
  }

  Future<int> cleanInactive() async {
    final result = _map(await _send('DELETE', '/members/inactive/clean'));
    notifyChanged();
    return (result['deleted'] as num).toInt();
  }

  Future<List<Payment>> payments() async => ((await _get('/finance')) as List)
      .map((value) => Payment.fromMap(_map(value)))
      .toList();

  Future<List<Payment>> paymentsFor(int memberId) async =>
      ((await _get('/finance?member_id=$memberId')) as List)
          .map((value) => Payment.fromMap(_map(value)))
          .toList();

  Future<double> goal() async =>
      ((await _get('/settings'))['revenue_goal'] as num).toDouble();

  Future<void> setGoal(double value) async {
    await _send('PUT', '/settings/goal', {'value': value});
    notifyChanged();
  }

  Future<List<PlanOption>> plans() async {
    final result = await _get('/settings');
    return (result['plans'] as List)
        .map(
          (value) => PlanOption.of(
            (value['months'] as num).toInt(),
            (value['fee'] as num).toDouble(),
          ),
        )
        .toList();
  }

  Future<void> setPlans(List<PlanOption> list) async {
    await _send('PUT', '/settings/plans', {
      'plans': list
          .map((plan) => {'months': plan.months, 'fee': plan.fee})
          .toList(),
    });
    notifyChanged();
  }

  Future<List<Note>> notesFor(int memberId) async =>
      ((await _get('/members/$memberId/notes')) as List)
          .map((value) => Note.fromMap(_map(value)))
          .toList();

  Future<void> addNote(
    int memberId,
    String title,
    String body,
    String tags,
  ) async {
    await _send('POST', '/members/$memberId/notes', {
      'title': title,
      'body': body,
      'tags': tags,
    });
    notifyChanged();
  }

  Future<Member?> findByCode(String raw) async {
    final result = await _get(
      '/checkins/find?code=${Uri.encodeQueryComponent(raw.trim())}',
    );
    return result == null ? null : Member.fromMap(_memberMap(result));
  }

  Future<bool> checkIn(int memberId) async {
    final result = await _send('POST', '/checkins/$memberId');
    notifyChanged();
    return result['created'] == true;
  }

  Future<({int total, int streak})> checkinStats(int memberId) async {
    final result = await _get('/checkins/$memberId/stats');
    return (
      total: (result['total'] as num).toInt(),
      streak: (result['streak'] as num).toInt(),
    );
  }

  Future<List<Map<String, Object?>>> todayCheckins() async =>
      ((await _get('/checkins/today/list')) as List)
          .map((value) => _map(value))
          .toList();
}
