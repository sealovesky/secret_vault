import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../l10n/app_localizations.dart';

/// PIN 码设置界面
class PinSetupScreen extends StatefulWidget {
  final VoidCallback onPinSet;

  const PinSetupScreen({super.key, required this.onPinSet});

  @override
  State<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen> {
  String _pin = '';
  String? _firstPin;
  bool _isConfirming = false;
  String? _errorMessage;

  void _onNumberTap(int number) {
    if (_pin.length >= 6) return;
    setState(() {
      _pin += number.toString();
      _errorMessage = null;
    });

    if (_pin.length == 6) {
      _onPinComplete();
    }
  }

  void _onDelete() {
    if (_pin.isEmpty) return;
    setState(() {
      _pin = _pin.substring(0, _pin.length - 1);
      _errorMessage = null;
    });
  }

  Future<void> _onPinComplete() async {
    if (!_isConfirming) {
      // 第一次输入
      setState(() {
        _firstPin = _pin;
        _pin = '';
        _isConfirming = true;
      });
    } else {
      // 确认输入
      if (_pin == _firstPin) {
        final authService = context.read<AuthService>();
        await authService.setPinCode(_pin);
        if (mounted) {
          widget.onPinSet();
        }
      } else {
        setState(() {
          _pin = '';
          _firstPin = null;
          _isConfirming = false;
          _errorMessage = AppLocalizations.of(context)!.pinMismatch;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),

            // 图标
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.pin_outlined,
                size: 40,
                color: colorScheme.primary,
              ),
            ),

            const SizedBox(height: 24),

            // 标题
            Text(
              _isConfirming ? l10n.confirmPinCode : l10n.pinCodeSetup,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              _isConfirming ? l10n.reenterPin : l10n.enterSixDigitPin,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 32),

            // PIN 指示器
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(6, (index) {
                final filled = index < _pin.length;
                return Container(
                  width: 16,
                  height: 16,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: filled ? colorScheme.primary : Colors.transparent,
                    border: Border.all(
                      color: colorScheme.primary,
                      width: 2,
                    ),
                  ),
                );
              }),
            ),

            const SizedBox(height: 16),

            // 错误消息
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(
                    color: colorScheme.error,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

            const Spacer(flex: 1),

            // 数字键盘
            _buildNumberPad(context),

            const SizedBox(height: 32),
          ],
        ),
      ),
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
                      _NumberButton(
                        number: row * 3 + col + 1,
                        onTap: () => _onNumberTap(row * 3 + col + 1),
                      ),
                  ] else ...[
                    const SizedBox(width: 72, height: 72),
                    _NumberButton(
                      number: 0,
                      onTap: () => _onNumberTap(0),
                    ),
                    SizedBox(
                      width: 72,
                      height: 72,
                      child: IconButton(
                        onPressed: _onDelete,
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
}

class _NumberButton extends StatelessWidget {
  final int number;
  final VoidCallback onTap;

  const _NumberButton({required this.number, required this.onTap});

  @override
  Widget build(BuildContext context) {
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
}
