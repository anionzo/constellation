import 'package:flutter/material.dart';
import '../theme/quire_tokens.dart';

/// Calm Authentication screen embodying Quiet Editorial principles.
/// Features frictionless Email OTP login and a single-tap "Guest Mode" bypass.
class CalmAuthView extends StatefulWidget {
  final void Function(String email) onAuthenticated;
  final VoidCallback onEnterAsGuest;

  const CalmAuthView({
    Key? key,
    required this.onAuthenticated,
    required this.onEnterAsGuest,
  }) : super(key: key);

  @override
  State<CalmAuthView> createState() => _CalmAuthViewState();
}

class _CalmAuthViewState extends State<CalmAuthView> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  bool _isOtpSent = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _sendOtp() {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() {
        _errorMessage = 'Vui lòng nhập địa chỉ email hợp lệ.';
      });
      return;
    }
    setState(() {
      _errorMessage = '';
      _isOtpSent = true;
    });
  }

  void _verifyAndLogin() {
    final otp = _otpController.text.trim();
    if (otp.length < 4) {
      setState(() {
        _errorMessage = 'Mã xác nhận gồm 6 chữ số.';
      });
      return;
    }
    widget.onAuthenticated(_emailController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? QuireTokens.paperDark : QuireTokens.paperLight;
    final surfaceColor = isDark ? QuireTokens.surfaceDark : QuireTokens.surfaceLight;
    final ruleColor = isDark ? QuireTokens.ruleDark : QuireTokens.ruleLight;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              padding: const EdgeInsets.all(28.0),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(QuireTokens.rCard),
                border: Border.all(color: ruleColor),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('QUIRE · BẮT ĐẦU', style: QuireTokens.eyebrow(isDark: isDark)),
                  const SizedBox(height: 6),
                  Text(
                    _isOtpSent ? 'Nhập mã xác nhận' : 'Chào mừng bạn',
                    style: QuireTokens.title(isDark: isDark),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isOtpSent
                        ? 'Mã đăng nhập đã được gửi đến ${_emailController.text.trim()}.'
                        : 'Đọc trọn một bài, chia sẻ một tấm ảnh cho đúng người. Yên lặng và riêng tư.',
                    style: QuireTokens.body(isDark: isDark).copyWith(
                      color: isDark ? QuireTokens.ink2Dark : QuireTokens.ink2Light,
                    ),
                  ),
                  const SizedBox(height: 24),

                  if (_errorMessage.isNotEmpty) ...[
                    Text(
                      _errorMessage,
                      style: TextStyle(
                        fontFamily: QuireTokens.fontSerif,
                        color: const Color(0xFFC13832),
                        fontSize: 13.0,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  if (!_isOtpSent) ...[
                    // Email Input
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: isDark ? QuireTokens.s2Dark : QuireTokens.s2Light,
                        borderRadius: BorderRadius.circular(QuireTokens.rField),
                        border: Border.all(color: ruleColor),
                      ),
                      child: TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(
                          fontFamily: QuireTokens.fontSerif,
                          color: isDark ? QuireTokens.inkDark : QuireTokens.inkLight,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Nhập email của bạn...',
                          hintStyle: TextStyle(
                            fontFamily: QuireTokens.fontSerif,
                            color: isDark ? QuireTokens.ink3Dark : QuireTokens.ink3Light,
                          ),
                          border: InputBorder.none,
                          icon: Icon(Icons.email_outlined, size: 20, color: isDark ? QuireTokens.ink3Dark : QuireTokens.ink3Light),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Primary Button: Send OTP
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
                        onPressed: _sendOtp,
                        child: Text(
                          'Tiếp tục với Email',
                          style: QuireTokens.button(isDark: isDark).copyWith(
                            color: isDark ? QuireTokens.onAccentDark : QuireTokens.onAccentLight,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Divider
                    Row(
                      children: [
                        Expanded(child: Divider(color: ruleColor)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Text('HOẶC', style: QuireTokens.meta(isDark: isDark).copyWith(fontSize: 9)),
                        ),
                        Expanded(child: Divider(color: ruleColor)),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Guest Mode Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: ruleColor),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(QuireTokens.rBtn),
                          ),
                        ),
                        onPressed: widget.onEnterAsGuest,
                        child: Text(
                          'Trải nghiệm ngay (Chế độ Khách)',
                          style: QuireTokens.button(isDark: isDark).copyWith(
                            color: isDark ? QuireTokens.inkDark : QuireTokens.inkLight,
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    // OTP Input
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: isDark ? QuireTokens.s2Dark : QuireTokens.s2Light,
                        borderRadius: BorderRadius.circular(QuireTokens.rField),
                        border: Border.all(color: ruleColor),
                      ),
                      child: TextField(
                        controller: _otpController,
                        keyboardType: TextInputType.number,
                        autofocus: true,
                        style: TextStyle(
                          fontFamily: QuireTokens.fontMono,
                          letterSpacing: 8.0,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: isDark ? QuireTokens.inkDark : QuireTokens.inkLight,
                        ),
                        decoration: InputDecoration(
                          hintText: '· · · · · ·',
                          hintStyle: TextStyle(
                            fontFamily: QuireTokens.fontMono,
                            color: isDark ? QuireTokens.ink3Dark : QuireTokens.ink3Light,
                            letterSpacing: 8.0,
                          ),
                          border: InputBorder.none,
                          icon: Icon(Icons.key_outlined, size: 20, color: isDark ? QuireTokens.ink3Dark : QuireTokens.ink3Light),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Verify Button
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
                        onPressed: _verifyAndLogin,
                        child: Text(
                          'Xác nhận & Vào ứng dụng',
                          style: QuireTokens.button(isDark: isDark).copyWith(
                            color: isDark ? QuireTokens.onAccentDark : QuireTokens.onAccentLight,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Back button
                    Center(
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            _isOtpSent = false;
                            _errorMessage = '';
                          });
                        },
                        child: Text(
                          'Dùng địa chỉ email khác',
                          style: QuireTokens.meta(isDark: isDark),
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
    );
  }
}
