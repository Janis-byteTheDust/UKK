// GANTI SELURUH ISI FILE: lib/pages/riwayat_pesanan_siswa_page.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api.dart';

class RiwayatPesananSiswaPage extends StatefulWidget {
  const RiwayatPesananSiswaPage({Key? key}) : super(key: key);

  @override
  State<RiwayatPesananSiswaPage> createState() => _RiwayatPesananSiswaPageState();
}

class _RiwayatPesananSiswaPageState extends State<RiwayatPesananSiswaPage> 
    with SingleTickerProviderStateMixin {
  
  late TabController _tabController;
  String? _token;
  
  List<dynamic> _semuaPesanan = [];
  List<dynamic> _belumDikonfirmList = [];
  List<dynamic> _dimasakList = [];
  List<dynamic> _diantarList = [];
  List<dynamic> _sampaiList = [];
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadToken();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = prefs.getString('access_token');
    });
    
    if (_token != null) {
      _loadOrders();
    }
  }

  Future<void> _loadOrders() async {
    if (_token == null) return;
    
    setState(() => _isLoading = true);

    try {
      // PENTING: Gunakan showOrder untuk SISWA
      final results = await Future.wait([
        ApiService.showOrder(token: _token!, status: 'belum dikonfirm'),
        ApiService.showOrder(token: _token!, status: 'dimasak'),
        ApiService.showOrder(token: _token!, status: 'diantar'),
        ApiService.showOrder(token: _token!, status: 'sampai'),
      ]);

      print('🔍 Raw API Results (Siswa - showOrder):');
      print('Belum Dikonfirm: ${results[0]}');
      print('Dimasak: ${results[1]}');
      print('Diantar: ${results[2]}');
      print('Sampai: ${results[3]}');

      setState(() {
        _belumDikonfirmList = _parseOrderData(results[0]);
        _dimasakList = _parseOrderData(results[1]);
        _diantarList = _parseOrderData(results[2]);
        _sampaiList = _parseOrderData(results[3]);
        
        _semuaPesanan = [
          ..._belumDikonfirmList,
          ..._dimasakList,
          ..._diantarList,
          ..._sampaiList,
        ];
      });

      print('✅ Loaded orders (Siswa):');
      print('Total: ${_semuaPesanan.length}');
      print('Belum Dikonfirm: ${_belumDikonfirmList.length}');
      print('Dimasak: ${_dimasakList.length}');
      print('Diantar: ${_diantarList.length}');
      print('Sampai: ${_sampaiList.length}');
      
    } catch (e) {
      print('❌ Error loading orders: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat riwayat pesanan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<dynamic> _parseOrderData(dynamic result) {
    if (result is Map<String, dynamic>) {
      final possibleKeys = ['data', 'pesan', 'pesanan', 'orders', 'order'];
      
      for (var key in possibleKeys) {
        if (result[key] != null && result[key] is List) {
          return result[key];
        }
      }
      return [];
    } else if (result is List) {
      return result;
    }
    return [];
  }

  dynamic _extractPesanan(dynamic order) {
    var pesanan = order['detail_trans'] ?? 
                  order['pesanan'] ?? 
                  order['pesan'] ?? 
                  order['items'] ?? 
                  order['detail'] ?? 
                  order['detail_pesanan'];
    
    if (pesanan is String) {
      try {
        pesanan = jsonDecode(pesanan);
      } catch (e) {
        print('⚠️ Failed to parse pesanan JSON: $e');
        return [];
      }
    }
    
    return pesanan ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Pesanan'),
        backgroundColor: const Color(0xFFF4511E),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          tabs: [
            Tab(text: 'Semua (${_semuaPesanan.length})'),
            Tab(
              child: Row(
                children: [
                  const Text('Menunggu'),
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
                _buildOrderList(_semuaPesanan, showStatus: true),
                _buildOrderList(_belumDikonfirmList, status: 'belum dikonfirm'),
                _buildOrderList(_dimasakList, status: 'dimasak'),
                _buildOrderList(_diantarList, status: 'diantar'),
                _buildOrderList(_sampaiList, status: 'sampai'),
              ],
            ),
    );
  }

  Widget _buildOrderList(List<dynamic> orders, {String? status, bool showStatus = false}) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long,
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
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF4511E),
              ),
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
          final orderStatus = status ?? (order['status'] ?? 'belum dikonfirm');
          return _buildOrderCard(order, orderStatus, showStatus: showStatus);
        },
      ),
    );
  }

  Widget _buildOrderCard(dynamic order, String status, {bool showStatus = false}) {
    final orderId = order['id_pesan'] ?? 
                    order['id'] ?? 
                    order['order_id'] ?? 
                    order['id_order'] ?? 0;
    
    final namaStan = order['nama_stan'] ?? 
                     order['stan'] ?? 
                     'Stan Kantin';
    
    final tanggal = order['tanggal'] ?? 
                    order['created_at'] ?? 
                    order['date'] ?? 
                    '';
    
    var pesanan = _extractPesanan(order);
    
    List<Widget> itemWidgets = [];
    int calculatedTotal = 0;
    
    if (pesanan is List && pesanan.isNotEmpty) {
      for (var item in pesanan) {
        final idMenu = item['id_menu'] ?? 0;
        final qtyValue = item['qty'] ?? 1;
        final hargaBeli = item['harga_beli'] ?? item['harga'] ?? 0;
        
        int qty = 1;
        if (qtyValue is int) {
          qty = qtyValue;
        } else if (qtyValue is String) {
          qty = int.tryParse(qtyValue) ?? 1;
        }
        
        int itemHarga = 0;
        if (hargaBeli is int) {
          itemHarga = hargaBeli;
        } else if (hargaBeli is String) {
          itemHarga = int.tryParse(hargaBeli) ?? 0;
        }
        
        calculatedTotal += itemHarga * qty;
        
        itemWidgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Menu ID: $idMenu',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Text(
                  '$qty x Rp $itemHarga',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }
    
    int total = 0;
    final totalValue = order['total'] ?? 
                      order['total_harga'] ?? 
                      order['grand_total'] ?? 
                      0;
    
    if (totalValue is String) {
      total = int.tryParse(totalValue) ?? 0;
    } else if (totalValue is int) {
      total = totalValue;
    }
    
    if (total == 0 && calculatedTotal > 0) {
      total = calculatedTotal;
    }

    Color statusColor;
    IconData statusIcon;
    String statusText;
    
    switch (status) {
      case 'belum dikonfirm':
        statusColor = Colors.orange;
        statusIcon = Icons.hourglass_empty;
        statusText = 'Menunggu Konfirmasi';
        break;
      case 'dimasak':
        statusColor = Colors.blue;
        statusIcon = Icons.restaurant;
        statusText = 'Sedang Dimasak';
        break;
      case 'diantar':
        statusColor = Colors.purple;
        statusIcon = Icons.delivery_dining;
        statusText = 'Sedang Diantar';
        break;
      case 'sampai':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'Selesai';
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.info;
        statusText = status;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '#$orderId',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    if (showStatus) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            Icon(statusIcon, size: 14, color: statusColor),
                            const SizedBox(width: 4),
                            Text(
                              statusText,
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  tanggal,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Icon(Icons.store, size: 16, color: Colors.grey[700]),
                const SizedBox(width: 8),
                Text(
                  namaStan,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            
            const Divider(height: 20),

            if (!showStatus)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(statusIcon, size: 20, color: statusColor),
                    const SizedBox(width: 12),
                    Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            
            if (!showStatus) const SizedBox(height: 12),

            if (itemWidgets.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Detail Pesanan:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...itemWidgets,
                  ],
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Detail pesanan tidak tersedia',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),

            const Divider(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Pembayaran',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
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
          ],
        ),
      ),
    );
  }
}