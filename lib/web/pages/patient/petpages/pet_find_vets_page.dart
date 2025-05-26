import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:safe_space_app/models/doctors_db.dart';

class PetFindVetsPage extends StatefulWidget {
  final Function() onBookAppointment;
  
  const PetFindVetsPage({
    Key? key,
    required this.onBookAppointment,
  }) : super(key: key);

  @override
  State<PetFindVetsPage> createState() => _PetFindVetsPageState();
}

class _PetFindVetsPageState extends State<PetFindVetsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedSpecialization = 'All';
  bool _isLoading = false;
  List<DoctorsDb>? _cachedDoctors;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<DoctorsDb>> _fetchDoctors() async {
    if (_cachedDoctors != null) {
      debugPrint('📦 [FindVets] Using cached vets list');
      return _cachedDoctors!;
    }

    setState(() => _isLoading = true);
    try {
      debugPrint('🔍 [FindVets] Starting to fetch vets...');
      final querySnapshot = await FirebaseFirestore.instance
          .collection('doctors')
          .where('doctorType', isEqualTo: 'Veterinary')
          .get();

      debugPrint('📊 [FindVets] Query snapshot size: ${querySnapshot.docs.length}');
      
      if (querySnapshot.docs.isEmpty) {
        debugPrint('⚠️ [FindVets] No vets found in the collection');
        return [];
      }

      final doctors = querySnapshot.docs.map((doc) {
        try {
          final data = doc.data();
          debugPrint('👨‍⚕️ [FindVets] Processing vet: ${data['name']}');
          debugPrint('📝 [FindVets] Vet data: ${data.toString()}');
          return DoctorsDb.fromJson(data);
        } catch (e) {
          debugPrint('❌ [FindVets] Error processing vet document: $e');
          return null;
        }
      }).whereType<DoctorsDb>().toList();

      debugPrint('✅ [FindVets] Successfully fetched ${doctors.length} vets');
      _cachedDoctors = doctors;
      return doctors;
    } catch (e) {
      debugPrint('❌ [FindVets] Error fetching vets: $e');
      return [];
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<String> _getSpecializations(List<DoctorsDb> doctors) {
    final specializations = doctors.map((d) => d.specialization).toSet().toList();
    specializations.insert(0, 'All');
    debugPrint('🏷️ [FindVets] Available specializations: $specializations');
    return specializations;
  }

  List<DoctorsDb> _filterDoctors(List<DoctorsDb> doctors) {
    final filtered = doctors.where((doctor) {
      final matchesSearch = doctor.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          doctor.specialization.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesSpecialization = _selectedSpecialization == 'All' ||
          doctor.specialization == _selectedSpecialization;
      return matchesSearch && matchesSpecialization;
    }).toList();
    debugPrint('🔍 [FindVets] Filtered vets count: ${filtered.length}');
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[50],
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.teal.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.pets,
                          color: Colors.teal,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'Find Your Vet',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Search and book appointments with our qualified veterinary doctors',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search by name or specialization...',
                              prefixIcon: const Icon(Icons.search, color: Colors.teal),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _searchQuery = value;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      FutureBuilder<List<DoctorsDb>>(
                        future: _fetchDoctors(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Container(
                              width: 200,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          if (snapshot.hasError) {
                            debugPrint('❌ [FindVets] Error in specialization dropdown: ${snapshot.error}');
                            return Container(
                              width: 200,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: const Center(
                                child: Text('Error loading specializations'),
                              ),
                            );
                          }

                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return Container(
                              width: 200,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: const Center(
                                child: Text('No specializations available'),
                              ),
                            );
                          }

                          final specializations = _getSpecializations(snapshot.data!);
                          return Container(
                            width: 200,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedSpecialization,
                                isExpanded: true,
                                icon: const Icon(Icons.arrow_drop_down, color: Colors.teal),
                                items: specializations.map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    setState(() {
                                      _selectedSpecialization = newValue;
                                    });
                                  }
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Vets List
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
              )
            else if (_cachedDoctors == null)
              FutureBuilder<List<DoctorsDb>>(
                future: _fetchDoctors(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError) {
                    debugPrint('❌ [FindVets] Error in vets list: ${snapshot.error}');
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 48,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error loading vets: ${snapshot.error}',
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.pets,
                              color: Colors.grey,
                              size: 48,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No vets found',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final doctors = _filterDoctors(snapshot.data!);

                  if (doctors.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.search_off,
                              color: Colors.grey,
                              size: 48,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No vets match your search criteria',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: doctors.length,
                    itemBuilder: (context, index) {
                      final doctor = doctors[index];
                      return _buildVetCard(doctor);
                    },
                  );
                },
              )
            else
              Builder(
                builder: (context) {
                  final doctors = _filterDoctors(_cachedDoctors!);

                  if (doctors.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.search_off,
                              color: Colors.grey,
                              size: 48,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No vets match your search criteria',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: doctors.length,
                    itemBuilder: (context, index) {
                      final doctor = doctors[index];
                      return _buildVetCard(doctor);
                    },
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildVetCard(DoctorsDb doctor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.teal[50],
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.pets, color: Colors.teal, size: 30),
        ),
        title: Text(
          doctor.name,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Container(
          margin: const EdgeInsets.only(top: 4),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.teal[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            doctor.specialization,
            style: TextStyle(
              color: Colors.teal[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(Icons.medical_services, 'Qualification', doctor.qualification),
                const SizedBox(height: 12),
                _buildInfoRow(Icons.work, 'Experience', doctor.experience),
                const SizedBox(height: 12),
                _buildInfoRow(Icons.business, 'Clinic', doctor.clinicName),
                const SizedBox(height: 12),
                _buildInfoRow(Icons.phone, 'Contact', doctor.contactNumberClinic),
                const SizedBox(height: 12),
                _buildInfoRow(Icons.attach_money, 'Fees', '₹${doctor.fees}/hour'),
                const SizedBox(height: 12),
                _buildInfoRow(Icons.access_time, 'Available Hours', '${doctor.startTime} - ${doctor.endTime}'),
                const SizedBox(height: 12),
                _buildInfoRow(Icons.calendar_today, 'Available Days', doctor.availableDays?.join(', ') ?? 'Not specified'),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'About',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        doctor.bio,
                        style: TextStyle(
                          color: Colors.grey[600],
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: widget.onBookAppointment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Book Appointment',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.teal[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: Colors.teal),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
} 