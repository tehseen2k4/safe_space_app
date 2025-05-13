import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorSlotsWidget extends StatefulWidget {
  final String doctorId;

  const DoctorSlotsWidget({super.key, required this.doctorId});

  @override
  _DoctorSlotsWidgetState createState() => _DoctorSlotsWidgetState();
}

class _DoctorSlotsWidgetState extends State<DoctorSlotsWidget> {
  late Future<Map<String, dynamic>?> doctorSlots;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    doctorSlots = fetchDoctorSlots(widget.doctorId);
  }

  Future<Map<String, dynamic>?> fetchDoctorSlots(String doctorId) async {
    try {
      final docSnapshot =
          await _firestore.collection('slots').doc(doctorId).get();
      if (docSnapshot.exists) {
        return docSnapshot.data();
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching slots for doctor: $e');
      return null;
    }
  }

  Widget buildSlotList(Map<String, dynamic> slots) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: slots.entries.map((entry) {
        final day = entry.key;
        final slotList = entry.value as List<dynamic>;

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 10),
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  day,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 2, 93, 98),
                  ),
                ),
                const SizedBox(height: 12),
                ...slotList.map((slot) {
                  final isBooked = slot['booked'] as bool;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      isBooked ? Icons.lock : Icons.check_circle,
                      color: isBooked ? Colors.red : Colors.green,
                    ),
                    title: Text(
                      DateFormat('hh:mm a').format(DateTime.parse(slot['time'])),
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    trailing: Text(
                      isBooked ? 'Booked' : 'Free',
                      style: TextStyle(
                        fontSize: 16,
                        color: isBooked ? Colors.red : Colors.green,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  void _showDaySelectionDialog() async {
    final availableDays = await _getAvailableDays();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            'Select Appointment Day',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: availableDays.map((day) {
                return GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    _showSlotSelectionDialog(day);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      day,
                      style: const TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Future<List<String>> _getAvailableDays() async {
    final slotsData = await fetchDoctorSlots(widget.doctorId);
    if (slotsData == null || slotsData['slots'] == null) {
      return [];
    }

    final slotsByDay = slotsData['slots'] as Map<String, dynamic>;
    return slotsByDay.keys.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Doctor Availability',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 2, 93, 98),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: doctorSlots,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 60),
                  const SizedBox(height: 10),
                  Text(
                    'Error fetching doctor slots',
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.event_busy, color: Colors.grey, size: 60),
                  const SizedBox(height: 10),
                  Text(
                    'No slots available.',
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                ],
              ),
            );
          }

          final slots = snapshot.data!['slots'] ?? {};
          return Column(
            children: [
              Expanded(child: buildSlotList(slots)),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: ElevatedButton(
                    onPressed: _showDaySelectionDialog,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 60),
                      backgroundColor: const Color.fromARGB(255, 2, 93, 98),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Select Time',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }

  void _showSlotSelectionDialog(String selectedDay) async {
    final slotsData = await fetchDoctorSlots(widget.doctorId);
    if (slotsData == null || slotsData['slots'] == null) {
      return;
    }

    final slotsByDay = slotsData['slots'] as Map<String, dynamic>;
    final slots = slotsByDay[selectedDay] as List<dynamic>;
    final availableSlots = slots.where((slot) => !slot['booked']).toList();

    if (availableSlots.isEmpty) {
      _showNoSlotsDialog();
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text('Select Time Slot for $selectedDay'),
          content: SingleChildScrollView(
            child: ListBody(
              children: availableSlots.map((slot) {
                return GestureDetector(
                  onTap: () {
                    _bookSlot(selectedDay, slot);
                    Navigator.pop(context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      DateFormat('hh:mm a').format(DateTime.parse(slot['time'])),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  void _showNoSlotsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text('No Slots Available'),
          content: const Text('Sorry, there are no available slots for booking.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _bookSlot(String selectedDay, dynamic selectedSlot) async {
    final slotTime = DateTime.parse(selectedSlot['time']);

    if (selectedSlot['booked']) {
      _showSlotAlreadyBookedDialog();
      return;
    }

    final updatedSlot = {
      'time': slotTime.toIso8601String(),
      'booked': true,
    };

    try {
      final slotsData = await fetchDoctorSlots(widget.doctorId);
      if (slotsData == null || slotsData['slots'] == null) {
        return;
      }

      final slotsByDay = slotsData['slots'] as Map<String, dynamic>;
      final slotsForSelectedDay = slotsByDay[selectedDay] as List<dynamic>;

      final slotIndex = slotsForSelectedDay.indexWhere(
          (slot) => DateTime.parse(slot['time']).isAtSameMomentAs(slotTime));

      if (slotIndex == -1) {
        _showSlotNotFoundDialog();
        return;
      }

      slotsForSelectedDay[slotIndex] = updatedSlot;

      await FirebaseFirestore.instance
          .collection('slots')
          .doc(widget.doctorId)
          .update({
        'slots.$selectedDay': slotsForSelectedDay,
      });

      Navigator.pop(context, {
        'day': selectedDay,
        'time': DateFormat('hh:mm a').format(slotTime),
      });

      print('Slot booked for $selectedDay at ${DateFormat('hh:mm a').format(slotTime)}');
    } catch (e) {
      print('Error booking slot: $e');
      _showBookingErrorDialog();
    }
  }

  void _showBookingErrorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text('Booking Failed'),
          content: const Text('An error occurred while booking the slot. Please try again later.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showSlotAlreadyBookedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text('Slot Already Booked'),
          content: const Text('The selected slot is already booked. Please select another one.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showSlotNotFoundDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text('Slot Not Found'),
          content: const Text('The selected slot could not be found. Please try again.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
