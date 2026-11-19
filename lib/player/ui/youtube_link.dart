import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_localizations.dart';

class YoutubeLink extends StatelessWidget {
  const YoutubeLink({super.key, required this.videoId, required this.label});

  final String videoId;
  final String label;

  Future<void> _open(BuildContext context) async {
    final uri = Uri.https('www.youtube.com', '/watch', {'v': videoId});
    var launched = false;
    try {
      launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } on PlatformException {
      // The same message covers a missing external handler.
    }
    if (!launched && context.mounted) {
      final labels = AppLocalizations.of(context);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(labels.openYouTubeError)));
    }
  }

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    onPressed: () => _open(context),
    icon: const Icon(Icons.open_in_new),
    label: Text(label),
  );
}
