// // ignore_for_file: use_build_context_synchronously

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import '../services/firestore_service.dart';

// class AddExpenseScreen extends StatefulWidget {
//   final String tripId;
//   const AddExpenseScreen({super.key, required this.tripId});

//   @override
//   State<AddExpenseScreen> createState() => _AddExpenseScreenState();
// }

// class _AddExpenseScreenState extends State<AddExpenseScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _title = TextEditingController();
//   final TextEditingController _amount = TextEditingController();
//   String _category = 'General';
//   DateTime _selectedDate = DateTime.now();
//   bool isLoading = false;

//   Future<void> _submit() async {
//     if (!_formKey.currentState!.validate()) return;
//     setState(() => isLoading = true);

//     final userId = FirebaseAuth.instance.currentUser!.uid;
//     final data = ExpenseModel(
//       id: '',
//       title: _title.text,
//       category: _category,
//       amount: double.parse(_amount.text),
//       date: _selectedDate,
//     ).toMap();

//     await FirestoreService().addExpense(userId, widget.tripId, data);
//     Navigator.pop(context);
//   }

//   Future<void> _pickDate() async {
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: _selectedDate,
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2100),
//     );
//     if (picked != null) setState(() => _selectedDate = picked);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Add Expense')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               TextFormField(
//                 controller: _title,
//                 decoration: InputDecoration(labelText: 'Title'),
//                 validator: (val) =>
//                     val == null || val.isEmpty ? 'Required' : null,
//               ),
//               TextFormField(
//                 controller: _amount,
//                 keyboardType: TextInputType.number,
//                 decoration: InputDecoration(labelText: 'Amount'),
//                 validator: (val) =>
//                     val == null || val.isEmpty ? 'Required' : null,
//               ),
//               DropdownButtonFormField<String>(
//                 value: _category,
//                 items: ['General', 'Food', 'Travel', 'Shopping', 'Stay']
//                     .map(
//                       (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
//                     )
//                     .toList(),
//                 onChanged: (val) => setState(() => _category = val!),
//                 decoration: InputDecoration(labelText: 'Category'),
//               ),
//               TextButton.icon(
//                 onPressed: _pickDate,
//                 icon: Icon(Icons.calendar_today),
//                 label: Text(
//                   'Date: ${_selectedDate.toLocal().toString().split(' ')[0]}',
//                 ),
//               ),
//               const SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: isLoading ? null : _submit,
//                 child: isLoading
//                     ? CircularProgressIndicator()
//                     : Text('Add Expense'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:expensex/services/firestore_service.dart';

class AddExpenseScreen extends StatefulWidget {
  final String tripId;
  const AddExpenseScreen({super.key, required this.tripId});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  String _category = 'General';
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final amount = double.parse(_amountController.text);

      await FirestoreService().addExpense(userId, widget.tripId, {
        'title': _titleController.text.trim(),
        'amount': amount,
        'category': _category,
        'date': Timestamp.fromDate(_selectedDate),
        'createdAt': FieldValue.serverTimestamp(),
      });

      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = Theme.of(context).colorScheme.surface;
    final gradient = const LinearGradient(
      colors: [Color.fromARGB(255, 152, 77, 227), Color(0xFFE100FF)],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          "Add Expense",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 3,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios),
        ),
       
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Amount field (big, pill-shaped)
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 28),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromARGB(255, 241, 195, 249), // No opacity
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                    decoration: const InputDecoration(
                       filled: true, // <-- Add this
                      fillColor:  Color.fromARGB(255, 233, 240, 251),                       border: InputBorder.none,
                      prefixText: '₹ ',
                      prefixStyle: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                      hintText: '0',
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Enter amount' : null,
                  ),
                ),
                // Category
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: DropdownButtonFormField<String>(
                    value: _category,
                    isExpanded: true,
                    items: ['General', 'Food', 'Travel', 'Shopping', 'Stay']
                        .map(
                          (cat) => DropdownMenuItem(
                            value: cat,
                            child: Row(
                              children: [
                                Icon(
                                  _categoryIcon(cat),
                                  color: const Color.fromARGB(255, 139, 94, 217),
                                ),
                                const SizedBox(width: 8),
                                Text(cat),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(() => _category = value!),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                       filled: true, // <-- Add this
                      fillColor:  Color.fromARGB(255, 233, 240, 251),                       hintText: 'Category',
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                  ),
                ),
                // Description (Note)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: TextFormField(
                    controller: _titleController,
                    style: const TextStyle(fontSize: 16),
                    decoration: const InputDecoration(
                       filled: true, // <-- Add this
                      fillColor:  Color.fromARGB(255, 233, 240, 251),                       border: InputBorder.none,
                      prefixIcon: Icon(
                        Icons.edit_note,
                        color: Color.fromARGB(255, 156, 106, 242),
                      ),
                      hintText: 'Description',
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Enter description'
                        : null,
                  ),
                ),
                // Date picker ("Today" field)
                GestureDetector(
                  onTap: _pickDate,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          color: Colors.deepPurple,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            DateFormat(
                              'EEE, dd MMM yyyy',
                            ).format(_selectedDate),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        const Icon(Icons.expand_more, color: Color.fromARGB(255, 182, 145, 246)),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                // Gradient Save Button
                GestureDetector(
                  onTap: _isLoading ? null : _submit,
                  child: Container(
                    width: double.infinity,
                    height: 54,
                    decoration: BoxDecoration(
                      gradient: gradient,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(255, 239, 178, 250), // No opacity
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'SAVE',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              letterSpacing: 1.2,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _categoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.restaurant;
      case 'travel':
        return Icons.directions_car;
      case 'shopping':
        return Icons.shopping_bag;
      case 'stay':
        return Icons.hotel;
      default:
        return Icons.category;
    }
  }
}
