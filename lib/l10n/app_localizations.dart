import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

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
    Locale('zh')
  ];

  /// No description provided for @appTitle.
  ///
  /// In zh, this message translates to:
  /// **'私密保险箱'**
  String get appTitle;

  /// No description provided for @passwords.
  ///
  /// In zh, this message translates to:
  /// **'密码'**
  String get passwords;

  /// No description provided for @notes.
  ///
  /// In zh, this message translates to:
  /// **'笔记'**
  String get notes;

  /// No description provided for @settings.
  ///
  /// In zh, this message translates to:
  /// **'设置'**
  String get settings;

  /// No description provided for @lockScreenTitle.
  ///
  /// In zh, this message translates to:
  /// **'私密保险箱'**
  String get lockScreenTitle;

  /// No description provided for @lockScreenDesc.
  ///
  /// In zh, this message translates to:
  /// **'安全存储您的密码和私密笔记\n所有数据均在本地加密保存'**
  String get lockScreenDesc;

  /// No description provided for @unlockWithBiometric.
  ///
  /// In zh, this message translates to:
  /// **'使用{type}解锁'**
  String unlockWithBiometric(String type);

  /// No description provided for @authenticating.
  ///
  /// In zh, this message translates to:
  /// **'验证中...'**
  String get authenticating;

  /// No description provided for @tapToAuthenticate.
  ///
  /// In zh, this message translates to:
  /// **'点击上方按钮进行身份验证'**
  String get tapToAuthenticate;

  /// No description provided for @dataSecurity.
  ///
  /// In zh, this message translates to:
  /// **'数据安全，本地加密'**
  String get dataSecurity;

  /// No description provided for @contentHidden.
  ///
  /// In zh, this message translates to:
  /// **'内容已隐藏'**
  String get contentHidden;

  /// No description provided for @authenticateReason.
  ///
  /// In zh, this message translates to:
  /// **'验证身份以访问私密保险箱'**
  String get authenticateReason;

  /// No description provided for @usePinUnlock.
  ///
  /// In zh, this message translates to:
  /// **'使用 PIN 码解锁'**
  String get usePinUnlock;

  /// No description provided for @enterPinCode.
  ///
  /// In zh, this message translates to:
  /// **'输入 PIN 码'**
  String get enterPinCode;

  /// No description provided for @confirmPinCode.
  ///
  /// In zh, this message translates to:
  /// **'确认 PIN 码'**
  String get confirmPinCode;

  /// No description provided for @pinCodeSetup.
  ///
  /// In zh, this message translates to:
  /// **'设置 PIN 码'**
  String get pinCodeSetup;

  /// No description provided for @enterSixDigitPin.
  ///
  /// In zh, this message translates to:
  /// **'请输入 6 位数字 PIN 码'**
  String get enterSixDigitPin;

  /// No description provided for @reenterPin.
  ///
  /// In zh, this message translates to:
  /// **'请再次输入 PIN 码'**
  String get reenterPin;

  /// No description provided for @pinMismatch.
  ///
  /// In zh, this message translates to:
  /// **'两次输入不一致，请重新设置'**
  String get pinMismatch;

  /// No description provided for @pinUpdated.
  ///
  /// In zh, this message translates to:
  /// **'PIN 码已更新'**
  String get pinUpdated;

  /// No description provided for @pinSetSuccess.
  ///
  /// In zh, this message translates to:
  /// **'PIN 码设置成功'**
  String get pinSetSuccess;

  /// No description provided for @pinRateLimited.
  ///
  /// In zh, this message translates to:
  /// **'操作过于频繁，请 {seconds} 秒后重试'**
  String pinRateLimited(int seconds);

  /// No description provided for @pinErrorRateLimit.
  ///
  /// In zh, this message translates to:
  /// **'PIN 码错误，请 {seconds} 秒后重试'**
  String pinErrorRateLimit(int seconds);

  /// No description provided for @pinErrorAttemptsLeft.
  ///
  /// In zh, this message translates to:
  /// **'PIN 码错误，请重试（{remaining} 次后将限制操作）'**
  String pinErrorAttemptsLeft(int remaining);

  /// No description provided for @passwordManagement.
  ///
  /// In zh, this message translates to:
  /// **'密码管理'**
  String get passwordManagement;

  /// No description provided for @searchPasswords.
  ///
  /// In zh, this message translates to:
  /// **'搜索密码...'**
  String get searchPasswords;

  /// No description provided for @secureStorage.
  ///
  /// In zh, this message translates to:
  /// **'安全存储'**
  String get secureStorage;

  /// No description provided for @nPasswords.
  ///
  /// In zh, this message translates to:
  /// **'{count} 个密码'**
  String nPasswords(int count);

  /// No description provided for @noPasswordsYet.
  ///
  /// In zh, this message translates to:
  /// **'还没有保存密码'**
  String get noPasswordsYet;

  /// No description provided for @tapToAddPassword.
  ///
  /// In zh, this message translates to:
  /// **'点击下方按钮添加第一个密码'**
  String get tapToAddPassword;

  /// No description provided for @addPassword.
  ///
  /// In zh, this message translates to:
  /// **'添加密码'**
  String get addPassword;

  /// No description provided for @editPasswordTitle.
  ///
  /// In zh, this message translates to:
  /// **'编辑密码'**
  String get editPasswordTitle;

  /// No description provided for @edit.
  ///
  /// In zh, this message translates to:
  /// **'编辑'**
  String get edit;

  /// No description provided for @deletePasswordTitle.
  ///
  /// In zh, this message translates to:
  /// **'删除密码'**
  String get deletePasswordTitle;

  /// No description provided for @deletePasswordConfirm.
  ///
  /// In zh, this message translates to:
  /// **'确定要删除 \"{title}\" 吗？此操作无法撤销。'**
  String deletePasswordConfirm(String title);

  /// No description provided for @cancel.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get delete;

  /// No description provided for @deleted.
  ///
  /// In zh, this message translates to:
  /// **'已删除'**
  String get deleted;

  /// No description provided for @copyPassword.
  ///
  /// In zh, this message translates to:
  /// **'复制密码'**
  String get copyPassword;

  /// No description provided for @passwordCopiedWithClear.
  ///
  /// In zh, this message translates to:
  /// **'密码已复制（30秒后自动清除）'**
  String get passwordCopiedWithClear;

  /// No description provided for @labelCopiedWithClear.
  ///
  /// In zh, this message translates to:
  /// **'{label}已复制（30秒后自动清除）'**
  String labelCopiedWithClear(String label);

  /// No description provided for @labelCopied.
  ///
  /// In zh, this message translates to:
  /// **'{label}已复制'**
  String labelCopied(String label);

  /// No description provided for @all.
  ///
  /// In zh, this message translates to:
  /// **'全部'**
  String get all;

  /// No description provided for @categorySocial.
  ///
  /// In zh, this message translates to:
  /// **'社交'**
  String get categorySocial;

  /// No description provided for @categoryShopping.
  ///
  /// In zh, this message translates to:
  /// **'购物'**
  String get categoryShopping;

  /// No description provided for @categoryBanking.
  ///
  /// In zh, this message translates to:
  /// **'银行'**
  String get categoryBanking;

  /// No description provided for @categoryEmail.
  ///
  /// In zh, this message translates to:
  /// **'邮箱'**
  String get categoryEmail;

  /// No description provided for @categoryGaming.
  ///
  /// In zh, this message translates to:
  /// **'游戏'**
  String get categoryGaming;

  /// No description provided for @categoryWork.
  ///
  /// In zh, this message translates to:
  /// **'工作'**
  String get categoryWork;

  /// No description provided for @categoryOther.
  ///
  /// In zh, this message translates to:
  /// **'其他'**
  String get categoryOther;

  /// No description provided for @username.
  ///
  /// In zh, this message translates to:
  /// **'用户名'**
  String get username;

  /// No description provided for @password.
  ///
  /// In zh, this message translates to:
  /// **'密码'**
  String get password;

  /// No description provided for @website.
  ///
  /// In zh, this message translates to:
  /// **'网站'**
  String get website;

  /// No description provided for @remark.
  ///
  /// In zh, this message translates to:
  /// **'备注'**
  String get remark;

  /// No description provided for @createdAt.
  ///
  /// In zh, this message translates to:
  /// **'创建于 {date}'**
  String createdAt(String date);

  /// No description provided for @dateFormat.
  ///
  /// In zh, this message translates to:
  /// **'{year}年{month}月{day}日'**
  String dateFormat(int year, int month, int day);

  /// No description provided for @monthDay.
  ///
  /// In zh, this message translates to:
  /// **'{month}月{day}日'**
  String monthDay(int month, int day);

  /// No description provided for @save.
  ///
  /// In zh, this message translates to:
  /// **'保存'**
  String get save;

  /// No description provided for @updated.
  ///
  /// In zh, this message translates to:
  /// **'已更新'**
  String get updated;

  /// No description provided for @saved.
  ///
  /// In zh, this message translates to:
  /// **'已保存'**
  String get saved;

  /// No description provided for @titleLabel.
  ///
  /// In zh, this message translates to:
  /// **'标题'**
  String get titleLabel;

  /// No description provided for @titleHint.
  ///
  /// In zh, this message translates to:
  /// **'例如：Gmail邮箱'**
  String get titleHint;

  /// No description provided for @titleRequired.
  ///
  /// In zh, this message translates to:
  /// **'请输入标题'**
  String get titleRequired;

  /// No description provided for @usernameLabel.
  ///
  /// In zh, this message translates to:
  /// **'用户名/邮箱'**
  String get usernameLabel;

  /// No description provided for @usernameHint.
  ///
  /// In zh, this message translates to:
  /// **'登录账号'**
  String get usernameHint;

  /// No description provided for @usernameRequired.
  ///
  /// In zh, this message translates to:
  /// **'请输入用户名'**
  String get usernameRequired;

  /// No description provided for @passwordHint.
  ///
  /// In zh, this message translates to:
  /// **'登录密码'**
  String get passwordHint;

  /// No description provided for @passwordRequired.
  ///
  /// In zh, this message translates to:
  /// **'请输入密码'**
  String get passwordRequired;

  /// No description provided for @generatePassword.
  ///
  /// In zh, this message translates to:
  /// **'生成密码'**
  String get generatePassword;

  /// No description provided for @categoryLabel.
  ///
  /// In zh, this message translates to:
  /// **'分类'**
  String get categoryLabel;

  /// No description provided for @websiteOptional.
  ///
  /// In zh, this message translates to:
  /// **'网站（可选）'**
  String get websiteOptional;

  /// No description provided for @websiteHint.
  ///
  /// In zh, this message translates to:
  /// **'https://example.com'**
  String get websiteHint;

  /// No description provided for @notesOptional.
  ///
  /// In zh, this message translates to:
  /// **'备注（可选）'**
  String get notesOptional;

  /// No description provided for @notesHint.
  ///
  /// In zh, this message translates to:
  /// **'其他备注信息'**
  String get notesHint;

  /// No description provided for @passwordGenerator.
  ///
  /// In zh, this message translates to:
  /// **'密码生成器'**
  String get passwordGenerator;

  /// No description provided for @length.
  ///
  /// In zh, this message translates to:
  /// **'长度'**
  String get length;

  /// No description provided for @includeUppercase.
  ///
  /// In zh, this message translates to:
  /// **'包含大写字母 (A-Z)'**
  String get includeUppercase;

  /// No description provided for @includeLowercase.
  ///
  /// In zh, this message translates to:
  /// **'包含小写字母 (a-z)'**
  String get includeLowercase;

  /// No description provided for @includeNumbers.
  ///
  /// In zh, this message translates to:
  /// **'包含数字 (0-9)'**
  String get includeNumbers;

  /// No description provided for @includeSymbols.
  ///
  /// In zh, this message translates to:
  /// **'包含特殊字符 (!@#\$...)'**
  String get includeSymbols;

  /// No description provided for @useThisPassword.
  ///
  /// In zh, this message translates to:
  /// **'使用此密码'**
  String get useThisPassword;

  /// No description provided for @privateNotes.
  ///
  /// In zh, this message translates to:
  /// **'私密笔记'**
  String get privateNotes;

  /// No description provided for @searchNotes.
  ///
  /// In zh, this message translates to:
  /// **'搜索笔记...'**
  String get searchNotes;

  /// No description provided for @privateRecords.
  ///
  /// In zh, this message translates to:
  /// **'私密记录'**
  String get privateRecords;

  /// No description provided for @nNotes.
  ///
  /// In zh, this message translates to:
  /// **'{count} 篇笔记'**
  String nNotes(int count);

  /// No description provided for @pinned.
  ///
  /// In zh, this message translates to:
  /// **'置顶'**
  String get pinned;

  /// No description provided for @allNotes.
  ///
  /// In zh, this message translates to:
  /// **'全部笔记'**
  String get allNotes;

  /// No description provided for @noNotesYet.
  ///
  /// In zh, this message translates to:
  /// **'还没有笔记'**
  String get noNotesYet;

  /// No description provided for @tapToAddNote.
  ///
  /// In zh, this message translates to:
  /// **'点击下方按钮创建第一条笔记'**
  String get tapToAddNote;

  /// No description provided for @writeNote.
  ///
  /// In zh, this message translates to:
  /// **'写笔记'**
  String get writeNote;

  /// No description provided for @unpinNote.
  ///
  /// In zh, this message translates to:
  /// **'取消置顶'**
  String get unpinNote;

  /// No description provided for @pinNote.
  ///
  /// In zh, this message translates to:
  /// **'置顶笔记'**
  String get pinNote;

  /// No description provided for @removePin.
  ///
  /// In zh, this message translates to:
  /// **'移除置顶状态'**
  String get removePin;

  /// No description provided for @showOnTop.
  ///
  /// In zh, this message translates to:
  /// **'让笔记显示在最前面'**
  String get showOnTop;

  /// No description provided for @editNote.
  ///
  /// In zh, this message translates to:
  /// **'编辑笔记'**
  String get editNote;

  /// No description provided for @modifyContent.
  ///
  /// In zh, this message translates to:
  /// **'修改笔记内容'**
  String get modifyContent;

  /// No description provided for @deleteNote.
  ///
  /// In zh, this message translates to:
  /// **'删除笔记'**
  String get deleteNote;

  /// No description provided for @deleteNoteConfirm.
  ///
  /// In zh, this message translates to:
  /// **'确定要删除 \"{title}\" 吗？此操作无法撤销。'**
  String deleteNoteConfirm(String title);

  /// No description provided for @cannotUndo.
  ///
  /// In zh, this message translates to:
  /// **'此操作无法撤销'**
  String get cannotUndo;

  /// No description provided for @nCharacters.
  ///
  /// In zh, this message translates to:
  /// **'{count}字'**
  String nCharacters(int count);

  /// No description provided for @wordCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 字'**
  String wordCount(int count);

  /// No description provided for @noteContentHint.
  ///
  /// In zh, this message translates to:
  /// **'开始记录你的想法...'**
  String get noteContentHint;

  /// No description provided for @insertTime.
  ///
  /// In zh, this message translates to:
  /// **'插入时间'**
  String get insertTime;

  /// No description provided for @insertDivider.
  ///
  /// In zh, this message translates to:
  /// **'插入分隔线'**
  String get insertDivider;

  /// No description provided for @insertList.
  ///
  /// In zh, this message translates to:
  /// **'插入列表项'**
  String get insertList;

  /// No description provided for @insertTodo.
  ///
  /// In zh, this message translates to:
  /// **'插入待办'**
  String get insertTodo;

  /// No description provided for @hideKeyboard.
  ///
  /// In zh, this message translates to:
  /// **'收起键盘'**
  String get hideKeyboard;

  /// No description provided for @selectBackground.
  ///
  /// In zh, this message translates to:
  /// **'选择背景色'**
  String get selectBackground;

  /// No description provided for @selectBackgroundDesc.
  ///
  /// In zh, this message translates to:
  /// **'为笔记选择一个漂亮的背景颜色'**
  String get selectBackgroundDesc;

  /// No description provided for @discardChanges.
  ///
  /// In zh, this message translates to:
  /// **'放弃更改'**
  String get discardChanges;

  /// No description provided for @unsavedChanges.
  ///
  /// In zh, this message translates to:
  /// **'您有未保存的更改，确定要放弃吗？'**
  String get unsavedChanges;

  /// No description provided for @continueEditing.
  ///
  /// In zh, this message translates to:
  /// **'继续编辑'**
  String get continueEditing;

  /// No description provided for @discard.
  ///
  /// In zh, this message translates to:
  /// **'放弃'**
  String get discard;

  /// No description provided for @enterContent.
  ///
  /// In zh, this message translates to:
  /// **'请输入内容'**
  String get enterContent;

  /// No description provided for @untitled.
  ///
  /// In zh, this message translates to:
  /// **'无标题'**
  String get untitled;

  /// No description provided for @security.
  ///
  /// In zh, this message translates to:
  /// **'安全'**
  String get security;

  /// No description provided for @pinManagement.
  ///
  /// In zh, this message translates to:
  /// **'PIN 码管理'**
  String get pinManagement;

  /// No description provided for @setOrChangePin.
  ///
  /// In zh, this message translates to:
  /// **'设置或更改 PIN 码'**
  String get setOrChangePin;

  /// No description provided for @changePinCode.
  ///
  /// In zh, this message translates to:
  /// **'修改 PIN 码'**
  String get changePinCode;

  /// No description provided for @clearPinCode.
  ///
  /// In zh, this message translates to:
  /// **'清除 PIN 码'**
  String get clearPinCode;

  /// No description provided for @clearPinConfirm.
  ///
  /// In zh, this message translates to:
  /// **'确定要清除 PIN 码吗？清除后将无法使用 PIN 码解锁。'**
  String get clearPinConfirm;

  /// No description provided for @clear.
  ///
  /// In zh, this message translates to:
  /// **'清除'**
  String get clear;

  /// No description provided for @pinCleared.
  ///
  /// In zh, this message translates to:
  /// **'PIN 码已清除'**
  String get pinCleared;

  /// No description provided for @dataManagement.
  ///
  /// In zh, this message translates to:
  /// **'数据管理'**
  String get dataManagement;

  /// No description provided for @exportBackup.
  ///
  /// In zh, this message translates to:
  /// **'导出备份'**
  String get exportBackup;

  /// No description provided for @exportBackupDesc.
  ///
  /// In zh, this message translates to:
  /// **'将所有数据导出为加密文件'**
  String get exportBackupDesc;

  /// No description provided for @importBackup.
  ///
  /// In zh, this message translates to:
  /// **'导入备份'**
  String get importBackup;

  /// No description provided for @importBackupDesc.
  ///
  /// In zh, this message translates to:
  /// **'从备份文件恢复数据'**
  String get importBackupDesc;

  /// No description provided for @setBackupPassword.
  ///
  /// In zh, this message translates to:
  /// **'设置备份密码'**
  String get setBackupPassword;

  /// No description provided for @backupPasswordHint.
  ///
  /// In zh, this message translates to:
  /// **'请设置用于保护备份文件的密码'**
  String get backupPasswordHint;

  /// No description provided for @enterBackupPassword.
  ///
  /// In zh, this message translates to:
  /// **'输入备份密码'**
  String get enterBackupPassword;

  /// No description provided for @backupPasswordInputHint.
  ///
  /// In zh, this message translates to:
  /// **'请输入导出时设置的密码'**
  String get backupPasswordInputHint;

  /// No description provided for @passwordLabel.
  ///
  /// In zh, this message translates to:
  /// **'密码'**
  String get passwordLabel;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In zh, this message translates to:
  /// **'确认密码'**
  String get confirmPasswordLabel;

  /// No description provided for @confirm.
  ///
  /// In zh, this message translates to:
  /// **'确认'**
  String get confirm;

  /// No description provided for @importMethod.
  ///
  /// In zh, this message translates to:
  /// **'导入方式'**
  String get importMethod;

  /// No description provided for @chooseImportMethod.
  ///
  /// In zh, this message translates to:
  /// **'请选择导入方式：'**
  String get chooseImportMethod;

  /// No description provided for @mergeKeepExisting.
  ///
  /// In zh, this message translates to:
  /// **'合并（保留现有数据）'**
  String get mergeKeepExisting;

  /// No description provided for @overwriteClearFirst.
  ///
  /// In zh, this message translates to:
  /// **'覆盖（清空后导入）'**
  String get overwriteClearFirst;

  /// No description provided for @importSuccess.
  ///
  /// In zh, this message translates to:
  /// **'导入成功：{passwords} 个密码，{notes} 条笔记'**
  String importSuccess(int passwords, int notes);

  /// No description provided for @exportFailed.
  ///
  /// In zh, this message translates to:
  /// **'导出失败: {error}'**
  String exportFailed(String error);

  /// No description provided for @importFailed.
  ///
  /// In zh, this message translates to:
  /// **'导入失败: {error}'**
  String importFailed(String error);

  /// No description provided for @passwordMismatch.
  ///
  /// In zh, this message translates to:
  /// **'两次密码不一致'**
  String get passwordMismatch;

  /// No description provided for @backupSubject.
  ///
  /// In zh, this message translates to:
  /// **'私密保险箱备份'**
  String get backupSubject;

  /// No description provided for @about.
  ///
  /// In zh, this message translates to:
  /// **'关于'**
  String get about;

  /// No description provided for @version.
  ///
  /// In zh, this message translates to:
  /// **'版本 {version}'**
  String version(String version);

  /// No description provided for @biometricNotAvailable.
  ///
  /// In zh, this message translates to:
  /// **'此设备不支持生物识别'**
  String get biometricNotAvailable;

  /// No description provided for @authFailed.
  ///
  /// In zh, this message translates to:
  /// **'认证失败'**
  String get authFailed;

  /// No description provided for @notEnrolled.
  ///
  /// In zh, this message translates to:
  /// **'未设置生物识别，请先在系统设置中添加指纹或面容'**
  String get notEnrolled;

  /// No description provided for @lockedOut.
  ///
  /// In zh, this message translates to:
  /// **'尝试次数过多，请稍后再试'**
  String get lockedOut;

  /// No description provided for @permanentlyLockedOut.
  ///
  /// In zh, this message translates to:
  /// **'生物识别已被锁定，请使用设备密码解锁后再试'**
  String get permanentlyLockedOut;

  /// No description provided for @passcodeNotSet.
  ///
  /// In zh, this message translates to:
  /// **'请先在系统设置中设置设备密码'**
  String get passcodeNotSet;

  /// No description provided for @unknownAuthError.
  ///
  /// In zh, this message translates to:
  /// **'认证过程中发生未知错误'**
  String get unknownAuthError;

  /// No description provided for @faceId.
  ///
  /// In zh, this message translates to:
  /// **'面容识别'**
  String get faceId;

  /// No description provided for @fingerprint.
  ///
  /// In zh, this message translates to:
  /// **'指纹识别'**
  String get fingerprint;

  /// No description provided for @iris.
  ///
  /// In zh, this message translates to:
  /// **'虹膜识别'**
  String get iris;

  /// No description provided for @biometric.
  ///
  /// In zh, this message translates to:
  /// **'生物识别'**
  String get biometric;

  /// No description provided for @devicePasscode.
  ///
  /// In zh, this message translates to:
  /// **'设备密码'**
  String get devicePasscode;

  /// No description provided for @justNow.
  ///
  /// In zh, this message translates to:
  /// **'刚刚'**
  String get justNow;

  /// No description provided for @minutesAgo.
  ///
  /// In zh, this message translates to:
  /// **'{count}分钟前'**
  String minutesAgo(int count);

  /// No description provided for @hoursAgo.
  ///
  /// In zh, this message translates to:
  /// **'{count}小时前'**
  String hoursAgo(int count);

  /// No description provided for @daysAgo.
  ///
  /// In zh, this message translates to:
  /// **'{count}天前'**
  String daysAgo(int count);

  /// No description provided for @veryWeak.
  ///
  /// In zh, this message translates to:
  /// **'非常弱'**
  String get veryWeak;

  /// No description provided for @weak.
  ///
  /// In zh, this message translates to:
  /// **'弱'**
  String get weak;

  /// No description provided for @medium.
  ///
  /// In zh, this message translates to:
  /// **'中等'**
  String get medium;

  /// No description provided for @strong.
  ///
  /// In zh, this message translates to:
  /// **'强'**
  String get strong;

  /// No description provided for @veryStrong.
  ///
  /// In zh, this message translates to:
  /// **'非常强'**
  String get veryStrong;

  /// No description provided for @invalidBackupFile.
  ///
  /// In zh, this message translates to:
  /// **'文件格式无效'**
  String get invalidBackupFile;

  /// No description provided for @notValidBackupFile.
  ///
  /// In zh, this message translates to:
  /// **'不是有效的备份文件'**
  String get notValidBackupFile;

  /// No description provided for @aboutDesc.
  ///
  /// In zh, this message translates to:
  /// **'注重隐私的本地密码管理器与私密笔记应用'**
  String get aboutDesc;

  /// No description provided for @openSourceLicenses.
  ///
  /// In zh, this message translates to:
  /// **'开源许可'**
  String get openSourceLicenses;

  /// No description provided for @allDataLocal.
  ///
  /// In zh, this message translates to:
  /// **'所有数据均在设备本地 AES-256 加密存储，不上传任何服务器。'**
  String get allDataLocal;

  /// No description provided for @language.
  ///
  /// In zh, this message translates to:
  /// **'语言'**
  String get language;

  /// No description provided for @languageDesc.
  ///
  /// In zh, this message translates to:
  /// **'切换应用显示语言'**
  String get languageDesc;

  /// No description provided for @followSystem.
  ///
  /// In zh, this message translates to:
  /// **'跟随系统'**
  String get followSystem;

  /// No description provided for @chinese.
  ///
  /// In zh, this message translates to:
  /// **'中文'**
  String get chinese;

  /// No description provided for @english.
  ///
  /// In zh, this message translates to:
  /// **'English'**
  String get english;
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
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
