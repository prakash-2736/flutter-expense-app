// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:intl/intl.dart';
// import 'package:expensex/models/expense_model.dart';
// import 'package:expensex/models/trip_model.dart';
// import 'package:expensex/services/firestore_service.dart';
// import 'package:expensex/screens/add_expense_screen.dart';

// class TripDetailScreen extends StatelessWidget {
//   final TripModel trip;
//   const TripDetailScreen({super.key, required this.trip});

//   @override
//   Widget build(BuildContext context) {
//     final userId = FirebaseAuth.instance.currentUser!.uid;
//     final firestore = FirestoreService();

//     return Scaffold(
//       appBar: AppBar(title: Text(trip.title)),
//       body: StreamBuilder<List<ExpenseModel>>(
//         stream: firestore.getExpenses(userId, trip.id),
//         builder: (context, snapshot) {
//           if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           }

//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           final expenses = snapshot.data ?? [];

//           return ListView.builder(
//             itemCount: expenses.length,
//             itemBuilder: (context, index) {
//               final expense = expenses[index];
//               return ListTile(
//                 title: Text(expense.title),
//                 subtitle: Text(
//                   '${expense.category} • ${DateFormat('MMM dd, yyyy').format(expense.date)}',
//                 ),
//                 trailing: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text('₹${expense.amount.toStringAsFixed(2)}'),
//                     IconButton(
//                       icon: const Icon(Icons.delete, color: Colors.red),
//                       onPressed: () => firestore.deleteExpense(
//                         userId,
//                         trip.id,
//                         expense.id,
//                         expense.month,
//                         expense.amount,
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           );
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         child: const Icon(Icons.add),
//         onPressed: () => Navigator.push(
//           context,
//           MaterialPageRoute(builder: (_) => AddExpenseScreen(tripId: trip.id)),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:expensex/models/expense_model.dart';
import 'package:expensex/models/trip_model.dart';
import 'package:expensex/services/firestore_service.dart';
import 'package:expensex/screens/add_expense_screen.dart';

class TripDetailScreen extends StatelessWidget {
  final TripModel trip;
  const TripDetailScreen({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final firestore = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          trip.title,
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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CircleAvatar(
              backgroundColor: Colors.white24,
              child: Icon(Icons.wallet, color: Colors.white, size: 20),
            ),
          ),
        ],
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
      ),
      body: StreamBuilder<List<ExpenseModel>>(
        stream: firestore.getExpenses(userId, trip.id),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final expenses = snapshot.data ?? [];
          if (expenses.isEmpty) {
            return const Center(
              child: Text(
                'No expenses yet for this trip.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: expenses.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final expense = expenses[index];
              return Card(
                color: Colors.white,
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 18,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primary.withAlpha(30),
                    child: Icon(
                      _categoryIcon(expense.category),
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  title: Text(
                    expense.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    '${expense.category} • ${DateFormat('MMM dd, yyyy').format(expense.date)}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  trailing: SizedBox(
                    width: 120, // Adjust width as needed
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '₹${expense.amount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.indigo,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.redAccent,
                            size: 20,
                          ),
                          tooltip: 'Delete',
                          onPressed: () => firestore.deleteExpense(
                            userId,
                            trip.id,
                            expense.id,
                            expense.month,
                            expense.amount,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AddExpenseScreen(tripId: trip.id)),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 6,
        child: const Icon(Icons.add, size: 28),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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
        return Icons.receipt_long;
    }
  }
}
