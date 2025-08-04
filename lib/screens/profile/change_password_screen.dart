import 'package:flutter/material.dart';
import 'package:cobic/theme/app_theme.dart';
import 'package:cobic/theme/custom_app_bar.dart';
import 'package:cobic/services/profile_service.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:cobic/utils/error_utils.dart';
import 'package:cobic/screens/main_tab_screen.dart';
import '../../l10n/app_localizations.dart';
import 'package:cobic/providers/theme_provider.dart';
import 'package:intl/intl.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validatePassword(String? value) {
    final l10n = AppLocalizations.of(context)!;
    if (value == null || value.isEmpty) {
      return l10n.newPasswordRequired;
    }
    if (value.length < 8) {
      return l10n.newPasswordLength;
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return l10n.newPasswordUpper;
    }
    return null;
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final storage = const FlutterSecureStorage();
      final token = await storage.read(key: 'token');
      
      if (token == null) {
        ErrorUtils.showErrorToast(context, AppLocalizations.of(context)!.loginTokenNotFound);
        return;
      }

      await ProfileService.changePassword(
        token: token,
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
      );

      if (mounted) {
        ErrorUtils.showSuccessToast(context, AppLocalizations.of(context)!.changePasswordSuccess);
        await Future.delayed(const Duration(milliseconds: 1500));
        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => MainTabScreen(initialTab: 0)),
          (route) => false,
        );
      }
    } catch (e, stack) {
      // Thêm log lỗi
      debugPrint('ChangePassword error: $e\n$stack');
      final errorMessage = ErrorUtils.parseApiError(e);
      if (mounted) {
        ErrorUtils.showErrorToast(context, errorMessage);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: CustomAppBar.themed(
        context: context,
        titleText: l10n.changePasswordTitle,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Mật khẩu hiện tại
              TextFormField(
                controller: _currentPasswordController,
                obscureText: _obscureCurrentPassword,
                style: Theme.of(context).textTheme.bodyLarge,
                decoration: InputDecoration(
                  labelText: l10n.currentPassword,
                  labelStyle: Theme.of(context).inputDecorationTheme.labelStyle,
                  hintStyle: Theme.of(context).inputDecorationTheme.hintStyle,
                  prefixIcon: Icon(Icons.lock_outline, color: Theme.of(context).iconTheme.color),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureCurrentPassword ? Icons.visibility_off : Icons.visibility,
                      color: Theme.of(context).iconTheme.color,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureCurrentPassword = !_obscureCurrentPassword;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.currentPasswordRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Mật khẩu mới
              TextFormField(
                controller: _newPasswordController,
                obscureText: _obscureNewPassword,
                style: Theme.of(context).textTheme.bodyLarge,
                decoration: InputDecoration(
                  labelText: l10n.newPassword,
                  labelStyle: Theme.of(context).inputDecorationTheme.labelStyle,
                  hintStyle: Theme.of(context).inputDecorationTheme.hintStyle,
                  prefixIcon: Icon(Icons.lock_outline, color: Theme.of(context).iconTheme.color),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureNewPassword ? Icons.visibility_off : Icons.visibility,
                      color: Theme.of(context).iconTheme.color,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureNewPassword = !_obscureNewPassword;
                      });
                    },
                  ),
                ),
                validator: _validatePassword,
              ),
              const SizedBox(height: 16),
              // Xác nhận mật khẩu mới
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                style: Theme.of(context).textTheme.bodyLarge,
                decoration: InputDecoration(
                  labelText: l10n.confirmNewPassword,
                  labelStyle: Theme.of(context).inputDecorationTheme.labelStyle,
                  hintStyle: Theme.of(context).inputDecorationTheme.hintStyle,
                  prefixIcon: Icon(Icons.lock_outline, color: Theme.of(context).iconTheme.color),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                      color: Theme.of(context).iconTheme.color,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.confirmPasswordRequired;
                  }
                  if (value != _newPasswordController.text) {
                    return l10n.confirmPasswordNotMatch;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              // Nút đổi mật khẩu
              ElevatedButton(
                onPressed: _isLoading ? null : _changePassword,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(l10n.changePasswordTitle, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 