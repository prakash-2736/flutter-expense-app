import 'package:flutter/material.dart';
import '../models/trip_model.dart';

class TripTile extends StatelessWidget {
  final TripModel trip;
  final VoidCallback onTap;

  const TripTile({super.key, required this.trip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: ListTile(
        title: Text(
          trip.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          "Created: ${trip.createdAt.toLocal().toString().split(' ')[0]}",
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
