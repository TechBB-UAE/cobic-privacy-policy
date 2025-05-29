import 'package:flutter/material.dart';
import 'package:cobic/theme/app_theme.dart';
import 'package:cobic/services/api_service.dart';
import 'package:cobic/utils/error_utils.dart';
import 'dart:async';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  bool _loading = false;
  String? _message;
  String? _error;
  int _resendCooldown = 0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    setState(() => _resendCooldown = 30);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCooldown > 0) {
        setState(() => _resendCooldown--);
      } else {
        _timer?.cancel();
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _message = null; _error = null; });
    try {
      final response = await ApiService.client.post(
        '/auth/forgot-password',
        data: {'email': _emailController.text.trim()},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          _message = response.data['message'] ?? 'Đã gửi hướng dẫn đặt lại mật khẩu tới email của bạn (nếu tồn tại trong hệ thống).';
        });
        _startCooldown();
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) Navigator.of(context).pop(); // Quay về login
      } else {
        setState(() { _error = 'Không thể gửi yêu cầu. Vui lòng thử lại!'; });
      }
    } catch (e) {
      setState(() { _error = ErrorUtils.parseApiError(e); });
    } finally {
      setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quên mật khẩu'),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock_reset, size: 60, color: AppTheme.primaryColor),
                const SizedBox(height: 18),
                const Text('Nhập email đã đăng ký để nhận hướng dẫn đặt lại mật khẩu.',
                  style: TextStyle(fontSize: 15), textAlign: TextAlign.center),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Vui lòng nhập email';
                    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.[a-zA-Z]{2,}');
                    if (!emailRegex.hasMatch(value.trim())) return 'Email không hợp lệ';
                    return null;
                  },
                  enabled: !_loading,
                ),
                const SizedBox(height: 24),
                if (_message != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(_message!, style: const TextStyle(color: Colors.green)),
                  ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(_error!, style: const TextStyle(color: Colors.red)),
                  ),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _loading || _resendCooldown > 0 ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.lightTheme.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _loading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text(_resendCooldown > 0 ? 'Gửi lại sau $_resendCooldown giây' : 'Gửi yêu cầu', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 