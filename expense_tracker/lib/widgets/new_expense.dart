import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/models/Expense.dart';

final formatter = DateFormat.yMd();

class NewExpense extends StatefulWidget {
  const NewExpense({super.key, required this.onAddExpense});

  final void Function(Expense expense) onAddExpense;

  @override
  State<NewExpense> createState() {
    return _NewExpenseState();
  }
}

class _NewExpenseState extends State<NewExpense> {
  // var _enteredTitle = "";
  //
  // void _saveTitleInput(String inputValue){
  //   _enteredTitle = inputValue;
  // }

  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime? _selectedDate;
  Category _selectedCategory = Category.leisure;

  void _presentDatePicker() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 1, now.month, now.day);

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: firstDate,
      lastDate: now,
    );

    setState(() {
      _selectedDate = pickedDate;
    });
  }

  void _submitExpenseDate() {
    final enterAmount = double.tryParse(_amountController.text);
    final amountIsInvalid = enterAmount == null || enterAmount <= 0;
    if (_titleController.text.trim().isEmpty ||
        amountIsInvalid ||
        _selectedDate == null) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Invalid input'),
          content: Text(
            'Please make sure a valid title, amount, date and category was entered',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
              },
              child: Text('Ok'),
            ),
          ],
        ),
      );
      return;
    }

    widget.onAddExpense(
      Expense(
        title: _titleController.text,
        amount: enterAmount,
        date: _selectedDate!,
        category: _selectedCategory,
      ),
    );

    Navigator.pop(context);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keyboard = MediaQuery.of(context).viewInsets.bottom;
    return LayoutBuilder(builder: (ctx, covariant){
      return SizedBox(
        height: double.infinity,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16,48,16,keyboard+16),
            child: Column(
              children: [
                TextField(
                  controller: _titleController,
                  maxLength: 50,
                  //keyboardType: TextInputType.text,
                  decoration: InputDecoration(label: Text('Title')),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _amountController,
                        maxLength: 10,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          prefixText: '\$',
                          label: Text("Amount"),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            _selectedDate == null
                                ? "No Date Selected"
                                : formatter.format(_selectedDate!),
                          ),
                          IconButton(
                            onPressed: () {
                              _presentDatePicker();
                            },
                            icon: Icon(Icons.calendar_month),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    DropdownButton(
                      value: _selectedCategory,
                      items: Category.values
                          .map(
                            (category) => DropdownMenuItem(
                          value: category,
                          child: Text(category.name.toUpperCase()),
                        ),
                      )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }
                        setState(() {
                          _selectedCategory = value;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    Spacer(),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text("Cancel"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _submitExpenseDate();
                      },
                      child: Text("Save Expense"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });


  }
}
