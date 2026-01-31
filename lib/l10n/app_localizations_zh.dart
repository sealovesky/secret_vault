// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '私密保险箱';

  @override
  String get passwords => '密码';

  @override
  String get notes => '笔记';

  @override
  String get settings => '设置';

  @override
  String get lockScreenTitle => '私密保险箱';

  @override
  String get lockScreenDesc => '安全存储您的密码和私密笔记\n所有数据均在本地加密保存';

  @override
  String unlockWithBiometric(String type) {
    return '使用$type解锁';
  }

  @override
  String get authenticating => '验证中...';

  @override
  String get tapToAuthenticate => '点击上方按钮进行身份验证';

  @override
  String get dataSecurity => '数据安全，本地加密';

  @override
  String get contentHidden => '内容已隐藏';

  @override
  String get authenticateReason => '验证身份以访问私密保险箱';

  @override
  String get usePinUnlock => '使用 PIN 码解锁';

  @override
  String get enterPinCode => '输入 PIN 码';

  @override
  String get confirmPinCode => '确认 PIN 码';

  @override
  String get pinCodeSetup => '设置 PIN 码';

  @override
  String get enterSixDigitPin => '请输入 6 位数字 PIN 码';

  @override
  String get reenterPin => '请再次输入 PIN 码';

  @override
  String get pinMismatch => '两次输入不一致，请重新设置';

  @override
  String get pinUpdated => 'PIN 码已更新';

  @override
  String get pinSetSuccess => 'PIN 码设置成功';

  @override
  String pinRateLimited(int seconds) {
    return '操作过于频繁，请 $seconds 秒后重试';
  }

  @override
  String pinErrorRateLimit(int seconds) {
    return 'PIN 码错误，请 $seconds 秒后重试';
  }

  @override
  String pinErrorAttemptsLeft(int remaining) {
    return 'PIN 码错误，请重试（$remaining 次后将限制操作）';
  }

  @override
  String get passwordManagement => '密码管理';

  @override
  String get searchPasswords => '搜索密码...';

  @override
  String get secureStorage => '安全存储';

  @override
  String nPasswords(int count) {
    return '$count 个密码';
  }

  @override
  String get noPasswordsYet => '还没有保存密码';

  @override
  String get tapToAddPassword => '点击下方按钮添加第一个密码';

  @override
  String get addPassword => '添加密码';

  @override
  String get editPasswordTitle => '编辑密码';

  @override
  String get edit => '编辑';

  @override
  String get deletePasswordTitle => '删除密码';

  @override
  String deletePasswordConfirm(String title) {
    return '确定要删除 \"$title\" 吗？此操作无法撤销。';
  }

  @override
  String get cancel => '取消';

  @override
  String get delete => '删除';

  @override
  String get deleted => '已删除';

  @override
  String get copyPassword => '复制密码';

  @override
  String get passwordCopiedWithClear => '密码已复制（30秒后自动清除）';

  @override
  String labelCopiedWithClear(String label) {
    return '$label已复制（30秒后自动清除）';
  }

  @override
  String labelCopied(String label) {
    return '$label已复制';
  }

  @override
  String get all => '全部';

  @override
  String get categorySocial => '社交';

  @override
  String get categoryShopping => '购物';

  @override
  String get categoryBanking => '银行';

  @override
  String get categoryEmail => '邮箱';

  @override
  String get categoryGaming => '游戏';

  @override
  String get categoryWork => '工作';

  @override
  String get categoryOther => '其他';

  @override
  String get username => '用户名';

  @override
  String get password => '密码';

  @override
  String get website => '网站';

  @override
  String get remark => '备注';

  @override
  String createdAt(String date) {
    return '创建于 $date';
  }

  @override
  String dateFormat(int year, int month, int day) {
    return '$year年$month月$day日';
  }

  @override
  String monthDay(int month, int day) {
    return '$month月$day日';
  }

  @override
  String get save => '保存';

  @override
  String get updated => '已更新';

  @override
  String get saved => '已保存';

  @override
  String get titleLabel => '标题';

  @override
  String get titleHint => '例如：Gmail邮箱';

  @override
  String get titleRequired => '请输入标题';

  @override
  String get usernameLabel => '用户名/邮箱';

  @override
  String get usernameHint => '登录账号';

  @override
  String get usernameRequired => '请输入用户名';

  @override
  String get passwordHint => '登录密码';

  @override
  String get passwordRequired => '请输入密码';

  @override
  String get generatePassword => '生成密码';

  @override
  String get categoryLabel => '分类';

  @override
  String get websiteOptional => '网站（可选）';

  @override
  String get websiteHint => 'https://example.com';

  @override
  String get notesOptional => '备注（可选）';

  @override
  String get notesHint => '其他备注信息';

  @override
  String get passwordGenerator => '密码生成器';

  @override
  String get length => '长度';

  @override
  String get includeUppercase => '包含大写字母 (A-Z)';

  @override
  String get includeLowercase => '包含小写字母 (a-z)';

  @override
  String get includeNumbers => '包含数字 (0-9)';

  @override
  String get includeSymbols => '包含特殊字符 (!@#\$...)';

  @override
  String get useThisPassword => '使用此密码';

  @override
  String get privateNotes => '私密笔记';

  @override
  String get searchNotes => '搜索笔记...';

  @override
  String get privateRecords => '私密记录';

  @override
  String nNotes(int count) {
    return '$count 篇笔记';
  }

  @override
  String get pinned => '置顶';

  @override
  String get allNotes => '全部笔记';

  @override
  String get noNotesYet => '还没有笔记';

  @override
  String get tapToAddNote => '点击下方按钮创建第一条笔记';

  @override
  String get writeNote => '写笔记';

  @override
  String get unpinNote => '取消置顶';

  @override
  String get pinNote => '置顶笔记';

  @override
  String get removePin => '移除置顶状态';

  @override
  String get showOnTop => '让笔记显示在最前面';

  @override
  String get editNote => '编辑笔记';

  @override
  String get modifyContent => '修改笔记内容';

  @override
  String get deleteNote => '删除笔记';

  @override
  String deleteNoteConfirm(String title) {
    return '确定要删除 \"$title\" 吗？此操作无法撤销。';
  }

  @override
  String get cannotUndo => '此操作无法撤销';

  @override
  String nCharacters(int count) {
    return '$count字';
  }

  @override
  String wordCount(int count) {
    return '$count 字';
  }

  @override
  String get noteContentHint => '开始记录你的想法...';

  @override
  String get insertTime => '插入时间';

  @override
  String get insertDivider => '插入分隔线';

  @override
  String get insertList => '插入列表项';

  @override
  String get insertTodo => '插入待办';

  @override
  String get hideKeyboard => '收起键盘';

  @override
  String get selectBackground => '选择背景色';

  @override
  String get selectBackgroundDesc => '为笔记选择一个漂亮的背景颜色';

  @override
  String get discardChanges => '放弃更改';

  @override
  String get unsavedChanges => '您有未保存的更改，确定要放弃吗？';

  @override
  String get continueEditing => '继续编辑';

  @override
  String get discard => '放弃';

  @override
  String get enterContent => '请输入内容';

  @override
  String get untitled => '无标题';

  @override
  String get security => '安全';

  @override
  String get pinManagement => 'PIN 码管理';

  @override
  String get setOrChangePin => '设置或更改 PIN 码';

  @override
  String get changePinCode => '修改 PIN 码';

  @override
  String get clearPinCode => '清除 PIN 码';

  @override
  String get clearPinConfirm => '确定要清除 PIN 码吗？清除后将无法使用 PIN 码解锁。';

  @override
  String get clear => '清除';

  @override
  String get pinCleared => 'PIN 码已清除';

  @override
  String get dataManagement => '数据管理';

  @override
  String get exportBackup => '导出备份';

  @override
  String get exportBackupDesc => '将所有数据导出为加密文件';

  @override
  String get importBackup => '导入备份';

  @override
  String get importBackupDesc => '从备份文件恢复数据';

  @override
  String get setBackupPassword => '设置备份密码';

  @override
  String get backupPasswordHint => '请设置用于保护备份文件的密码';

  @override
  String get enterBackupPassword => '输入备份密码';

  @override
  String get backupPasswordInputHint => '请输入导出时设置的密码';

  @override
  String get passwordLabel => '密码';

  @override
  String get confirmPasswordLabel => '确认密码';

  @override
  String get confirm => '确认';

  @override
  String get importMethod => '导入方式';

  @override
  String get chooseImportMethod => '请选择导入方式：';

  @override
  String get mergeKeepExisting => '合并（保留现有数据）';

  @override
  String get overwriteClearFirst => '覆盖（清空后导入）';

  @override
  String importSuccess(int passwords, int notes) {
    return '导入成功：$passwords 个密码，$notes 条笔记';
  }

  @override
  String exportFailed(String error) {
    return '导出失败: $error';
  }

  @override
  String importFailed(String error) {
    return '导入失败: $error';
  }

  @override
  String get passwordMismatch => '两次密码不一致';

  @override
  String get backupSubject => '私密保险箱备份';

  @override
  String get about => '关于';

  @override
  String version(String version) {
    return '版本 $version';
  }

  @override
  String get biometricNotAvailable => '此设备不支持生物识别';

  @override
  String get authFailed => '认证失败';

  @override
  String get notEnrolled => '未设置生物识别，请先在系统设置中添加指纹或面容';

  @override
  String get lockedOut => '尝试次数过多，请稍后再试';

  @override
  String get permanentlyLockedOut => '生物识别已被锁定，请使用设备密码解锁后再试';

  @override
  String get passcodeNotSet => '请先在系统设置中设置设备密码';

  @override
  String get unknownAuthError => '认证过程中发生未知错误';

  @override
  String get faceId => '面容识别';

  @override
  String get fingerprint => '指纹识别';

  @override
  String get iris => '虹膜识别';

  @override
  String get biometric => '生物识别';

  @override
  String get devicePasscode => '设备密码';

  @override
  String get justNow => '刚刚';

  @override
  String minutesAgo(int count) {
    return '$count分钟前';
  }

  @override
  String hoursAgo(int count) {
    return '$count小时前';
  }

  @override
  String daysAgo(int count) {
    return '$count天前';
  }

  @override
  String get veryWeak => '非常弱';

  @override
  String get weak => '弱';

  @override
  String get medium => '中等';

  @override
  String get strong => '强';

  @override
  String get veryStrong => '非常强';

  @override
  String get invalidBackupFile => '文件格式无效';

  @override
  String get notValidBackupFile => '不是有效的备份文件';

  @override
  String get aboutDesc => '注重隐私的本地密码管理器与私密笔记应用';

  @override
  String get openSourceLicenses => '开源许可';

  @override
  String get allDataLocal => '所有数据均在设备本地 AES-256 加密存储，不上传任何服务器。';

  @override
  String get language => '语言';

  @override
  String get languageDesc => '切换应用显示语言';

  @override
  String get followSystem => '跟随系统';

  @override
  String get chinese => '中文';

  @override
  String get english => 'English';
}
