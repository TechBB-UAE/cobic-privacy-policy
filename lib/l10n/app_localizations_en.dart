// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Cobic';

  @override
  String get welcome => 'Welcome to Cobic';

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  @override
  String get alreadyHaveAccount => 'Already have an account? Login';

  @override
  String get scanQR => 'QR scan';

  @override
  String get wallet => 'Wallet';

  @override
  String get balance => 'Balance';

  @override
  String get tasks => 'Tasks';

  @override
  String get profile => 'Profile';

  @override
  String get settings => 'Settings';

  @override
  String get logout => 'Logout';

  @override
  String get submit => 'Submit';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String get success => 'Success';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get noInternet => 'No Internet Connection';

  @override
  String get serverError => 'Server Error';

  @override
  String get unknownError => 'Unknown Error';

  @override
  String get language => 'Language';

  @override
  String get changePassword => 'Change password';

  @override
  String get referralCode => 'Referral code';

  @override
  String get kycStatus => 'KYC status';

  @override
  String get dob => 'Date of birth';

  @override
  String get notUpdated => 'Not updated';

  @override
  String get pending => 'Pending';

  @override
  String get approved => 'Approved';

  @override
  String get rejected => 'Rejected';

  @override
  String get reasonKycRejected => 'KYC rejection reason';

  @override
  String get nonTransferableBalance => 'Non-transferable balance';

  @override
  String get miningRate => 'Mining rate';

  @override
  String get sendKyc => 'Send KYC';

  @override
  String get updateProfile => 'Update profile';

  @override
  String get copyReferralCode => 'Referral code copied!';

  @override
  String get shareReferral =>
      'Share this code to invite others and get a mining rate bonus!';

  @override
  String get enterReferral => 'Enter referral code';

  @override
  String get taskContent => 'Task content';

  @override
  String get execute => 'Execute';

  @override
  String get previousPage => 'Previous page';

  @override
  String get searchCountry => 'Search country';

  @override
  String get account => 'Account';

  @override
  String get close => 'Close';

  @override
  String get missingEmail => 'Email not updated';

  @override
  String cobicPerDay(Object amount) {
    return '$amount COBIC/day';
  }

  @override
  String get all => 'All';

  @override
  String get notSubmitted => 'Not submitted';

  @override
  String get pendingTask => 'Pending';

  @override
  String get approvedTask => 'Approved';

  @override
  String get rejectedTask => 'Rejected';

  @override
  String get mining => 'Mining';

  @override
  String get mine => 'Start mining now';

  @override
  String get nextMining => 'Next mining';

  @override
  String get readyToMine => 'Ready to mine!';

  @override
  String get countingDown => 'Counting down...';

  @override
  String get scanVietQR => 'Scan VietQR';

  @override
  String get scanVietQRDesc =>
      'Scan VietQR code to receive Cobic Points\nEarn Cobic Points at a rate of 250 VND = 1 Cobic Point.';

  @override
  String get scanNow => 'Scan Now';

  @override
  String get currentBalance => 'Current balance';

  @override
  String get receiverName => 'Receiver name';

  @override
  String get amountCobic => 'Amount (Cobic)';

  @override
  String get send => 'Send';

  @override
  String get transactionHistory => 'Transaction history';

  @override
  String get transactionType => 'Transaction type';

  @override
  String get noTransaction => 'No transaction yet';

  @override
  String get nextPage => 'Next page';

  @override
  String get transactionTypeMining => 'Mining';

  @override
  String get transactionTypeDailyCheckIn => 'Daily Check-in';

  @override
  String get transactionTypeTransfer => 'Transfer';

  @override
  String get transactionTypeQrScan => 'QR Scan';

  @override
  String get transactionTypeBounty => 'Bounty';

  @override
  String transferDescription(String receiver) {
    return 'Transfer to $receiver';
  }

  @override
  String miningDescription(String amount) {
    return 'Mined $amount COBIC';
  }

  @override
  String bountyDescription(String taskName) {
    return 'Bounty reward for $taskName';
  }

  @override
  String dailyCheckInDescription(String amount) {
    return 'Daily check-in reward $amount COBIC';
  }

  @override
  String qrScanDescription(String amount) {
    return 'QR scan reward $amount COBIC';
  }

  @override
  String get referralStats => 'Referral Statistics';

  @override
  String get invitedUsers => 'Invited Users';

  @override
  String get remainingInvites => 'Remaining Invites';

  @override
  String get invitedByYou => 'Users You\'ve Invited';

  @override
  String get noInvitedUsers => 'No users invited yet';

  @override
  String get invitedBy => 'Invited By';

  @override
  String get noReferrer => 'No one has invited you yet';

  @override
  String get securityCircle => 'Security Circle';

  @override
  String get noSecurityCircle => 'You don\'t have a security circle yet';

  @override
  String get securityCircleDesc =>
      'A security circle is created when two users refer each other. Find someone you trust and create a security circle to get +0.1 to your mining rate.';

  @override
  String get yourReferralCode => 'Your Referral Code';

  @override
  String get enterReferralCode => 'Enter Referral Code';

  @override
  String get referralCodeHint => 'Enter code';

  @override
  String get apply => 'Apply';

  @override
  String get alreadyEnteredCode =>
      'You have already entered a referral code, you can only enter it once!';

  @override
  String get enterCodeSuccess => 'Referral code entered successfully!';

  @override
  String get pleaseEnterCode => 'Please enter a referral code!';

  @override
  String joinedAt(String date) {
    return 'Joined $date';
  }

  @override
  String referralCodeLabel(String code) {
    return 'Referral code: $code';
  }

  @override
  String get updateProfileTitle => 'Update Profile';

  @override
  String get username => 'Username';

  @override
  String get fullName => 'Full name';

  @override
  String get country => 'Country';

  @override
  String get chooseCountry => 'Choose country';

  @override
  String get pleaseChooseCountry => 'Please choose a country';

  @override
  String get phone => 'Phone number';

  @override
  String get address => 'Address';

  @override
  String get bio => 'Bio';

  @override
  String get chooseDob => 'Choose date of birth';

  @override
  String get pleaseChooseDob => 'Please choose date of birth';

  @override
  String get dob18plus => 'You must be at least 18 years old';

  @override
  String get cannotChangeDob =>
      'Cannot change date of birth after KYC is approved';

  @override
  String get update => 'Update';

  @override
  String get usernameRequired => 'Please enter username';

  @override
  String get usernameLength => 'Username must be 4-32 characters';

  @override
  String get usernamePattern =>
      'Only letters, numbers, and underscores allowed';

  @override
  String get usernameExists => 'Username already exists';

  @override
  String get fullNameRequired => 'Please enter full name';

  @override
  String get fullNameLength => 'Full name must be at least 2 characters';

  @override
  String get emailRequired => 'Please enter email';

  @override
  String get emailInvalid => 'Invalid email';

  @override
  String get emailExists => 'Email already exists';

  @override
  String get phoneRequired => 'Please enter phone number';

  @override
  String get phoneInvalid => 'Invalid phone number';

  @override
  String get updateProfileSuccess => 'Profile updated successfully!';

  @override
  String get updateProfileError => 'An error occurred while updating profile';

  @override
  String get changePasswordTitle => 'Change password';

  @override
  String get currentPassword => 'Current password';

  @override
  String get newPassword => 'New password';

  @override
  String get confirmNewPassword => 'Confirm new password';

  @override
  String get currentPasswordRequired => 'Please enter current password';

  @override
  String get newPasswordRequired => 'Please enter new password';

  @override
  String get newPasswordLength => 'Password must be at least 8 characters';

  @override
  String get newPasswordUpper =>
      'Password must contain at least one uppercase letter';

  @override
  String get confirmPasswordRequired => 'Please confirm new password';

  @override
  String get confirmPasswordNotMatch => 'Passwords do not match';

  @override
  String get changePasswordSuccess => 'Password changed successfully!';

  @override
  String get changePasswordError => 'An error occurred while changing password';

  @override
  String get loginTokenNotFound => 'Login token not found';

  @override
  String get kycSubmitTitle => 'Submit KYC';

  @override
  String get kycApprovedMsg => 'Your KYC has been successfully verified!';

  @override
  String get kycPendingMsg =>
      'Your KYC application is under review. Please wait for the result.';

  @override
  String get kycTakePhoto => 'Take photo';

  @override
  String get kycChooseFromGallery => 'Choose from gallery';

  @override
  String get kycSubmitSuccess => 'KYC submission successful!';

  @override
  String get kycSelectCountry => 'Select country';

  @override
  String get kycSelectAllImages => 'Please select all 3 images.';

  @override
  String get kycFullName => 'Full name';

  @override
  String get kycDob => 'Date of birth';

  @override
  String get kycAddress => 'Address';

  @override
  String get kycIdentityNumber => 'Identity document number';

  @override
  String get kycDocumentType => 'Document type';

  @override
  String get kycNationalId => 'National ID';

  @override
  String get kycPassport => 'Passport';

  @override
  String get kycDriversLicense => 'Driver\'s license';

  @override
  String get kycFrontImage => 'Front of document';

  @override
  String get kycBackImage => 'Back of document';

  @override
  String get kycSelfieImage => 'Selfie with document';

  @override
  String get kycSubmit => 'Submit KYC';

  @override
  String get kycRequired => 'Required';

  @override
  String get kycDobFormat => 'Date of birth (YYYY-MM-DD)';

  @override
  String get kycAddressOptional => 'Address (optional)';

  @override
  String get kycIdType => 'Identity document type';

  @override
  String get kycFrontImageTitle => 'Front of identity document:';

  @override
  String get kycBackImageTitle => 'Back of identity document:';

  @override
  String get kycSelfieImageTitle => 'Selfie with identity document:';

  @override
  String get kycSelectOrTakePhoto => 'Select/take photo';

  @override
  String get kycSearchCountry => 'Search country';

  @override
  String get referral => 'Referral';

  @override
  String get logoutSuccess => 'Logout successful!';

  @override
  String get or => 'Or';

  @override
  String get loginGuest => 'Quick login (guest)';

  @override
  String get registerNewAccount => 'Register new account';

  @override
  String get loginSuccess => 'Login successful!';

  @override
  String get loginFailed => 'Login failed!';

  @override
  String get wrongCredentials => 'Wrong username or password!';

  @override
  String get guestLoginFailed => 'Quick login failed!';

  @override
  String get passwordRequired => 'Please enter password';

  @override
  String get passwordMinLength => 'Password must be at least 6 characters';

  @override
  String get passwordPattern =>
      'Password must contain at least 1 letter and 1 number';

  @override
  String get registerTitle => 'Register Account';

  @override
  String get registerSuccess => 'Registration successful!';

  @override
  String get registerFailed => 'Registration failed!';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get forgotPasswordTitle => 'Forgot Password';

  @override
  String get forgotPasswordDesc =>
      'Enter your registered email to receive password reset instructions.';

  @override
  String get sendResetLink => 'Send reset instructions';

  @override
  String get resetLinkSent =>
      'Reset instructions sent! Please check your email.';

  @override
  String get resetLinkFailed => 'Failed to send reset instructions!';

  @override
  String get logoutConfirmTitle => 'Logout confirmation';

  @override
  String get logoutConfirmContent => 'Are you sure you want to logout?';

  @override
  String get referent => 'Referent';

  @override
  String get guestAccountTitle => 'Guest Account';

  @override
  String get guestUsername => 'Username:';

  @override
  String get guestPassword => 'Password:';

  @override
  String get guestSaveInfoNote => 'Save this information to log in later!';

  @override
  String get guestSavedToGallery => 'Information saved to gallery!';

  @override
  String get appTitle => 'Cobic';

  @override
  String get theme => 'Theme';

  @override
  String get systemTheme => 'System';

  @override
  String get lightTheme => 'Light';

  @override
  String get darkTheme => 'Dark';

  @override
  String get cannotTransferToYourself => 'Cannot transfer to yourself';

  @override
  String get recipientNotFound => 'Recipient not found';

  @override
  String get invalidAmount => 'Please enter a valid amount!';
}
