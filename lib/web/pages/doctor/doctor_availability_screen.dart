import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:safe_space_app/models/appoinment_db_service.dart';
import 'package:intl/intl.dart';

class DoctorAvailabilityScreen extends StatefulWidget {
  const DoctorAvailabilityScreen({Key? key}) : super(key: key);

  @override
  State<DoctorAvailabilityScreen> createState() => _DoctorAvailabilityScreenState();
}

class _DoctorAvailabilityScreenState extends State<DoctorAvailabilityScreen> {
  final User? user = FirebaseAuth.instance.currentUser;

  Future<Map<String, dynamic>?> _fetchSlots() async {
    try {
      if (user == null) return null;

      final docSnapshot = await FirebaseFirestore.instance
          .collection('slots')
          .doc(user!.uid)
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.teal[100],
                  child: const Icon(Icons.access_time, size: 40, color: Colors.teal),
                ),
                const SizedBox(width: 24),
                const Expanded(
                  child: Text(
                    'Check Availability',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Stats Section
          FutureBuilder<Map<String, dynamic>?>(
            future: _fetchSlots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Row(
                  children: [
                    Expanded(child: _buildStatCard('Total Slots', '...', Icons.access_time, Colors.blue)),
                    const SizedBox(width: 24),
                    Expanded(child: _buildStatCard('Booked', '...', Icons.event_busy, Colors.red)),
                    const SizedBox(width: 24),
                    Expanded(child: _buildStatCard('Available', '...', Icons.event_available, Colors.green)),
                  ],
                );
              }

              if (!snapshot.hasData || snapshot.data == null) {
                return Row(
                  children: [
                    Expanded(child: _buildStatCard('Total Slots', '0', Icons.access_time, Colors.blue)),
                    const SizedBox(width: 24),
                    Expanded(child: _buildStatCard('Booked', '0', Icons.event_busy, Colors.red)),
                    const SizedBox(width: 24),
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
                  const SizedBox(width: 24),
                  Expanded(
                    child: _buildStatCard(
                      'Booked',
                      bookedSlots.toString(),
                      Icons.event_busy,
                      Colors.red,
                    ),
                  ),
                  const SizedBox(width: 24),
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
          ),
          const SizedBox(height: 24),
          // Weekly Schedule
          FutureBuilder<Map<String, dynamic>?>(
            future: _fetchSlots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data == null) {
                return _buildEmptyState();
              }

              final slots = snapshot.data!['slots'] as Map<String, dynamic>;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Weekly Schedule',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ...slots.entries.map((entry) {
                    final day = entry.key;
                    final slotList = entry.value as List<dynamic>;
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ExpansionTile(
                        title: Text(
                          day,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        leading: const Icon(Icons.calendar_today, color: Colors.teal),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: slotList.map((slot) {
                                final time = DateTime.parse(slot['time']);
                                final isBooked = slot['booked'] ?? false;
                                
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.all(12),
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
                                          const SizedBox(width: 10),
                                          Text(
                                            DateFormat('hh:mm a').format(time),
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 10),
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
          const SizedBox(height: 20),
          Text(
            'No Availability Slots',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'No slots have been set for your schedule',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}