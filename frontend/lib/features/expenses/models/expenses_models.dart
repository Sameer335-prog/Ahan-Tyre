
class Expense {
  final String id;
  final String expenseNumber;
  final String categoryId;
  final String categoryName;
  final String paymentMethodId;
  final String paymentMethodName;
  final double amount;
  final DateTime expenseDate;
  final String? description;
  final String? reference;

  Expense({
    required this.id,
    required this.expenseNumber,
    required this.categoryId,
    required this.categoryName,
    required this.paymentMethodId,
    required this.paymentMethodName,
    required this.amount,
    required this.expenseDate,
    this.description,
    this.reference,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      expenseNumber: json['expense_number'],
      categoryId: json['expense_category_id'],
      categoryName: json['expense_categories']?['name'] ?? 'Unknown',
      paymentMethodId: json['payment_method_id'],
      paymentMethodName: json['payment_methods']?['name'] ?? 'Unknown',
      amount: (json['amount'] as num).toDouble(),
      expenseDate: DateTime.parse(json['expense_date'] ?? json['created_at']),
      description: json['description'],
      reference: json['reference'],
    );
  }
}

class ExpenseCategory {
  final String id;
  final String name;

  ExpenseCategory({required this.id, required this.name});

  factory ExpenseCategory.fromJson(Map<String, dynamic> json) {
    return ExpenseCategory(
      id: json['id'],
      name: json['name'],
    );
  }
}
