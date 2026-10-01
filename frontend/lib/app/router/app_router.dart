import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/auth_controller.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/forgot_password_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/products/screens/inventory_list_screen.dart';
import '../../features/products/screens/product_details_screen.dart';
import '../../features/products/screens/product_form_screen.dart';
import '../../features/products/screens/inventory_history_screen.dart';
import '../../features/sales/screens/sales_list_screen.dart';
import '../../features/sales/screens/sale_details_screen.dart';
import '../../features/sales/screens/new_sale_screen.dart';
import '../../features/purchases/screens/purchases_list_screen.dart';
import '../../features/purchases/screens/purchase_details_screen.dart';
import '../../features/purchases/screens/new_purchase_screen.dart';
import '../../features/payments/screens/payments_list_screen.dart';
import '../../features/payments/screens/payment_details_screen.dart';
import '../../features/payments/screens/new_payment_screen.dart';
import '../../features/expenses/screens/expenses_list_screen.dart';
import '../../features/expenses/screens/expense_details_screen.dart';
import '../../features/expenses/screens/new_expense_screen.dart';
import '../../features/reports/screens/reports_landing_screen.dart';
import '../../features/reports/screens/sales_report_screen.dart';
import '../../features/reports/screens/receivables_report_screen.dart';
import '../../features/reports/screens/payables_report_screen.dart';
import '../../features/reports/screens/inventory_report_screen.dart';
import '../../features/reports/screens/low_stock_report_screen.dart';
import '../../features/placeholders/placeholder_screens.dart';
import '../../core/widgets/states.dart';
import '../shell/app_shell.dart';

class AppRouter {
  static GoRouter createRouter(AuthController authController) {
    return GoRouter(
      initialLocation: '/dashboard',
      refreshListenable: authController,
      redirect: (context, state) {
        final authStatus = authController.status;
        final isAuthRoute = state.matchedLocation == '/login' || state.matchedLocation == '/forgot-password';

        if (authStatus == AuthStatus.unknown) {
          return '/splash';
        }

        if (authStatus == AuthStatus.unauthenticated && !isAuthRoute) {
          return '/login';
        }

        if (authStatus == AuthStatus.authenticated && isAuthRoute) {
          return '/dashboard';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/splash',
          builder: (context, state) => const Scaffold(
            body: LoadingState(message: 'Initializing Ahsan Tyre...'),
          ),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/forgot-password',
          builder: (context, state) => const ForgotPasswordScreen(),
        ),
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return AppShell(navigationShell: navigationShell);
          },
          branches: [
            StatefulShellBranch(
              routes: [GoRoute(path: '/dashboard', builder: (context, state) => const DashboardScreen())],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/sales', 
                  builder: (context, state) => const SalesListScreen(),
                  routes: [
                    GoRoute(
                      path: 'new',
                      builder: (context, state) => const NewSaleScreen(),
                    ),
                    GoRoute(
                      path: ':id',
                      builder: (context, state) {
                        final id = state.pathParameters['id']!;
                        return SaleDetailsScreen(saleId: id);
                      },
                    ),
                  ],
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/purchases', 
                  builder: (context, state) => const PurchasesListScreen(),
                  routes: [
                    GoRoute(
                      path: 'new',
                      builder: (context, state) => const NewPurchaseScreen(),
                    ),
                    GoRoute(
                      path: ':id',
                      builder: (context, state) {
                        final id = state.pathParameters['id']!;
                        return PurchaseDetailsScreen(purchaseId: id);
                      },
                    ),
                  ],
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/inventory', 
                  builder: (context, state) => const InventoryListScreen(),
                  routes: [
                    GoRoute(
                      path: 'new',
                      builder: (context, state) => const ProductFormScreen(),
                    ),
                    GoRoute(
                      path: ':id',
                      builder: (context, state) {
                        final id = state.pathParameters['id']!;
                        return ProductDetailsScreen(productId: id);
                      },
                      routes: [
                        GoRoute(
                          path: 'edit',
                          builder: (context, state) {
                            final id = state.pathParameters['id']!;
                            return ProductFormScreen(productId: id);
                          },
                        ),
                        GoRoute(
                          path: 'history',
                          builder: (context, state) {
                            final id = state.pathParameters['id']!;
                            return InventoryHistoryScreen(productId: id);
                          },
                        ),
                      ],
                    ),
                  ],
                )
              ],
            ),
            StatefulShellBranch(
              routes: [GoRoute(path: '/customers', builder: (context, state) => const CustomersScreen())],
            ),
            StatefulShellBranch(
              routes: [GoRoute(path: '/suppliers', builder: (context, state) => const SuppliersScreen())],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/payments', 
                  builder: (context, state) => const PaymentsListScreen(),
                  routes: [
                    GoRoute(
                      path: 'new',
                      builder: (context, state) => const NewPaymentScreen(),
                    ),
                    GoRoute(
                      path: ':id',
                      builder: (context, state) {
                        final id = state.pathParameters['id']!;
                        return PaymentDetailsScreen(paymentId: id);
                      },
                    ),
                  ],
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/expenses', 
                  builder: (context, state) => const ExpensesListScreen(),
                  routes: [
                    GoRoute(
                      path: 'new',
                      builder: (context, state) => const NewExpenseScreen(),
                    ),
                    GoRoute(
                      path: ':id',
                      builder: (context, state) {
                        final id = state.pathParameters['id']!;
                        return ExpenseDetailsScreen(expenseId: id);
                      },
                    ),
                  ],
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/reports',
                  builder: (context, state) => const ReportsLandingScreen(),
                  routes: [
                    GoRoute(
                      path: 'sales',
                      builder: (context, state) => const SalesReportScreen(),
                    ),
                    GoRoute(
                      path: 'receivables',
                      builder: (context, state) => const ReceivablesReportScreen(),
                    ),
                    GoRoute(
                      path: 'payables',
                      builder: (context, state) => const PayablesReportScreen(),
                    ),
                    GoRoute(
                      path: 'inventory',
                      builder: (context, state) => const InventoryReportScreen(),
                    ),
                    GoRoute(
                      path: 'low-stock',
                      builder: (context, state) => const LowStockReportScreen(),
                    ),
                  ]
                )
              ],
            ),
            StatefulShellBranch(
              routes: [GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen())],
            ),
          ],
        ),
      ],
    );
  }
}
