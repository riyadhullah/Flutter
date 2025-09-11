import 'package:expense_tracker/models/Expense.dart';
import 'package:expense_tracker/widgets/expenses_list/expenses_item.dart';
import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class ExpensesList extends StatelessWidget {
  const ExpensesList({
    super.key,
    required this.expenses,
    required this.onRemoveExpense,
  });

  final List<Expense> expenses;
  final void Function(Expense expense) onRemoveExpense;

  Future<void> _handleRefresh() async {}

  @override
  Widget build(BuildContext context) {
    return LiquidPullToRefresh(
      onRefresh: _handleRefresh,
      child: ListView.builder(
        itemCount: expenses.length,
        itemBuilder: (ctx, index) => Dismissible(
          onDismissed: (direction) {
            onRemoveExpense(expenses[index]);
          },
          background: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Theme.of(context).colorScheme.error.withAlpha(140),
            ),
            margin: Theme.of(context).cardTheme.margin,
          ),
          key: ValueKey(expenses[index]),
          child: ExpenseItem(expenses[index]),
        ),
      ),
    );
  }
}
