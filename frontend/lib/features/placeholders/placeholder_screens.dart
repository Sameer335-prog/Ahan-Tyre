import 'package:flutter/material.dart';
import '../../core/widgets/states.dart';

class PlaceholderScreen extends StatelessWidget {
  final String title;
  final String description;

  const PlaceholderScreen({
    super.key,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: EmptyState(
        title: title,
        message: description,
        icon: Icons.construction,
      ),
    );
  }
}









class CustomersScreen extends StatelessWidget {
  const CustomersScreen({super.key});
  @override
  Widget build(BuildContext context) => const PlaceholderScreen(
    title: 'Customers',
    description: 'Customer management will appear here.',
  );
}

class SuppliersScreen extends StatelessWidget {
  const SuppliersScreen({super.key});
  @override
  Widget build(BuildContext context) => const PlaceholderScreen(
    title: 'Suppliers',
    description: 'Supplier management will appear here.',
  );
}





class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) => const PlaceholderScreen(
    title: 'Settings',
    description: 'Application settings will appear here.',
  );
}
