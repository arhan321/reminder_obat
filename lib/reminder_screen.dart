import 'package:flutter/material.dart';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  // Dummy data sementara (nanti bisa diganti dengan database)
  List<Map<String, dynamic>> medicines = [
    {
      'name': 'Paracetamol',
      'dose': '500 mg',
      'time': '08:00 AM',
      'taken': false
    },
    {
      'name': 'Vitamin C',
      'dose': '1000 mg',
      'time': '12:00 PM',
      'taken': false
    },
  ];

  void _markAsTaken(int index) {
    setState(() {
      medicines[index]['taken'] = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${medicines[index]['name']} sudah diminum 💊'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengingat Obat'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Kembali ke Beranda',
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/');
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: medicines.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.alarm_off, size: 80, color: Colors.grey),
                    SizedBox(height: 10),
                    Text(
                      'Belum ada pengingat obat',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                itemCount: medicines.length,
                itemBuilder: (context, index) {
                  final medicine = medicines[index];
                  return Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: Icon(
                        Icons.medication,
                        color: medicine['taken'] ? Colors.green : Colors.blue,
                        size: 35,
                      ),
                      title: Text(
                        medicine['name'],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          decoration: medicine['taken']
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                      subtitle: Text(
                        '${medicine['dose']} • ${medicine['time']}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      trailing: medicine['taken']
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : ElevatedButton(
                              onPressed: () => _markAsTaken(index),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                              ),
                              child: const Text('Tandai'),
                            ),
                    ),
                  );
                },
              ),
      ),

      // ✅ Bottom Navigation Bar (sama seperti di home_screen)
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/addMedicine');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/reminder');
          } else if (index == 3) {
            Navigator.pushReplacementNamed(context, '/profile');
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Obat'),
          BottomNavigationBarItem(icon: Icon(Icons.alarm), label: 'Pengingat'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
