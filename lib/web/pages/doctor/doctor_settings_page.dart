import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorSettingsPage extends StatefulWidget {
  const DoctorSettingsPage({Key? key}) : super(key: key);

  @override
  State<DoctorSettingsPage> createState() => _DoctorSettingsPageState();
}

class _DoctorSettingsPageState extends State<DoctorSettingsPage> {
  final User? user = FirebaseAuth.instance.currentUser;
  bool _isLoading = false;
  bool _emailNotifications = true;
  bool _smsNotifications = false;
  bool _darkMode = false;
  String _language = 'English';
  int _sessionDuration = 30;
  bool _autoConfirmAppointments = false;
  bool _showAvailability = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    if (user == null) return;

    setState(() => _isLoading = true);
    try {
      final doc = await FirebaseFirestore.instance
          .collection('doctors')
          .doc(user!.uid)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        setState(() {
          _emailNotifications = data['emailNotifications'] ?? true;
          _smsNotifications = data['smsNotifications'] ?? false;
          _darkMode = data['darkMode'] ?? false;
          _language = data['language'] ?? 'English';
          _sessionDuration = data['sessionDuration'] ?? 30;
          _autoConfirmAppointments = data['autoConfirmAppointments'] ?? false;
          _showAvailability = data['showAvailability'] ?? true;
        });
      }
    } catch (e) {
      print('Error loading settings: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveSettings() async {
    if (user == null) return;

    setState(() => _isLoading = true);
    try {
      await FirebaseFirestore.instance.collection('doctors').doc(user!.uid).update({
        'emailNotifications': _emailNotifications,
        'smsNotifications': _smsNotifications,
        'darkMode': _darkMode,
        'language': _language,
        'sessionDuration': _sessionDuration,
        'autoConfirmAppointments': _autoConfirmAppointments,
        'showAvailability': _showAvailability,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settings saved successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving settings: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildSettingSection(String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Settings',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          // Notifications Settings
          _buildSettingSection(
            'Notifications',
            [
              SwitchListTile(
                title: const Text('Email Notifications'),
                subtitle: const Text('Receive appointment updates via email'),
                value: _emailNotifications,
                onChanged: (value) => setState(() => _emailNotifications = value),
                activeColor: Colors.teal,
              ),
              const Divider(),
              SwitchListTile(
                title: const Text('SMS Notifications'),
                subtitle: const Text('Receive appointment updates via SMS'),
                value: _smsNotifications,
                onChanged: (value) => setState(() => _smsNotifications = value),
                activeColor: Colors.teal,
              ),
            ],
          ),

          // Appearance Settings
          _buildSettingSection(
            'Appearance',
            [
              SwitchListTile(
                title: const Text('Dark Mode'),
                subtitle: const Text('Enable dark theme'),
                value: _darkMode,
                onChanged: (value) => setState(() => _darkMode = value),
                activeColor: Colors.teal,
              ),
              const Divider(),
              ListTile(
                title: const Text('Language'),
                subtitle: Text(_language),
                trailing: DropdownButton<String>(
                  value: _language,
                  items: ['English', 'Spanish', 'French', 'German']
                      .map((lang) => DropdownMenuItem(
                            value: lang,
                            child: Text(lang),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _language = value);
                    }
                  },
                ),
              ),
            ],
          ),

          // Appointment Settings
          _buildSettingSection(
            'Appointment Settings',
            [
              ListTile(
                title: const Text('Default Session Duration'),
                subtitle: Text('$_sessionDuration minutes'),
                trailing: DropdownButton<int>(
                  value: _sessionDuration,
                  items: [15, 30, 45, 60]
                      .map((duration) => DropdownMenuItem(
                            value: duration,
                            child: Text('$duration minutes'),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _sessionDuration = value);
                    }
                  },
                ),
              ),
              const Divider(),
              SwitchListTile(
                title: const Text('Auto-Confirm Appointments'),
                subtitle: const Text('Automatically confirm new appointment requests'),
                value: _autoConfirmAppointments,
                onChanged: (value) => setState(() => _autoConfirmAppointments = value),
                activeColor: Colors.teal,
              ),
              const Divider(),
              SwitchListTile(
                title: const Text('Show Availability'),
                subtitle: const Text('Display your availability to patients'),
                value: _showAvailability,
                onChanged: (value) => setState(() => _showAvailability = value),
                activeColor: Colors.teal,
              ),
            ],
          ),

          // Save Button
          Center(
            child: ElevatedButton(
              onPressed: _saveSettings,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Save Changes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 