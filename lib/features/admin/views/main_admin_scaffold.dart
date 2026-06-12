import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/auth/controllers/auth_controller.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_text_styles.dart';
import 'package:mobile/features/admin/views/users_tab.dart';
import 'package:mobile/features/admin/views/levels_tab.dart';
import 'package:mobile/features/admin/views/topics_tab.dart';
import 'package:mobile/features/admin/views/vocab_tab.dart';
import 'package:mobile/core/widgets/lazy_indexed_stack.dart';

class MainAdminScaffold extends ConsumerStatefulWidget {
  const MainAdminScaffold({super.key});

  @override
  ConsumerState<MainAdminScaffold> createState() => _MainAdminScaffoldState();
}

class _MainAdminScaffoldState extends ConsumerState<MainAdminScaffold> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    const UsersTab(),
    const LevelsTab(),
    const TopicsTab(),
    const VocabTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          'Sakura Admin',
          style: AppTextStyles.h2.copyWith(color: AppColors.brandDark),
        ),
        actions: [
          PopupMenuButton<String>(
            offset: const Offset(0, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            icon: const CircleAvatar(
              backgroundColor: AppColors.brandDark,
              child: Icon(Icons.person, color: Colors.white, size: 20),
            ),
            onSelected: (value) async {
              if (value == 'profile') {
                // Navigate to profile
              } else if (value == 'logout') {
                await ref.read(authControllerProvider.notifier).logout();
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'profile',
                child: Row(
                  children: [
                    const Icon(
                      Icons.person_outline,
                      color: AppColors.textPrimary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Hồ sơ cá nhân',
                      style: AppTextStyles.bodyText.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    const Icon(Icons.logout, color: AppColors.error, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      'Đăng xuất',
                      style: AppTextStyles.bodyText.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.border, height: 1),
        ),
      ),
      body: LazyIndexedStack(index: _currentIndex, children: _tabs),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Color(0x05000000),
              blurRadius: 20,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.brandDark,
          unselectedItemColor: AppColors.textSecondary,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: _buildIcon(Icons.people_outline, 0),
              activeIcon: _buildIcon(Icons.people, 0),
              label: 'Users',
            ),
            BottomNavigationBarItem(
              icon: _buildIcon(Icons.layers_outlined, 1),
              activeIcon: _buildIcon(Icons.layers, 1),
              label: 'Levels',
            ),
            BottomNavigationBarItem(
              icon: _buildIcon(Icons.category_outlined, 2),
              activeIcon: _buildIcon(Icons.category, 2),
              label: 'Topics',
            ),
            BottomNavigationBarItem(
              icon: _buildIcon(Icons.translate_outlined, 3),
              activeIcon: _buildIcon(Icons.translate, 3),
              label: 'Vocab',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(IconData icon, int index) {
    final isSelected = _currentIndex == index;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.surfacePink : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(icon),
    );
  }
}
