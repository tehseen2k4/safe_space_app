import 'package:cloud_firestore/cloud_firestore.dart';

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

  /// Converts time string (e.g., "09:00") to a DateTime object.
  /// Converts time string (e.g., "09:00 PM") to a DateTime object.
  DateTime _parseTime(String time, DateTime referenceDate) {
    final RegExp timeFormat =
        RegExp(r'^(\d+):(\d+)\s?(AM|PM)?$', caseSensitive: false);
    final match = timeFormat.firstMatch(time);

    if (match == null) {
      throw FormatException("Invalid time format: $time");
    }

    int hour = int.parse(match.group(1)!);
    int minute = int.parse(match.group(2)!);
    String? period = match.group(3);

    // Convert 12-hour time format to 24-hour format
    if (period != null) {
      if (period.toUpperCase() == 'PM' && hour != 12) {
        hour += 12;
      } else if (period.toUpperCase() == 'AM' && hour == 12) {
        hour = 0;
      }
    }

    return DateTime(
      referenceDate.year,
      referenceDate.month,
      referenceDate.day,
      hour,
      minute,
    );
  }

  /// Generates time slots of 30 minutes between startTime and endTime.
  List<Map<String, dynamic>> _generateSlotsForDay(String day) {
    final now = DateTime.now();
    final start = _parseTime(startTime, now);
    final end = _parseTime(endTime, now);

    List<Map<String, dynamic>> slots = [];
    DateTime current = start;

    while (current.isBefore(end)) {
      final slot = {
        'time': current.toIso8601String(),
        'booked': false, // Default all slots to available
      };
      slots.add(slot);
      current = current.add(Duration(minutes: 30));
    }

    return slots;
  }

  /// Creates and saves slots in Firestore for the given UID.
  Future<void> saveSlotsToFirestore() async {
    try {
      // Logging input parameters for debugging
      print("UID: $uid");
      print("Start Time: $startTime");
      print("End Time: $endTime");
      print("Available Days: $availableDays");

      // Firestore reference
      final docRef = FirebaseFirestore.instance.collection('slots').doc(uid);

      // Generate slots
      Map<String, List<Map<String, dynamic>>> slotsByDay = {};
      for (String day in availableDays) {
        slotsByDay[day] = _generateSlotsForDay(day);
        print("Generated slots for $day: ${slotsByDay[day]}"); // Debug log
      }

      // Save to Firestore
      await docRef.set({
        'uid': uid,
        'startTime': startTime,
        'endTime': endTime,
        'availableDays': availableDays,
        'slots': slotsByDay,
      });

      print('Slots created and saved successfully for UID: $uid');
    } catch (e) {
      print('Error saving slots to Firestore: $e');
    }
  }

  /// Fetch slots for a doctor
  Future<Map<String, dynamic>?> fetchSlotsForDoctor(String doctorId) async {
    try {
      final docRef =
          FirebaseFirestore.instance.collection('slots').doc(doctorId);
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
}
