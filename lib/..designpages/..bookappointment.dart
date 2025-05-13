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
      final docSnapshot = await _firestore.collection('slots').doc(doctorId).get();
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
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 1200;
    final isTablet = screenSize.width > 600 && screenSize.width <= 1200;

    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 3 : (isTablet ? 2 : 1),
        childAspectRatio: isDesktop ? 2.5 : 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: slots.length,
      itemBuilder: (context, index) {
        final day = slots.keys.elementAt(index);
        final slotList = slots[day] as List<dynamic>;

        return Card(
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
                Expanded(
                  child: ListView.builder(
                    itemCount: slotList.length,
                    itemBuilder: (context, slotIndex) {
                      final slot = slotList[slotIndex];
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
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
          title: Text(
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
                      style: TextStyle(fontSize: 16, color: Colors.black87),
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
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 1200;
    final isTablet = screenSize.width > 600 && screenSize.width <= 1200;

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
      body: Container(
        constraints: BoxConstraints(
          maxWidth: isDesktop ? 1200 : (isTablet ? 800 : screenSize.width),
        ),
        margin: EdgeInsets.symmetric(
          horizontal: isDesktop ? 40 : (isTablet ? 20 : 0),
        ),
        child: FutureBuilder<Map<String, dynamic>?>(
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
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
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
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
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
                        minimumSize: Size(double.infinity, 60),
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
                      DateFormat('hh:mm a')
                          .format(DateTime.parse(slot['time'])),
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
          title: Text('No Slots Available'),
          content: Text('Sorry, there are no available slots for booking.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _bookSlot(String selectedDay, dynamic selectedSlot) async {
    final slotTime = DateTime.parse(selectedSlot['time']);

    // Check if the slot is already booked
    if (selectedSlot['booked']) {
      _showSlotAlreadyBookedDialog();
      return;
    }

    // Update the slot to be booked
    final updatedSlot = {
      'time': slotTime.toIso8601String(),
      'booked': true,
    };

    try {
      // Fetch the existing slots for the selected day
      final slotsData = await fetchDoctorSlots(widget.doctorId);
      if (slotsData == null || slotsData['slots'] == null) {
        return;
      }

      final slotsByDay = slotsData['slots'] as Map<String, dynamic>;
      final slotsForSelectedDay = slotsByDay[selectedDay] as List<dynamic>;

      // Find the index of the slot to be updated
      final slotIndex = slotsForSelectedDay.indexWhere(
          (slot) => DateTime.parse(slot['time']).isAtSameMomentAs(slotTime));

      if (slotIndex == -1) {
        _showSlotNotFoundDialog();
        return;
      }

      // Update the booked slot status to true
      slotsForSelectedDay[slotIndex] = updatedSlot;

      // Update the Firestore database
      await FirebaseFirestore.instance
          .collection('slots')
          .doc(widget.doctorId)
          .update({
        'slots.$selectedDay': slotsForSelectedDay,
      });

      // Navigate back with the selected time slot
      Navigator.pop(context, {
        'day': selectedDay,
        'time': DateFormat('hh:mm a').format(slotTime),
      });

      print(
          'Slot booked for $selectedDay at ${DateFormat('hh:mm a').format(slotTime)}');
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
          title: Text('Booking Failed'),
          content: Text(
              'An error occurred while booking the slot. Please try again later.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
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
          title: Text('Slot Already Booked'),
          content: Text(
              'The selected slot is already booked. Please select another one.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
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
          title: Text('Slot Not Found'),
          content:
              Text('The selected slot could not be found. Please try again.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
