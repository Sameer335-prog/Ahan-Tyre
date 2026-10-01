import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/responsive/responsive_layout.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../features/auth/auth_controller.dart';
import '../../core/widgets/dialogs.dart';

class AppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  static const List<NavigationDestination> _destinations = [
    NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Dashboard'),
    NavigationDestination(icon: Icon(Icons.shopping_cart_outlined), selectedIcon: Icon(Icons.shopping_cart), label: 'Sales'),
    NavigationDestination(icon: Icon(Icons.shopping_bag_outlined), selectedIcon: Icon(Icons.shopping_bag), label: 'Purchases'),
    NavigationDestination(icon: Icon(Icons.inventory_2_outlined), selectedIcon: Icon(Icons.inventory_2), label: 'Inventory'),
    NavigationDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people), label: 'Customers'),
    NavigationDestination(icon: Icon(Icons.local_shipping_outlined), selectedIcon: Icon(Icons.local_shipping), label: 'Suppliers'),
    NavigationDestination(icon: Icon(Icons.payments_outlined), selectedIcon: Icon(Icons.payments), label: 'Payments'),
    NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: 'Expenses'),
    NavigationDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart), label: 'Reports'),
    NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Settings'),
  ];

  void _onNavigate(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  void _handleLogout(BuildContext context) {
    ConfirmDialog.show(
      context,
      title: 'Log Out',
      message: 'Are you sure you want to log out?',
      confirmText: 'Log Out',
      isDestructive: true,
      onConfirm: () {
        context.read<AuthController>().signOut();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);

    return Scaffold(
      appBar: isMobile 
          ? AppBar(
              title: Text(_destinations[navigationShell.currentIndex].label, style: AppTypography.textTheme.headlineMedium),
              actions: [
                IconButton(icon: const Icon(Icons.search), onPressed: () {}),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.account_circle),
                  onSelected: (value) {
                    if (value == 'logout') _handleLogout(context);
                  },
                  itemBuilder: (context) => <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'profile',
                      child: Text('Owner Account'),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem<String>(
                      value: 'logout',
                      child: Text('Log Out', style: TextStyle(color: AppColors.error)),
                    ),
                  ],
                ),
              ],
            )
          : null,
      body: Row(
        children: [
          if (!isMobile)
            NavigationRail(
              extended: ResponsiveLayout.isDesktop(context),
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: _onNavigate,
              backgroundColor: AppColors.surface,
              indicatorColor: AppColors.primaryContainer,
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  ResponsiveLayout.isDesktop(context) ? 'AHSAN TYRE' : 'AT',
                  style: AppTypography.textTheme.titleLarge?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              trailing: Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: IconButton(
                      icon: const Icon(Icons.logout, color: AppColors.error),
                      onPressed: () => _handleLogout(context),
                      tooltip: 'Log Out',
                    ),
                  ),
                ),
              ),
              destinations: _destinations.map((d) => NavigationRailDestination(
                icon: d.icon,
                selectedIcon: d.selectedIcon,
                label: Text(d.label),
              )).toList(),
            ),
          if (!isMobile) const VerticalDivider(thickness: 1, width: 1, color: AppColors.border),
          Expanded(
            child: Column(
              children: [
                if (!isMobile)
                  Container(
                    height: 64,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: const BoxDecoration(
                      color: AppColors.surface,
                      border: Border(bottom: BorderSide(color: AppColors.border)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_destinations[navigationShell.currentIndex].label, style: AppTypography.textTheme.headlineMedium),
                        Row(
                          children: [
                            const SizedBox(
                              width: 300,
                              height: 40,
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: 'Search...',
                                  prefixIcon: Icon(Icons.search, size: 20),
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(context.watch<AuthController>().currentUser?.email ?? 'Owner', style: AppTypography.textTheme.labelMedium),
                            const SizedBox(width: 8),
                            const CircleAvatar(
                              backgroundColor: AppColors.primaryContainer,
                              child: Icon(Icons.person, color: AppColors.primary),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                Expanded(child: navigationShell),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: isMobile
          ? NavigationBar(
              selectedIndex: navigationShell.currentIndex < 4 ? navigationShell.currentIndex : 4,
              onDestinationSelected: (idx) {
                if (idx < 4) {
                  _onNavigate(idx);
                } else {
                  // Handle "More" menu on mobile to show other destinations
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => ListView(
                      shrinkWrap: true,
                      children: _destinations.skip(4).toList().asMap().entries.map((entry) {
                        final actualIndex = entry.key + 4;
                        final dest = entry.value;
                        return ListTile(
                          leading: dest.icon,
                          title: Text(dest.label),
                          onTap: () {
                            Navigator.pop(context);
                            _onNavigate(actualIndex);
                          },
                        );
                      }).toList(),
                    ),
                  );
                }
              },
              backgroundColor: AppColors.surface,
              indicatorColor: AppColors.primaryContainer,
              destinations: _destinations.take(4).toList()..add(
                const NavigationDestination(icon: Icon(Icons.menu), label: 'More'),
              ),
            )
          : null,
    );
  }
}
