// ... imports stay exactly the same ...
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ubel/core/theme/app_colors.dart';
import 'package:ubel/features/bidding/presentation/providers/bidding_provider.dart';

class PlaceBidButton extends ConsumerStatefulWidget {
  final String auctionId;
  final double currentPrice;

  const PlaceBidButton({
    super.key,
    required this.auctionId,
    required this.currentPrice,
  });

  @override
  ConsumerState<PlaceBidButton> createState() => _PlaceBidButtonState();
}

class _PlaceBidButtonState extends ConsumerState<PlaceBidButton> {
  final _amountController = TextEditingController();

  double get _minBid => widget.currentPrice + 1.0;

  @override
  void initState() {
    super.initState();
    _amountController.text = _minBid.toStringAsFixed(2);
  }

  @override
  void didUpdateWidget(PlaceBidButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentPrice != widget.currentPrice) {
      _amountController.text = _minBid.toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _showBidDialog() async {
    _amountController.text = _minBid.toStringAsFixed(2);

    final result = await showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.7), // Deeper backdrop for focus
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          top: 12, // Slightly tighter top
          left: 24,
          right: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.darkGray.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Place Your Bid',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -1.0, // Luxury tight tracking
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Minimum bid: \$${_minBid.toStringAsFixed(2)}',
              style: const TextStyle(
                color: AppColors.mediumGray,
                fontSize: 14,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 28),
            TextField(
              controller: _amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              decoration: InputDecoration(
                labelText: 'Bid Amount',
                labelStyle:
                    const TextStyle(color: AppColors.mediumGray, fontSize: 14),
                prefixText: '\$ ',
                prefixStyle: const TextStyle(
                    fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                filled: true,
                fillColor: AppColors.surface, // Cleaner than shade100
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide:
                      BorderSide(color: AppColors.darkGray.withOpacity(0.1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                      color: AppColors.primaryYellow, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      final amount = double.tryParse(_amountController.text);
                      if (amount != null && amount >= _minBid) {
                        HapticFeedback.heavyImpact();
                        Navigator.pop(context, amount);
                      } else {
                        HapticFeedback.vibrate();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 20),
                      decoration: BoxDecoration(
                        color: AppColors.primaryYellow,
                        borderRadius: BorderRadius.circular(16),
                        // boxShadow: [
                        //   BoxShadow(
                        //     color: AppColors.primaryYellow.withOpacity(0.3),
                        //     blurRadius: 20,
                        //     offset: const Offset(0, 8),
                        //   ),
                        // ],
                      ),
                      child: const Text(
                        'Confirm a Bid',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          letterSpacing: 0.5,
                          color: AppColors.textPrimary
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      border: Border.all(
                          width: 1, color: AppColors.darkGray.withOpacity(0.1)),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: SvgPicture.asset(
                      'assets/icons/heart-light.svg',
                      width: 22,
                      colorFilter: const ColorFilter.mode(
                          AppColors.textPrimary, BlendMode.srcIn),
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      await _placeBid(result);
    }
  }

  Future<void> _placeBid(double amount) async {
    await ref.read(biddingControllerProvider.notifier).placeBid(
          auctionId: widget.auctionId,
          amount: amount,
        );

    if (mounted) {
      final state = ref.read(biddingControllerProvider);
      if (state.hasError) {
        _showNotification('Failed: ${state.error}', Colors.red);
      } else {
        _showNotification('Bid placed successfully!', AppColors.success);
      }
    }
  }

  void _showNotification(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text(message, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(biddingControllerProvider);

    return InkWell(
      onTap: state.isLoading ? null : _showBidDialog,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: state.isLoading
              ? AppColors.mediumGray.withOpacity(0.2)
              : AppColors.primaryYellow,
          borderRadius: BorderRadius.circular(16),
          // boxShadow: state.isLoading
          //     ? []
          //     : [
          //         BoxShadow(
          //           color: AppColors.primaryYellow.withOpacity(0.25),
          //           blurRadius: 15,
          //           offset: const Offset(0, 4),
          //         )
          //       ],
        ),
        child: state.isLoading
            ? const Center(
                child: SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.black)))
            : const Text(
                'Place a Bid',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  letterSpacing: 1.0,
                  color: AppColors.textPrimary
                ),
              ),
      ),
    );
  }
}
