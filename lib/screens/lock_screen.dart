import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../l10n/app_localizations.dart';

/// 锁屏页面 - 生物识别认证入口
class LockScreen extends StatefulWidget {
  final VoidCallback onAuthenticated;

  const LockScreen({
    super.key,
    required this.onAuthenticated,
  });

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isAuthenticating = false;
  String _biometricType = '生物识别';
  String? _errorMessage;
  bool _biometricAvailable = true;
  bool _hasPinCode = false;
  bool _showPinInput = false;
  String _pinInput = '';
  int _failedAttempts = 0;
  DateTime? _lockoutUntil;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initAuth();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _animationController.forward();
  }

  Future<void> _initAuth() async {
    final authService = context.read<AuthService>();
    final biometricType = await authService.getBiometricTypeKey();
    final biometricAvailable = await authService.isBiometricAvailable();
    final hasPinCode = await authService.hasPinCode();

    if (mounted) {
      // 如果没有生物识别且没有 PIN，直接放行
      if (!biometricAvailable && !hasPinCode) {
        widget.onAuthenticated();
        return;
      }

      setState(() {
        _biometricType = biometricType;
        _biometricAvailable = biometricAvailable;
        _hasPinCode = hasPinCode;
      });
    }
  }

  Future<void> _authenticate() async {
    if (_isAuthenticating) return;

    setState(() {
      _isAuthenticating = true;
      _errorMessage = null;
    });

    final authService = context.read<AuthService>();
    final result = await authService.authenticate(
      reason: AppLocalizations.of(context)!.authenticateReason,
    );

    if (!mounted) return;

    if (result.success) {
      widget.onAuthenticated();
    } else {
      setState(() {
        _isAuthenticating = false;
        _errorMessage = _localizeAuthError(result.error);
      });
    }
  }

  void _onPinNumberTap(int number) {
    if (_pinInput.length >= 6) return;
    setState(() {
      _pinInput += number.toString();
      _errorMessage = null;
    });

    if (_pinInput.length == 6) {
      _verifyPin();
    }
  }

  void _onPinDelete() {
    if (_pinInput.isEmpty) return;
    setState(() {
      _pinInput = _pinInput.substring(0, _pinInput.length - 1);
      _errorMessage = null;
    });
  }

  Future<void> _verifyPin() async {
    // 检查是否在锁定期
    if (_lockoutUntil != null && DateTime.now().isBefore(_lockoutUntil!)) {
      final remaining = _lockoutUntil!.difference(DateTime.now()).inSeconds;
      setState(() {
        _pinInput = '';
        _errorMessage = AppLocalizations.of(context)!.pinRateLimited(remaining);
      });
      return;
    }

    final authService = context.read<AuthService>();
    final success = await authService.verifyPinCode(_pinInput);

    if (!mounted) return;

    if (success) {
      _failedAttempts = 0;
      _lockoutUntil = null;
      widget.onAuthenticated();
    } else {
      _failedAttempts++;
      // 指数退避：3次后锁定 5s、10s、30s、60s...
      if (_failedAttempts >= 3) {
        final lockSeconds = 5 * (1 << (_failedAttempts - 3)).clamp(1, 12);
        _lockoutUntil = DateTime.now().add(Duration(seconds: lockSeconds));
        setState(() {
          _pinInput = '';
          _errorMessage = AppLocalizations.of(context)!.pinErrorRateLimit(lockSeconds);
        });
      } else {
        setState(() {
          _pinInput = '';
          _errorMessage = AppLocalizations.of(context)!.pinErrorAttemptsLeft(3 - _failedAttempts);
        });
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.primary.withValues(alpha:0.08),
              colorScheme.surface,
              colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: _showPinInput
                  ? _buildPinInputView(context)
                  : _buildBiometricView(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBiometricView(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          const Spacer(flex: 2),

          // Logo 图标
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.primary,
                  colorScheme.primary.withValues(alpha:0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha:0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.shield_outlined,
              size: 48,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 32),

          // 标题
          Text(
            l10n.lockScreenTitle,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),

          const SizedBox(height: 12),

          // 描述
          Text(
            l10n.lockScreenDesc,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),

          const Spacer(flex: 2),

          // 错误消息
          if (_errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: colorScheme.error,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: colorScheme.onErrorContainer,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // 解锁按钮
          if (_biometricAvailable) ...[
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton.icon(
                onPressed: _isAuthenticating ? null : _authenticate,
                icon: _isAuthenticating
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.onPrimary,
                        ),
                      )
                    : Icon(_getBiometricIcon()),
                label: Text(
                  _isAuthenticating ? l10n.authenticating : l10n.unlockWithBiometric(_localizeBiometricType(l10n)),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],

          // PIN 码解锁按钮
          if (_hasPinCode) ...[
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _showPinInput = true;
                  _pinInput = '';
                  _errorMessage = null;
                });
              },
              icon: const Icon(Icons.pin_outlined),
              label: Text(l10n.usePinUnlock),
            ),
          ],

          const SizedBox(height: 16),

          // 提示文字
          Text(
            l10n.tapToAuthenticate,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.outline,
            ),
          ),

          const Spacer(flex: 1),

          // 底部安全标识
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.verified_user_outlined,
                size: 16,
                color: colorScheme.outline,
              ),
              const SizedBox(width: 6),
              Text(
                l10n.dataSecurity,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.outline,
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildPinInputView(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        const SizedBox(height: 16),

        // 返回按钮（如果有生物识别可以切回）
        if (_biometricAvailable)
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: IconButton(
                onPressed: () {
                  setState(() {
                    _showPinInput = false;
                    _pinInput = '';
                    _errorMessage = null;
                  });
                },
                icon: const Icon(Icons.arrow_back),
              ),
            ),
          ),

        const Spacer(flex: 1),

        // 图标
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            Icons.lock_outline,
            size: 36,
            color: colorScheme.primary,
          ),
        ),

        const SizedBox(height: 20),

        Text(
          l10n.enterPinCode,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 24),

        // PIN 指示器
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(6, (index) {
            final filled = index < _pinInput.length;
            return Container(
              width: 14,
              height: 14,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: filled ? colorScheme.primary : Colors.transparent,
                border: Border.all(
                  color: _errorMessage != null
                      ? colorScheme.error
                      : colorScheme.primary,
                  width: 2,
                ),
              ),
            );
          }),
        ),

        const SizedBox(height: 16),

        // 错误消息
        if (_errorMessage != null)
          Text(
            _errorMessage!,
            style: TextStyle(
              color: colorScheme.error,
              fontSize: 14,
            ),
          ),

        const Spacer(flex: 1),

        // 数字键盘
        _buildNumberPad(context),

        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildNumberPad(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Column(
        children: [
          for (int row = 0; row < 4; row++)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (row < 3) ...[
                    for (int col = 0; col < 3; col++)
                      _buildNumberButton(
                        context,
                        row * 3 + col + 1,
                        () => _onPinNumberTap(row * 3 + col + 1),
                      ),
                  ] else ...[
                    const SizedBox(width: 72, height: 72),
                    _buildNumberButton(
                      context,
                      0,
                      () => _onPinNumberTap(0),
                    ),
                    SizedBox(
                      width: 72,
                      height: 72,
                      child: IconButton(
                        onPressed: _onPinDelete,
                        icon: Icon(
                          Icons.backspace_outlined,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNumberButton(BuildContext context, int number, VoidCallback onTap) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: 72,
      height: 72,
      child: Material(
        color: colorScheme.surfaceContainerHighest,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Center(
            child: Text(
              '$number',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getBiometricIcon() {
    switch (_biometricType) {
      case 'faceId':
        return Icons.face;
      case 'iris':
        return Icons.remove_red_eye;
      default:
        return Icons.fingerprint;
    }
  }

  String _localizeBiometricType(AppLocalizations l10n) {
    switch (_biometricType) {
      case 'faceId':
        return l10n.faceId;
      case 'fingerprint':
        return l10n.fingerprint;
      case 'iris':
        return l10n.iris;
      case 'biometric':
        return l10n.biometric;
      case 'devicePasscode':
        return l10n.devicePasscode;
      default:
        return l10n.biometric;
    }
  }

  String? _localizeAuthError(AuthError? error) {
    if (error == null) return null;
    final l10n = AppLocalizations.of(context)!;
    switch (error) {
      case AuthError.notAvailable:
        return l10n.biometricNotAvailable;
      case AuthError.notEnrolled:
        return l10n.notEnrolled;
      case AuthError.lockedOut:
        return l10n.lockedOut;
      case AuthError.permanentlyLockedOut:
        return l10n.permanentlyLockedOut;
      case AuthError.passcodeNotSet:
        return l10n.passcodeNotSet;
      case AuthError.failed:
        return l10n.authFailed;
      case AuthError.cancelled:
        return null;
      case AuthError.unknown:
        return l10n.unknownAuthError;
    }
  }
}
