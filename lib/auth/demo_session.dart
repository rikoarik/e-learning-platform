import 'package:flutter_riverpod/flutter_riverpod.dart';

class Student {
  const Student({required this.id, required this.email});

  final String id;
  final String email;
}

abstract final class DemoAccount {
  static const student = Student(
    id: 'student-demo',
    email: 'student@lembar.example',
  );
  static const password = 'lembar-demo';
}

final sessionProvider = NotifierProvider<DemoSession, Student?>(
  DemoSession.new,
);

class DemoSession extends Notifier<Student?> {
  @override
  Student? build() => null;

  bool signIn(String email, String password) {
    if (email.trim().toLowerCase() != DemoAccount.student.email ||
        password != DemoAccount.password) {
      return false;
    }
    state = DemoAccount.student;
    return true;
  }

  void signOut() => state = null;
}
