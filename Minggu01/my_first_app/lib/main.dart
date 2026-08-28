import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: const Text('Profil Mahasiswa')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.school, size: 72),
              SizedBox(height: 16),
              Text(
                'Nama Anda: Muhammad Fitra Adhim Nurrochman',
                style: TextStyle(fontSize: 24),
              ),
              Text(
                'NIM: 244107020089',
                style: TextStyle(fontSize: 24),
              ),
              ElevatedButton(
                onPressed: () {
                  print('Tombol ditekan pada aplikasi');
                },
                child: Text('Klik saya untuk menampilkan pesan di console'),
              ),
              Text('Pemrograman Mobile - Minggu 1'),
            ],
          ),
        ),
      ),
    );
  }
}
