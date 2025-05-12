import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class DoctorAvailability extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Doctor Availability',
      theme: ThemeData(
        primaryColor: Colors.teal,
        scaffoldBackgroundColor: Colors.grey[50],
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
      home: DoctorAvailabilityScreen(),
    );
  }
}

class DoctorAvailabilityScreen extends StatefulWidget {
  @override
  State<DoctorAvailabilityScreen> createState() => _DoctorAvailabilityScreenState();
}

class _DoctorAvailabilityScreenState extends State<DoctorAvailabilityScreen> {
  Future<Map<String, dynamic>?> fetchSlots(String uid) async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('slots')
          .doc(uid)
          .get();

      if (docSnapshot.exists) {
        return docSnapshot.data();
      }
      return null;
    } catch (e) {
      print('Error fetching slots: $e');
      return null;
    }
  }

  Future<void> _refreshData() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        title: Text(
          'Availability Schedule',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderSection(),
              SizedBox(height: 20),
              _buildStatsSection(),
              SizedBox(height: 30),
              _buildScheduleSection(user.uid),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.teal,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_today, color: Colors.white, size: 30),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Manage Your Schedule',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'View and manage your availability slots',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return FutureBuilder<Map<String, dynamic>?>(
      future: fetchSlots(FirebaseAuth.instance.currentUser!.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Row(
            children: [
              Expanded(child: _buildStatCard('Total Slots', '...', Icons.access_time, Colors.blue)),
              SizedBox(width: 15),
              Expanded(child: _buildStatCard('Booked', '...', Icons.event_busy, Colors.red)),
              SizedBox(width: 15),
              Expanded(child: _buildStatCard('Available', '...', Icons.event_available, Colors.green)),
            ],
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return Row(
            children: [
              Expanded(child: _buildStatCard('Total Slots', '0', Icons.access_time, Colors.blue)),
              SizedBox(width: 15),
              Expanded(child: _buildStatCard('Booked', '0', Icons.event_busy, Colors.red)),
              SizedBox(width: 15),
              Expanded(child: _buildStatCard('Available', '0', Icons.event_available, Colors.green)),
            ],
          );
        }

        final slots = snapshot.data!['slots'] as Map<String, dynamic>;
        int totalSlots = 0;
        int bookedSlots = 0;

        slots.forEach((day, slotList) {
          final daySlots = slotList as List<dynamic>;
          totalSlots += daySlots.length;
          bookedSlots += daySlots.where((slot) => slot['booked'] == true).length;
        });

        int availableSlots = totalSlots - bookedSlots;

        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Slots',
                totalSlots.toString(),
                Icons.access_time,
                Colors.blue,
              ),
            ),
            SizedBox(width: 15),
            Expanded(
              child: _buildStatCard(
                'Booked',
                bookedSlots.toString(),
                Icons.event_busy,
                Colors.red,
              ),
            ),
            SizedBox(width: 15),
            Expanded(
              child: _buildStatCard(
                'Available',
                availableSlots.toString(),
                Icons.event_available,
                Colors.green,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleSection(String uid) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: fetchSlots(uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        
        if (!snapshot.hasData || snapshot.data == null) {
          return _buildEmptyState();
        }

        final slots = snapshot.data!['slots'] as Map<String, dynamic>;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weekly Schedule',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            SizedBox(height: 20),
            ...slots.entries.map((entry) {
              final day = entry.key;
              final slotList = entry.value as List<dynamic>;
              
              return Container(
                margin: EdgeInsets.only(bottom: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: ExpansionTile(
                  title: Text(
                    day,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  leading: Icon(Icons.calendar_today, color: Colors.teal),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: slotList.map((slot) {
                          final time = DateTime.parse(slot['time']);
                          final isBooked = slot['booked'] ?? false;
                          
                          return Container(
                            margin: EdgeInsets.only(bottom: 10),
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isBooked ? Colors.red[50] : Colors.green[50],
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isBooked ? Colors.red[100]! : Colors.green[100]!,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      isBooked ? Icons.event_busy : Icons.event_available,
                                      color: isBooked ? Colors.red : Colors.green,
                                      size: 20,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      DateFormat('hh:mm a').format(time),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: isBooked ? Colors.red[100] : Colors.green[100],
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    isBooked ? 'Booked' : 'Available',
                                    style: TextStyle(
                                      color: isBooked ? Colors.red : Colors.green,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today,
            size: 80,
            color: Colors.grey[300],
          ),
          SizedBox(height: 20),
          Text(
            'No Availability Slots',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Add your availability slots to start accepting appointments',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement add new slot functionality
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Add New Slot',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
