import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_text_styles.dart';
import 'package:mobile/core/validators/user_validator.dart';
import 'package:mobile/features/admin/controllers/user_controller.dart';
import 'package:mobile/features/auth/models/user_model.dart';
import 'package:mobile/core/utils/debouncer.dart';
import 'package:mobile/core/widgets/error_retry_widget.dart';

class UsersTab extends ConsumerStatefulWidget {
  const UsersTab({super.key});

  @override
  ConsumerState<UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends ConsumerState<UsersTab> {
  final _searchController = TextEditingController();
  String? _searchError;
  final _debouncer = Debouncer(milliseconds: 500);

  @override
  void dispose() {
    _debouncer.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    final error = UserValidator.validateSearch(query);
    setState(() => _searchError = error);
    // Chỉ gọi API khi không có lỗi validation
    if (error == null) {
      _debouncer.run(() {
        ref.read(userControllerProvider.notifier).search(query);
      });
    }
  }

  Future<void> _confirmToggleStatus(
    BuildContext context,
    UserModel user,
  ) async {
    final isBanning = user.isActive;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          isBanning ? 'Khóa tài khoản' : 'Mở khóa tài khoản',
          style: AppTextStyles.h3,
        ),
        content: Text(
          isBanning
              ? 'Bạn có chắc muốn khóa tài khoản của "${user.username}" không? Người dùng sẽ không thể đăng nhập.'
              : 'Bạn có chắc muốn mở khóa tài khoản của "${user.username}" không?',
          style: AppTextStyles.bodyText,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              isBanning ? 'Khóa' : 'Mở khóa',
              style: TextStyle(
                color: isBanning ? AppColors.error : AppColors.success,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final messenger = ScaffoldMessenger.of(context);
      try {
        await ref
            .read(userControllerProvider.notifier)
            .toggleUserStatus(user.id, user.isActive);
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              isBanning
                  ? 'Đã khóa tài khoản "${user.username}"'
                  : 'Đã mở khóa tài khoản "${user.username}"',
            ),
            backgroundColor: isBanning ? AppColors.error : AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } catch (e) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final usersState = ref.watch(userControllerProvider);

    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quản lý Người dùng',
                style: AppTextStyles.h2,
              ),
              const SizedBox(height: 4),
              Text(
                'Quản lý tài khoản và trạng thái người dùng trong hệ thống.',
                style: AppTextStyles.bodyText.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearch,
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm theo tên hoặc email...',
                    hintStyle: AppTextStyles.bodyText.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppColors.textSecondary,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.clear,
                              color: AppColors.textSecondary,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchError = null);
                              _onSearch('');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              // Hiển thị lỗi validation ngay dưới ô tìm kiếm
              if (_searchError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6, left: 16),
                  child: Text(
                    _searchError!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.error,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Stats Cards
        usersState.when(
          data: (users) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Tổng người dùng',
                    '${users.length}',
                    AppColors.brandDark,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Đang hoạt động',
                    '${users.where((u) => u.isActive).length}',
                    AppColors.success,
                  ),
                ),
              ],
            ),
          ),
          loading: () => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Tổng người dùng',
                    '...',
                    AppColors.brandDark,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Đang hoạt động',
                    '...',
                    AppColors.success,
                  ),
                ),
              ],
            ),
          ),
          error: (error, stackTrace) => const SizedBox.shrink(),
        ),

        const SizedBox(height: 24),

        // User List
        Expanded(
          child: usersState.when(
            loading: () => const SizedBox.shrink(),
            error: (error, _) => ErrorRetryWidget(
              errorMessage: error.toString(),
              onRetry: () => ref.read(userControllerProvider.notifier).refresh(),
            ),
            data: (users) {
              if (users.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.people_outline,
                        size: 64,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Không tìm thấy người dùng nào',
                        style: AppTextStyles.bodyText.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () =>
                    ref.read(userControllerProvider.notifier).refresh(),
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: users.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return _buildUserCard(context, users[index]);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, Color valueColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(value, style: AppTextStyles.h2.copyWith(color: valueColor)),
        ],
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, UserModel user) {
    final isAdmin = user.role == 'admin';
    final isActive = user.isActive;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: !isActive
            ? Border.all(color: AppColors.error.withValues(alpha: 0.3))
            : null,
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
          // Avatar
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primary,
            child: Text(
              user.initials,
              style: AppTextStyles.bodyText.copyWith(
                color: AppColors.brandDark,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        user.username,
                        style: AppTextStyles.h3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isAdmin
                            ? AppColors.surfacePink
                            : AppColors.tertiary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isAdmin ? 'Admin' : 'User',
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 10,
                          color: isAdmin
                              ? AppColors.brandDark
                              : AppColors.textSecondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (!isActive) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Bị khóa',
                          style: AppTextStyles.bodySmall.copyWith(
                            fontSize: 10,
                            color: AppColors.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Action Menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: (value) async {
              if (value == 'toggle_status') {
                await _confirmToggleStatus(context, user);
              }
            },
            itemBuilder: (ctx) => [
              PopupMenuItem<String>(
                value: 'toggle_status',
                child: Row(
                  children: [
                    Icon(
                      isActive ? Icons.block : Icons.check_circle_outline,
                      color: isActive ? AppColors.error : AppColors.success,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      isActive ? 'Khóa tài khoản' : 'Mở khóa tài khoản',
                      style: AppTextStyles.bodyText.copyWith(
                        color: isActive ? AppColors.error : AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
