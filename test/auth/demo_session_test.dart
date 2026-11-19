import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lembar/auth/demo_session.dart';

void main() {
  group('DemoSession', () {
    late ProviderContainer container;
    late DemoSession session;

    setUp(() {
      container = ProviderContainer();
      addTearDown(container.dispose);
      session = container.read(sessionProvider.notifier);
    });

    test('starts signed out and rejects an unknown student', () {
      expect(container.read(sessionProvider), isNull);

      expect(
        session.signIn('other@example.test', DemoAccount.password),
        isFalse,
      );
      expect(container.read(sessionProvider), isNull);
    });

    test('normalizes email whitespace and casing before sign-in', () {
      final email = DemoAccount.student.email.toUpperCase();

      expect(session.signIn('  $email  ', DemoAccount.password), isTrue);
      expect(container.read(sessionProvider), same(DemoAccount.student));
    });

    test('requires the exact password', () {
      final email = DemoAccount.student.email;
      final password = DemoAccount.password;

      expect(session.signIn(email, ' $password '), isFalse);
      expect(session.signIn(email, password.toUpperCase()), isFalse);
      expect(container.read(sessionProvider), isNull);
    });

    test('sign-out clears the current student', () {
      expect(
        session.signIn(DemoAccount.student.email, DemoAccount.password),
        isTrue,
      );

      session.signOut();

      expect(container.read(sessionProvider), isNull);
    });
  });
}
