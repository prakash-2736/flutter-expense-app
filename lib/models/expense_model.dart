
import 'package:cloud_firestore/cloud_firestore.dart';

class ExpenseModel {
  final String id;
  final String title;
  final String category;
  final double amount;
  final DateTime date;
  final String month;

  ExpenseModel({
    required this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
    required this.month,
  });

  factory ExpenseModel.fromMap(String id, Map<String, dynamic> data) {
    return ExpenseModel(
      id: id,
      title: data['title'] ?? '',
      category: data['category'] ?? '',
      amount: (data['amount'] as num).toDouble(),
      date: (data['date'] as Timestamp).toDate(),
      month: data['month'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'category': category,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'month': month,
    };
  }
}
