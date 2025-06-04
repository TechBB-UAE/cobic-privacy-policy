import 'package:flutter/material.dart';
import 'package:cobic/theme/app_theme.dart';
import 'package:cobic/services/api_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:cobic/screens/home_screen.dart';
import 'package:cobic/utils/error_utils.dart';
import 'package:cobic/screens/register_screen.dart';
import 'package:cobic/screens/forgot_password_screen.dart';
import 'package:cobic/screens/user_info_card.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  bool _loading = false;
  String? _error;
  bool _obscurePassword = true;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    try {
      final response = await ApiService.client.post(
        '/auth/login',
        data: {
          'username': _usernameController.text.trim(),
          'password': _passwordController.text,
        },
      );
      if (response.statusCode == 200 && response.data['token'] != null) {
        await _secureStorage.write(key: 'token', value: response.data['token']);
        await _secureStorage.write(key: 'username', value: _usernameController.text.trim());
        await _secureStorage.write(key: 'isGuest', value: 'false');
        if (mounted) {
          ErrorUtils.showSuccessToast(context, AppLocalizations.of(context)!.loginSuccess);
          await Future.delayed(const Duration(milliseconds: 1200));
          if (mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const HomeScreen()),
              (route) => false,
            );
          }
        }
      } else {
        setState(() { _error = AppLocalizations.of(context)!.wrongCredentials; });
      }
    } catch (e) {
      setState(() { _error = AppLocalizations.of(context)!.loginFailed; });
    } finally {
      setState(() { _loading = false; });
    }
  }

  Future<void> _loginGuest() async {
    setState(() { _loading = true; _error = null; });
    try {
      final response = await ApiService.client.post('/auth/guest-register');
      if (response.statusCode == 201 && response.data['user'] != null) {
        final user = response.data['user'];
        final token = response.data['token'] ?? '';
        final username = user['username'] ?? '';
        final password = user['plainPassword'] ?? '';
        await _secureStorage.write(key: 'token', value: token);
        await _secureStorage.write(key: 'username', value: username);
        await _secureStorage.write(key: 'password', value: password);
        await _secureStorage.write(key: 'isGuest', value: 'true');
        if (mounted) {
          await showDialog(
            context: context,
            builder: (context) => Center(
              child: UserInfoCard(username: username, password: password),
            ),
          );
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const HomeScreen()),
              (route) => false,
            );
        }
      } else {
        setState(() { _error = AppLocalizations.of(context)!.guestLoginFailed; });
      }
    } catch (e) {
      setState(() { _error = AppLocalizations.of(context)!.guestLoginFailed; });
    } finally {
      setState(() { _loading = false; });
    }
  }

  void _goToRegister() {
    // TODO: Chuyển sang trang đăng ký
    // Navigator.of(context).push(MaterialPageRoute(builder: (_) => RegisterScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/logo.gif',
                  width: 160,
                  height: 160,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: l10n.username,
                    prefixIcon: const Icon(Icons.person),
                  ),
                  validator: (value) => (value == null || value.trim().isEmpty) ? l10n.usernameRequired : null,
                  enabled: !_loading,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: l10n.password,
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  obscureText: _obscurePassword,
                  validator: (value) => (value == null || value.isEmpty) ? l10n.passwordRequired : null,
                  enabled: !_loading,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _loading
                        ? null
                        : () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                            );
                          },
                    child: Text(l10n.forgotPassword),
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.lightTheme.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _loading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text(l10n.login, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey.shade400, thickness: 1)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(l10n.or, style: TextStyle(color: Colors.grey.shade600)),
                    ),
                    Expanded(child: Divider(color: Colors.grey.shade400, thickness: 1)),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _loading ? null : _loginGuest,
                    child: Text(l10n.loginGuest),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: _loading
                        ? null
                        : () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const RegisterScreen()),
                            );
                          },
                    child: Text(l10n.registerNewAccount),
                  ),
                ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(_error!, style: const TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 