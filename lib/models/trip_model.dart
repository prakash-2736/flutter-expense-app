
import 'package:cloud_firestore/cloud_firestore.dart';

class TripModel {
  final String id;
  final String title;
  final String description;
  final DateTime createdAt;
  final String month;
  final double total;

  TripModel({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.month,
    required this.total,
  });

  factory TripModel.fromMap(String id, Map<String, dynamic> map) {
    return TripModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      month: map['month'] is String ? map['month'] : map['month'].toString(),
      total: (map['total'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'createdAt': createdAt,
      'month': month,
      'total': total,
    };
  }
}
