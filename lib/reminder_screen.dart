import 'package:flutter/material.dart';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  // Dummy data sementara (nanti bisa diganti storage/database)
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

  // Format TimeOfDay ke 'hh:mm AM/PM'
  String _formatTimeOfDay(TimeOfDay t) {
    final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod; // 0 -> 12
    final minute = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '${hour.toString().padLeft(2, '0')}:$minute $period';
  }

  // Tandai sudah diminum
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

  // Edit waktu minum
  Future<void> _editTime(int index) async {
    final current = medicines[index]['time'] as String;
    TimeOfDay initial = TimeOfDay.now();

    // Parse sederhana "HH:MM AM/PM"
    try {
      final parts = current.split(' ');
      final hm = parts[0].split(':');
      int h = int.parse(hm[0]);
      final m = int.parse(hm[1]);
      final isPM = parts.length > 1 && parts[1].toUpperCase() == 'PM';
      if (h == 12) h = 0; // 12 AM/PM penyesuaian
      final hour24 = isPM ? h + 12 : h;
      initial = TimeOfDay(hour: hour24, minute: m);
    } catch (_) {}

    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
    );

    if (picked != null) {
      setState(() {
        medicines[index]['time'] = _formatTimeOfDay(picked);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Waktu ${medicines[index]['name']} diperbarui ke ${medicines[index]['time']} ⏰'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  // Hapus obat (dengan peringatan & opsi Undo)
  Future<void> _deleteMedicine(int index) async {
    final item = Map<String, dynamic>.from(
        medicines[index]); // simpan salinan untuk Undo
    final name = item['name'] as String;
    final taken = item['taken'] as bool;

    final agree = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // wajib pilih tombol
      builder: (ctx) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Konfirmasi Hapus'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Yakin ingin menghapus "$name"?'),
            const SizedBox(height: 8),
            if (!taken)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Icon(Icons.info_outline, size: 18, color: Colors.orange),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Obat ini belum ditandai diminum. Menghapus akan menghilangkan pengingat terkait.',
                      style: TextStyle(color: Colors.orange),
                    ),
                  ),
                ],
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            icon: const Icon(Icons.delete),
            label: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (agree == true) {
      setState(() {
        medicines.removeAt(index);
      });

      // Snackbar dengan Undo
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Obat "$name" berhasil dihapus 🗑️'),
          action: SnackBarAction(
            label: 'URUNGKAN',
            onPressed: () {
              setState(() {
                final pos = index.clamp(0, medicines.length);
                medicines.insert(pos, item);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Penghapusan "$name" dibatalkan.')),
              );
            },
          ),
        ),
      );
    }
  }

  // Trailing actions (tandai / edit / hapus)
  Widget _buildTrailingActions(int index, Map<String, dynamic> medicine) {
    final taken = medicine['taken'] as bool;

    if (!taken) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            onPressed: () => _markAsTaken(index),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            ),
            child: const Text('Tandai'),
          ),
          const SizedBox(width: 4),
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'edit') _editTime(index);
              if (v == 'delete') _deleteMedicine(index);
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'edit',
                child: ListTile(
                    leading: Icon(Icons.edit), title: Text('Edit waktu')),
              ),
              PopupMenuItem(
                value: 'delete',
                child: ListTile(
                    leading: Icon(Icons.delete), title: Text('Hapus obat')),
              ),
            ],
            icon: const Icon(Icons.more_vert),
            tooltip: 'Opsi',
          ),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.check_circle, color: Colors.green),
        PopupMenuButton<String>(
          onSelected: (v) {
            if (v == 'edit') _editTime(index);
            if (v == 'delete') _deleteMedicine(index);
          },
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: 'edit',
              child: ListTile(
                  leading: Icon(Icons.edit), title: Text('Edit waktu')),
            ),
            PopupMenuItem(
              value: 'delete',
              child: ListTile(
                  leading: Icon(Icons.delete), title: Text('Hapus obat')),
            ),
          ],
          icon: const Icon(Icons.more_vert),
          tooltip: 'Opsi',
        ),
      ],
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
                      trailing: _buildTrailingActions(index, medicine),
                    ),
                  );
                },
              ),
      ),

      // Bottom Navigation (konsisten dengan Home)
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
