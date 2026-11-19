// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appName => 'Lembar';

  @override
  String get wordmark => 'lembar';

  @override
  String get catalogTitle => 'Katalog';

  @override
  String get otherCourses => 'Course lainnya';

  @override
  String courseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count course',
    );
    return '$_temp0';
  }

  @override
  String lessonCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lesson',
    );
    return '$_temp0';
  }

  @override
  String courseMetadata(String lessons, String duration) {
    return '$lessons / $duration';
  }

  @override
  String durationMinutes(int minutes) {
    return '$minutes mnt';
  }

  @override
  String durationSeconds(int seconds) {
    return '$seconds dtk';
  }

  @override
  String durationMinutesSeconds(int minutes, int seconds) {
    return '$minutes mnt $seconds dtk';
  }

  @override
  String lessonOrdinal(String number, String count) {
    return 'Lesson $number / $count';
  }

  @override
  String openCourse(String title) {
    return 'Buka $title';
  }

  @override
  String get goBack => 'Kembali';

  @override
  String get goToCatalog => 'Ke katalog';

  @override
  String get lessonsTitle => 'Daftar lesson';

  @override
  String get startFirstLesson => 'Mulai lesson pertama';

  @override
  String get selected => 'Dipilih';

  @override
  String get playing => 'Sedang diputar';

  @override
  String get play => 'Putar';

  @override
  String get pause => 'Jeda';

  @override
  String get replay => 'Putar ulang';

  @override
  String get seek => 'Geser posisi video';

  @override
  String get backTen => 'Mundur 10 detik';

  @override
  String get forwardTen => 'Maju 10 detik';

  @override
  String get catalogLoading => 'Memuat course…';

  @override
  String get detailLoading => 'Memuat detail course…';

  @override
  String get catalogEmpty => 'Belum ada course';

  @override
  String get catalogEmptyBody => 'Course yang tersedia akan muncul di sini.';

  @override
  String get courseEmpty => 'Belum ada lesson';

  @override
  String get courseEmptyBody =>
      'Materi course akan muncul di sini saat tersedia.';

  @override
  String get offline => 'Koneksi terputus';

  @override
  String get offlineBody => 'Periksa koneksi internetmu, lalu coba lagi.';

  @override
  String get courseError => 'Course gagal dimuat';

  @override
  String get catalogErrorBody =>
      'Terjadi gangguan saat mengambil daftar course.';

  @override
  String get detailErrorBody =>
      'Terjadi gangguan saat mengambil detail course.';

  @override
  String get courseUnavailable => 'Course tidak tersedia';

  @override
  String get courseUnavailableBody =>
      'Course ini mungkin telah dihapus. Pilih course lain dari katalog.';

  @override
  String get lessonUnavailable => 'Lesson tidak tersedia.';

  @override
  String get routeUnavailable => 'Halaman tidak tersedia';

  @override
  String get routeUnavailableBody => 'Kembali ke katalog untuk memilih course.';

  @override
  String get retry => 'Coba lagi';

  @override
  String get videoLoading => 'Menyiapkan video…';

  @override
  String get videoBuffering => 'Menunggu koneksi…';

  @override
  String get videoError => 'Video gagal diputar';

  @override
  String get videoErrorBody => 'Periksa koneksi, lalu coba lagi.';

  @override
  String get signInTitle => 'Masuk ke Lembar';

  @override
  String get signInBody => 'Coba katalog dan video tanpa mengisi form.';

  @override
  String get email => 'Email';

  @override
  String get password => 'Kata sandi';

  @override
  String get signIn => 'Masuk';

  @override
  String get signInDemo => 'Masuk dengan akun demo';

  @override
  String get invalidCredentials => 'Email atau kata sandi demo tidak cocok.';

  @override
  String get account => 'Akun';

  @override
  String get profileTitle => 'Profil';

  @override
  String get demoStudent => 'Pelajar Demo';

  @override
  String get showPassword => 'Tampilkan kata sandi';

  @override
  String get hidePassword => 'Sembunyikan kata sandi';

  @override
  String get learningLibrary => 'Perpustakaan belajar';

  @override
  String librarySummary(int courses, int lessons) {
    return '$courses course · $lessons lesson';
  }

  @override
  String get sessionTitle => 'Sesi demo';

  @override
  String get demoSessionBody => 'Sesi demo berlaku selama aplikasi berjalan.';

  @override
  String get signOut => 'Keluar';

  @override
  String get youtubeSource => 'YouTube';

  @override
  String youtubeCredit(String channel) {
    return 'YouTube · $channel';
  }

  @override
  String get youtubeReference => 'Referensi resmi di YouTube';

  @override
  String get youtubeBody => 'Video YouTube memerlukan koneksi internet.';

  @override
  String get openYouTube => 'Buka di YouTube';

  @override
  String get openYouTubeError => 'Tautan YouTube gagal dibuka.';

  @override
  String get refreshCourses => 'Muat ulang course';
}
