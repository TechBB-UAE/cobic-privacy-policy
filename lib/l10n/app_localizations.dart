import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Cobic'**
  String get appName;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Cobic'**
  String get welcome;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Login'**
  String get alreadyHaveAccount;

  /// No description provided for @scanQR.
  ///
  /// In en, this message translates to:
  /// **'QR scan'**
  String get scanQR;

  /// No description provided for @wallet.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get wallet;

  /// No description provided for @balance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get balance;

  /// No description provided for @tasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tasks;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Settings screen title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @noInternet.
  ///
  /// In en, this message translates to:
  /// **'No Internet Connection'**
  String get noInternet;

  /// No description provided for @serverError.
  ///
  /// In en, this message translates to:
  /// **'Server Error'**
  String get serverError;

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'Unknown Error'**
  String get unknownError;

  /// Language setting
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePassword;

  /// No description provided for @referralCode.
  ///
  /// In en, this message translates to:
  /// **'Referral code'**
  String get referralCode;

  /// No description provided for @kycStatus.
  ///
  /// In en, this message translates to:
  /// **'KYC status'**
  String get kycStatus;

  /// No description provided for @dob.
  ///
  /// In en, this message translates to:
  /// **'Date of birth'**
  String get dob;

  /// No description provided for @notUpdated.
  ///
  /// In en, this message translates to:
  /// **'Not updated'**
  String get notUpdated;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @approved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get approved;

  /// No description provided for @rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rejected;

  /// No description provided for @reasonKycRejected.
  ///
  /// In en, this message translates to:
  /// **'KYC rejection reason'**
  String get reasonKycRejected;

  /// No description provided for @nonTransferableBalance.
  ///
  /// In en, this message translates to:
  /// **'Non-transferable balance'**
  String get nonTransferableBalance;

  /// No description provided for @miningRate.
  ///
  /// In en, this message translates to:
  /// **'Mining rate'**
  String get miningRate;

  /// No description provided for @sendKyc.
  ///
  /// In en, this message translates to:
  /// **'Send KYC'**
  String get sendKyc;

  /// No description provided for @updateProfile.
  ///
  /// In en, this message translates to:
  /// **'Update profile'**
  String get updateProfile;

  /// No description provided for @copyReferralCode.
  ///
  /// In en, this message translates to:
  /// **'Referral code copied!'**
  String get copyReferralCode;

  /// No description provided for @shareReferral.
  ///
  /// In en, this message translates to:
  /// **'Share this code to invite others and get a mining rate bonus!'**
  String get shareReferral;

  /// No description provided for @enterReferral.
  ///
  /// In en, this message translates to:
  /// **'Enter referral code'**
  String get enterReferral;

  /// No description provided for @taskContent.
  ///
  /// In en, this message translates to:
  /// **'Task content'**
  String get taskContent;

  /// No description provided for @execute.
  ///
  /// In en, this message translates to:
  /// **'Execute'**
  String get execute;

  /// No description provided for @previousPage.
  ///
  /// In en, this message translates to:
  /// **'Previous page'**
  String get previousPage;

  /// No description provided for @searchCountry.
  ///
  /// In en, this message translates to:
  /// **'Search country'**
  String get searchCountry;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @missingEmail.
  ///
  /// In en, this message translates to:
  /// **'Email not updated'**
  String get missingEmail;

  /// No description provided for @cobicPerDay.
  ///
  /// In en, this message translates to:
  /// **'{amount} COBIC/day'**
  String cobicPerDay(Object amount);

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @notSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Not submitted'**
  String get notSubmitted;

  /// No description provided for @pendingTask.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pendingTask;

  /// No description provided for @approvedTask.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get approvedTask;

  /// No description provided for @rejectedTask.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rejectedTask;

  /// No description provided for @mining.
  ///
  /// In en, this message translates to:
  /// **'Mining'**
  String get mining;

  /// No description provided for @mine.
  ///
  /// In en, this message translates to:
  /// **'Start mining now'**
  String get mine;

  /// No description provided for @nextMining.
  ///
  /// In en, this message translates to:
  /// **'Next mining'**
  String get nextMining;

  /// No description provided for @readyToMine.
  ///
  /// In en, this message translates to:
  /// **'Ready to mine!'**
  String get readyToMine;

  /// No description provided for @countingDown.
  ///
  /// In en, this message translates to:
  /// **'Counting down...'**
  String get countingDown;

  /// No description provided for @scanVietQR.
  ///
  /// In en, this message translates to:
  /// **'Scan VietQR'**
  String get scanVietQR;

  /// No description provided for @scanVietQRDesc.
  ///
  /// In en, this message translates to:
  /// **'Scan VietQR code to receive Cobic Points\nEarn Cobic Points at a rate of 250 VND = 1 Cobic Point.'**
  String get scanVietQRDesc;

  /// No description provided for @scanNow.
  ///
  /// In en, this message translates to:
  /// **'Scan Now'**
  String get scanNow;

  /// No description provided for @currentBalance.
  ///
  /// In en, this message translates to:
  /// **'Current balance'**
  String get currentBalance;

  /// No description provided for @receiverName.
  ///
  /// In en, this message translates to:
  /// **'Receiver name'**
  String get receiverName;

  /// No description provided for @amountCobic.
  ///
  /// In en, this message translates to:
  /// **'Amount (Cobic)'**
  String get amountCobic;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @transactionHistory.
  ///
  /// In en, this message translates to:
  /// **'Transaction history'**
  String get transactionHistory;

  /// No description provided for @transactionType.
  ///
  /// In en, this message translates to:
  /// **'Transaction type'**
  String get transactionType;

  /// No description provided for @noTransaction.
  ///
  /// In en, this message translates to:
  /// **'No transaction yet'**
  String get noTransaction;

  /// No description provided for @nextPage.
  ///
  /// In en, this message translates to:
  /// **'Next page'**
  String get nextPage;

  /// No description provided for @transactionTypeMining.
  ///
  /// In en, this message translates to:
  /// **'Mining'**
  String get transactionTypeMining;

  /// No description provided for @transactionTypeDailyCheckIn.
  ///
  /// In en, this message translates to:
  /// **'Daily Check-in'**
  String get transactionTypeDailyCheckIn;

  /// No description provided for @transactionTypeTransfer.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get transactionTypeTransfer;

  /// No description provided for @transactionTypeQrScan.
  ///
  /// In en, this message translates to:
  /// **'QR Scan'**
  String get transactionTypeQrScan;

  /// No description provided for @transactionTypeBounty.
  ///
  /// In en, this message translates to:
  /// **'Bounty'**
  String get transactionTypeBounty;

  /// No description provided for @transferDescription.
  ///
  /// In en, this message translates to:
  /// **'Transfer to {receiver}'**
  String transferDescription(String receiver);

  /// No description provided for @miningDescription.
  ///
  /// In en, this message translates to:
  /// **'Mined {amount} COBIC'**
  String miningDescription(String amount);

  /// No description provided for @bountyDescription.
  ///
  /// In en, this message translates to:
  /// **'Bounty reward for {taskName}'**
  String bountyDescription(String taskName);

  /// No description provided for @dailyCheckInDescription.
  ///
  /// In en, this message translates to:
  /// **'Daily check-in reward {amount} COBIC'**
  String dailyCheckInDescription(String amount);

  /// No description provided for @qrScanDescription.
  ///
  /// In en, this message translates to:
  /// **'QR scan reward {amount} COBIC'**
  String qrScanDescription(String amount);

  /// No description provided for @referralStats.
  ///
  /// In en, this message translates to:
  /// **'Referral Statistics'**
  String get referralStats;

  /// No description provided for @invitedUsers.
  ///
  /// In en, this message translates to:
  /// **'Invited Users'**
  String get invitedUsers;

  /// No description provided for @remainingInvites.
  ///
  /// In en, this message translates to:
  /// **'Remaining Invites'**
  String get remainingInvites;

  /// No description provided for @invitedByYou.
  ///
  /// In en, this message translates to:
  /// **'Users You\'ve Invited'**
  String get invitedByYou;

  /// No description provided for @noInvitedUsers.
  ///
  /// In en, this message translates to:
  /// **'No users invited yet'**
  String get noInvitedUsers;

  /// No description provided for @invitedBy.
  ///
  /// In en, this message translates to:
  /// **'Invited By'**
  String get invitedBy;

  /// No description provided for @noReferrer.
  ///
  /// In en, this message translates to:
  /// **'No one has invited you yet'**
  String get noReferrer;

  /// No description provided for @securityCircle.
  ///
  /// In en, this message translates to:
  /// **'Security Circle'**
  String get securityCircle;

  /// No description provided for @noSecurityCircle.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have a security circle yet'**
  String get noSecurityCircle;

  /// No description provided for @securityCircleDesc.
  ///
  /// In en, this message translates to:
  /// **'A security circle is created when two users refer each other. Find someone you trust and create a security circle to get +0.1 to your mining rate.'**
  String get securityCircleDesc;

  /// No description provided for @yourReferralCode.
  ///
  /// In en, this message translates to:
  /// **'Your Referral Code'**
  String get yourReferralCode;

  /// No description provided for @enterReferralCode.
  ///
  /// In en, this message translates to:
  /// **'Enter Referral Code'**
  String get enterReferralCode;

  /// No description provided for @referralCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Enter code'**
  String get referralCodeHint;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @alreadyEnteredCode.
  ///
  /// In en, this message translates to:
  /// **'You have already entered a referral code, you can only enter it once!'**
  String get alreadyEnteredCode;

  /// No description provided for @enterCodeSuccess.
  ///
  /// In en, this message translates to:
  /// **'Referral code entered successfully!'**
  String get enterCodeSuccess;

  /// No description provided for @pleaseEnterCode.
  ///
  /// In en, this message translates to:
  /// **'Please enter a referral code!'**
  String get pleaseEnterCode;

  /// No description provided for @joinedAt.
  ///
  /// In en, this message translates to:
  /// **'Joined {date}'**
  String joinedAt(String date);

  /// No description provided for @referralCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Referral code: {code}'**
  String referralCodeLabel(String code);

  /// No description provided for @updateProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Update Profile'**
  String get updateProfileTitle;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @country.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get country;

  /// No description provided for @chooseCountry.
  ///
  /// In en, this message translates to:
  /// **'Choose country'**
  String get chooseCountry;

  /// No description provided for @pleaseChooseCountry.
  ///
  /// In en, this message translates to:
  /// **'Please choose a country'**
  String get pleaseChooseCountry;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phone;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @bio.
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get bio;

  /// No description provided for @chooseDob.
  ///
  /// In en, this message translates to:
  /// **'Choose date of birth'**
  String get chooseDob;

  /// No description provided for @pleaseChooseDob.
  ///
  /// In en, this message translates to:
  /// **'Please choose date of birth'**
  String get pleaseChooseDob;

  /// No description provided for @dob18plus.
  ///
  /// In en, this message translates to:
  /// **'You must be at least 18 years old'**
  String get dob18plus;

  /// No description provided for @cannotChangeDob.
  ///
  /// In en, this message translates to:
  /// **'Cannot change date of birth after KYC is approved'**
  String get cannotChangeDob;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @usernameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter username'**
  String get usernameRequired;

  /// No description provided for @usernameLength.
  ///
  /// In en, this message translates to:
  /// **'Username must be 4-32 characters'**
  String get usernameLength;

  /// No description provided for @usernamePattern.
  ///
  /// In en, this message translates to:
  /// **'Only letters, numbers, and underscores allowed'**
  String get usernamePattern;

  /// No description provided for @usernameExists.
  ///
  /// In en, this message translates to:
  /// **'Username already exists'**
  String get usernameExists;

  /// No description provided for @fullNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter full name'**
  String get fullNameRequired;

  /// No description provided for @fullNameLength.
  ///
  /// In en, this message translates to:
  /// **'Full name must be at least 2 characters'**
  String get fullNameLength;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter email'**
  String get emailRequired;

  /// No description provided for @emailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid email'**
  String get emailInvalid;

  /// No description provided for @emailExists.
  ///
  /// In en, this message translates to:
  /// **'Email already exists'**
  String get emailExists;

  /// No description provided for @phoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter phone number'**
  String get phoneRequired;

  /// No description provided for @phoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid phone number'**
  String get phoneInvalid;

  /// No description provided for @updateProfileSuccess.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully!'**
  String get updateProfileSuccess;

  /// No description provided for @updateProfileError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while updating profile'**
  String get updateProfileError;

  /// No description provided for @changePasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePasswordTitle;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPassword;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get confirmNewPassword;

  /// No description provided for @currentPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter current password'**
  String get currentPasswordRequired;

  /// No description provided for @newPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter new password'**
  String get newPasswordRequired;

  /// No description provided for @newPasswordLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get newPasswordLength;

  /// No description provided for @newPasswordUpper.
  ///
  /// In en, this message translates to:
  /// **'Password must contain at least one uppercase letter'**
  String get newPasswordUpper;

  /// No description provided for @confirmPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please confirm new password'**
  String get confirmPasswordRequired;

  /// No description provided for @confirmPasswordNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get confirmPasswordNotMatch;

  /// No description provided for @changePasswordSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully!'**
  String get changePasswordSuccess;

  /// No description provided for @changePasswordError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while changing password'**
  String get changePasswordError;

  /// No description provided for @loginTokenNotFound.
  ///
  /// In en, this message translates to:
  /// **'Login token not found'**
  String get loginTokenNotFound;

  /// No description provided for @kycSubmitTitle.
  ///
  /// In en, this message translates to:
  /// **'Submit KYC'**
  String get kycSubmitTitle;

  /// No description provided for @kycApprovedMsg.
  ///
  /// In en, this message translates to:
  /// **'Your KYC has been successfully verified!'**
  String get kycApprovedMsg;

  /// No description provided for @kycPendingMsg.
  ///
  /// In en, this message translates to:
  /// **'Your KYC application is under review. Please wait for the result.'**
  String get kycPendingMsg;

  /// No description provided for @kycTakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get kycTakePhoto;

  /// No description provided for @kycChooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get kycChooseFromGallery;

  /// No description provided for @kycSubmitSuccess.
  ///
  /// In en, this message translates to:
  /// **'KYC submission successful!'**
  String get kycSubmitSuccess;

  /// No description provided for @kycSelectCountry.
  ///
  /// In en, this message translates to:
  /// **'Select country'**
  String get kycSelectCountry;

  /// No description provided for @kycSelectAllImages.
  ///
  /// In en, this message translates to:
  /// **'Please select all 3 images.'**
  String get kycSelectAllImages;

  /// No description provided for @kycFullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get kycFullName;

  /// No description provided for @kycDob.
  ///
  /// In en, this message translates to:
  /// **'Date of birth'**
  String get kycDob;

  /// No description provided for @kycAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get kycAddress;

  /// No description provided for @kycIdentityNumber.
  ///
  /// In en, this message translates to:
  /// **'Identity document number'**
  String get kycIdentityNumber;

  /// No description provided for @kycDocumentType.
  ///
  /// In en, this message translates to:
  /// **'Document type'**
  String get kycDocumentType;

  /// No description provided for @kycNationalId.
  ///
  /// In en, this message translates to:
  /// **'National ID'**
  String get kycNationalId;

  /// No description provided for @kycPassport.
  ///
  /// In en, this message translates to:
  /// **'Passport'**
  String get kycPassport;

  /// No description provided for @kycDriversLicense.
  ///
  /// In en, this message translates to:
  /// **'Driver\'s license'**
  String get kycDriversLicense;

  /// No description provided for @kycFrontImage.
  ///
  /// In en, this message translates to:
  /// **'Front of document'**
  String get kycFrontImage;

  /// No description provided for @kycBackImage.
  ///
  /// In en, this message translates to:
  /// **'Back of document'**
  String get kycBackImage;

  /// No description provided for @kycSelfieImage.
  ///
  /// In en, this message translates to:
  /// **'Selfie with document'**
  String get kycSelfieImage;

  /// No description provided for @kycSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit KYC'**
  String get kycSubmit;

  /// No description provided for @kycRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get kycRequired;

  /// No description provided for @kycDobFormat.
  ///
  /// In en, this message translates to:
  /// **'Date of birth (YYYY-MM-DD)'**
  String get kycDobFormat;

  /// No description provided for @kycAddressOptional.
  ///
  /// In en, this message translates to:
  /// **'Address (optional)'**
  String get kycAddressOptional;

  /// No description provided for @kycIdType.
  ///
  /// In en, this message translates to:
  /// **'Identity document type'**
  String get kycIdType;

  /// No description provided for @kycFrontImageTitle.
  ///
  /// In en, this message translates to:
  /// **'Front of identity document:'**
  String get kycFrontImageTitle;

  /// No description provided for @kycBackImageTitle.
  ///
  /// In en, this message translates to:
  /// **'Back of identity document:'**
  String get kycBackImageTitle;

  /// No description provided for @kycSelfieImageTitle.
  ///
  /// In en, this message translates to:
  /// **'Selfie with identity document:'**
  String get kycSelfieImageTitle;

  /// No description provided for @kycSelectOrTakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Select/take photo'**
  String get kycSelectOrTakePhoto;

  /// No description provided for @kycSearchCountry.
  ///
  /// In en, this message translates to:
  /// **'Search country'**
  String get kycSearchCountry;

  /// No description provided for @referral.
  ///
  /// In en, this message translates to:
  /// **'Referral'**
  String get referral;

  /// No description provided for @logoutSuccess.
  ///
  /// In en, this message translates to:
  /// **'Logout successful!'**
  String get logoutSuccess;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'Or'**
  String get or;

  /// No description provided for @loginGuest.
  ///
  /// In en, this message translates to:
  /// **'Quick login (guest)'**
  String get loginGuest;

  /// No description provided for @registerNewAccount.
  ///
  /// In en, this message translates to:
  /// **'Register new account'**
  String get registerNewAccount;

  /// No description provided for @loginSuccess.
  ///
  /// In en, this message translates to:
  /// **'Login successful!'**
  String get loginSuccess;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed!'**
  String get loginFailed;

  /// No description provided for @wrongCredentials.
  ///
  /// In en, this message translates to:
  /// **'Wrong username or password!'**
  String get wrongCredentials;

  /// No description provided for @guestLoginFailed.
  ///
  /// In en, this message translates to:
  /// **'Quick login failed!'**
  String get guestLoginFailed;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter password'**
  String get passwordRequired;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMinLength;

  /// No description provided for @passwordPattern.
  ///
  /// In en, this message translates to:
  /// **'Password must contain at least 1 letter and 1 number'**
  String get passwordPattern;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Register Account'**
  String get registerTitle;

  /// No description provided for @registerSuccess.
  ///
  /// In en, this message translates to:
  /// **'Registration successful!'**
  String get registerSuccess;

  /// No description provided for @registerFailed.
  ///
  /// In en, this message translates to:
  /// **'Registration failed!'**
  String get registerFailed;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordDesc.
  ///
  /// In en, this message translates to:
  /// **'Enter your registered email to receive password reset instructions.'**
  String get forgotPasswordDesc;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send reset instructions'**
  String get sendResetLink;

  /// No description provided for @resetLinkSent.
  ///
  /// In en, this message translates to:
  /// **'Reset instructions sent! Please check your email.'**
  String get resetLinkSent;

  /// No description provided for @resetLinkFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to send reset instructions!'**
  String get resetLinkFailed;

  /// No description provided for @logoutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Logout confirmation'**
  String get logoutConfirmTitle;

  /// No description provided for @logoutConfirmContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirmContent;

  /// No description provided for @referent.
  ///
  /// In en, this message translates to:
  /// **'Referent'**
  String get referent;

  /// No description provided for @guestAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Guest Account'**
  String get guestAccountTitle;

  /// No description provided for @guestUsername.
  ///
  /// In en, this message translates to:
  /// **'Username:'**
  String get guestUsername;

  /// No description provided for @guestPassword.
  ///
  /// In en, this message translates to:
  /// **'Password:'**
  String get guestPassword;

  /// No description provided for @guestSaveInfoNote.
  ///
  /// In en, this message translates to:
  /// **'Save this information to log in later!'**
  String get guestSaveInfoNote;

  /// No description provided for @guestSavedToGallery.
  ///
  /// In en, this message translates to:
  /// **'Information saved to gallery!'**
  String get guestSavedToGallery;

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Cobic'**
  String get appTitle;

  /// Theme setting
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// System theme option
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get systemTheme;

  /// Light theme option
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get lightTheme;

  /// Dark theme option
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get darkTheme;

  /// No description provided for @cannotTransferToYourself.
  ///
  /// In en, this message translates to:
  /// **'Cannot transfer to yourself'**
  String get cannotTransferToYourself;

  /// No description provided for @recipientNotFound.
  ///
  /// In en, this message translates to:
  /// **'Recipient not found'**
  String get recipientNotFound;

  /// No description provided for @invalidAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount!'**
  String get invalidAmount;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
