import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/account.dart';

const _accountKeyPrefix = 'account_';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden in main()');
});

class AccountNotifier extends StateNotifier<Account> {
  AccountNotifier(this._prefs, this._role, Account initial)
      : super(initial) {
    _load();
  }

  final SharedPreferences _prefs;
  final String _role;

  String get _key => '$_accountKeyPrefix$_role';

  Future<void> _load() async {
    final name = _prefs.getString('${_key}_companyName');
    if (name == null) return;
    state = Account(
      companyName: name,
      companyUrl: _prefs.getString('${_key}_url') ?? state.companyUrl,
      tel: _prefs.getString('${_key}_tel') ?? state.tel,
      contactName: _prefs.getString('${_key}_contact') ?? state.contactName,
    );
  }

  Future<void> update(Account account) async {
    state = account;
    await _prefs.setString('${_key}_companyName', account.companyName);
    await _prefs.setString('${_key}_url', account.companyUrl);
    await _prefs.setString('${_key}_tel', account.tel);
    await _prefs.setString('${_key}_contact', account.contactName);
  }
}

Account defaultAccountForRole(String role) {
  switch (role) {
    case 'distributor':
      return const Account(
        companyName: '株式会社○○ガス 名古屋支店',
        companyUrl: 'https://gas-company.example.com',
        tel: '0120-846-722',
        contactName: '配信担当 けんじゃ',
      );
    case 'advertiser':
      return const Account(
        companyName: '株式会社○○ガス 広告部',
        companyUrl: 'https://gas-company.example.com/ad',
        tel: '052-000-1111',
        contactName: '広報 けんじゃ',
      );
    default:
      return const Account(
        companyName: '山田 太郎',
        companyUrl: 'https://example.com',
        tel: '090-1234-5678',
        contactName: '山田 太郎',
      );
  }
}

final memberAccountProvider =
    StateNotifierProvider<AccountNotifier, Account>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return AccountNotifier(prefs, 'member', defaultAccountForRole('member'));
});

final distributorAccountProvider =
    StateNotifierProvider<AccountNotifier, Account>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return AccountNotifier(
    prefs,
    'distributor',
    defaultAccountForRole('distributor'),
  );
});

final advertiserAccountProvider =
    StateNotifierProvider<AccountNotifier, Account>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return AccountNotifier(
    prefs,
    'advertiser',
    defaultAccountForRole('advertiser'),
  );
});
