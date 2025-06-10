import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../models/trip_model.dart';
import '../models/expense_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference _tripRef(String userId) =>
      _db.collection('users').doc(userId).collection('trips');

  Future<void> addExpense(
    String userId,
    String tripId,
    Map<String, dynamic> expenseData,
  ) async {
    final batch = _db.batch();
    final date = (expenseData['date'] as Timestamp).toDate();
    final amount = expenseData['amount'] as double;
    final month = DateFormat('MMMM yyyy').format(date);

    // Add expense with month
    final expenseRef = _tripRef(
      userId,
    ).doc(tripId).collection('expenses').doc();
    batch.set(expenseRef, {...expenseData, 'month': month});

    // Update TRIP TOTAL
    final tripRef = _tripRef(userId).doc(tripId);
    batch.update(tripRef, {'total': FieldValue.increment(amount)});

    // Update monthly summary (atomic operation)
    final monthlyRef = _db
        .collection('users')
        .doc(userId)
        .collection('monthlySummaries')
        .doc(month);
    batch.set(monthlyRef, {
      'total': FieldValue.increment(expenseData['amount']),
      'month': month,
    }, SetOptions(merge: true));

    await batch.commit();
  }

  Future<void> deleteExpense(
    String userId,
    String tripId,
    String expenseId,
    String month,
    double amount,
  ) async {
    final batch = _db.batch();

    // Delete expense
    batch.delete(
      _tripRef(userId).doc(tripId).collection('expenses').doc(expenseId),
    );

    // Update TRIP TOTAL
    final tripRef = _tripRef(userId).doc(tripId);
    batch.update(tripRef, {'total': FieldValue.increment(-amount)});

    // Update monthly total
    final monthlyRef = _db
        .collection('users')
        .doc(userId)
        .collection('monthlySummaries')
        .doc(month);
    batch.update(monthlyRef, {'total': FieldValue.increment(-amount)});

    await batch.commit();
  }

  Stream<List<TripModel>> getTrips(String userId) {
    return _tripRef(userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map(
                (doc) => TripModel.fromMap(
                  doc.id,
                  doc.data() as Map<String, dynamic>,
                ),
              )
              .toList(),
        );
  }

  Stream<List<ExpenseModel>> getExpenses(String userId, String tripId) {
    return _tripRef(userId)
        .doc(tripId)
        .collection('expenses')
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map(
                (doc) => ExpenseModel.fromMap(
                  doc.id,
                  // ignore: unnecessary_cast
                  doc.data() as Map<String, dynamic>, // Explicit cast added
                ),
              )
              .toList(),
        );
  }

  Stream<List<Map<String, dynamic>>> getMonthlySummaries(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('monthlySummaries')
        .orderBy('month', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => doc.data()).toList());
  }
}



