import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class DatabaseService {
  final String uid;
  final String startTime;
  final String endTime;
  final List<String> availableDays;

  DatabaseService({
    required this.uid,
    required this.startTime,
    required this.endTime,
    required this.availableDays,
  });

  /// Converts time string (e.g., "09:00 AM") to a DateTime object
  DateTime _parseTime(String time, DateTime referenceDate) {
    try {
      final timeFormat = DateFormat('hh:mm a');
      return timeFormat.parse(time);
    } catch (e) {
      print('Error parsing time: $e');
      return referenceDate;
    }
  }

  /// Generates time slots of 30 minutes between startTime and endTime
  List<Map<String, dynamic>> _generateSlotsForDay(String day) {
    final now = DateTime.now();
    final start = _parseTime(startTime, now);
    final end = _parseTime(endTime, now);

    List<Map<String, dynamic>> slots = [];
    DateTime current = start;

    while (current.isBefore(end)) {
      final slot = {
        'time': current.toIso8601String(),
        'booked': false,
        'day': day,
      };
      slots.add(slot);
      current = current.add(Duration(minutes: 30));
    }

    return slots;
  }

  /// Creates and saves slots in Firestore for the given UID
  Future<void> saveSlotsToFirestore() async {
    try {
      // Firestore reference
      final docRef = FirebaseFirestore.instance.collection('slots').doc(uid);

      // Generate slots
      Map<String, List<Map<String, dynamic>>> slotsByDay = {};
      for (String day in availableDays) {
        slotsByDay[day] = _generateSlotsForDay(day);
      }

      // Save to Firestore
      await docRef.set({
        'uid': uid,
        'startTime': startTime,
        'endTime': endTime,
        'availableDays': availableDays,
        'slots': slotsByDay,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      print('Slots created and saved successfully for UID: $uid');
    } catch (e) {
      print('Error saving slots to Firestore: $e');
      throw e;
    }
  }

  /// Fetch slots for a doctor
  Future<Map<String, dynamic>?> fetchSlotsForDoctor(String doctorId) async {
    try {
      final docRef = FirebaseFirestore.instance.collection('slots').doc(doctorId);
      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        return docSnapshot.data();
      } else {
        print("No slots found for doctor with UID: $doctorId");
        return null;
      }
    } catch (e) {
      print('Error fetching slots: $e');
      return null;
    }
  }

  /// Update a specific slot's booked status
  Future<void> updateSlotStatus(String doctorId, String day, String time, bool isBooked) async {
    try {
      final docRef = FirebaseFirestore.instance.collection('slots').doc(doctorId);
      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data()!;
        final slots = data['slots'] as Map<String, dynamic>;
        
        if (slots.containsKey(day)) {
          final daySlots = slots[day] as List<dynamic>;
          final updatedSlots = daySlots.map((slot) {
            if (slot['time'] == time) {
              return {...slot, 'booked': isBooked};
            }
            return slot;
          }).toList();

          await docRef.update({
            'slots.$day': updatedSlots,
          });
        }
      }
    } catch (e) {
      print('Error updating slot status: $e');
      throw e;
    }
  }
}
