// GANTI FILE: lib/pages/pesanan_page.dart

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:ukkkantin/services/api.dart';

class PesananPage extends StatefulWidget {
  final String token;
  const PesananPage({Key? key, required this.token}) : super(key: key);

  @override
  State<PesananPage> createState() => _PesananPageState();
}

class _PesananPageState extends State<PesananPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  List<dynamic> _belumDikonfirmList = [];
  List<dynamic> _dimasakList = [];
  List<dynamic> _diantarList = [];
  List<dynamic> _sampaiList = [];
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);

    try {
      final results = await Future.wait([
        ApiService.getOrderByStatus(token: widget.token, status: 'belum dikonfirm'),
        ApiService.getOrderByStatus(token: widget.token, status: 'dimasak'),
        ApiService.getOrderByStatus(token: widget.token, status: 'diantar'),
        ApiService.getOrderByStatus(token: widget.token, status: 'sampai'),
      ]);

      print('🔍 Raw API Results:');
      print('Belum Dikonfirm: ${results[0]}');
      print('Dimasak: ${results[1]}');
      print('Diantar: ${results[2]}');
      print('Sampai: ${results[3]}');

      setState(() {
        _belumDikonfirmList = _parseOrderData(results[0]);
        _dimasakList = _parseOrderData(results[1]);
        _diantarList = _parseOrderData(results[2]);
        _sampaiList = _parseOrderData(results[3]);
      });

      print('✅ Parsed orders:');
      print('Belum Dikonfirm: ${_belumDikonfirmList.length}');
      print('Dimasak: ${_dimasakList.length}');
      print('Diantar: ${_diantarList.length}');
      print('Sampai: ${_sampaiList.length}');
      
      if (_belumDikonfirmList.isNotEmpty) {
        print('📦 Sample Belum Dikonfirm order:');
        print(_belumDikonfirmList[0]);
      }
    } catch (e) {
      print('❌ Error loading orders: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<dynamic> _parseOrderData(dynamic result) {
    print('🔍 Parsing data: $result');
    
    if (result is Map<String, dynamic>) {
      // Coba berbagai kemungkinan key
      final possibleKeys = ['data', 'pesan', 'pesanan', 'orders', 'order'];
      
      for (var key in possibleKeys) {
        if (result[key] != null && result[key] is List) {
          print('✅ Found data in key: $key');
          return result[key];
        }
      }
      
      // Jika tidak ada key yang cocok, coba ambil langsung jika result adalah array
      print('⚠️ No matching key found in response');
      return [];
    } else if (result is List) {
      print('✅ Result is already a list');
      return result;
    }
    
    print('⚠️ Unknown data format');
    return [];
  }

  Future<void> _updateStatus(int orderId, String newStatus) async {
    try {
      print('📤 Updating order #$orderId to status: $newStatus');
      
      final result = await ApiService.updateOrderStatus(
        token: widget.token,
        orderId: orderId,
        status: newStatus,
      );

      print('📦 Update result: $result');

      if (!mounted) return;

      if (result['success'] == true || 
          result['message']?.toString().toLowerCase().contains('berhasil') == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Status pesanan berhasil diupdate!'),
            backgroundColor: Colors.green,
          ),
        );
        _loadOrders(); // Reload data
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Gagal update status'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('❌ Error updating status: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showUpdateStatusDialog(dynamic order) {
    print('📋 Order data for dialog: $order');
    
    // Coba berbagai kemungkinan key untuk ID
    final orderId = order['id_pesan'] ?? 
                    order['id'] ?? 
                    order['order_id'] ?? 
                    order['id_order'] ?? 0;
    
    final currentStatus = order['status'] ?? 'belum dikonfirm';

    print('🔍 Order ID: $orderId, Status: $currentStatus');

    if (orderId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: ID pesanan tidak ditemukan'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Tentukan status berikutnya
    String nextStatus;
    String actionText;
    
    switch (currentStatus) {
      case 'belum dikonfirm':
        nextStatus = 'dimasak';
        actionText = 'Konfirmasi & Masak';
        break;
      case 'dimasak':
        nextStatus = 'diantar';
        actionText = 'Antarkan';
        break;
      case 'diantar':
        nextStatus = 'sampai';
        actionText = 'Tandai Sampai';
        break;
      default:
        return; // Sudah sampai, tidak ada aksi
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Status'),
        content: Text('Ubah status pesanan #$orderId menjadi "$nextStatus"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _updateStatus(orderId, nextStatus);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF4511E),
            ),
            child: Text(actionText),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pesanan Masuk'),
        backgroundColor: const Color(0xFFF4511E),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          tabs: [
            Tab(
              child: Row(
                children: [
                  const Text('Baru'),
                  if (_belumDikonfirmList.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${_belumDikonfirmList.length}',
                        style: const TextStyle(fontSize: 10),
                      ),
                    ),
                ],
              ),
            ),
            Tab(text: 'Dimasak (${_dimasakList.length})'),
            Tab(text: 'Diantar (${_diantarList.length})'),
            Tab(text: 'Selesai (${_sampaiList.length})'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadOrders,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOrderList(_belumDikonfirmList, 'belum dikonfirm'),
                _buildOrderList(_dimasakList, 'dimasak'),
                _buildOrderList(_diantarList, 'diantar'),
                _buildOrderList(_sampaiList, 'sampai'),
              ],
            ),
    );
  }

  Widget _buildOrderList(List<dynamic> orders, String status) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 20),
            Text(
              'Belum ada pesanan',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _loadOrders,
              icon: const Icon(Icons.refresh),
              label: const Text('Muat Ulang'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadOrders,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return _buildOrderCard(order, status);
        },
      ),
    );
  }

  Widget _buildOrderCard(dynamic order, String status) {
    print('🎴 Building card for order: $order');
    
    // Coba berbagai kemungkinan key untuk ID
    final orderId = order['id_pesan'] ?? 
                    order['id'] ?? 
                    order['order_id'] ?? 
                    order['id_order'] ?? 0;
    
    // Coba berbagai kemungkinan key untuk nama siswa
    final namaSiswa = order['nama_siswa'] ?? 
                      order['siswa'] ?? 
                      order['nama'] ?? 
                      order['customer'] ?? 
                      'Siswa';
    
    // Tanggal
    final tanggal = order['tanggal'] ?? 
                    order['created_at'] ?? 
                    order['date'] ?? 
                    '';
    
    // Pesanan/items - coba berbagai kemungkinan key
    var pesanan = order['pesanan'] ?? 
                  order['pesan'] ?? 
                  order['items'] ?? 
                  order['detail'] ?? 
                  order['detail_pesanan'] ?? 
                  [];
    
    print('📦 Order #$orderId - Items: $pesanan');
    
    // Jika pesanan adalah string JSON, parse dulu
    if (pesanan is String) {
      try {
        pesanan = jsonDecode(pesanan);
      } catch (e) {
        print('⚠️ Failed to parse pesanan JSON: $e');
        pesanan = [];
      }
    }
    
    // Hitung total
    int total = 0;
    if (pesanan is List && pesanan.isNotEmpty) {
      for (var item in pesanan) {
        // Coba berbagai kemungkinan key
        final harga = item['harga'] ?? 
                      item['price'] ?? 
                      item['harga_menu'] ?? 
                      0;
        
        final qty = item['qty'] ?? 
                    item['quantity'] ?? 
                    item['jumlah'] ?? 
                    1;
        
        total += ((harga is int ? harga : int.tryParse(harga.toString()) ?? 0) * 
                  (qty is int ? qty : int.tryParse(qty.toString()) ?? 1));
      }
    }
    
    // Jika total masih 0, coba ambil dari order langsung
    if (total == 0) {
      final totalValue = order['total'] ?? 
              order['total_harga'] ?? 
              order['grand_total'] ?? 
              0;
      
      if (totalValue is String) {
        total = int.tryParse(totalValue) ?? 0;
      } else if (totalValue is int) {
        total = totalValue;
      }
    }

    print('💰 Total calculated: Rp $total');

    // Status color
    Color statusColor;
    switch (status) {
      case 'belum dikonfirm':
        statusColor = Colors.orange;
        break;
      case 'dimasak':
        statusColor = Colors.blue;
        break;
      case 'diantar':
        statusColor = Colors.purple;
        break;
      case 'sampai':
        statusColor = Colors.green;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '#$orderId',
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      tanggal,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Customer Info
            Row(
              children: [
                const Icon(Icons.person, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  namaSiswa,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            // Items
            if (pesanan is List && pesanan.isNotEmpty)
              ...pesanan.map((item) {
                final namaMenu = item['nama_makanan'] ?? 
                                item['nama'] ?? 
                                item['menu'] ?? 
                                item['nama_menu'] ?? 
                                'Menu';
                
                final harga = item['harga'] ?? 
                              item['price'] ?? 
                              item['harga_menu'] ?? 
                              0;
                
                final qty = item['qty'] ?? 
                            item['quantity'] ?? 
                            item['jumlah'] ?? 
                            1;
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${qty}x $namaMenu',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      Text(
                        'Rp $harga',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList()
            else
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'Detail pesanan tidak tersedia',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),

            const Divider(height: 24),

            // Total & Action
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      'Rp $total',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFF4511E),
                      ),
                    ),
                  ],
                ),
                if (status != 'sampai')
                  ElevatedButton(
                    onPressed: () => _showUpdateStatusDialog(order),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: statusColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    child: Text(
                      status == 'belum dikonfirm'
                          ? 'Konfirmasi'
                          : status == 'dimasak'
                              ? 'Antarkan'
                              : 'Selesai',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}