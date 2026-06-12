import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_colors.dart';

class PaginationWidget extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageChanged;

  const PaginationWidget({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildControlButton(
              icon: Icons.chevron_left,
              onPressed: currentPage > 1 ? () => onPageChanged(currentPage - 1) : null,
            ),
            const SizedBox(width: 8),
            ..._buildPageNumbers(),
            const SizedBox(width: 8),
            _buildControlButton(
              icon: Icons.chevron_right,
              onPressed: currentPage < totalPages ? () => onPageChanged(currentPage + 1) : null,
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildPageNumbers() {
    final List<Widget> widgets = [];
    final List<int?> pageNumbers = _calculatePageNumbers();

    for (int i = 0; i < pageNumbers.length; i++) {
      final page = pageNumbers[i];
      if (page == null) {
        widgets.add(const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.0),
          child: Text('...', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
        ));
      } else {
        widgets.add(_buildPageButton(page));
      }
    }
    return widgets;
  }

  List<int?> _calculatePageNumbers() {
    const int maxVisible = 6;
    if (totalPages <= maxVisible) {
      return List.generate(totalPages, (index) => index + 1);
    }

    final List<int?> pages = [];
    if (currentPage <= 3) {
      pages.addAll([1, 2, 3, 4, null, totalPages]);
    } else if (currentPage >= totalPages - 2) {
      pages.addAll([1, null, totalPages - 3, totalPages - 2, totalPages - 1, totalPages]);
    } else {
      pages.addAll([1, null, currentPage - 1, currentPage, currentPage + 1, null, totalPages]);
    }
    return pages;
  }

  Widget _buildPageButton(int page) {
    final isSelected = page == currentPage;
    return InkWell(
      onTap: isSelected ? null : () => onPageChanged(page),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.brandDark : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.brandDark : AppColors.border,
          ),
        ),
        child: Text(
          page.toString(),
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({required IconData icon, VoidCallback? onPressed}) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: onPressed != null ? AppColors.surface : AppColors.surface.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.border,
          ),
        ),
        child: Icon(
          icon,
          size: 20,
          color: onPressed != null ? AppColors.textPrimary : AppColors.textSecondary,
        ),
      ),
    );
  }
}
