import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_text_styles.dart';
import 'package:mobile/core/widgets/error_retry_widget.dart';
import 'package:mobile/features/auth/controllers/profile_controller.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isEditingName = false;
  final TextEditingController _nameController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submitNameChange(String currentName) async {
    final newName = _nameController.text.trim();
    if (newName.isEmpty || newName == currentName) {
      setState(() {
        _isEditingName = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final success = await ref
        .read(profileControllerProvider.notifier)
        .updateUsername(newName);

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (success) {
          _isEditingName = false;
        }
      });
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cập nhật tên thất bại. Vui lòng thử lại.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ sơ cá nhân'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: profileState.when(
        data: (user) => SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // Avatar
              CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                child: Text(
                  user.initials,
                  style: AppTextStyles.h1.copyWith(
                    color: AppColors.brandDark,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Name and Email
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isEditingName)
                    SizedBox(
                      width: 200,
                      child: TextField(
                        controller: _nameController,
                        style: AppTextStyles.heading2.copyWith(color: AppColors.brandDark),
                        decoration: InputDecoration(
                          hintText: 'Nhập tên mới',
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onSubmitted: (_) => _submitNameChange(user.username),
                        autofocus: true,
                      ),
                    )
                  else
                    Flexible(
                      child: Text(
                        user.username,
                        style: AppTextStyles.heading2.copyWith(color: AppColors.brandDark),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  const SizedBox(width: 8),
                  if (_isLoading)
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    IconButton(
                      icon: Icon(
                        _isEditingName ? Icons.check : Icons.edit,
                        color: _isEditingName ? AppColors.success : AppColors.primary,
                      ),
                      onPressed: () {
                        if (_isEditingName) {
                          _submitNameChange(user.username);
                        } else {
                          setState(() {
                            _isEditingName = true;
                            _nameController.text = user.username;
                          });
                        }
                      },
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                user.email,
                style: AppTextStyles.bodyText.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: user.role == 'admin' 
                      ? AppColors.error.withValues(alpha: 0.1)
                      : AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  user.role.toUpperCase(),
                  style: AppTextStyles.caption.copyWith(
                    color: user.role == 'admin' ? AppColors.error : AppColors.success,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Stats Cards
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      title: 'Cấp độ',
                      value: '${user.level}',
                      icon: Icons.star_rounded,
                      color: AppColors.warning,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      title: 'Kinh nghiệm',
                      value: '${user.xp}',
                      icon: Icons.flash_on_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      title: 'Xu',
                      value: '${user.coins}',
                      icon: Icons.monetization_on_rounded,
                      color: const Color(0xFFFFB300),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (err, st) => Center(
          child: ErrorRetryWidget(
            errorMessage: 'Không thể tải thông tin hồ sơ',
            onRetry: () => ref.read(profileControllerProvider.notifier).refresh(),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTextStyles.h3.copyWith(color: AppColors.brandDark),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
