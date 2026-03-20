import 'package:flutter/material.dart';
import 'package:ubel/core/theme/app_colors.dart';

class LuxuryAccordionItem extends StatefulWidget {
  final String? title;
  final Widget? titleWidget;
  final Widget content;
  final bool isLast;
  final bool isHighest; // Triggers the Pulse and Gavel icon

  const LuxuryAccordionItem({
    super.key,
    this.title,
    this.titleWidget,
    required this.content,
    this.isLast = false,
    this.isHighest = false,
  });

  @override
  State<LuxuryAccordionItem> createState() => _LuxuryAccordionItemState();
}

class _LuxuryAccordionItemState extends State<LuxuryAccordionItem>
    with SingleTickerProviderStateMixin {
  bool isExpanded = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    if (widget.isHighest) {
      _pulseController.repeat();
    }
  }

  @override
  void didUpdateWidget(LuxuryAccordionItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Start or stop pulse if the "Highest" status changes in real-time
    if (widget.isHighest && !_pulseController.isAnimating) {
      _pulseController.repeat();
    } else if (!widget.isHighest && _pulseController.isAnimating) {
      _pulseController.stop();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- LEFT COLUMN: ICON & CONNECTING LINE ---
          SizedBox(
            width: 48,
            child: Column(
              children: [
                _buildAnimatedIcon(),
                if (!widget.isLast)
                  Expanded(
                    child: Container(
                      width: 0.2,
                      height: 28,
                      color: AppColors.darkGray,
                    ),
                  ),
              ],
            ),
          ),

          // --- RIGHT COLUMN: HEADER & CONTENT ---
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => setState(() => isExpanded = !isExpanded),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(top: 4, bottom: 12),
                    child: widget.titleWidget ??
                        Text(
                          widget.title ?? '',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.textPrimary,
                          ),
                        ),
                  ),
                ),

                // Content Expansion
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: SizedBox(
                    width: double.infinity,
                    child: isExpanded
                        ? Padding(
                            padding:
                                const EdgeInsets.only(bottom: 24, right: 16),
                            child: widget.content,
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedIcon() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // The Pulse Ring (Only for Top Bidder)
        if (widget.isHighest)
          ScaleTransition(
            scale: Tween(begin: 1.0, end: 2.0).animate(
              CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
            ),
            child: FadeTransition(
              opacity: Tween(begin: 0.5, end: 0.0).animate(_pulseController),
              child: Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryPurple,
                ),
              ),
            ),
          ),

        // The Primary Icon Circle
        GestureDetector(
          onTap: () => setState(() => isExpanded = !isExpanded),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.isHighest
                  ? AppColors.primaryPurple
                  : (isExpanded ? AppColors.darkGray : Colors.white),
              border: Border.all(
                color:
                    widget.isHighest ? AppColors.primaryPurple : AppColors.darkGray,
                width: 0.4,
              ),
              boxShadow: widget.isHighest
                  ? [
                      BoxShadow(
                        color: AppColors.primaryPurple.withAlpha(40),
                        blurRadius: 8,
                        spreadRadius: 1,
                      )
                    ]
                  : null,
            ),
            child: Icon(
              widget.isHighest
                  ? Icons.gavel_rounded
                  : (isExpanded ? Icons.remove : Icons.add),
              size: 14,
              color: (widget.isHighest || isExpanded)
                  ? AppColors.pureWhite
                  : AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
