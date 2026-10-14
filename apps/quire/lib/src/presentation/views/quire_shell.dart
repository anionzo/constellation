import 'package:flutter/material.dart';
import '../theme/quire_tokens.dart';

/// Responsive shell that frames Quire into an elegant, centered phone mockup
/// on desktop/web viewports, and seamlessly expands full-screen on mobile devices.
class QuireShell extends StatelessWidget {
  final Widget child;

  const QuireShell({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktopWeb = size.width > 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (!isDesktopWeb) {
      return child;
    }

    // Centered mobile phone mockup for desktop browser
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF100D0A) : const Color(0xFFF0EAE1),
      body: Center(
        child: Container(
          width: 420,
          height: size.height > 920 ? 880 : size.height * 0.94,
          decoration: BoxDecoration(
            color: isDark ? QuireTokens.paperDark : QuireTokens.paperLight,
            borderRadius: BorderRadius.circular(QuireTokens.rScreen),
            border: Border.all(
              color: isDark ? const Color(0xFF2C241D) : const Color(0xFFDFD7CC),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, isDark ? 0.6 : 0.12),
                blurRadius: 36,
                spreadRadius: 2,
                offset: const Offset(0, 16),
              ),
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, isDark ? 0.4 : 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: child,
        ),
      ),
    );
  }
}
