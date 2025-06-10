import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:expensex/screens/show_add_trip.dart';
import 'package:expensex/services/firestore_service.dart';
import 'package:expensex/models/trip_model.dart';
import 'trip_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirestoreService _firestore = FirestoreService();
  String? _selectedMonth;
  late final String _currentMonth;
  Future<String?> _fetchUserName() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    return doc.data()?['name'] as String?;
  }

  @override
  void initState() {
    super.initState();
    _currentMonth = DateFormat('MMMM yyyy').format(DateTime.now());
    _selectedMonth = _currentMonth;
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final user = FirebaseAuth.instance.currentUser;
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        
        title: FutureBuilder<String?>(
          future: _fetchUserName(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return const Text('Error fetching name');
            } else if (!snapshot.hasData || snapshot.data == null) {
              return const Text('No name found');
            } else {
              return Text(
                'Welcome, ${snapshot.data!}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                   color: Colors.black,
                ),
              );
            }
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0,),
          
          child: CircleAvatar(
            radius: 20,
            backgroundColor: Color.fromARGB(255, 52, 69, 170),
            child: Text(
              (user?.email?.substring(0, 1).toUpperCase()) ?? 'U',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onPrimary,
              ),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: Colors.deepPurple[300],
              child: const Icon(Icons.notifications, color: Colors.white),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMonthlyCard(userId),
          _buildTripListHeader(),
          _buildTripList(userId),
        ],
      ),
      floatingActionButton: _buildAddButton(context),
    );
  }

  Widget _buildMonthlyCard(String userId) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _firestore.getMonthlySummaries(userId),
        builder: (context, snapshot) {
          final monthlyTotal = _calculateMonthlyTotal(snapshot.data);

          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF7F00FF), Color(0xFFE100FF)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTotalDisplay(monthlyTotal),
                _buildMonthDropdown(snapshot.data),
              ],
            ),
          );
        },
      ),
    );
  }

  double _calculateMonthlyTotal(List<Map<String, dynamic>>? monthlyData) {
    if (monthlyData == null) return 0;
    final currentMonthData = monthlyData.firstWhere(
      (data) => data['month'] == _selectedMonth,
      orElse: () => {'total': 0},
    );
    return (currentMonthData['total'] as num?)?.toDouble() ?? 0;
  }

  Widget _buildTotalDisplay(double total) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'This Months Expense',
          style: TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 8),
        Text(
          '₹${total.toStringAsFixed(2)}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildMonthDropdown(List<Map<String, dynamic>>? monthlyData) {
    final months = monthlyData?.map((m) => m['month'] as String).toList() ?? [];
    if (!months.contains(_selectedMonth)) _selectedMonth = _currentMonth;

    return DropdownButton<String>(
      value: _selectedMonth,
      dropdownColor: const Color.fromARGB(255, 140, 84, 238),
      iconEnabledColor: Colors.white,
      underline: const SizedBox(),
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      items: months
          .map((month) => DropdownMenuItem(value: month, child: Text(month)))
          .toList(),
      onChanged: (value) => setState(() => _selectedMonth = value!),
    );
  }

  Widget _buildTripListHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.0, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Your Expenses',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            "View all",
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildTripList(String userId) {
    return Expanded(
      child: StreamBuilder<List<TripModel>>(
        stream: _firestore.getTrips(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final trips =
              snapshot.data
                  ?.where((trip) => trip.month == _selectedMonth)
                  .toList() ??
              [];

          if (trips.isEmpty) {
            return const Center(child: Text('No trips for selected month'));
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: trips.length,
            itemBuilder: (context, index) {
              final trip = trips[index];
              return _buildTripCard(trip);
            },
          );
        },
      ),
    );
  }

  Widget _buildTripCard(TripModel trip) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          trip.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          'Created on ${DateFormat.yMMMd().format(trip.createdAt)}',
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Total',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Text(
              '₹${trip.total.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => TripDetailScreen(trip: trip)),
        ),
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => showAddTripDialog(context),
      backgroundColor: const Color(0xFF7F00FF),
      shape: const CircleBorder(),
      child: const Icon(Icons.add, size: 32),
    );
  }
}

