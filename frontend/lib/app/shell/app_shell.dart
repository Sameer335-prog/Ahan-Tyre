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

  // Re-define destinations to match the Bottom Navigation Bar in the screenshots
  static const List<NavigationDestination> _mainDestinations = [
    NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Dashboard'),
    NavigationDestination(icon: Icon(Icons.point_of_sale_outlined), selectedIcon: Icon(Icons.point_of_sale), label: 'POS'),
    NavigationDestination(icon: Icon(Icons.inventory_2_outlined), selectedIcon: Icon(Icons.inventory_2), label: 'Inventory'),
  ];
  
  static const List<NavigationDestination> _moreDestinations = [
    NavigationDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people), label: 'Customers'),
    NavigationDestination(icon: Icon(Icons.local_shipping_outlined), selectedIcon: Icon(Icons.local_shipping), label: 'Vendors'),
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
    final int navIndex = navigationShell.currentIndex;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: navigationShell,
      bottomNavigationBar: isMobile
          ? NavigationBar(
              selectedIndex: navIndex < 3 ? navIndex : 3,
              onDestinationSelected: (idx) {
                if (idx < 3) {
                  // Standard branch: Dashboard(0), POS/Sales(1), Inventory(3)
                  // Wait, our router branches are: Dashboard(0), Sales(1), Purchases(2), Inventory(3), Customers(4), Suppliers(5), Payments(6), Expenses(7), Reports(8), Settings(9)
                  // Let's map POS to Sales(1) and Inventory to Inventory(3)
                  if (idx == 0) _onNavigate(0);
                  if (idx == 1) _onNavigate(1); // Sales -> POS
                  if (idx == 2) _onNavigate(3); // Inventory
                } else {
                  // Show "More" Menu
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => _buildMoreMenu(context),
                  );
                }
              },
              backgroundColor: AppColors.surface,
              indicatorColor: AppColors.primaryContainer,
              destinations: [
                ..._mainDestinations,
                const NavigationDestination(icon: Icon(Icons.grid_view), label: 'More'),
              ],
            )
          : null, // Need desktop nav implementation here eventually if required
    );
  }
  
  Widget _buildMoreMenu(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('More Modules', style: AppTypography.textTheme.titleLarge),
                IconButton(icon: const Icon(Icons.logout, color: AppColors.error), onPressed: () => _handleLogout(context)),
              ],
            ),
          ),
          const Divider(),
          ListTile(leading: const Icon(Icons.shopping_bag), title: const Text('Purchases / Stock Inward'), onTap: () { Navigator.pop(context); _onNavigate(2); }),
          ListTile(leading: const Icon(Icons.people), title: const Text('Customers'), onTap: () { Navigator.pop(context); _onNavigate(4); }),
          ListTile(leading: const Icon(Icons.local_shipping), title: const Text('Vendors / Suppliers'), onTap: () { Navigator.pop(context); _onNavigate(5); }),
          ListTile(leading: const Icon(Icons.payments), title: const Text('Payments'), onTap: () { Navigator.pop(context); _onNavigate(6); }),
          ListTile(leading: const Icon(Icons.receipt_long), title: const Text('Expenses'), onTap: () { Navigator.pop(context); _onNavigate(7); }),
          ListTile(leading: const Icon(Icons.bar_chart), title: const Text('Reports'), onTap: () { Navigator.pop(context); _onNavigate(8); }),
          ListTile(leading: const Icon(Icons.settings), title: const Text('Settings'), onTap: () { Navigator.pop(context); _onNavigate(9); }),
        ],
      ),
    );
  }
}
