import 'package:flutter/material.dart';
import '../../models/Expense.dart';

class ExpenseItem extends StatelessWidget{
  const ExpenseItem(this.expense , {super.key});

  final Expense expense;

  @override
  Widget build(BuildContext context) {
    return Card(
    child: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 16
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(expense.title, style: Theme.of(context).textTheme.titleLarge,),
          SizedBox(height: 4),
          Row(
            children: [
              Text('\$${expense.amount.toStringAsFixed(2)}'), //3.3333 => 3.33
              const Spacer(),
              Row(
                children: [
                  Icon(categoryIcons[expense.category]),
                  const SizedBox(width: 10,),
                  Text(expense.formattedDate),
                ],
              )
            ],
          )
        ],
      ),
    ),
    );
  }
}