import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
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
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<String?>(
              future: _fetchUserName(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return const Text('Error fetching name');
                } else if (!snapshot.hasData || snapshot.data == null) {
                  return const Text('No name found');
                } else {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 3,
                    children: [
                      Text(
                        'Welcome 👋',
                        style: GoogleFonts.nunitoSans(
                          fontSize: 22,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500
                        )
                      ),
                      Text(
                        '${snapshot.data!}!',
                        style:  GoogleFonts.nunitoSans(
                          fontSize: 28,
                          color: Colors.grey.shade900,
                          fontWeight: FontWeight.w600
                        )
                      ),
                    ],
                  );
                }
              },
            ),
            SizedBox(height: 20,),
            _buildMonthlyCard(userId),
            _buildTripListHeader(),
            _buildTripList(userId),
          ],
        ),
      ),
      floatingActionButton: _buildAddButton(context),
    );
  }

  Widget _buildMonthlyCard(String userId) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _firestore.getMonthlySummaries(userId),
      builder: (context, snapshot) {
        final monthlyTotal = _calculateMonthlyTotal(snapshot.data);
    
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color.fromARGB(255, 241, 238, 255), Color.fromARGB(255, 189, 181, 255)],
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
        Text(
          'This Months Expense', style: GoogleFonts.nunitoSans(
            fontSize: 14,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '₹${total.toStringAsFixed(2)}',
          style: GoogleFonts.nunitoSans(
            fontSize: 30,
            color: Colors.grey.shade900,
            fontWeight: FontWeight.w700
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
      dropdownColor: const Color.fromARGB(255, 255, 255, 255),
      iconEnabledColor: const Color.fromARGB(255, 25, 25, 25),
      underline: const SizedBox(),
      style: const TextStyle(color: Color.fromARGB(255, 27, 27, 27), fontWeight: FontWeight.bold),
      items: months
          .map((month) => DropdownMenuItem(value: month, child: Text(month)))
          .toList(),
      onChanged: (value) => setState(() => _selectedMonth = value!),
    );
  }

  Widget _buildTripListHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Your Expenses',
            style: GoogleFonts.nunitoSans(
              fontSize: 18,
              color: Colors.grey.shade800,
              fontWeight: FontWeight.w600
            ),
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
    return GestureDetector(
      onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => TripDetailScreen(trip: trip)),
              ),
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [ 
            BoxShadow(
              blurRadius: 20,
              color: const Color.fromARGB(10, 0, 0, 0),
            )
          ]
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              spacing: 3,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trip.title,
                  style: GoogleFonts.nunitoSans(
                    fontSize: 24,
                    color: Colors.grey.shade900,
                    fontWeight: FontWeight.w600
                  ),
                ),
      
                Text(
                  'Created on ${DateFormat.yMMMd().format(trip.createdAt)}',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 16,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500
                  ),
                ),
              ],
            ),
      
            Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                spacing: 2,
                children: [
                  Text(
                    'Total',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500
                    ),
                  ),
                  Text(
                    '₹${trip.total.toStringAsFixed(2)}',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 24,
                      color: Colors.grey.shade900,
                      fontWeight: FontWeight.w700
                    ),
                  ),
                ],
              ),
          ],
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

