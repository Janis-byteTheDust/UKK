// GANTI FILE: lib/pages/dashboard_siswa_page.dart (VERSI LENGKAP DENGAN RIWAYAT PESANAN)

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ukkkantin/pages/riwayat_pesanan_page.dart';
import 'package:ukkkantin/services/api.dart';
import 'package:ukkkantin/services/cart_service.dart';

import 'welcome_page.dart';
import 'keranjang_page.dart';
import 'riwayat_pesanan_page.dart'; 

class DashboardSiswaPage extends StatefulWidget {
  const DashboardSiswaPage({Key? key}) : super(key: key);

  @override
  State<DashboardSiswaPage> createState() => _DashboardSiswaPageState();
}

class _DashboardSiswaPageState extends State<DashboardSiswaPage> {
  String? _token;
  String? _username;
  List<dynamic> _menuList = [];
  List<dynamic> _makananList = [];
  List<dynamic> _minumanList = [];
  bool _isLoading = true;
  String _selectedCategory = 'Semua';
  
  final CartService _cartService = CartService();

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
    
    if (_token != null) {
      _loadMenu();
    }
  }

  Future<void> _loadMenu() async {
    setState(() => _isLoading = true);

    try {
      final results = await Future.wait([
        ApiService.getMenuFood(token: _token!, search: ''),
        ApiService.getMenuDrink(token: _token!, search: ''),
      ]);

      final foodResult = results[0];
      final drinkResult = results[1];

      print('🔍 Food Result: $foodResult');
      print('🔍 Drink Result: $drinkResult');

      if (foodResult['success'] == false && 
          foodResult['message']?.toString().contains('Token') == true) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(foodResult['message'] ?? 'Token expired'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Login Ulang',
              textColor: Colors.white,
              onPressed: () => _logout(context),
            ),
          ),
        );
        return;
      }

      List<dynamic> foodList = [];
      List<dynamic> drinkList = [];

      if (foodResult['data'] != null && foodResult['data'] is List) {
        foodList = foodResult['data'];
      } else if (foodResult['pesan'] != null && foodResult['pesan'] is List) {
        foodList = foodResult['pesan'];
      } else if (foodResult is List) {
        foodList = foodResult as List<dynamic>;
      }

      if (drinkResult['data'] != null && drinkResult['data'] is List) {
        drinkList = drinkResult['data'];
      } else if (drinkResult['pesan'] != null && drinkResult['pesan'] is List) {
        drinkList = drinkResult['pesan'];
      } else if (drinkResult is List) {
        drinkList = drinkResult as List<dynamic>;
      }

      setState(() {
        _makananList = foodList;
        _minumanList = drinkList;
        _menuList = [...foodList, ...drinkList];
      });

      print('✅ Loaded ${_makananList.length} makanan, ${_minumanList.length} minuman');
    } catch (e) {
      print('❌ Error loading menu: $e');
      setState(() {
        _menuList = [];
        _makananList = [];
        _minumanList = [];
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat menu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
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

  List<dynamic> get _filteredMenu {
    if (_selectedCategory == 'Makanan') {
      return _makananList;
    } else if (_selectedCategory == 'Minuman') {
      return _minumanList;
    }
    return _menuList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Siswa'),
        backgroundColor: const Color(0xFFF4511E),
        automaticallyImplyLeading: false,
        actions: [
          // TOMBOL RIWAYAT PESANAN - BARU!
          IconButton(
            icon: const Icon(Icons.receipt_long),
            tooltip: 'Riwayat Pesanan',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RiwayatPesananSiswaPage(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMenu,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadMenu,
        child: Column(
          children: [
            // Welcome Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFF4511E), Color(0xFFFB8C00)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selamat Datang,',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  Text(
                    _username ?? 'Siswa',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Pilih menu favoritmu hari ini!',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            // Menu Shortcuts - BARU!
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildMenuButton(
                      icon: Icons.receipt_long,
                      label: 'Riwayat\nPesanan',
                      color: Colors.blue,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RiwayatPesananSiswaPage(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMenuButton(
                      icon: Icons.shopping_cart,
                      label: 'Keranjang\nBelanja',
                      color: const Color(0xFFF4511E),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const KeranjangPage(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Category Filter
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              child: Row(
                children: [
                  _buildCategoryChip('Semua'),
                  const SizedBox(width: 10),
                  _buildCategoryChip('Makanan'),
                  const SizedBox(width: 10),
                  _buildCategoryChip('Minuman'),
                ],
              ),
            ),

            // Menu List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredMenu.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.restaurant,
                                size: 80,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 20),
                              Text(
                                _selectedCategory == 'Semua'
                                    ? 'Belum ada menu tersedia'
                                    : 'Belum ada $_selectedCategory tersedia',
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 10),
                              ElevatedButton.icon(
                                onPressed: _loadMenu,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Muat Ulang'),
                              ),
                            ],
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 15,
                            mainAxisSpacing: 15,
                            childAspectRatio: 0.75,
                          ),
                          itemCount: _filteredMenu.length,
                          itemBuilder: (context, index) {
                            final menu = _filteredMenu[index];
                            return _buildMenuCard(menu);
                          },
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const KeranjangPage()),
          );
        },
        backgroundColor: const Color(0xFFF4511E),
        icon: const Icon(Icons.shopping_cart),
        label: const Text('Keranjang'),
      ),
    );
  }

  // WIDGET BARU untuk menu button
  Widget _buildMenuButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    final isSelected = _selectedCategory == category;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedCategory = category;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF4511E) : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          category,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard(dynamic menu) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(15),
                ),
              ),
              child: menu['foto'] != null
                  ? ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(15),
                      ),
                      child: Image.network(
                        menu['foto'],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.fastfood,
                            size: 50,
                            color: Colors.grey,
                          );
                        },
                      ),
                    )
                  : const Icon(
                      Icons.fastfood,
                      size: 50,
                      color: Colors.grey,
                    ),
            ),
          ),
          
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        menu['nama_makanan'] ?? 'Menu',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        menu['deskripsi'] ?? '',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Rp ${menu['harga'] ?? 0}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF4511E),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          final menuData = {
                            'id_menu': menu['id_menu'] ?? menu['id'] ?? 0,
                            'nama_makanan': menu['nama_makanan'] ?? 'Menu',
                            'harga': menu['harga'] ?? 0,
                            'qty': 1,
                            'foto': menu['foto'],
                            'id_stan': menu['id_stan'] ?? 1,
                          };
                          
                          _cartService.addToCart(menuData);
                          setState(() {});
                          
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${menu['nama_makanan']} ditambahkan ke keranjang'),
                              backgroundColor: Colors.green,
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4511E),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.add,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}