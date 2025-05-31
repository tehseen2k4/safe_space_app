import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:safe_space_app/models/appoinment_db_service.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class DoctorAvailabilityScreen extends StatefulWidget {
  const DoctorAvailabilityScreen({Key? key}) : super(key: key);

  @override
  State<DoctorAvailabilityScreen> createState() => _DoctorAvailabilityScreenState();
}

class _DoctorAvailabilityScreenState extends State<DoctorAvailabilityScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, Map<String, List<dynamic>>> _events = {};

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

  void _processSlots(Map<String, dynamic> slots) {
    _events.clear();
    slots.forEach((dateKey, slotList) {
      try {
        // Skip if the dateKey is not a valid date format
        if (!dateKey.contains('-')) {
          print('Skipping invalid date key: $dateKey');
          return;
        }

        final date = DateTime.parse(dateKey);
        
        // Process slots to separate booked and available
        final List<dynamic> bookedSlots = [];
        final List<dynamic> availableSlots = [];
        
        for (var slot in slotList) {
          if (slot['status'] == 'booked') {
            bookedSlots.add(slot);
          } else if (slot['status'] == 'available') {
            availableSlots.add(slot);
          }
        }
        
        // Store both types of slots
        _events[date] = {
          'booked': bookedSlots,
          'available': availableSlots,
        };
      } catch (e) {
        print('Error processing date for $dateKey: $e');
      }
    });
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
          // Calendar Section
          Container(
            padding: const EdgeInsets.all(16),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Monthly Schedule',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                const SizedBox(height: 20),
                FutureBuilder<Map<String, dynamic>?>(
                  future: _fetchSlots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasData && snapshot.data != null) {
                      _processSlots(snapshot.data!['slots']);
                    }

                    return TableCalendar(
                      firstDay: DateTime.utc(2024, 1, 1),
                      lastDay: DateTime.utc(2025, 12, 31),
                      focusedDay: _focusedDay,
                      calendarFormat: _calendarFormat,
                      selectedDayPredicate: (day) {
                        return isSameDay(_selectedDay, day);
                      },
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                      },
                      onFormatChanged: (format) {
                        setState(() {
                          _calendarFormat = format;
                        });
                      },
                      eventLoader: (day) {
                        final events = _events[day];
                        if (events == null) return [];
                        return [
                          ...events['booked'] ?? [],
                          ...events['available'] ?? [],
                        ];
                      },
                      calendarStyle: const CalendarStyle(
                        markersMaxCount: 1,
                        markerDecoration: BoxDecoration(
                          color: Colors.teal,
                          shape: BoxShape.circle,
                        ),
                        todayDecoration: BoxDecoration(
                          color: Colors.teal,
                          shape: BoxShape.circle,
                        ),
                        selectedDecoration: BoxDecoration(
                          color: Colors.tealAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                      calendarBuilders: CalendarBuilders(
                        markerBuilder: (context, date, events) {
                          if (events.isEmpty) return null;
                          
                          final dayEvents = _events[date];
                          if (dayEvents == null) return null;
                          
                          final bookedCount = dayEvents['booked']?.length ?? 0;
                          final availableCount = dayEvents['available']?.length ?? 0;
                          
                          // If there are no available slots, show red marker
                          if (availableCount == 0 && bookedCount > 0) {
                            return Positioned(
                              bottom: 1,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            );
                          }
                          
                          // If there are available slots, show green marker
                          if (availableCount > 0) {
                            return Positioned(
                              bottom: 1,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            );
                          }
                          
                          return null;
                        },
                      ),
                    );
                  },
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

              slots.forEach((dateKey, slotList) {
                final daySlots = slotList as List<dynamic>;
                totalSlots += daySlots.length;
                bookedSlots += daySlots.where((slot) => slot['status'] == 'booked').length;
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
          // Daily Schedule
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

              // Sort entries by date and convert to list
              final sortedEntries = slots.entries
                .where((entry) => entry.key.contains('-'))
                .toList()
                ..sort((a, b) {
                  final dateA = DateTime.parse(a.key);
                  final dateB = DateTime.parse(b.key);
                  return dateA.compareTo(dateB);
                });

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Daily Schedule',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ...sortedEntries.map((entry) {
                    final dateKey = entry.key;
                    final date = DateTime.parse(dateKey);
                    final slotList = entry.value as List<dynamic>;
                    
                    // Sort slots by time
                    final sortedSlots = List<dynamic>.from(slotList)
                      ..sort((a, b) {
                        final timeA = a['time'] as String;
                        final timeB = b['time'] as String;
                        return timeA.compareTo(timeB);
                      });
                    
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
                          DateFormat('EEEE, MMMM d').format(date),
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
                              children: sortedSlots.map((slot) {
                                // Parse the time string properly
                                final timeStr = slot['time'] as String;
                                final timeParts = timeStr.split(':');
                                final hour = int.parse(timeParts[0]);
                                final minute = int.parse(timeParts[1]);
                                final time = DateTime(2000, 1, 1, hour, minute);
                                
                                final isBooked = slot['status'] == 'booked';
                                
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
                                            slot['timeDisplay'] ?? DateFormat('hh:mm a').format(time),
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