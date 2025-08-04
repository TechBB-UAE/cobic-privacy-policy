import 'package:flutter/material.dart';
import 'package:cobic/theme/app_theme.dart';
import 'package:cobic/services/api_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cobic/screens/login_screen.dart';
import 'package:cobic/screens/home_screen.dart';
import 'package:cobic/utils/error_utils.dart';
import '../l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:cobic/providers/theme_provider.dart';
import 'package:cobic/widgets/language_switch_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _loading = false;
  String? _error;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    try {
      final response = await ApiService.client.post(
        '/auth/register',
        data: {
          'username': _usernameController.text.trim(),
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
        },
      );
      if (response.statusCode == 201 && response.data['token'] != null) {
        await _secureStorage.write(key: 'token', value: response.data['token']);
        await _secureStorage.write(key: 'username', value: _usernameController.text.trim());
        await _secureStorage.write(key: 'isGuest', value: 'false');
        if (mounted) {
          ErrorUtils.showSuccessToast(context, AppLocalizations.of(context)!.registerSuccess);
          await Future.delayed(const Duration(milliseconds: 1200));
          if (mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const HomeScreen()),
              (route) => false,
            );
          }
        }
      } else {
        setState(() { _error = AppLocalizations.of(context)!.registerFailed; });
      }
    } catch (e) {
      setState(() { _error = ErrorUtils.parseApiError(e); });
    } finally {
      setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.registerTitle,
            style: theme.textTheme.titleLarge?.copyWith(
              color: colorScheme.onBackground,
              fontWeight: FontWeight.bold,
            )),
        backgroundColor: colorScheme.background,
        iconTheme: IconThemeData(color: colorScheme.onBackground),
        elevation: 0,
        actions: [
          const LanguageSwitchButton(),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) => IconButton(
              icon: Icon(
                themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                color: colorScheme.primary,
              ),
              tooltip: themeProvider.isDarkMode ? 'Chuyển sang chế độ sáng' : 'Chuyển sang chế độ tối',
              onPressed: () {
                themeProvider.setThemeMode(
                  themeProvider.isDarkMode ? ThemeMode.light : ThemeMode.dark
                );
              },
            ),
          ),
        ],
      ),
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
                    prefixIcon: Icon(Icons.person, color: colorScheme.primary),
                  ),
                  validator: (value) => (value == null || value.trim().isEmpty) ? l10n.usernameRequired : null,
                  enabled: !_loading,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: l10n.email,
                    prefixIcon: Icon(Icons.email, color: colorScheme.primary),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return l10n.emailRequired;
                    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.[a-zA-Z]{2,}');
                    if (!emailRegex.hasMatch(value.trim())) return l10n.emailInvalid;
                    return null;
                  },
                  enabled: !_loading,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: l10n.password,
                    prefixIcon: Icon(Icons.lock, color: colorScheme.primary),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: colorScheme.primary),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.length < 6) return l10n.passwordMinLength;
                    final hasLetter = RegExp(r'[A-Za-z]').hasMatch(value);
                    final hasNumber = RegExp(r'[0-9]').hasMatch(value);
                    if (!hasLetter || !hasNumber) return l10n.passwordPattern;
                    return null;
                  },
                  enabled: !_loading,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: l10n.confirmPassword,
                    prefixIcon: Icon(Icons.lock_outline, color: colorScheme.primary),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility, color: colorScheme.primary),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) => value != _passwordController.text ? l10n.confirmPasswordNotMatch : null,
                  enabled: !_loading,
                ),
                const SizedBox(height: 24),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(_error!, style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.error)),
                  ),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _loading
                        ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme.onPrimary))
                        : Text(l10n.register, style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onPrimary)),
                  ),
                ),
                TextButton(
                  onPressed: _loading
                      ? null
                      : () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                          );
                        },
                  child: Text(l10n.alreadyHaveAccount, style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.primary)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 