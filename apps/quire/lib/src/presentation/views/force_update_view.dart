import 'package:flutter/material.dart';
import '../theme/quire_tokens.dart';

/// Full-screen unskippable view presented when app version is below
/// minSupportedVersion (Force Update) or when system is in emergency maintenance.
///
/// Designed with Calm Computing principles: serene paper surface, quiet typography,
/// no frantic warning badges or aggressive animations.
class ForceUpdateView extends StatelessWidget {
  final String title;
  final String message;
  final String? updateUrl;
  final bool isMaintenance;
  final VoidCallback? onRetry;
  final ValueChanged<String>? onOpenUrl;

  const ForceUpdateView({
    Key? key,
    required this.title,
    required this.message,
    this.updateUrl,
    this.isMaintenance = false,
    this.onRetry,
    this.onOpenUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? QuireTokens.paperDark : QuireTokens.paperLight;
    final surfaceColor = isDark ? QuireTokens.surfaceDark : QuireTokens.surfaceLight;
    final ruleColor = isDark ? QuireTokens.ruleDark : QuireTokens.ruleLight;

    return PopScope(
      // Lock back navigation — this screen is unskippable
      canPop: false,
      child: Scaffold(
        backgroundColor: bgColor,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 32.0),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 420),
                padding: const EdgeInsets.all(28.0),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(QuireTokens.rCard),
                  border: Border.all(color: ruleColor),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Eyebrow tag in mono font
                    Text(
                      isMaintenance ? 'BẢO TRÌ HỆ THỐNG' : 'PHIÊN BẢN MỚI',
                      style: QuireTokens.eyebrow(isDark: isDark),
                    ),
                    const SizedBox(height: 16),

                    // Serene Editorial Title
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: QuireTokens.title(isDark: isDark),
                    ),
                    const SizedBox(height: 14),

                    // Body description
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: QuireTokens.body(isDark: isDark).copyWith(
                        color: isDark ? QuireTokens.ink2Dark : QuireTokens.ink2Light,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Primary Action (Update / Re-open URL)
                    if (updateUrl != null && updateUrl!.isNotEmpty)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark ? QuireTokens.accentDark : QuireTokens.accentLight,
                            foregroundColor: isDark ? QuireTokens.onAccentDark : QuireTokens.onAccentLight,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(QuireTokens.rBtn),
                            ),
                            elevation: 0,
                          ),
                          onPressed: () {
                            if (onOpenUrl != null) {
                              onOpenUrl!(updateUrl!);
                            }
                          },
                          child: Text(
                            isMaintenance ? 'Xem thông báo chi tiết' : 'Cập nhật ứng dụng',
                            style: QuireTokens.button(isDark: isDark).copyWith(
                              color: isDark ? QuireTokens.onAccentDark : QuireTokens.onAccentLight,
                            ),
                          ),
                        ),
                      ),

                    if (onRetry != null) ...[
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: onRetry,
                        style: TextButton.styleFrom(
                          minimumSize: const Size(double.infinity, 44),
                        ),
                        child: Text(
                          'Kiểm tra lại',
                          style: QuireTokens.meta(isDark: isDark).copyWith(
                            fontSize: 13.0,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
