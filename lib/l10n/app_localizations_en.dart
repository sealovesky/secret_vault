// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Secret Vault';

  @override
  String get passwords => 'Passwords';

  @override
  String get notes => 'Notes';

  @override
  String get settings => 'Settings';

  @override
  String get lockScreenTitle => 'Secret Vault';

  @override
  String get lockScreenDesc =>
      'Securely store your passwords and private notes\nAll data is encrypted locally';

  @override
  String unlockWithBiometric(String type) {
    return 'Unlock with $type';
  }

  @override
  String get authenticating => 'Authenticating...';

  @override
  String get tapToAuthenticate => 'Tap the button above to authenticate';

  @override
  String get dataSecurity => 'Data secure, locally encrypted';

  @override
  String get contentHidden => 'Content hidden';

  @override
  String get authenticateReason => 'Authenticate to access Secret Vault';

  @override
  String get usePinUnlock => 'Unlock with PIN';

  @override
  String get enterPinCode => 'Enter PIN';

  @override
  String get confirmPinCode => 'Confirm PIN';

  @override
  String get pinCodeSetup => 'Set PIN Code';

  @override
  String get enterSixDigitPin => 'Enter a 6-digit PIN';

  @override
  String get reenterPin => 'Re-enter your PIN';

  @override
  String get pinMismatch => 'PINs don\'t match, please try again';

  @override
  String get pinUpdated => 'PIN updated';

  @override
  String get pinSetSuccess => 'PIN set successfully';

  @override
  String pinRateLimited(int seconds) {
    return 'Too many attempts, please wait ${seconds}s';
  }

  @override
  String pinErrorRateLimit(int seconds) {
    return 'Incorrect PIN, please wait ${seconds}s';
  }

  @override
  String pinErrorAttemptsLeft(int remaining) {
    return 'Incorrect PIN, try again ($remaining attempts left before lockout)';
  }

  @override
  String get passwordManagement => 'Password Manager';

  @override
  String get searchPasswords => 'Search passwords...';

  @override
  String get secureStorage => 'Secure Storage';

  @override
  String nPasswords(int count) {
    return '$count passwords';
  }

  @override
  String get noPasswordsYet => 'No passwords saved yet';

  @override
  String get tapToAddPassword =>
      'Tap the button below to add your first password';

  @override
  String get addPassword => 'Add Password';

  @override
  String get editPasswordTitle => 'Edit Password';

  @override
  String get edit => 'Edit';

  @override
  String get deletePasswordTitle => 'Delete Password';

  @override
  String deletePasswordConfirm(String title) {
    return 'Are you sure you want to delete \"$title\"? This cannot be undone.';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get deleted => 'Deleted';

  @override
  String get copyPassword => 'Copy password';

  @override
  String get passwordCopiedWithClear => 'Password copied (auto-clear in 30s)';

  @override
  String labelCopiedWithClear(String label) {
    return '$label copied (auto-clear in 30s)';
  }

  @override
  String labelCopied(String label) {
    return '$label copied';
  }

  @override
  String get all => 'All';

  @override
  String get categorySocial => 'Social';

  @override
  String get categoryShopping => 'Shopping';

  @override
  String get categoryBanking => 'Banking';

  @override
  String get categoryEmail => 'Email';

  @override
  String get categoryGaming => 'Gaming';

  @override
  String get categoryWork => 'Work';

  @override
  String get categoryOther => 'Other';

  @override
  String get username => 'Username';

  @override
  String get password => 'Password';

  @override
  String get website => 'Website';

  @override
  String get remark => 'Notes';

  @override
  String createdAt(String date) {
    return 'Created on $date';
  }

  @override
  String dateFormat(int year, int month, int day) {
    return '$month/$day/$year';
  }

  @override
  String monthDay(int month, int day) {
    return '$month/$day';
  }

  @override
  String get save => 'Save';

  @override
  String get updated => 'Updated';

  @override
  String get saved => 'Saved';

  @override
  String get titleLabel => 'Title';

  @override
  String get titleHint => 'e.g. Gmail';

  @override
  String get titleRequired => 'Please enter a title';

  @override
  String get usernameLabel => 'Username/Email';

  @override
  String get usernameHint => 'Login account';

  @override
  String get usernameRequired => 'Please enter a username';

  @override
  String get passwordHint => 'Login password';

  @override
  String get passwordRequired => 'Please enter a password';

  @override
  String get generatePassword => 'Generate password';

  @override
  String get categoryLabel => 'Category';

  @override
  String get websiteOptional => 'Website (optional)';

  @override
  String get websiteHint => 'https://example.com';

  @override
  String get notesOptional => 'Notes (optional)';

  @override
  String get notesHint => 'Additional notes';

  @override
  String get passwordGenerator => 'Password Generator';

  @override
  String get length => 'Length';

  @override
  String get includeUppercase => 'Include uppercase (A-Z)';

  @override
  String get includeLowercase => 'Include lowercase (a-z)';

  @override
  String get includeNumbers => 'Include numbers (0-9)';

  @override
  String get includeSymbols => 'Include symbols (!@#\$...)';

  @override
  String get useThisPassword => 'Use This Password';

  @override
  String get privateNotes => 'Private Notes';

  @override
  String get searchNotes => 'Search notes...';

  @override
  String get privateRecords => 'Private Records';

  @override
  String nNotes(int count) {
    return '$count notes';
  }

  @override
  String get pinned => 'Pinned';

  @override
  String get allNotes => 'All Notes';

  @override
  String get noNotesYet => 'No notes yet';

  @override
  String get tapToAddNote => 'Tap the button below to create your first note';

  @override
  String get writeNote => 'Write Note';

  @override
  String get unpinNote => 'Unpin';

  @override
  String get pinNote => 'Pin Note';

  @override
  String get removePin => 'Remove pin status';

  @override
  String get showOnTop => 'Show note at the top';

  @override
  String get editNote => 'Edit Note';

  @override
  String get modifyContent => 'Modify note content';

  @override
  String get deleteNote => 'Delete Note';

  @override
  String deleteNoteConfirm(String title) {
    return 'Are you sure you want to delete \"$title\"? This cannot be undone.';
  }

  @override
  String get cannotUndo => 'This cannot be undone';

  @override
  String nCharacters(int count) {
    return '$count chars';
  }

  @override
  String wordCount(int count) {
    return '$count chars';
  }

  @override
  String get noteContentHint => 'Start writing your thoughts...';

  @override
  String get insertTime => 'Insert time';

  @override
  String get insertDivider => 'Insert divider';

  @override
  String get insertList => 'Insert list item';

  @override
  String get insertTodo => 'Insert todo';

  @override
  String get hideKeyboard => 'Hide keyboard';

  @override
  String get selectBackground => 'Select Background';

  @override
  String get selectBackgroundDesc => 'Choose a background color for your note';

  @override
  String get discardChanges => 'Discard Changes';

  @override
  String get unsavedChanges => 'You have unsaved changes. Discard them?';

  @override
  String get continueEditing => 'Continue Editing';

  @override
  String get discard => 'Discard';

  @override
  String get enterContent => 'Please enter content';

  @override
  String get untitled => 'Untitled';

  @override
  String get security => 'Security';

  @override
  String get pinManagement => 'PIN Management';

  @override
  String get setOrChangePin => 'Set or change PIN code';

  @override
  String get changePinCode => 'Change PIN';

  @override
  String get clearPinCode => 'Clear PIN';

  @override
  String get clearPinConfirm =>
      'Are you sure you want to clear the PIN? You won\'t be able to unlock with PIN after clearing.';

  @override
  String get clear => 'Clear';

  @override
  String get pinCleared => 'PIN cleared';

  @override
  String get dataManagement => 'Data Management';

  @override
  String get exportBackup => 'Export Backup';

  @override
  String get exportBackupDesc => 'Export all data as an encrypted file';

  @override
  String get importBackup => 'Import Backup';

  @override
  String get importBackupDesc => 'Restore data from a backup file';

  @override
  String get setBackupPassword => 'Set Backup Password';

  @override
  String get backupPasswordHint => 'Set a password to protect the backup file';

  @override
  String get enterBackupPassword => 'Enter Backup Password';

  @override
  String get backupPasswordInputHint => 'Enter the password set during export';

  @override
  String get passwordLabel => 'Password';

  @override
  String get confirmPasswordLabel => 'Confirm Password';

  @override
  String get confirm => 'Confirm';

  @override
  String get importMethod => 'Import Method';

  @override
  String get chooseImportMethod => 'Choose how to import:';

  @override
  String get mergeKeepExisting => 'Merge (keep existing data)';

  @override
  String get overwriteClearFirst => 'Overwrite (clear and import)';

  @override
  String importSuccess(int passwords, int notes) {
    return 'Import successful: $passwords passwords, $notes notes';
  }

  @override
  String exportFailed(String error) {
    return 'Export failed: $error';
  }

  @override
  String importFailed(String error) {
    return 'Import failed: $error';
  }

  @override
  String get passwordMismatch => 'Passwords don\'t match';

  @override
  String get backupSubject => 'Secret Vault Backup';

  @override
  String get about => 'About';

  @override
  String version(String version) {
    return 'Version $version';
  }

  @override
  String get biometricNotAvailable => 'Biometric authentication not available';

  @override
  String get authFailed => 'Authentication failed';

  @override
  String get notEnrolled =>
      'No biometrics enrolled. Please add fingerprint or face in system settings';

  @override
  String get lockedOut => 'Too many attempts, please try again later';

  @override
  String get permanentlyLockedOut =>
      'Biometrics locked. Please use device passcode to unlock first';

  @override
  String get passcodeNotSet =>
      'Please set a device passcode in system settings first';

  @override
  String get unknownAuthError =>
      'An unknown error occurred during authentication';

  @override
  String get faceId => 'Face ID';

  @override
  String get fingerprint => 'Fingerprint';

  @override
  String get iris => 'Iris';

  @override
  String get biometric => 'Biometric';

  @override
  String get devicePasscode => 'Device Passcode';

  @override
  String get justNow => 'Just now';

  @override
  String minutesAgo(int count) {
    return '${count}m ago';
  }

  @override
  String hoursAgo(int count) {
    return '${count}h ago';
  }

  @override
  String daysAgo(int count) {
    return '${count}d ago';
  }

  @override
  String get veryWeak => 'Very Weak';

  @override
  String get weak => 'Weak';

  @override
  String get medium => 'Medium';

  @override
  String get strong => 'Strong';

  @override
  String get veryStrong => 'Very Strong';

  @override
  String get invalidBackupFile => 'Invalid file format';

  @override
  String get notValidBackupFile => 'Not a valid backup file';

  @override
  String get aboutDesc =>
      'A privacy-focused local password manager and private notes app';

  @override
  String get openSourceLicenses => 'Open Source Licenses';

  @override
  String get allDataLocal =>
      'All data is encrypted with AES-256 and stored locally on your device. Nothing is uploaded to any server.';

  @override
  String get language => 'Language';

  @override
  String get languageDesc => 'Change app display language';

  @override
  String get followSystem => 'Follow System';

  @override
  String get chinese => '中文';

  @override
  String get english => 'English';
}
