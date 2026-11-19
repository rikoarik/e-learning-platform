import 'package:flutter/material.dart';

import '../../app/theme/lembar_theme.dart';
import '../../l10n/app_localizations.dart';

class ContentWidth extends StatelessWidget {
  const ContentWidth({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topCenter,
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: LembarMetrics.maxContent),
      child: SizedBox(width: double.infinity, child: child),
    ),
  );
}

const pageInsets = EdgeInsets.symmetric(horizontal: LembarMetrics.gutter);

class RefreshableList extends StatelessWidget {
  const RefreshableList({
    super.key,
    required this.scrollKey,
    required this.padding,
    required this.onRefresh,
    required this.children,
  });

  final Key scrollKey;
  final EdgeInsets padding;
  final RefreshCallback onRefresh;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => RefreshIndicator(
    semanticsLabel: AppLocalizations.of(context).refreshCourses,
    onRefresh: onRefresh,
    color: context.colors.ink,
    backgroundColor: context.colors.action,
    child: ListView(
      key: scrollKey,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: padding,
      children: children,
    ),
  );
}

class LembarWordmark extends StatelessWidget {
  const LembarWordmark({super.key});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      ExcludeSemantics(
        child: Image.asset('assets/brand/mark.png', width: 36, height: 36),
      ),
      const SizedBox(width: 9),
      Flexible(
        child: Text(
          AppLocalizations.of(context).wordmark,
          style: context.type.headlineMedium,
        ),
      ),
    ],
  );
}

class ScreenHeader extends StatelessWidget {
  const ScreenHeader({super.key, required this.title, required this.onBack});

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final labels = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          IconButton(
            tooltip: labels.goBack,
            onPressed: onBack,
            icon: const BackButtonIcon(),
            constraints: const BoxConstraints.tightFor(
              width: LembarMetrics.tap,
              height: LembarMetrics.tap,
            ),
          ),
          Expanded(
            child: Text(
              title,
              style: context.type.titleMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class LembarButton extends StatelessWidget {
  const LembarButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.icon,
    this.leadingText = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData icon;
  final bool leadingText;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return FilledButton(
      onPressed: onPressed,
      style: ButtonStyle(
        textStyle: WidgetStatePropertyAll(context.type.labelLarge),
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) return colors.disabled;
          if (states.contains(WidgetState.pressed)) return colors.actionPressed;
          return colors.action;
        }),
        foregroundColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.disabled) ? colors.muted : colors.ink,
        ),
        minimumSize: const WidgetStatePropertyAll(
          Size(LembarMetrics.tap, LembarMetrics.tap),
        ),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
        shape: const WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(LembarMetrics.mediumRadius),
            ),
          ),
        ),
      ),
      child: Row(
        mainAxisSize: leadingText ? MainAxisSize.max : MainAxisSize.min,
        children: [
          if (leadingText)
            Expanded(child: Text(label))
          else
            Flexible(child: Text(label)),
          const SizedBox(width: 12),
          Icon(icon, size: 20),
        ],
      ),
    );
  }
}

class StatusPanel extends StatelessWidget {
  const StatusPanel({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    this.actionLabel,
    this.onAction,
    this.actionIcon = Icons.refresh_rounded,
    this.onDark = false,
  });

  final String title;
  final String description;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData actionIcon;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: onDark ? colors.videoPanel : colors.selected,
        borderRadius: BorderRadius.circular(LembarMetrics.mediaRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: onDark
              ? CrossAxisAlignment.center
              : CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: onDark ? colors.videoControl : colors.ink,
                borderRadius: BorderRadius.circular(LembarMetrics.smallRadius),
              ),
              child: SizedBox.square(
                dimension: 44,
                child: Icon(icon, color: colors.action),
              ),
            ),
            const SizedBox(height: 16),
            Semantics(
              header: true,
              child: Text(
                title,
                textAlign: onDark ? TextAlign.center : TextAlign.start,
                style: context.type.titleLarge?.copyWith(
                  color: onDark ? colors.onDark : colors.ink,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: onDark ? TextAlign.center : TextAlign.start,
              style: context.type.bodyMedium?.copyWith(
                color: onDark ? colors.onVideo : colors.muted,
              ),
            ),
            if (actionLabel case final label?) ...[
              const SizedBox(height: 20),
              LembarButton(
                label: label,
                onPressed: onAction,
                icon: actionIcon,
                leadingText: !onDark,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class Bone extends StatelessWidget {
  const Bone({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.radius = LembarMetrics.smallRadius,
  });

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    height: height,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.disabled,
        borderRadius: BorderRadius.circular(radius),
      ),
    ),
  );
}
