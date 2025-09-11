import 'package:expense_tracker/widgets/chart/chart.dart';
import 'package:expense_tracker/widgets/expenses_list/expenses_list.dart';
import 'package:expense_tracker/models/Expense.dart';
import 'package:expense_tracker/widgets/new_expense.dart';
import 'package:flutter/material.dart';


class Expenses extends StatefulWidget {
  const Expenses({super.key});

  @override
  State<Expenses> createState() {
    return _ExpensesState();
  }
}

class _ExpensesState extends State<Expenses> {
  final List<Expense> _registeredExpenses = [
    Expense(
      title: 'Kacchi',
      amount: 100,
      date: DateTime.now(),
      category: Category.food,
    ),
    Expense(
      title: 'Cinema',
      amount: 10,
      date: DateTime.now(),
      category: Category.work,
    ),
  ];

  void _openAddExpenseOverlay() {
    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // Allow custom container width
      context: context,
      builder: (ctx) {
        final screenWidth = MediaQuery.of(ctx).size.width;
        final screenHeight = MediaQuery.of(ctx).size.height;

        return SizedBox(
          width: screenWidth, // Full width
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(ctx).colorScheme.background,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: NewExpense(onAddExpense: _addExpense),
          ),
        );
      },
    );
  }


  void _addExpense(Expense expense) {
    setState(() {
      _registeredExpenses.add(expense);
    });
  }

  void _removeExpense(Expense expense) {
    final expenseIndex = _registeredExpenses.indexOf(expense);
    setState(() {
      _registeredExpenses.remove(expense);
    });
    ScaffoldMessenger.of(context).clearSnackBars();
    
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
        SnackBar(
            content: Text("Expense deleted"),
          duration: Duration(seconds: 3),
          action: SnackBarAction(label: 'undo', onPressed: (){
            setState(() {
              _registeredExpenses.insert(expenseIndex, expense);

            });
          }),
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;

    Widget mainContent = const Center(
      child: Text('No expenses found. Start Adding some!'),
    );

    if (_registeredExpenses.isNotEmpty) {
      mainContent = ExpensesList(
        expenses: _registeredExpenses,
        onRemoveExpense: _removeExpense,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Flutter Expense Tracker"),
        actions: [
          IconButton(
            onPressed: _openAddExpenseOverlay,
            icon: const Icon(Icons.add),
          ),

        ],
      ),
      body: width <600 ? Column(
        children: [
          Chart(expenses: _registeredExpenses),
          Expanded(child: mainContent),
        ],
      ) : Row(
        children: [
          Expanded(child: Chart(expenses: _registeredExpenses)),
          Expanded(child: mainContent),
        ],
      ),
    );
  }
}
