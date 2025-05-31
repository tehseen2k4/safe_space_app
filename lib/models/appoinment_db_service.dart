import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class DatabaseService {
  final String uid;
  final String startTime;
  final String endTime;
  final List<String> availableDays;
  final int maxDaysInAdvance; // Maximum number of days in advance for booking

  DatabaseService({
    required this.uid,
    required this.startTime,
    required this.endTime,
    required this.availableDays,
    this.maxDaysInAdvance = 30, // Default to 30 days in advance
  });

  /// Converts time string (e.g., "09:00 AM") to a DateTime object
  DateTime _parseTime(String time, DateTime referenceDate) {
    try {
      print('Parsing time: $time for date: ${referenceDate.toString()}');
      
      // Handle 24-hour format if needed
      String timeToParse = time;
      if (!time.contains('AM') && !time.contains('PM')) {
        final parts = time.split(':');
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        timeToParse = '${hour > 12 ? hour - 12 : hour}:${minute.toString().padLeft(2, '0')} ${hour >= 12 ? 'PM' : 'AM'}';
      }
      
      final timeFormat = DateFormat('hh:mm a');
      final parsedTime = timeFormat.parse(timeToParse);
      final result = DateTime(
        referenceDate.year,
        referenceDate.month,
        referenceDate.day,
        parsedTime.hour,
        parsedTime.minute,
      );
      print('Parsed time result: ${result.toString()}');
      return result;
    } catch (e) {
      print('Error parsing time: $e');
      return referenceDate;
    }
  }

  /// Generates time slots for a specific date
  List<Map<String, dynamic>> _generateSlotsForDate(DateTime date) {
    print('\nGenerating slots for date: ${date.toString()}');
    print('Start time: $startTime, End time: $endTime');
    
    final start = _parseTime(startTime, date);
    DateTime end = _parseTime(endTime, date);
    
    // If end time is before start time, it means the slot crosses midnight
    // So we need to add 24 hours to the end time
    if (end.isBefore(start)) {
      end = end.add(const Duration(days: 1));
    }
    
    print('Parsed start: ${start.toString()}');
    print('Parsed end: ${end.toString()}');

    List<Map<String, dynamic>> slots = [];
    DateTime current = start;

    while (current.isBefore(end)) {
      final slot = {
        'date': DateFormat('yyyy-MM-dd').format(date),
        'time': DateFormat('HH:mm').format(current),
        'timeDisplay': DateFormat('hh:mm a').format(current),
        'booked': false,
        'bookedBy': null,
        'bookedAt': null,
        'status': 'available',
        'dayOfWeek': DateFormat('EEEE').format(date),
      };
      slots.add(slot);
      current = current.add(const Duration(minutes: 30));
    }

    print('Generated ${slots.length} slots for ${DateFormat('yyyy-MM-dd').format(date)}');
    if (slots.isNotEmpty) {
      print('First slot: ${slots.first}');
      print('Last slot: ${slots.last}');
    }
    return slots;
  }

  /// Validates if a date is valid for booking
  bool _isValidBookingDate(DateTime date) {
    final now = DateTime.now();
    final maxDate = now.add(Duration(days: maxDaysInAdvance));
    
    print('\nValidating booking date: ${date.toString()}');
    print('Current date: ${now.toString()}');
    print('Max date: ${maxDate.toString()}');
    print('Available days: $availableDays');
    
    // Check if date is in the future and within max days in advance
    if (date.isBefore(now)) {
      print('Date is in the past');
      return false;
    }
    if (date.isAfter(maxDate)) {
      print('Date is beyond max days in advance');
      return false;
    }

    // Check if the day of week is in availableDays
    final dayOfWeek = DateFormat('EEEE').format(date);
    print('Day of week: $dayOfWeek');
    final isValid = availableDays.contains(dayOfWeek);
    print('Is valid day: $isValid');
    
    return isValid;
  }

  /// Creates and saves slots in Firestore for the given UID
  Future<void> saveSlotsToFirestore() async {
    try {
      print('\n=== Starting Slot Generation ===');
      print('UID: $uid');
      print('Start Time: $startTime');
      print('End Time: $endTime');
      print('Available Days: $availableDays');
      print('Max Days in Advance: $maxDaysInAdvance');

      final docRef = FirebaseFirestore.instance.collection('slots').doc(uid);
      final now = DateTime.now();
      final maxDate = now.add(Duration(days: maxDaysInAdvance));

      print('\nDate Range:');
      print('From: ${now.toString()}');
      print('To: ${maxDate.toString()}');

      // Generate slots for each day within the range
      Map<String, List<Map<String, dynamic>>> slotsByDate = {};
      DateTime currentDate = now;

      while (currentDate.isBefore(maxDate)) {
        print('\nProcessing date: ${currentDate.toString()}');
        if (_isValidBookingDate(currentDate)) {
          final dateKey = DateFormat('yyyy-MM-dd').format(currentDate);
          print('Generating slots for date key: $dateKey');
          final slots = _generateSlotsForDate(currentDate);
          if (slots.isNotEmpty) {
            slotsByDate[dateKey] = slots;
          }
        } else {
          print('Skipping invalid date: ${currentDate.toString()}');
        }
        currentDate = currentDate.add(const Duration(days: 1));
      }

      print('\nSlot Generation Summary:');
      print('Total days with slots: ${slotsByDate.length}');
      slotsByDate.forEach((date, slots) {
        print('Date $date: ${slots.length} slots');
        if (slots.isNotEmpty) {
          print('First slot: ${slots.first}');
          print('Last slot: ${slots.last}');
        }
      });

      // Save to Firestore
      print('\nSaving to Firestore...');
      await docRef.set({
        'uid': uid,
        'startTime': startTime,
        'endTime': endTime,
        'availableDays': availableDays,
        'maxDaysInAdvance': maxDaysInAdvance,
        'slots': slotsByDate,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      print('Slots created and saved successfully for UID: $uid');
      print('=== Slot Generation Complete ===\n');
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

  /// Check if a slot is available for booking
  Future<bool> isSlotAvailable(String doctorId, DateTime date, String time) async {
    try {
      final docRef = FirebaseFirestore.instance.collection('slots').doc(doctorId);
      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data()!;
        final slots = data['slots'] as Map<String, dynamic>;
        final dateKey = date.toIso8601String();
        
        if (slots.containsKey(dateKey)) {
          final daySlots = slots[dateKey] as List<dynamic>;
          final slot = daySlots.firstWhere(
            (slot) => slot['time'] == time,
            orElse: () => null,
          );
          
          return slot != null && slot['status'] == 'available';
        }
      }
      return false;
    } catch (e) {
      print('Error checking slot availability: $e');
      return false;
    }
  }

  /// Update a specific slot's status
  Future<void> updateSlotStatus(
    String doctorId,
    DateTime date,
    String time,
    String status,
    {String? bookedBy}
  ) async {
    try {
      final docRef = FirebaseFirestore.instance.collection('slots').doc(doctorId);
      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data()!;
        final slots = data['slots'] as Map<String, dynamic>;
        final dateKey = date.toIso8601String();
        
        if (slots.containsKey(dateKey)) {
          final daySlots = slots[dateKey] as List<dynamic>;
          final updatedSlots = daySlots.map((slot) {
            if (slot['time'] == time) {
              return {
                ...slot,
                'status': status,
                'booked': status == 'booked',
                'bookedBy': bookedBy,
                'bookedAt': status == 'booked' ? FieldValue.serverTimestamp() : null,
              };
            }
            return slot;
          }).toList();

          await docRef.update({
            'slots.$dateKey': updatedSlots,
          });
        }
      }
    } catch (e) {
      print('Error updating slot status: $e');
      throw e;
    }
  }
}
