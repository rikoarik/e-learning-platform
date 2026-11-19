import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/navigation.dart';
import '../app/theme/lembar_theme.dart';
import '../courses/state/course_providers.dart';
import '../courses/ui/course_components.dart';
import '../l10n/app_localizations.dart';
import '../shared/ui/lembar_widgets.dart';
import 'demo_session.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscurePassword = true;
  bool _rejected = false;

  void _signIn(String email, String password) {
    FocusScope.of(context).unfocus();
    final signedIn = ref.read(sessionProvider.notifier).signIn(email, password);
    if (!signedIn) setState(() => _rejected = true);
  }

  void _clearError(String _) {
    if (_rejected) setState(() => _rejected = false);
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final labels = AppLocalizations.of(context);
    final colors = context.colors;
    return Scaffold(
      body: SafeArea(
        child: ContentWidth(
          child: ListView(
            padding: pageInsets.copyWith(
              top: LembarMetrics.space12,
              bottom: LembarMetrics.space24,
            ),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              const LembarWordmark(),
              const SizedBox(height: LembarMetrics.space16),
              _SignInHero(title: labels.signInTitle),
              const SizedBox(height: LembarMetrics.space24),
              AutofillGroup(
                onDisposeAction: AutofillContextAction.cancel,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _email,
                      onChanged: _clearError,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autocorrect: false,
                      autofillHints: const [AutofillHints.username],
                      decoration: InputDecoration(
                        labelText: labels.email,
                        prefixIcon: const Icon(Icons.alternate_email_rounded),
                      ),
                    ),
                    const SizedBox(height: LembarMetrics.space12),
                    TextField(
                      controller: _password,
                      obscureText: _obscurePassword,
                      autocorrect: false,
                      enableSuggestions: false,
                      autofillHints: const [AutofillHints.password],
                      onChanged: _clearError,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _signIn(_email.text, _password.text),
                      decoration: InputDecoration(
                        labelText: labels.password,
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        suffixIcon: IconButton(
                          tooltip: _obscurePassword
                              ? labels.showPassword
                              : labels.hidePassword,
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                    ),
                    if (_rejected) ...[
                      const SizedBox(height: LembarMetrics.space12),
                      Semantics(
                        liveRegion: true,
                        child: Text(
                          labels.invalidCredentials,
                          style: context.type.bodySmall?.copyWith(
                            color: colors.error,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: LembarMetrics.space20),
                    LembarButton(
                      label: labels.signIn,
                      icon: Icons.arrow_forward_rounded,
                      onPressed: () => _signIn(_email.text, _password.text),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: LembarMetrics.space16),
              _SignInDemo(
                onPressed: () =>
                    _signIn(DemoAccount.student.email, DemoAccount.password),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SignInHero extends StatelessWidget {
  const _SignInHero({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ClipRRect(
      borderRadius: BorderRadius.circular(LembarMetrics.cardRadius),
      child: Stack(
        children: [
          const Positioned(
            top: 0,
            bottom: 0,
            right: 0,
            width: LembarMetrics.signInArtworkWidth,
            child: ExcludeSemantics(child: CourseCover(coverKey: 'design')),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colors.ink,
                    colors.ink,
                    colors.ink.withValues(alpha: 0.35),
                  ],
                  stops: const [0, 0.45, 1],
                ),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(
              minHeight: LembarMetrics.signInHeroHeight,
            ),
            alignment: Alignment.bottomLeft,
            padding: const EdgeInsets.all(LembarMetrics.space20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: LembarMetrics.signInTitleWidth,
              ),
              child: Semantics(
                header: true,
                child: Text(
                  title,
                  style: context.type.headlineLarge?.copyWith(
                    color: colors.onDark,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SignInDemo extends StatelessWidget {
  const _SignInDemo({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final labels = AppLocalizations.of(context);
    return _AccountSection(
      child: _AccountAction(
        icon: Icons.school_outlined,
        title: labels.signInDemo,
        subtitle: labels.signInBody,
        onPressed: onPressed,
      ),
    );
  }
}

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final student = ref.watch(sessionProvider);
    final catalog = ref.watch(catalogProvider);
    final courses = catalog.asData?.value;
    final labels = AppLocalizations.of(context);
    final colors = context.colors;
    return Scaffold(
      body: SafeArea(
        child: ContentWidth(
          child: ListView(
            padding: pageInsets.copyWith(
              top: LembarMetrics.space12,
              bottom: LembarMetrics.space24,
            ),
            children: [
              const LembarWordmark(),
              const SizedBox(height: LembarMetrics.space16),
              const Divider(height: 1),
              const SizedBox(height: LembarMetrics.space16),
              Semantics(
                header: true,
                child: Text(
                  labels.profileTitle,
                  style: context.type.headlineLarge,
                ),
              ),
              const SizedBox(height: LembarMetrics.space16),
              if (student != null) _StudentIdentity(email: student.email),
              const SizedBox(height: LembarMetrics.space24),
              Semantics(
                header: true,
                child: Text(
                  labels.learningLibrary,
                  style: context.type.titleLarge,
                ),
              ),
              const SizedBox(height: LembarMetrics.space12),
              _AccountSection(
                child: _AccountAction(
                  icon: Icons.grid_view_rounded,
                  title: labels.goToCatalog,
                  subtitle: courses == null
                      ? null
                      : labels.librarySummary(
                          courses.length,
                          courses.fold(
                            0,
                            (count, course) => count + course.lessonCount,
                          ),
                        ),
                  onPressed: () => LembarRoutes.openCatalog(context),
                ),
              ),
              const SizedBox(height: LembarMetrics.space24),
              Semantics(
                header: true,
                child: Text(
                  labels.sessionTitle,
                  style: context.type.titleLarge,
                ),
              ),
              const SizedBox(height: LembarMetrics.space8),
              Text(
                labels.demoSessionBody,
                style: context.type.bodySmall?.copyWith(color: colors.muted),
              ),
              const SizedBox(height: LembarMetrics.space8),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: colors.error,
                    minimumSize: const Size.square(LembarMetrics.tap),
                    padding: EdgeInsets.zero,
                  ),
                  onPressed: () => ref.read(sessionProvider.notifier).signOut(),
                  icon: const Icon(Icons.logout_rounded),
                  label: Text(labels.signOut),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StudentIdentity extends StatelessWidget {
  const _StudentIdentity({required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    final labels = AppLocalizations.of(context);
    final colors = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.ink,
        borderRadius: BorderRadius.circular(LembarMetrics.cardRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(LembarMetrics.space20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _AccountIcon(icon: Icons.person_outline_rounded, emphasized: true),
            const SizedBox(height: LembarMetrics.space16),
            Text(
              labels.demoStudent,
              style: context.type.headlineMedium?.copyWith(
                color: colors.onDark,
              ),
            ),
            const SizedBox(height: LembarMetrics.space4),
            Text(
              email,
              style: context.type.bodyMedium?.copyWith(color: colors.onVideo),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountSection extends StatelessWidget {
  const _AccountSection({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Material(
    color: context.colors.selected,
    borderRadius: BorderRadius.circular(LembarMetrics.mediaRadius),
    clipBehavior: Clip.antiAlias,
    child: child,
  );
}

class _AccountAction extends StatelessWidget {
  const _AccountAction({
    required this.icon,
    required this.title,
    required this.onPressed,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return InkWell(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.all(LembarMetrics.space12),
        child: Row(
          children: [
            _AccountIcon(icon: icon),
            const SizedBox(width: LembarMetrics.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: context.type.labelLarge),
                  if (subtitle case final text?) ...[
                    const SizedBox(height: LembarMetrics.space4),
                    Text(
                      text,
                      style: context.type.bodySmall?.copyWith(
                        color: colors.muted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: LembarMetrics.space8),
            Icon(Icons.arrow_forward_rounded, color: colors.ink),
          ],
        ),
      ),
    );
  }
}

class _AccountIcon extends StatelessWidget {
  const _AccountIcon({required this.icon, this.emphasized = false});

  final IconData icon;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SizedBox.square(
      dimension: LembarMetrics.tap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: emphasized ? colors.action : colors.surface,
          borderRadius: BorderRadius.circular(LembarMetrics.mediumRadius),
        ),
        child: Icon(icon, color: colors.ink),
      ),
    );
  }
}
