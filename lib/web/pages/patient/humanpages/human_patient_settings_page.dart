import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HumanPatientSettingsPage extends StatefulWidget {
  const HumanPatientSettingsPage({Key? key}) : super(key: key);

  @override
  State<HumanPatientSettingsPage> createState() => _HumanPatientSettingsPageState();
}

class _HumanPatientSettingsPageState extends State<HumanPatientSettingsPage> {
  final User? user = FirebaseAuth.instance.currentUser;
  bool _isLoading = false;
  bool _emailNotifications = true;
  bool _smsNotifications = false;
  bool _darkMode = false;
  String _language = 'English';
  bool _showMedicalHistory = true;
  bool _allowDoctorAccess = true;
  bool _emergencyContactEnabled = true;

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
          .collection('humanpatients')
          .doc(user!.uid)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        setState(() {
          _emailNotifications = data['emailNotifications'] ?? true;
          _smsNotifications = data['smsNotifications'] ?? false;
          _darkMode = data['darkMode'] ?? false;
          _language = data['language'] ?? 'English';
          _showMedicalHistory = data['showMedicalHistory'] ?? true;
          _allowDoctorAccess = data['allowDoctorAccess'] ?? true;
          _emergencyContactEnabled = data['emergencyContactEnabled'] ?? true;
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
      await FirebaseFirestore.instance.collection('humanpatients').doc(user!.uid).update({
        'emailNotifications': _emailNotifications,
        'smsNotifications': _smsNotifications,
        'darkMode': _darkMode,
        'language': _language,
        'showMedicalHistory': _showMedicalHistory,
        'allowDoctorAccess': _allowDoctorAccess,
        'emergencyContactEnabled': _emergencyContactEnabled,
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

          // Privacy Settings
          _buildSettingSection(
            'Privacy',
            [
              SwitchListTile(
                title: const Text('Show Medical History'),
                subtitle: const Text('Allow doctors to view your medical history'),
                value: _showMedicalHistory,
                onChanged: (value) => setState(() => _showMedicalHistory = value),
                activeColor: Colors.teal,
              ),
              const Divider(),
              SwitchListTile(
                title: const Text('Allow Doctor Access'),
                subtitle: const Text('Allow doctors to access your health records'),
                value: _allowDoctorAccess,
                onChanged: (value) => setState(() => _allowDoctorAccess = value),
                activeColor: Colors.teal,
              ),
              const Divider(),
              SwitchListTile(
                title: const Text('Emergency Contact'),
                subtitle: const Text('Share emergency contact information with healthcare providers'),
                value: _emergencyContactEnabled,
                onChanged: (value) => setState(() => _emergencyContactEnabled = value),
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