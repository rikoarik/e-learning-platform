import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_id.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('id')];

  /// No description provided for @appName.
  ///
  /// In id, this message translates to:
  /// **'Lembar'**
  String get appName;

  /// No description provided for @wordmark.
  ///
  /// In id, this message translates to:
  /// **'lembar'**
  String get wordmark;

  /// No description provided for @catalogTitle.
  ///
  /// In id, this message translates to:
  /// **'Katalog'**
  String get catalogTitle;

  /// No description provided for @otherCourses.
  ///
  /// In id, this message translates to:
  /// **'Course lainnya'**
  String get otherCourses;

  /// No description provided for @courseCount.
  ///
  /// In id, this message translates to:
  /// **'{count, plural, other{{count} course}}'**
  String courseCount(int count);

  /// No description provided for @lessonCount.
  ///
  /// In id, this message translates to:
  /// **'{count, plural, other{{count} lesson}}'**
  String lessonCount(int count);

  /// No description provided for @courseMetadata.
  ///
  /// In id, this message translates to:
  /// **'{lessons} / {duration}'**
  String courseMetadata(String lessons, String duration);

  /// No description provided for @durationMinutes.
  ///
  /// In id, this message translates to:
  /// **'{minutes} mnt'**
  String durationMinutes(int minutes);

  /// No description provided for @durationSeconds.
  ///
  /// In id, this message translates to:
  /// **'{seconds} dtk'**
  String durationSeconds(int seconds);

  /// No description provided for @durationMinutesSeconds.
  ///
  /// In id, this message translates to:
  /// **'{minutes} mnt {seconds} dtk'**
  String durationMinutesSeconds(int minutes, int seconds);

  /// No description provided for @lessonOrdinal.
  ///
  /// In id, this message translates to:
  /// **'Lesson {number} / {count}'**
  String lessonOrdinal(String number, String count);

  /// No description provided for @openCourse.
  ///
  /// In id, this message translates to:
  /// **'Buka {title}'**
  String openCourse(String title);

  /// No description provided for @goBack.
  ///
  /// In id, this message translates to:
  /// **'Kembali'**
  String get goBack;

  /// No description provided for @goToCatalog.
  ///
  /// In id, this message translates to:
  /// **'Ke katalog'**
  String get goToCatalog;

  /// No description provided for @lessonsTitle.
  ///
  /// In id, this message translates to:
  /// **'Daftar lesson'**
  String get lessonsTitle;

  /// No description provided for @startFirstLesson.
  ///
  /// In id, this message translates to:
  /// **'Mulai lesson pertama'**
  String get startFirstLesson;

  /// No description provided for @selected.
  ///
  /// In id, this message translates to:
  /// **'Dipilih'**
  String get selected;

  /// No description provided for @playing.
  ///
  /// In id, this message translates to:
  /// **'Sedang diputar'**
  String get playing;

  /// No description provided for @play.
  ///
  /// In id, this message translates to:
  /// **'Putar'**
  String get play;

  /// No description provided for @pause.
  ///
  /// In id, this message translates to:
  /// **'Jeda'**
  String get pause;

  /// No description provided for @replay.
  ///
  /// In id, this message translates to:
  /// **'Putar ulang'**
  String get replay;

  /// No description provided for @seek.
  ///
  /// In id, this message translates to:
  /// **'Geser posisi video'**
  String get seek;

  /// No description provided for @backTen.
  ///
  /// In id, this message translates to:
  /// **'Mundur 10 detik'**
  String get backTen;

  /// No description provided for @forwardTen.
  ///
  /// In id, this message translates to:
  /// **'Maju 10 detik'**
  String get forwardTen;

  /// No description provided for @catalogLoading.
  ///
  /// In id, this message translates to:
  /// **'Memuat course…'**
  String get catalogLoading;

  /// No description provided for @detailLoading.
  ///
  /// In id, this message translates to:
  /// **'Memuat detail course…'**
  String get detailLoading;

  /// No description provided for @catalogEmpty.
  ///
  /// In id, this message translates to:
  /// **'Belum ada course'**
  String get catalogEmpty;

  /// No description provided for @catalogEmptyBody.
  ///
  /// In id, this message translates to:
  /// **'Course yang tersedia akan muncul di sini.'**
  String get catalogEmptyBody;

  /// No description provided for @courseEmpty.
  ///
  /// In id, this message translates to:
  /// **'Belum ada lesson'**
  String get courseEmpty;

  /// No description provided for @courseEmptyBody.
  ///
  /// In id, this message translates to:
  /// **'Materi course akan muncul di sini saat tersedia.'**
  String get courseEmptyBody;

  /// No description provided for @offline.
  ///
  /// In id, this message translates to:
  /// **'Koneksi terputus'**
  String get offline;

  /// No description provided for @offlineBody.
  ///
  /// In id, this message translates to:
  /// **'Periksa koneksi internetmu, lalu coba lagi.'**
  String get offlineBody;

  /// No description provided for @courseError.
  ///
  /// In id, this message translates to:
  /// **'Course gagal dimuat'**
  String get courseError;

  /// No description provided for @catalogErrorBody.
  ///
  /// In id, this message translates to:
  /// **'Terjadi gangguan saat mengambil daftar course.'**
  String get catalogErrorBody;

  /// No description provided for @detailErrorBody.
  ///
  /// In id, this message translates to:
  /// **'Terjadi gangguan saat mengambil detail course.'**
  String get detailErrorBody;

  /// No description provided for @courseUnavailable.
  ///
  /// In id, this message translates to:
  /// **'Course tidak tersedia'**
  String get courseUnavailable;

  /// No description provided for @courseUnavailableBody.
  ///
  /// In id, this message translates to:
  /// **'Course ini mungkin telah dihapus. Pilih course lain dari katalog.'**
  String get courseUnavailableBody;

  /// No description provided for @lessonUnavailable.
  ///
  /// In id, this message translates to:
  /// **'Lesson tidak tersedia.'**
  String get lessonUnavailable;

  /// No description provided for @routeUnavailable.
  ///
  /// In id, this message translates to:
  /// **'Halaman tidak tersedia'**
  String get routeUnavailable;

  /// No description provided for @routeUnavailableBody.
  ///
  /// In id, this message translates to:
  /// **'Kembali ke katalog untuk memilih course.'**
  String get routeUnavailableBody;

  /// No description provided for @retry.
  ///
  /// In id, this message translates to:
  /// **'Coba lagi'**
  String get retry;

  /// No description provided for @videoLoading.
  ///
  /// In id, this message translates to:
  /// **'Menyiapkan video…'**
  String get videoLoading;

  /// No description provided for @videoBuffering.
  ///
  /// In id, this message translates to:
  /// **'Menunggu koneksi…'**
  String get videoBuffering;

  /// No description provided for @videoError.
  ///
  /// In id, this message translates to:
  /// **'Video gagal diputar'**
  String get videoError;

  /// No description provided for @videoErrorBody.
  ///
  /// In id, this message translates to:
  /// **'Periksa koneksi, lalu coba lagi.'**
  String get videoErrorBody;

  /// No description provided for @signInTitle.
  ///
  /// In id, this message translates to:
  /// **'Masuk ke Lembar'**
  String get signInTitle;

  /// No description provided for @signInBody.
  ///
  /// In id, this message translates to:
  /// **'Coba katalog dan video tanpa mengisi form.'**
  String get signInBody;

  /// No description provided for @email.
  ///
  /// In id, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In id, this message translates to:
  /// **'Kata sandi'**
  String get password;

  /// No description provided for @signIn.
  ///
  /// In id, this message translates to:
  /// **'Masuk'**
  String get signIn;

  /// No description provided for @signInDemo.
  ///
  /// In id, this message translates to:
  /// **'Masuk dengan akun demo'**
  String get signInDemo;

  /// No description provided for @invalidCredentials.
  ///
  /// In id, this message translates to:
  /// **'Email atau kata sandi demo tidak cocok.'**
  String get invalidCredentials;

  /// No description provided for @account.
  ///
  /// In id, this message translates to:
  /// **'Akun'**
  String get account;

  /// No description provided for @profileTitle.
  ///
  /// In id, this message translates to:
  /// **'Profil'**
  String get profileTitle;

  /// No description provided for @demoStudent.
  ///
  /// In id, this message translates to:
  /// **'Pelajar Demo'**
  String get demoStudent;

  /// No description provided for @showPassword.
  ///
  /// In id, this message translates to:
  /// **'Tampilkan kata sandi'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In id, this message translates to:
  /// **'Sembunyikan kata sandi'**
  String get hidePassword;

  /// No description provided for @learningLibrary.
  ///
  /// In id, this message translates to:
  /// **'Perpustakaan belajar'**
  String get learningLibrary;

  /// No description provided for @librarySummary.
  ///
  /// In id, this message translates to:
  /// **'{courses} course · {lessons} lesson'**
  String librarySummary(int courses, int lessons);

  /// No description provided for @sessionTitle.
  ///
  /// In id, this message translates to:
  /// **'Sesi demo'**
  String get sessionTitle;

  /// No description provided for @demoSessionBody.
  ///
  /// In id, this message translates to:
  /// **'Sesi demo berlaku selama aplikasi berjalan.'**
  String get demoSessionBody;

  /// No description provided for @signOut.
  ///
  /// In id, this message translates to:
  /// **'Keluar'**
  String get signOut;

  /// No description provided for @youtubeSource.
  ///
  /// In id, this message translates to:
  /// **'YouTube'**
  String get youtubeSource;

  /// No description provided for @youtubeCredit.
  ///
  /// In id, this message translates to:
  /// **'YouTube · {channel}'**
  String youtubeCredit(String channel);

  /// No description provided for @youtubeReference.
  ///
  /// In id, this message translates to:
  /// **'Referensi resmi di YouTube'**
  String get youtubeReference;

  /// No description provided for @youtubeBody.
  ///
  /// In id, this message translates to:
  /// **'Video YouTube memerlukan koneksi internet.'**
  String get youtubeBody;

  /// No description provided for @openYouTube.
  ///
  /// In id, this message translates to:
  /// **'Buka di YouTube'**
  String get openYouTube;

  /// No description provided for @openYouTubeError.
  ///
  /// In id, this message translates to:
  /// **'Tautan YouTube gagal dibuka.'**
  String get openYouTubeError;

  /// No description provided for @refreshCourses.
  ///
  /// In id, this message translates to:
  /// **'Muat ulang course'**
  String get refreshCourses;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
