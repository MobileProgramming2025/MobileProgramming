import 'package:flutter/material.dart';
import 'EditDoctorScreen.dart';
import '../../services/DoctorService.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DoctorService _doctorService = DoctorService();
  late Stream<List<Map<String, dynamic>>> _doctorsStream;

  @override
  void initState() {
    super.initState();
    _doctorsStream = _doctorService.fetchDoctors();
  }

  void _addDoctor() {
    Navigator.pushNamed(context, '/add-doctor');
  }

  void _editDoctor(Map<String, dynamic> doctor) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditDoctorScreen(doctor: doctor),
      ),
    );
  }

  void _deleteDoctor(String id) async {
    try {
      await _doctorService.deleteDoctor(id);
      // Check if the widget is still in the tree before using context
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Doctor deleted successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete doctor: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Doctors Dashboard"),
        //backgroundColor: const Color.fromARGB(255, 186, 124, 236),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<List<Map<String, dynamic>>>( 
          stream: _doctorsStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("No doctors available."));
            }

            final doctors = snapshot.data!;
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
              ),
              itemCount: doctors.length,
              itemBuilder: (context, index) {
                final doctor = doctors[index];
                return Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          doctor['name'],
                          style: Theme.of(context).textTheme.headlineMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          doctor['specialization'],
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Expanded(
                              child: IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _editDoctor(doctor),
                               // color: Color.fromARGB(255, 186, 124, 236),
                                iconSize: 28,
                              ),
                            ),
                            Expanded(
                              child: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _deleteDoctor(doctor['id']),
                                color: Colors.red,
                                iconSize: 28,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addDoctor,
        tooltip: "Add Doctor",
        child: const Icon(Icons.add),
      ),
    );
  }
}
