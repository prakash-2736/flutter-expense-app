import 'package:expensex/utils/user.data.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
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

  @override
  void initState() {
    super.initState();
    _currentMonth = DateFormat('MMMM yyyy').format(DateTime.now());
    _selectedMonth = _currentMonth;
  }

  // Future<void> _loadUserName() async {
  //   final uid = FirebaseAuth.instance.currentUser?.uid;
  //   if (uid != null) {
  //     final doc = await FirebaseFirestore.instance
  //         .collection('users')
  //         .doc(uid)
  //         .get();
  //     setState(() {
  //       _userName = doc.data()?['name'];
  //       _isLoading = false;
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 25),
            UserData.name == null
                ? const SizedBox()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 15),
                      Text(
                        'Welcome 👋',
                        style: GoogleFonts.nunitoSans(
                          fontSize: 22,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${UserData.name}!',
                        style: GoogleFonts.nunitoSans(
                          fontSize: 28,
                          color: Colors.grey.shade900,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

            SizedBox(height: 20),
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
              colors: [
                Color.fromARGB(255, 241, 238, 255),
                Color.fromARGB(255, 189, 181, 255),
              ],
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
          'This Months Expense',
          style: GoogleFonts.nunitoSans(
            fontSize: 14,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '₹${total.toStringAsFixed(2)}',
          style: GoogleFonts.nunitoSans(
            fontSize: 30,
            color: Colors.grey.shade900,
            fontWeight: FontWeight.w700,
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
      style: const TextStyle(
        color: Color.fromARGB(255, 27, 27, 27),
        fontWeight: FontWeight.bold,
      ),
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
              fontWeight: FontWeight.w600,
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

          return ListView.separated(
            itemCount: trips.length,
            itemBuilder: (context, index) {
              final trip = trips[index];
              return _buildTripCard(trip, userId);
            },
            separatorBuilder: (BuildContext context, int index) =>
                const SizedBox(height: 10),
          );
        },
      ),
    );
  }

  // Widget _buildTripCard(TripModel trip) {
  //   return GestureDetector(
  //     onTap: () => Navigator.push(
  //       context,
  //       MaterialPageRoute(builder: (_) => TripDetailScreen(trip: trip)),
  //     ),
  //     child: Container(
  //       margin: EdgeInsets.only(bottom: 10),
  //       padding: EdgeInsets.all(20),
  //       decoration: BoxDecoration(
  //         color: Colors.white,
  //         borderRadius: BorderRadius.circular(20),
  //         boxShadow: [
  //           BoxShadow(blurRadius: 20, color: const Color.fromARGB(10, 0, 0, 0)),
  //         ],
  //       ),
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //         children: [
  //           Column(
  //             spacing: 3,
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Text(
  //                 trip.title,
  //                 style: GoogleFonts.nunitoSans(
  //                   fontSize: 24,
  //                   color: Colors.grey.shade900,
  //                   fontWeight: FontWeight.w600,
  //                 ),
  //               ),

  //               Text(
  //                 'Created on ${DateFormat.yMMMd().format(trip.createdAt)}',
  //                 style: GoogleFonts.nunitoSans(
  //                   fontSize: 16,
  //                   color: Colors.grey.shade700,
  //                   fontWeight: FontWeight.w500,
  //                 ),
  //               ),
  //             ],
  //           ),

  //           Column(
  //             crossAxisAlignment: CrossAxisAlignment.end,
  //             spacing: 2,
  //             children: [
  //               Text(
  //                 'Total',
  //                 style: GoogleFonts.nunitoSans(
  //                   fontSize: 14,
  //                   color: Colors.grey.shade700,
  //                   fontWeight: FontWeight.w500,
  //                 ),
  //               ),
  //               Text(
  //                 '₹${trip.total.toStringAsFixed(2)}',
  //                 style: GoogleFonts.nunitoSans(
  //                   fontSize: 24,
  //                   color: Colors.grey.shade900,
  //                   fontWeight: FontWeight.w700,
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildTripCard(TripModel trip, String userId) {
    return Slidable(
      key: Key(trip.id),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),

        children: [
          SlidableAction(
            onPressed: (context) async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete Trip?'),
                  content: const Text('This action cannot be undone'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                try {
                  await _firestore.deleteTrip(
                    userId,
                    trip.id,
                    trip.month,
                    trip.total,
                  );
                  if (mounted) {
                    setState(() {
                      _selectedMonth = _selectedMonth; // Trigger refresh
                    });
                  }
                } catch (e) {
                  if (!mounted) return;
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error deleting trip: $e')),
                  );
                }
              }
            },
            backgroundColor: Colors.red,
            icon: Icons.delete,
            borderRadius: BorderRadius.circular(20),

            label: 'Delete',
          ),
        ],
      ),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => TripDetailScreen(trip: trip)),
        ),
        child: Container(
          // margin: EdgeInsets.only(bottom: 10),
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                blurRadius: 20,
                color: const Color.fromARGB(10, 0, 0, 0),
              ),
            ],
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
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  Text(
                    'Created on ${DateFormat.yMMMd().format(trip.createdAt)}',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 16,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
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
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '₹${trip.total.toStringAsFixed(2)}',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 24,
                      color: Colors.grey.shade900,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => showAddTripDialog(context),
      backgroundColor: Color.fromARGB(255, 126, 114, 253),
      shape: const CircleBorder(),
      child: const Icon(Icons.add, size: 32),
    );
  }
}
