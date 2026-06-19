import 'package:carilune/models/notification.dart';
import 'package:carilune/providers/auth_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('authRedirect', () {
    test('redirects unauthenticated users to login', () {
      const session = AuthSession();
      expect(authRedirect('/member/home', session), '/login');
      expect(authRedirect('/login', session), isNull);
    });

    test('redirects authenticated users away from login', () {
      const session = AuthSession(
        isLoggedIn: true,
        role: AppRole.member,
      );
      expect(authRedirect('/login', session), '/member/home');
      expect(authRedirect('/member/home', session), isNull);
    });

    test('distributor home route for distributor role', () {
      const session = AuthSession(
        isLoggedIn: true,
        role: AppRole.distributor,
      );
      expect(session.homeRoute, '/distributor/home');
      expect(authRedirect('/login', session), '/distributor/home');
    });
  });
}
