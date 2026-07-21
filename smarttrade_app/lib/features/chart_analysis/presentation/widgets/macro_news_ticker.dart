import 'package:flutter/material.dart';
import 'package:smarttrade_app/app/theme/app_colors.dart';
import 'package:smarttrade_app/features/chart_analysis/domain/entities/macro_news_headline.dart';

/// Fixed-height strip reserved at the bottom of the chart screen for a
/// scrolling news-ticker ("tarja") of macroeconomic headlines.
///
/// Data comes from [MacroNewsRepository], which is a placeholder today
/// (see `data/repositories/macro_news_repository_impl.dart`); this
/// widget only owns the scrolling presentation so wiring in a live feed
/// later is a data-layer change.
class MacroNewsTicker extends StatefulWidget {
  const MacroNewsTicker({super.key, required this.headlines});

  final List<MacroNewsHeadline> headlines;

  static const double height = 36;

  @override
  State<MacroNewsTicker> createState() => _MacroNewsTickerState();
}

class _MacroNewsTickerState extends State<MacroNewsTicker>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..addListener(_advanceScroll);
    if (widget.headlines.isNotEmpty) {
      _controller.repeat();
    }
  }

  void _advanceScroll() {
    if (!_scrollController.hasClients) return;
    final max = _scrollController.position.maxScrollExtent;
    if (max <= 0) return;
    _scrollController.jumpTo(_controller.value * max);
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.headlines.isEmpty) {
      return Container(
        height: MacroNewsTicker.height,
        color: AppColors.tickerBackground,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: const Text(
          'Tarja macroeconômica: aguardando dados.',
          style: TextStyle(fontSize: 12, color: AppColors.textDisabled),
        ),
      );
    }

    return Container(
      height: MacroNewsTicker.height,
      color: AppColors.tickerBackground,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            alignment: Alignment.center,
            color: AppColors.surfaceElevated,
            height: double.infinity,
            child: const Text(
              'MACRO',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: widget.headlines.length,
              separatorBuilder: (_, _) => const SizedBox(width: 28),
              itemBuilder: (context, index) {
                final item = widget.headlines[index];
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ImpactDot(impact: item.impact),
                    const SizedBox(width: 6),
                    Text(
                      item.headline,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ImpactDot extends StatelessWidget {
  const _ImpactDot({required this.impact});

  final MacroImpact impact;

  @override
  Widget build(BuildContext context) {
    final color = switch (impact) {
      MacroImpact.high => AppColors.loss,
      MacroImpact.medium => AppColors.warning,
      MacroImpact.low => AppColors.textDisabled,
    };
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
