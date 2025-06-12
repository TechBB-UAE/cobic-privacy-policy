import 'package:flutter/material.dart';
import 'package:cobic/theme/app_theme.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:cobic/services/profile_service.dart';
import 'package:cobic/utils/error_utils.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:country_picker/country_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:provider/provider.dart';
import 'package:cobic/providers/profile_provider.dart';
import 'package:cobic/screens/main_tab_screen.dart';
import 'package:image/image.dart' as img;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:cobic/providers/theme_provider.dart';
import 'package:intl/intl.dart';
import 'package:cobic/theme/custom_app_bar.dart';

class KycSubmitScreen extends StatefulWidget {
  const KycSubmitScreen({Key? key}) : super(key: key);

  @override
  State<KycSubmitScreen> createState() => _KycSubmitScreenState();
}

class _KycSubmitScreenState extends State<KycSubmitScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _identityNumberController = TextEditingController();
  XFile? _idCardFrontFile;
  XFile? _idCardBackFile;
  XFile? _selfieWithIdCardFile;
  String _documentType = 'national_id';
  String _country = 'VN';
  Country? _selectedCountry;

  @override
  void dispose() {
    _fullNameController.dispose();
    _dobController.dispose();
    _addressController.dispose();
    _identityNumberController.dispose();
    super.dispose();
  }

  String getMimeType(String path) {
    final ext = path.toLowerCase();
    if (ext.endsWith('.png')) return 'png';
    if (ext.endsWith('.webp')) return 'webp';
    return 'jpeg'; // default
  }

  Future<List<int>> compressImage(String filePath) async {
    return await FlutterImageCompress.compressWithFile(
      filePath,
      minWidth: 1024,
      minHeight: 1024,
      quality: 70,
      format: CompressFormat.jpeg,
    ) ?? [];
  }

  Future<void> _submitKyc() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCountry == null || _country.isEmpty) {
      ErrorUtils.showErrorToast(context, AppLocalizations.of(context)!.kycSelectCountry);
      return;
    }
    if (_idCardFrontFile == null || _idCardBackFile == null || _selfieWithIdCardFile == null) {
      ErrorUtils.showErrorToast(context, AppLocalizations.of(context)!.kycSelectAllImages);
      return;
    }
    try {
      final compressedFront = await compressImage(_idCardFrontFile!.path);
      final compressedBack = await compressImage(_idCardBackFile!.path);
      final compressedSelfie = await compressImage(_selfieWithIdCardFile!.path);

      final formData = FormData.fromMap({
        "fullName": _fullNameController.text,
        "dateOfBirth": _dobController.text,
        "country": _country,
        "address": _addressController.text,
        "documentType": _documentType,
        "documentFront": MultipartFile.fromBytes(
          compressedFront,
          filename: "front.jpg",
          contentType: MediaType('image', 'jpeg'),
        ),
        "documentBack": MultipartFile.fromBytes(
          compressedBack,
          filename: "back.jpg",
          contentType: MediaType('image', 'jpeg'),
        ),
        "selfieWithDocument": MultipartFile.fromBytes(
          compressedSelfie,
          filename: "selfie.jpg",
          contentType: MediaType('image', 'jpeg'),
        ),
      });
      await ProfileService.submitKyc(formData);
      ErrorUtils.showSuccessToast(context, AppLocalizations.of(context)!.kycSubmitSuccess);
      await Future.delayed(const Duration(milliseconds: 1200));
      if (mounted) {
        try {
          await Provider.of<ProfileProvider>(context, listen: false).fetchUserInfo(context);
        } catch (e, stack) {
          debugPrint('KYC fetchUserInfo error: $e\n$stack');
        }
        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainTabScreen(initialTab: 0)),
          (route) => false,
        );
      }
    } catch (e, stack) {
      debugPrint('KYC submit error: $e\n$stack');
      ErrorUtils.showErrorToast(context, ErrorUtils.parseApiError(e));
    }
  }

  Future<void> _pickImage(Function(XFile) onPicked) async {
    final picker = ImagePicker();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt, color: Theme.of(context).colorScheme.primary),
                title: Text(AppLocalizations.of(context)!.kycTakePhoto, style: Theme.of(context).textTheme.bodyLarge),
                onTap: () async {
                  Navigator.of(context).pop();
                  final pickedFile = await picker.pickImage(source: ImageSource.camera, imageQuality: 70);
                  if (pickedFile != null) {
                    onPicked(pickedFile);
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library, color: Theme.of(context).colorScheme.primary),
                title: Text(AppLocalizations.of(context)!.kycChooseFromGallery, style: Theme.of(context).textTheme.bodyLarge),
                onTap: () async {
                  Navigator.of(context).pop();
                  final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
                  if (pickedFile != null) {
                    onPicked(pickedFile);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final profileProvider = Provider.of<ProfileProvider>(context);
    final userInfo = profileProvider.userInfo;
    final kycStatus = userInfo?['kycStatus']?.toString().toLowerCase();

    String? kycMessage;
    if (kycStatus == 'approved') {
      kycMessage = AppLocalizations.of(context)!.kycApprovedMsg;
    } else if (kycStatus == 'pending') {
      kycMessage = AppLocalizations.of(context)!.kycPendingMsg;
    }

    return Scaffold(
      appBar: CustomAppBar.themed(
        context: context,
        titleText: l10n.kycSubmitTitle,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
      ),
      body: kycMessage != null
          ? Center(
              child: Card(
                color: Theme.of(context).cardColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 2,
                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified_user, color: Theme.of(context).colorScheme.primary, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        kycMessage,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _fullNameController,
                      style: Theme.of(context).textTheme.bodyLarge,
                      decoration: InputDecoration(
                        labelText: l10n.kycFullName,
                        labelStyle: Theme.of(context).inputDecorationTheme.labelStyle,
                        hintStyle: Theme.of(context).inputDecorationTheme.hintStyle,
                        border: const OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person_outline, color: Theme.of(context).iconTheme.color),
                      ),
                      validator: (v) => v == null || v.isEmpty ? l10n.kycRequired : null,
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                          builder: (context, child) {
                            final theme = Theme.of(context);
                            final isDark = theme.brightness == Brightness.dark;
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
                        if (picked != null) {
                          _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
                        }
                      },
                      child: IgnorePointer(
                        child: TextFormField(
                          controller: _dobController,
                          style: Theme.of(context).textTheme.bodyLarge,
                          decoration: InputDecoration(
                            labelText: l10n.kycDobFormat,
                            labelStyle: Theme.of(context).inputDecorationTheme.labelStyle,
                            hintStyle: Theme.of(context).inputDecorationTheme.hintStyle,
                            border: const OutlineInputBorder(),
                            prefixIcon: Icon(Icons.cake_outlined, color: Theme.of(context).iconTheme.color),
                          ),
                          validator: (v) => v == null || v.isEmpty ? l10n.kycRequired : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () {
                        showCountryPicker(
                          context: context,
                          showPhoneCode: false,
                          countryListTheme: CountryListThemeData(
                            backgroundColor: Theme.of(context).cardColor,
                            textStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color),
                            inputDecoration: InputDecoration(
                              labelText: l10n.kycSearchCountry,
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
                              _country = country.countryCode;
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
                          prefixIcon: Icon(Icons.flag_outlined, color: Theme.of(context).iconTheme.color),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_selectedCountry?.name ?? l10n.kycSelectCountry,
                              style: _selectedCountry != null
                                  ? Theme.of(context).textTheme.bodyLarge
                                  : Theme.of(context).inputDecorationTheme.hintStyle),
                            Icon(Icons.arrow_drop_down, color: Theme.of(context).iconTheme.color),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _addressController,
                      style: Theme.of(context).textTheme.bodyLarge,
                      decoration: InputDecoration(
                        labelText: l10n.kycAddressOptional,
                        labelStyle: Theme.of(context).inputDecorationTheme.labelStyle,
                        hintStyle: Theme.of(context).inputDecorationTheme.hintStyle,
                        border: const OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_on_outlined, color: Theme.of(context).iconTheme.color),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _documentType,
                      decoration: InputDecoration(
                        labelText: l10n.kycIdType,
                        labelStyle: Theme.of(context).inputDecorationTheme.labelStyle,
                        hintStyle: Theme.of(context).inputDecorationTheme.hintStyle,
                        border: const OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description_outlined, color: Theme.of(context).iconTheme.color),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'national_id',
                          child: Text(l10n.kycNationalId, style: Theme.of(context).textTheme.bodyLarge),
                        ),
                        DropdownMenuItem(
                          value: 'passport',
                          child: Text(l10n.kycPassport, style: Theme.of(context).textTheme.bodyLarge),
                        ),
                        DropdownMenuItem(
                          value: 'drivers_license',
                          child: Text(l10n.kycDriversLicense, style: Theme.of(context).textTheme.bodyLarge),
                        ),
                      ],
                      dropdownColor: Theme.of(context).cardColor,
                      style: Theme.of(context).textTheme.bodyLarge,
                      onChanged: (v) => setState(() => _documentType = v ?? 'national_id'),
                      validator: (v) => v == null || v.isEmpty ? l10n.kycRequired : null,
                    ),
                    const SizedBox(height: 16),
                    Text(l10n.kycFrontImageTitle, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 90,
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Theme.of(context).dividerColor, width: 1.2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: _idCardFrontFile == null
                                ? IconButton(
                                    icon: Icon(Icons.add_a_photo, color: Theme.of(context).colorScheme.primary, size: 32),
                                    onPressed: () => _pickImage((img) => setState(() => _idCardFrontFile = img)),
                                    tooltip: l10n.kycSelectOrTakePhoto,
                                  )
                                : Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(14),
                                        child: Image.file(
                                          File(_idCardFrontFile!.path),
                                          width: double.infinity,
                                          height: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Positioned(
                                        top: 4,
                                        right: 4,
                                        child: InkWell(
                                          onTap: () => setState(() => _idCardFrontFile = null),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Theme.of(context).cardColor.withOpacity(0.85),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(Icons.close, color: Colors.red, size: 20),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            height: 90,
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Theme.of(context).dividerColor, width: 1.2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: _idCardBackFile == null
                                ? IconButton(
                                    icon: Icon(Icons.add_a_photo, color: Theme.of(context).colorScheme.primary, size: 32),
                                    onPressed: () => _pickImage((img) => setState(() => _idCardBackFile = img)),
                                    tooltip: l10n.kycSelectOrTakePhoto,
                                  )
                                : Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(14),
                                        child: Image.file(
                                          File(_idCardBackFile!.path),
                                          width: double.infinity,
                                          height: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Positioned(
                                        top: 4,
                                        right: 4,
                                        child: InkWell(
                                          onTap: () => setState(() => _idCardBackFile = null),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Theme.of(context).cardColor.withOpacity(0.85),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(Icons.close, color: Colors.red, size: 20),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(l10n.kycSelfieImageTitle, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                    Container(
                      height: 90,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Theme.of(context).dividerColor, width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: _selfieWithIdCardFile == null
                          ? IconButton(
                              icon: Icon(Icons.add_a_photo, color: Theme.of(context).colorScheme.primary, size: 32),
                              onPressed: () => _pickImage((img) => setState(() => _selfieWithIdCardFile = img)),
                              tooltip: l10n.kycSelectOrTakePhoto,
                            )
                          : Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Image.file(
                                    File(_selfieWithIdCardFile!.path),
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: InkWell(
                                    onTap: () => setState(() => _selfieWithIdCardFile = null),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).cardColor.withOpacity(0.85),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(Icons.close, color: Colors.red, size: 20),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitKyc,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(l10n.kycSubmit),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
} 