import 'package:flutter/material.dart';
import '../../features/auth/auth_session_manager.dart';
import '../theme/quire_tokens.dart';

enum AuthMode { signIn, signUp }

/// Calm Authentication screen embodying Quiet Editorial principles.
/// Supports Email & Password Login, Registration, and a single-tap "Guest Mode" bypass.
class CalmAuthView extends StatefulWidget {
  final AuthSessionManager sessionManager;
  final VoidCallback? onLoggedIn;
  final void Function(String email)? onAuthenticated;
  final VoidCallback? onEnterAsGuest;

  const CalmAuthView({
    Key? key,
    required this.sessionManager,
    this.onLoggedIn,
    this.onAuthenticated,
    this.onEnterAsGuest,
  }) : super(key: key);

  @override
  State<CalmAuthView> createState() => _CalmAuthViewState();
}

class _CalmAuthViewState extends State<CalmAuthView> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  AuthMode _mode = AuthMode.signIn;
  bool _obscurePassword = true;
  bool _isLoading = false;
  String _errorMessage = '';

// Session state is coordinated cleanly via widget.sessionManager

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      setState(() => _errorMessage = 'Vui lòng nhập địa chỉ email hợp lệ.');
      return;
    }
    if (password.length < 6) {
      setState(() => _errorMessage = 'Mật khẩu phải có tối thiểu 6 ký tự.');
      return;
    }
    if (_mode == AuthMode.signUp && name.isEmpty) {
      setState(() => _errorMessage = 'Vui lòng nhập họ và tên của bạn.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      if (_mode == AuthMode.signIn) {
        final res = await widget.sessionManager.login(email: email, password: password);
        if (!mounted) return;
        if (res['success'] == true) {
          widget.onLoggedIn?.call();
          widget.onAuthenticated?.call(email);
        } else {
          setState(() {
            _errorMessage = res['error']?.toString() ?? 'Email hoặc mật khẩu không chính xác.';
          });
        }
      } else {
        final res = await widget.sessionManager.signUp(
          email: email,
          password: password,
          displayName: name,
        );
        if (!mounted) return;
        if (res['success'] == true) {
          widget.onLoggedIn?.call();
          widget.onAuthenticated?.call(email);
        } else {
          setState(() {
            _errorMessage = res['error']?.toString() ?? 'Lỗi khi đăng ký tài khoản.';
          });
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Không thể kết nối máy chủ: $e';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
              constraints: const BoxConstraints(maxWidth: 420),
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
                  Text('QUIRE · TÀI KHOẢN', style: QuireTokens.eyebrow(isDark: isDark)),
                  const SizedBox(height: 6),
                  Text(
                    _mode == AuthMode.signIn ? 'Chào mừng trở lại' : 'Tạo tài khoản mới',
                    style: QuireTokens.title(isDark: isDark),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _mode == AuthMode.signIn
                        ? 'Đăng nhập để đọc bài viết và xem khoảnh khắc vòng bạn bè.'
                        : 'Tham gia không gian yên tĩnh và riêng tư cùng những người thân thiết.',
                    style: QuireTokens.body(isDark: isDark).copyWith(
                      color: isDark ? QuireTokens.ink2Dark : QuireTokens.ink2Light,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Mode Toggle Tabs (Đăng nhập / Đăng ký)
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? QuireTokens.s2Dark : QuireTokens.s2Light,
                      borderRadius: BorderRadius.circular(QuireTokens.rBtn),
                      border: Border.all(color: ruleColor),
                    ),
                    padding: const EdgeInsets.all(3.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            key: const ValueKey('tab_signin'),
                            style: TextButton.styleFrom(
                              backgroundColor: _mode == AuthMode.signIn
                                  ? (isDark ? QuireTokens.surfaceDark : Colors.white)
                                  : Colors.transparent,
                              foregroundColor: _mode == AuthMode.signIn
                                  ? (isDark ? QuireTokens.inkDark : QuireTokens.inkLight)
                                  : (isDark ? QuireTokens.ink3Dark : QuireTokens.ink3Light),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(QuireTokens.rBtn - 2),
                              ),
                              elevation: _mode == AuthMode.signIn ? 1 : 0,
                            ),
                            onPressed: () {
                              if (_mode != AuthMode.signIn) {
                                setState(() {
                                  _mode = AuthMode.signIn;
                                  _errorMessage = '';
                                });
                              }
                            },
                            child: Text(
                              'Đăng nhập',
                              style: QuireTokens.button(isDark: isDark).copyWith(
                                fontWeight: _mode == AuthMode.signIn ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextButton(
                            key: const ValueKey('tab_signup'),
                            style: TextButton.styleFrom(
                              backgroundColor: _mode == AuthMode.signUp
                                  ? (isDark ? QuireTokens.surfaceDark : Colors.white)
                                  : Colors.transparent,
                              foregroundColor: _mode == AuthMode.signUp
                                  ? (isDark ? QuireTokens.inkDark : QuireTokens.inkLight)
                                  : (isDark ? QuireTokens.ink3Dark : QuireTokens.ink3Light),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(QuireTokens.rBtn - 2),
                              ),
                              elevation: _mode == AuthMode.signUp ? 1 : 0,
                            ),
                            onPressed: () {
                              if (_mode != AuthMode.signUp) {
                                setState(() {
                                  _mode = AuthMode.signUp;
                                  _errorMessage = '';
                                });
                              }
                            },
                            child: Text(
                              'Đăng ký',
                              style: QuireTokens.button(isDark: isDark).copyWith(
                                fontWeight: _mode == AuthMode.signUp ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  if (_errorMessage.isNotEmpty) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFFC13832).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(QuireTokens.rField),
                        border: Border.all(color: const Color(0xFFC13832).withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, size: 16, color: Color(0xFFC13832)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage,
                              style: const TextStyle(
                                color: Color(0xFFC13832),
                                fontSize: 13.0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Display Name (Only in Sign Up Mode)
                  if (_mode == AuthMode.signUp) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: isDark ? QuireTokens.s2Dark : QuireTokens.s2Light,
                        borderRadius: BorderRadius.circular(QuireTokens.rField),
                        border: Border.all(color: ruleColor),
                      ),
                      child: TextField(
                        controller: _nameController,
                        style: TextStyle(
                          fontFamily: QuireTokens.fontSerif,
                          color: isDark ? QuireTokens.inkDark : QuireTokens.inkLight,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Họ và tên của bạn...',
                          hintStyle: TextStyle(
                            fontFamily: QuireTokens.fontSerif,
                            color: isDark ? QuireTokens.ink3Dark : QuireTokens.ink3Light,
                          ),
                          border: InputBorder.none,
                          icon: Icon(Icons.person_outline, size: 20, color: isDark ? QuireTokens.ink3Dark : QuireTokens.ink3Light),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

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
                        hintText: 'Nhập email...',
                        hintStyle: TextStyle(
                          fontFamily: QuireTokens.fontSerif,
                          color: isDark ? QuireTokens.ink3Dark : QuireTokens.ink3Light,
                        ),
                        border: InputBorder.none,
                        icon: Icon(Icons.email_outlined, size: 20, color: isDark ? QuireTokens.ink3Dark : QuireTokens.ink3Light),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Password Input
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 4.0),
                    decoration: BoxDecoration(
                      color: isDark ? QuireTokens.s2Dark : QuireTokens.s2Light,
                      borderRadius: BorderRadius.circular(QuireTokens.rField),
                      border: Border.all(color: ruleColor),
                    ),
                    child: TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: TextStyle(
                        color: isDark ? QuireTokens.inkDark : QuireTokens.inkLight,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Mật khẩu (tối thiểu 6 ký tự)...',
                        hintStyle: TextStyle(
                          fontFamily: QuireTokens.fontSerif,
                          color: isDark ? QuireTokens.ink3Dark : QuireTokens.ink3Light,
                        ),
                        border: InputBorder.none,
                        icon: Icon(Icons.lock_outline, size: 20, color: isDark ? QuireTokens.ink3Dark : QuireTokens.ink3Light),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            size: 18,
                            color: isDark ? QuireTokens.ink3Dark : QuireTokens.ink3Light,
                          ),
                          onPressed: () {
                            setState(() => _obscurePassword = !_obscurePassword);
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),

                  // Primary Submit Button
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
                      onPressed: _isLoading ? null : _submit,
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.0,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              _mode == AuthMode.signIn ? 'Đăng nhập' : 'Tạo tài khoản',
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
                      onPressed: () {
                        widget.sessionManager.enterAsGuest();
                        widget.onLoggedIn?.call();
                        widget.onEnterAsGuest?.call();
                      },
                      child: Text(
                        'Trải nghiệm ngay (Chế độ Khách)',
                        style: QuireTokens.button(isDark: isDark).copyWith(
                          color: isDark ? QuireTokens.inkDark : QuireTokens.inkLight,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
