import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:nft_marketplace_mobile/config/themes/app_palette.dart';

// Custom Filter Option class
class FilterOption {
  final String label;
  final String value;
  final IconData? icon;

  FilterOption({required this.label, required this.value, this.icon});
}

// Updated Custom Filter Chip Widget
class CustomFilterChip extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isSelected;
  final IconData? icon;

  const CustomFilterChip({
    super.key,
    required this.label,
    this.onTap,
    this.isSelected = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(
            color: Colors.grey[800]!,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16.r,
                color: AppPalette.textPrimary,
              ),
              Gap(4.w),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppPalette.textPrimary,
              ),
            ),
            Gap(4.w),
            Icon(
              Icons.keyboard_arrow_down,
              size: 20.r,
              color: AppPalette.textPrimary,
            ),
          ],
        ),
      ),
    );
  }
}

// Updated Filter Bottom Sheet
class FilterBottomSheet extends StatelessWidget {
  final List<FilterOption> options;
  final String selectedValue;
  final Function(FilterOption) onOptionSelected;
  final double initialChildSize;
  final double maxChildSize;

  const FilterBottomSheet({
    super.key,
    required this.options,
    required this.selectedValue,
    required this.onOptionSelected,
    this.initialChildSize = 0.3,
    this.maxChildSize = 0.7,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.pop(context),
      child: DraggableScrollableSheet(
        initialChildSize: initialChildSize,
        maxChildSize: maxChildSize,
        minChildSize: 0.2,
        builder: (context, scrollController) {
          return GestureDetector(
            onTap: () {},
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 12.h),
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Colors.grey[600],
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: options.length,
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      itemBuilder: (context, index) {
                        final option = options[index];
                        final isSelected = option.value == selectedValue;

                        return InkWell(
                          onTap: () {
                            onOptionSelected(option);
                            Navigator.pop(context);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 12.h,
                            ),
                            child: Row(
                              children: [
                                if (option.icon != null) ...[
                                  Icon(
                                    option.icon,
                                    size: 24.r,
                                    color: AppPalette.textPrimary,
                                  ),
                                  Gap(12.w),
                                ],
                                Text(
                                  option.label,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    color: AppPalette.textPrimary,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                                const Spacer(),
                                if (isSelected)
                                  Icon(
                                    Icons.check,
                                    size: 24.r,
                                    color: Colors.blue,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
