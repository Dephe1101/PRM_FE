import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_text_styles.dart';
import 'package:mobile/core/exceptions/app_exception.dart';
import 'package:mobile/features/admin/controllers/level_controller.dart';
import 'package:mobile/features/admin/models/level_model.dart';
import 'package:mobile/features/admin/views/widgets/level_crud_dialog.dart';
import 'package:mobile/features/admin/views/widgets/level_detail_dialog.dart';

class LevelsTab extends ConsumerWidget {
  const LevelsTab({super.key});

  void _showCrudDialog(
    BuildContext context,
    WidgetRef ref, {
    LevelModel? level,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => LevelCrudDialog(
        initialData: level,
        onSubmit: (data) async {
          if (level == null) {
            await ref.read(levelControllerProvider.notifier).createLevel(data);
          } else {
            await ref
                .read(levelControllerProvider.notifier)
                .updateLevel(level.id, data);
          }
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, LevelModel level) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa cấp độ "${level.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy', style: TextStyle(color: AppColors.error)),
          ),
          TextButton(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              Navigator.pop(dialogContext);
              try {
                await ref
                    .read(levelControllerProvider.notifier)
                    .deleteLevel(level.id);
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Xóa cấp độ thành công'),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } catch (e) {
                final errorMessage = e is AppException
                    ? e.message
                    : 'Đã xảy ra lỗi không xác định';
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(errorMessage),
                    backgroundColor: AppColors.error,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showLevelDetailsDialog(BuildContext context, LevelModel level) {
    showDialog(
      context: context,
      builder: (context) => LevelDetailDialog(level: level),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(levelControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        heroTag: 'levels_fab',
        onPressed: () => _showCrudDialog(context, ref),
        backgroundColor: AppColors.brandDark,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, color: AppColors.surface, size: 28),
      ),
      body: state.when(
        data: (levels) {
          return ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: levels.length + 1, // +1 for Header
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              if (index == 0) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Quản lý Cấp độ', style: AppTextStyles.h2),
                    const SizedBox(height: 8),
                    Text(
                      'Quản lý các cấp độ JLPT và người học.',
                      style: AppTextStyles.bodyText.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              }
              final level = levels[index - 1];
              return _buildLevelCard(context, ref, level);
            },
          );
        },
        loading: () => const SizedBox.shrink(),
        error: (err, stack) => Center(
          child: Text(
            'Error loading levels: $err',
            style: AppTextStyles.bodyText.copyWith(color: AppColors.error),
          ),
        ),
      ),
    );
  }

  Widget _buildLevelCard(
    BuildContext context,
    WidgetRef ref,
    LevelModel level,
  ) {
    final isActive = level.isActive;

    // Tạo level badge text từ tên (VD: "JLPT N5" -> "N5", hoặc lấy 2 ký tự đầu)
    String badgeText = level.name.length >= 2
        ? level.name.substring(0, 2).toUpperCase()
        : level.name;
    if (level.name.contains('N5')) badgeText = 'N5';
    if (level.name.contains('N4')) badgeText = 'N4';
    if (level.name.contains('N3')) badgeText = 'N3';
    if (level.name.contains('N2')) badgeText = 'N2';
    if (level.name.contains('N1')) badgeText = 'N1';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showLevelDetailsDialog(context, level),
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x03000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Level Circle
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive ? AppColors.surfacePink : AppColors.tertiary,
                ),
                alignment: Alignment.center,
                child: Text(
                  badgeText,
                  style: AppTextStyles.h2.copyWith(
                    color: isActive
                        ? AppColors.brandDark
                        : AppColors.textSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      level.name,
                      style: AppTextStyles.h3.copyWith(
                        color: isActive
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                    if (level.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        level.description,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isActive
                              ? AppColors.brandDark
                              : AppColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              // Action Menu
              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_vert,
                  color: AppColors.textSecondary,
                ),
                onSelected: (value) {
                  if (value == 'edit') {
                    _showCrudDialog(context, ref, level: level);
                  } else if (value == 'delete') {
                    _confirmDelete(context, ref, level);
                  } else if (value == 'toggle') {
                    ref
                        .read(levelControllerProvider.notifier)
                        .toggleActiveStatus(level.id, level.isActive);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'toggle',
                    child: Row(
                      children: [
                        Icon(
                          isActive ? Icons.visibility_off : Icons.visibility,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(isActive ? 'Deactivate' : 'Activate'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, color: AppColors.brandDark, size: 20),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: AppColors.error, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Delete',
                          style: TextStyle(color: AppColors.error),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
