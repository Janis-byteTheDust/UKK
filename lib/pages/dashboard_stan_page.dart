// GANTI FILE: lib/pages/dashboard_stan_page.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:ukkkantin/services/api.dart';

import 'welcome_page.dart';
import 'pesanan_page.dart';

class DashboardStanPage extends StatefulWidget {
  const DashboardStanPage({Key? key}) : super(key: key);

  @override
  State<DashboardStanPage> createState() => _DashboardStanPageState();
}

class _DashboardStanPageState extends State<DashboardStanPage> {
  String? _token;
  String? _username;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = prefs.getString('access_token');
      _username = prefs.getString('username');
    });
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    
    if (!context.mounted) return;
    
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const WelcomePage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Admin Stan'),
        backgroundColor: const Color(0xFFF4511E),
        automaticallyImplyLeading: false, // Hapus tombol back
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: Color(0xFFF4511E),
                      child: Icon(Icons.store, color: Colors.white, size: 30),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Selamat Datang,',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          Text(
                            _username ?? 'Admin',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            const Text(
              'Menu Manajemen',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            
            // Menu Cards
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                children: [
                  _buildMenuCard(
                    icon: Icons.add_circle,
                    title: 'Tambah Menu',
                    color: Colors.green,
                    onTap: () async {
                      // Tunggu hasil dari halaman tambah menu
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TambahMenuPage(token: _token ?? ''),
                        ),
                      );
                      
                      // Jika berhasil tambah menu, tampilkan notifikasi
                      if (result == true && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Menu berhasil ditambahkan!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    },
                  ),
                  _buildMenuCard(
                    icon: Icons.restaurant_menu,
                    title: 'Lihat Menu',
                    color: Colors.blue,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LihatMenuPage(token: _token ?? ''),
                        ),
                      );
                    },
                  ),
                  _buildMenuCard(
                    icon: Icons.shopping_bag,
                    title: 'Pesanan Masuk',
                    color: Colors.orange,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PesananPage(token: _token ?? ''),
                        ),
                      );
                    },
                  ),
                  _buildMenuCard(
                    icon: Icons.assessment,
                    title: 'Laporan',
                    color: Colors.purple,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Fitur segera hadir')),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 3,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: color),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ========== HALAMAN TAMBAH MENU ==========

class TambahMenuPage extends StatefulWidget {
  final String token;
  const TambahMenuPage({Key? key, required this.token}) : super(key: key);

  @override
  State<TambahMenuPage> createState() => _TambahMenuPageState();
}

class _TambahMenuPageState extends State<TambahMenuPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _hargaController = TextEditingController();
  final _deskripsiController = TextEditingController();
  
  String _jenis = 'makanan';
  File? _imageFile;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _namaController.dispose();
    _hargaController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitMenu() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final result = await ApiService.tambahMenu(
        token: widget.token,
        namaMakanan: _namaController.text.trim(),
        jenis: _jenis,
        harga: int.parse(_hargaController.text),
        deskripsi: _deskripsiController.text.trim(),
        foto: _imageFile,
      );

      if (!mounted) return;

      if (result['success'] == true || result['message']?.toString().toLowerCase().contains('berhasil') == true) {
        // Kembali ke dashboard dengan status berhasil
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Gagal menambahkan menu'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Menu'),
        backgroundColor: const Color(0xFFF4511E),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Picker
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(15),
                    image: _imageFile != null
                        ? DecorationImage(
                            image: FileImage(_imageFile!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _imageFile == null
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt, size: 50, color: Colors.grey),
                            SizedBox(height: 10),
                            Text('Tap untuk upload foto'),
                          ],
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 20),

              // Nama Menu
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(
                  labelText: 'Nama Menu',
                  prefixIcon: Icon(Icons.restaurant),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama menu harus diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // Jenis
              DropdownButtonFormField<String>(
                value: _jenis,
                decoration: const InputDecoration(
                  labelText: 'Jenis',
                  prefixIcon: Icon(Icons.category),
                ),
                items: const [
                  DropdownMenuItem(value: 'makanan', child: Text('Makanan')),
                  DropdownMenuItem(value: 'minuman', child: Text('Minuman')),
                ],
                onChanged: (value) {
                  setState(() {
                    _jenis = value!;
                  });
                },
              ),
              const SizedBox(height: 15),

              // Harga
              TextFormField(
                controller: _hargaController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Harga',
                  prefixIcon: Icon(Icons.attach_money),
                  prefixText: 'Rp ',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Harga harus diisi';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Harga harus berupa angka';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // Deskripsi
              TextFormField(
                controller: _deskripsiController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi',
                  prefixIcon: Icon(Icons.description),
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Deskripsi harus diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),

              // Submit Button
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitMenu,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Tambah Menu',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ========== HALAMAN LIHAT MENU ==========

class LihatMenuPage extends StatefulWidget {
  final String token;
  const LihatMenuPage({Key? key, required this.token}) : super(key: key);

  @override
  State<LihatMenuPage> createState() => _LihatMenuPageState();
}

class _LihatMenuPageState extends State<LihatMenuPage> {
  List<dynamic> _menuList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMenu();
  }

  Future<void> _loadMenu() async {
    setState(() => _isLoading = true);

    try {
      final result = await ApiService.showMenu(token: widget.token);

      print('🔍 Full Result: $result');

      // Handle berbagai kemungkinan struktur response
      if (result['data'] != null && result['data'] is List) {
        setState(() {
          _menuList = result['data'];
        });
        print('✅ Loaded ${_menuList.length} items');
      } else if (result['pesan'] != null && result['pesan'] is List) {
        setState(() {
          _menuList = result['pesan'];
        });
        print('✅ Loaded ${_menuList.length} items from pesan field');
      } else if (result is List) {
        setState(() {
          _menuList = result as List<dynamic>;
        });
        print('✅ Loaded ${_menuList.length} items (direct array)');
      } else {
        print('⚠️ No data found in response');
        setState(() {
          _menuList = [];
        });
      }

      print('📋 Menu List: $_menuList');
    } catch (e) {
      print('❌ Error loading menu: $e');
      setState(() {
        _menuList = [];
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Menu'),
        backgroundColor: const Color(0xFFF4511E),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMenu,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _menuList.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox, size: 80, color: Colors.grey),
                      SizedBox(height: 20),
                      Text(
                        'Belum ada menu',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _menuList.length,
                  itemBuilder: (context, index) {
                    final menu = _menuList[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 15),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFF4511E),
                          child: Icon(Icons.fastfood, color: Colors.white),
                        ),
                        title: Text(
                          menu['nama_makanan'] ?? 'Menu',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          menu['deskripsi'] ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Text(
                          'Rp ${menu['harga'] ?? 0}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFF4511E),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}