import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CommuteTimeModal extends StatefulWidget {
  final int initialMinutes;
  final double distanceKm;
  final String distanceText;
  final String durationText;
  final String fromLocation;
  final String toLocation;
  final VoidCallback onConfirm;
  final Function(int) onTimeChanged;

  const CommuteTimeModal({
    super.key,
    required this.initialMinutes,
    required this.distanceKm,
    required this.distanceText,
    required this.durationText,
    required this.fromLocation,
    required this.toLocation,
    required this.onConfirm,
    required this.onTimeChanged,
  });

  @override
  State<CommuteTimeModal> createState() => _CommuteTimeModalState();
}

class _CommuteTimeModalState extends State<CommuteTimeModal>
    with SingleTickerProviderStateMixin {
  late int _minutes;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _minutes = widget.initialMinutes;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _updateTime(int delta) {
    setState(() {
      _minutes = (_minutes + delta).clamp(5, 300);
      widget.onTimeChanged(_minutes);
    });
  }

  Future<void> _close() async {
    await _animationController.reverse();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Blurred background
        FadeTransition(
          opacity: _fadeAnimation,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              color: Colors.black.withOpacity(0.5),
            ),
          ),
        ),

        // Modal content
        Center(
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Dialog(
                backgroundColor: Colors.transparent,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceDark,
                    borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                    border: Border.all(
                      color: AppTheme.borderDark,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.route,
                              color: AppTheme.primary,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Route Calculated',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'We’ll match the podcast to this time.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: _close,
                            icon: Icon(
                              Icons.close,
                              color: Colors.grey.shade400,
                            ),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.05),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Route Info
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.backgroundDark,
                          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                          border: Border.all(
                            color: AppTheme.borderDark,
                          ),
                        ),
                        child: Column(
                          children: [
                            _buildRouteRow(
                              Icons.my_location,
                              'From',
                              widget.fromLocation,
                              AppTheme.primary,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  const SizedBox(width: 40),
                                  Expanded(
                                    child: Container(
                                      height: 1,
                                      color: AppTheme.borderDark,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: Text(
                                      widget.distanceText,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade500,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      height: 1,
                                      color: AppTheme.borderDark,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _buildRouteRow(
                              Icons.location_on,
                              'To',
                              widget.toLocation,
                              Colors.red,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Time Display
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
                        decoration: BoxDecoration(
                          // 1. Richer Dark Gradient
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppTheme.surfaceDark.withOpacity(0.9),
                              Colors.black.withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          // 2. Subtle Glow Border
                          border: Border.all(
                            color: AppTheme.primary.withOpacity(0.15),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'TARGET DURATION',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade500,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 7),
                            
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Left Group
                                Row(
                                  children: [
                                    _buildSecondaryButton('-5', () => _updateTime(-5)),
                                    const SizedBox(width: 7),
                                    _buildPrimaryButton(Icons.remove, () => _updateTime(-1)),
                                  ],
                                ),

                                // Center Display (Rich Text for better alignment)
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text(
                                      '$_minutes',
                                      style: const TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.w800, // Extra bold
                                        color: Colors.white,
                                        letterSpacing: -1,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'min',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.primary.withOpacity(0.8),
                                      ),
                                    ),
                                  ],
                                ),

                                // Right Group
                                Row(
                                  children: [
                                    _buildPrimaryButton(Icons.add, () => _updateTime(1)),
                                    const SizedBox(width: 7),
                                    _buildSecondaryButton('+5', () => _updateTime(5)),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Confirm Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () async {
                            await _close();
                            widget.onConfirm();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Continue',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

Widget _buildPrimaryButton(IconData icon, VoidCallback onTap) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(30),
    child: Container(
      width: 38, // Slightly larger touch target
      height: 38,
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.1), // Subtle tint fill
        shape: BoxShape.circle,
        border: Border.all(
          color: AppTheme.primary.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          // Small glow behind the main buttons
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Icon(
        icon,
        size: 20,
        color: AppTheme.primary, // Bright Icon
      ),
    ),
  );
}

// 2. Secondary Button (The Pill - Low profile, "Utility" feel)
Widget _buildSecondaryButton(String label, VoidCallback onTap) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03), // Very faint background
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1), // Subtle border
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.grey.shade400,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}

  Widget _buildRouteRow(
    IconData icon,
    String label,
    String location,
    Color iconColor,
  ) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                location,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeButton(String label, IconData icon, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.backgroundDark,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          side: const BorderSide(
            color: AppTheme.borderDark,
          ),
        ),
        elevation: 0,
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

