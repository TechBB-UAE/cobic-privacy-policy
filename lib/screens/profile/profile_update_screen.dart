import 'package:flutter/material.dart';
import 'package:cobic/theme/app_theme.dart';
import 'package:cobic/services/profile_service.dart';
import 'package:provider/provider.dart';
import 'package:cobic/providers/profile_provider.dart';
import 'package:country_picker/country_picker.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';
import 'package:another_flushbar/flushbar.dart';
import 'profile_screen.dart';
import 'package:cobic/theme/custom_app_bar.dart';
import 'package:cobic/utils/error_utils.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:cobic/providers/theme_provider.dart';
import 'package:intl/intl.dart';

class ProfileUpdateScreen extends StatefulWidget {
  final GlobalKey<NavigatorState>? navigatorKey;
  const ProfileUpdateScreen({super.key, this.navigatorKey});

  @override
  State<ProfileUpdateScreen> createState() => _ProfileUpdateScreenState();
}

class _ProfileUpdateScreenState extends State<ProfileUpdateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _bioController = TextEditingController();
  DateTime? _selectedDate;
  Country? _selectedCountry;
  bool _isLoading = false;
  String? _error;
  String? _usernameError;
  bool _isCheckingUsername = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final userInfo = Provider.of<ProfileProvider>(context, listen: false).userInfo;
    if (userInfo != null) {
      _usernameController.text = userInfo['username'] ?? '';
      _fullNameController.text = userInfo['fullName'] ?? '';
      _emailController.text = userInfo['email'] ?? '';
      _phoneController.text = userInfo['phoneNumber'] ?? '';
      _addressController.text = userInfo['address'] ?? '';
      _bioController.text = userInfo['bio'] ?? '';
      if (userInfo['dateOfBirth'] != null) {
        try {
          _selectedDate = DateTime.parse(userInfo['dateOfBirth']);
        } catch (e) {
          _selectedDate = null;
        }
      }
      if (userInfo['country'] != null) {
        try {
          _selectedCountry = Country.parse(userInfo['country']);
        } catch (e) {
          _selectedCountry = null;
        }
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: isDark
              ? ThemeData.dark().copyWith(
                  colorScheme: theme.colorScheme.copyWith(
                    primary: theme.colorScheme.primary,
                    surface: theme.dialogBackgroundColor,
                    onSurface: theme.textTheme.bodyLarge?.color ?? Colors.white,
                  ),
                  dialogBackgroundColor: theme.dialogBackgroundColor,
                  textButtonTheme: TextButtonThemeData(
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.primary,
                    ),
                  ),
                )
              : ThemeData.light().copyWith(
                  colorScheme: theme.colorScheme.copyWith(
                    primary: theme.colorScheme.primary,
                    surface: theme.dialogBackgroundColor,
                    onSurface: theme.textTheme.bodyLarge?.color ?? Colors.black,
                  ),
                  dialogBackgroundColor: theme.dialogBackgroundColor,
                  textButtonTheme: TextButtonThemeData(
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.primary,
                    ),
                  ),
                ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _checkUsername() async {
    final username = _usernameController.text.trim();
    if (username.isEmpty) return;

    setState(() {
      _isCheckingUsername = true;
      _usernameError = null;
    });

    try {
      final response = await ProfileService.checkUsername(username);
      if (response['exists'] == true) {
        setState(() {
          _usernameError = 'Tên đăng nhập đã tồn tại';
        });
      }
    } catch (e) {
      // Bỏ qua lỗi khi kiểm tra
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingUsername = false;
        });
      }
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate() || _usernameError != null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Update username nếu có thay đổi
      if (_usernameController.text != Provider.of<ProfileProvider>(context, listen: false).userInfo?['username']) {
        final usernameResponse = await ProfileService.updateUsername(_usernameController.text);
        if (usernameResponse is Map && usernameResponse['success'] == false) {
          String msg = usernameResponse['message']?.toString().toLowerCase() ?? '';
          if (msg.contains('already in use') || msg.contains('tồn tại')) {
            setState(() {
              _error = 'Tên đăng nhập đã tồn tại';
            });
          } else {
            setState(() {
              _error = usernameResponse['message'] ?? 'Có lỗi xảy ra khi cập nhật tên đăng nhập';
            });
          }
          return;
        }
      }

      // Update email nếu có thay đổi
      if (_emailController.text != Provider.of<ProfileProvider>(context, listen: false).userInfo?['email']) {
        final emailResponse = await ProfileService.updateEmail(_emailController.text);
        if (emailResponse is Map && emailResponse['success'] == false) {
          String msg = emailResponse['message']?.toString().toLowerCase() ?? '';
          if (msg.contains('already in use') || msg.contains('tồn tại')) {
            setState(() {
              _error = 'Email đã tồn tại';
            });
          } else {
            setState(() {
              _error = emailResponse['message'] ?? 'Có lỗi xảy ra khi cập nhật email';
            });
          }
          return;
        }
      }

      // Update các thông tin khác
      final response = await ProfileService.updateProfile({
        'fullName': _fullNameController.text,
        'dateOfBirth': _selectedDate?.toIso8601String() ?? '',
        'country': _selectedCountry?.countryCode ?? '',
        'address': _addressController.text,
        'bio': _bioController.text,
        'phone': _phoneController.text,
      });
      if (response is Map && response['success'] == false) {
        setState(() {
          _error = response['message'] ?? 'Có lỗi xảy ra khi cập nhật hồ sơ';
        });
        return;
      }

        // Gọi lại API lấy user info mới nhất
        await Provider.of<ProfileProvider>(context, listen: false).fetchUserInfo(context);
        if (mounted) {
        ErrorUtils.showSuccessToast(context, 'Cập nhật hồ sơ thành công!');
          await Future.delayed(const Duration(milliseconds: 1200));
          if (widget.navigatorKey != null) {
            widget.navigatorKey!.currentState?.popUntil((route) => route.settings.name == '/profile');
          } else {
            Navigator.of(context).pop();
          }
      }
    } catch (e) {
      setState(() {
        _error = 'Có lỗi xảy ra: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: CustomAppBar.themed(
        context: context,
        titleText: l10n.updateProfileTitle,
        actions: [
          IconButton(
            icon: Icon(Icons.language, color: Theme.of(context).iconTheme.color),
            tooltip: l10n.language,
            onPressed: () {
              // Thêm logic đổi ngôn ngữ nếu cần
            },
          ),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) => IconButton(
              icon: Icon(
                themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                color: Theme.of(context).iconTheme.color,
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        centerTitle: true,
      ),
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_error != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red),
                    ),
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                TextFormField(
                  controller: _usernameController,
                  style: Theme.of(context).textTheme.bodyLarge,
                  decoration: InputDecoration(
                    labelText: l10n.username,
                    labelStyle: Theme.of(context).inputDecorationTheme.labelStyle,
                    hintStyle: Theme.of(context).inputDecorationTheme.hintStyle,
                    border: const OutlineInputBorder(),
                    errorText: _usernameError,
                    suffixIcon: _isCheckingUsername
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            ),
                          )
                        : null,
                  ),
                  onChanged: (_) => _checkUsername(),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return l10n.usernameRequired;
                    if (value.length < 4 || value.length > 32) return l10n.usernameLength;
                    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) return l10n.usernamePattern;
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _fullNameController,
                  style: Theme.of(context).textTheme.bodyLarge,
                  decoration: InputDecoration(
                    labelText: l10n.fullName,
                    labelStyle: Theme.of(context).inputDecorationTheme.labelStyle,
                    hintStyle: Theme.of(context).inputDecorationTheme.hintStyle,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return l10n.fullNameRequired;
                    if (value.trim().length < 2) return l10n.fullNameLength;
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  style: Theme.of(context).textTheme.bodyLarge,
                  decoration: InputDecoration(
                    labelText: l10n.email,
                    labelStyle: Theme.of(context).inputDecorationTheme.labelStyle,
                    hintStyle: Theme.of(context).inputDecorationTheme.hintStyle,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return l10n.emailRequired;
                    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.[a-zA-Z]{2,}');
                    if (!emailRegex.hasMatch(value.trim())) return l10n.emailInvalid;
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () {
                    showCountryPicker(
                      context: context,
                      showPhoneCode: true,
                      countryListTheme: CountryListThemeData(
                        backgroundColor: Theme.of(context).cardColor,
                        textStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color),
                        inputDecoration: InputDecoration(
                          labelText: l10n.searchCountry,
                          labelStyle: Theme.of(context).inputDecorationTheme.labelStyle,
                          prefixIcon: Icon(Icons.search, color: Theme.of(context).iconTheme.color),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Theme.of(context).dividerColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                          ),
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                        searchTextStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.primary),
                        flagSize: 24,
                        bottomSheetHeight: 600,
                      ),
                      onSelect: (Country country) {
                        setState(() {
                          _selectedCountry = country;
                          _phoneController.clear();
                        });
                      },
                    );
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: l10n.country,
                      labelStyle: Theme.of(context).inputDecorationTheme.labelStyle,
                      hintStyle: Theme.of(context).inputDecorationTheme.hintStyle,
                      border: const OutlineInputBorder(),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_selectedCountry?.name ?? l10n.chooseCountry,
                            style: TextStyle(
                              color: (_selectedCountry == null) ? Colors.red : Colors.black,
                            )),
                        const Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                ),
                if (_selectedCountry == null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(l10n.pleaseChooseCountry, style: const TextStyle(color: Colors.red, fontSize: 12)),
                  ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  style: Theme.of(context).textTheme.bodyLarge,
                  decoration: InputDecoration(
                    labelText: l10n.phone,
                    labelStyle: Theme.of(context).inputDecorationTheme.labelStyle,
                    hintStyle: Theme.of(context).inputDecorationTheme.hintStyle,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.phone_outlined),
                    prefixText: _selectedCountry?.phoneCode != null ? '+${_selectedCountry!.phoneCode} ' : null,
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return l10n.phoneRequired;
                    final phoneRegex = RegExp(r'^(0[0-9]{9,10}|[1-9][0-9]{8,14})$');
                    if (!phoneRegex.hasMatch(value.trim())) return l10n.phoneInvalid;
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _addressController,
                  style: Theme.of(context).textTheme.bodyLarge,
                  decoration: InputDecoration(
                    labelText: l10n.address,
                    labelStyle: Theme.of(context).inputDecorationTheme.labelStyle,
                    hintStyle: Theme.of(context).inputDecorationTheme.hintStyle,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.location_on_outlined),
                  ),
                  validator: (value) => null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _bioController,
                  style: Theme.of(context).textTheme.bodyLarge,
                  decoration: InputDecoration(
                    labelText: l10n.bio,
                    labelStyle: Theme.of(context).inputDecorationTheme.labelStyle,
                    hintStyle: Theme.of(context).inputDecorationTheme.hintStyle,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.info_outline),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 3,
                  maxLength: 150,
                  validator: (value) => null,
                ),
                const SizedBox(height: 16),
                Builder(
                  builder: (context) {
                    final userInfo = Provider.of<ProfileProvider>(context);
                    final kycStatus = userInfo.userInfo?['kycStatus']?.toString().toLowerCase();
                    final isKycApproved = kycStatus == 'approved';
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                InkWell(
                          onTap: isKycApproved ? null : () => _selectDate(context),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: l10n.dob,
                      labelStyle: Theme.of(context).inputDecorationTheme.labelStyle,
                      hintStyle: Theme.of(context).inputDecorationTheme.hintStyle,
                      border: const OutlineInputBorder(),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                                Text(
                                  _selectedDate != null
                            ? DateFormat.yMMMd(Localizations.localeOf(context).toString()).format(_selectedDate!)
                                      : l10n.chooseDob,
                                  style: _selectedDate != null
                                      ? Theme.of(context).textTheme.bodyLarge
                                      : Theme.of(context).inputDecorationTheme.hintStyle,
                                ),
                        Icon(Icons.calendar_today, color: Theme.of(context).colorScheme.primary),
                      ],
                    ),
                  ),
                        ),
                        if (!isKycApproved)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Builder(
                              builder: (context) {
                                return Text(
                                  _selectedDate == null
                                      ? l10n.pleaseChooseDob
                                      : (() {
                                          final now = DateTime.now();
                                          final dob = _selectedDate!;
                                          final age = now.year - dob.year - ((now.month < dob.month || (now.month == dob.month && now.day < dob.day)) ? 1 : 0);
                                          if (age < 18) return l10n.dob18plus;
                                          return '';
                                        })(),
                                  style: const TextStyle(color: Colors.red, fontSize: 12),
                                );
                              },
                            ),
                          ),
                        if (isKycApproved)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              l10n.cannotChangeDob,
                              style: const TextStyle(color: Colors.red, fontSize: 12),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _updateProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.lightTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(l10n.update),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _bioController.dispose();
    super.dispose();
  }
} 