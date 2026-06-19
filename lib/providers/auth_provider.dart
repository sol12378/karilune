import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/notification.dart';
import 'account_provider.dart';

const _authRoleKey = 'auth_role';
const _authLoggedInKey = 'auth_logged_in';

class AuthSession {
  const AuthSession({
    this.role,
    this.isLoggedIn = false,
  });

  final AppRole? role;
  final bool isLoggedIn;

  String get displayName {
    if (role == null) return '';
    return defaultAccountForRole(role!.name).companyName;
  }

  String get homeRoute {
    switch (role) {
      case AppRole.distributor:
        return '/distributor/home';
      case AppRole.advertiser:
        return '/advertiser/home';
      case AppRole.member:
      case null:
        return '/member/home';
    }
  }

  AuthSession copyWith({
    AppRole? role,
    bool? isLoggedIn,
  }) {
    return AuthSession(
      role: role ?? this.role,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthSession> {
  AuthNotifier(this._prefs) : super(const AuthSession()) {
    _load();
  }

  final SharedPreferences _prefs;

  void _load() {
    final loggedIn = _prefs.getBool(_authLoggedInKey) ?? false;
    if (!loggedIn) return;
    final roleName = _prefs.getString(_authRoleKey);
    if (roleName == null) return;
    final role = AppRole.values.firstWhere(
      (r) => r.name == roleName,
      orElse: () => AppRole.member,
    );
    state = AuthSession(role: role, isLoggedIn: true);
  }

  Future<void> login(AppRole role) async {
    state = AuthSession(role: role, isLoggedIn: true);
    await _prefs.setBool(_authLoggedInKey, true);
    await _prefs.setString(_authRoleKey, role.name);
  }

  Future<void> logout() async {
    state = const AuthSession();
    await _prefs.setBool(_authLoggedInKey, false);
    await _prefs.remove(_authRoleKey);
  }

  Future<void> switchRole(AppRole role) async {
    await login(role);
  }
}

final authProvider =
    StateNotifierProvider<AuthNotifier, AuthSession>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return AuthNotifier(prefs);
});

String? authRedirect(String location, AuthSession session) {
  final isLogin = location == '/login';
  if (!session.isLoggedIn) {
    return isLogin ? null : '/login';
  }
  if (isLogin) {
    return session.homeRoute;
  }
  return null;
}
