import '../../l10n/app_localizations.dart';

String twoDigits(int value) => value.toString().padLeft(2, '0');

String playbackTime(Duration value) {
  final minutes = twoDigits(value.inMinutes);
  final seconds = twoDigits(value.inSeconds.remainder(60));
  return '$minutes:$seconds';
}

String courseDuration(AppLocalizations labels, Duration duration) {
  final minutes = duration.inMinutes;
  final seconds = duration.inSeconds.remainder(60);
  if (minutes == 0) return labels.durationSeconds(seconds);
  if (seconds == 0) return labels.durationMinutes(minutes);
  return labels.durationMinutesSeconds(minutes, seconds);
}
