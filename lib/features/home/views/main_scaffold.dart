import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'home_tab.dart';
import 'package:mobile/core/widgets/lazy_indexed_stack.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    const HomeTab(),
    const Scaffold(body: Center(child: Text('Study Tab'))),
    const Scaffold(body: Center(child: Text('Progress Tab'))),
    const Scaffold(body: Center(child: Text('Settings Tab'))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: LazyIndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Color(0x05000000),
              blurRadius: 20,
              offset: Offset(0, -4),
            )
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
              icon: _buildIcon(Icons.home_outlined, 0),
              activeIcon: _buildIcon(Icons.home, 0),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: _buildIcon(Icons.menu_book_outlined, 1),
              activeIcon: _buildIcon(Icons.menu_book, 1),
              label: 'Study',
            ),
            BottomNavigationBarItem(
              icon: _buildIcon(Icons.bar_chart_outlined, 2),
              activeIcon: _buildIcon(Icons.bar_chart, 2),
              label: 'Progress',
            ),
            BottomNavigationBarItem(
              icon: _buildIcon(Icons.settings_outlined, 3),
              activeIcon: _buildIcon(Icons.settings, 3),
              label: 'Settings',
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
