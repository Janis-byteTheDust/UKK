// GANTI SELURUH ISI FILE: lib/services/cart_service.dart

class CartService {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  final List<Map<String, dynamic>> _cartItems = [];

  List<Map<String, dynamic>> get items => _cartItems;
  
  int get itemCount => _cartItems.length;
  
  int get totalItems {
    return _cartItems.fold(0, (sum, item) => sum + (item['qty'] as int));
  }

  void addToCart(Map<String, dynamic> menu) {
    print('🛒 Adding to cart: $menu');
    
    // Cek apakah item sudah ada di keranjang
    final existingIndex = _cartItems.indexWhere(
      (item) => item['id_menu'] == menu['id_menu'],
    );

    if (existingIndex >= 0) {
      // Tambah quantity jika sudah ada
      _cartItems[existingIndex]['qty']++;
      print('✅ Updated qty for item #${menu['id_menu']} to ${_cartItems[existingIndex]['qty']}');
    } else {
      // Pastikan harga adalah integer
      int harga = 0;
      if (menu['harga'] is int) {
        harga = menu['harga'];
      } else if (menu['harga'] is String) {
        harga = int.tryParse(menu['harga']) ?? 0;
      }

      // Tambah item baru dengan semua data yang diperlukan
      _cartItems.add({
        'id_menu': menu['id_menu'],
        'nama_makanan': menu['nama_makanan'] ?? 'Menu',
        'harga': harga,
        'qty': 1,
        'foto': menu['foto'],
        'id_stan': menu['id_stan'] ?? 1,
        'deskripsi': menu['deskripsi'] ?? '',
        'jenis': menu['jenis'] ?? 'makanan',
      });
      print('✅ Added new item to cart: ${menu['nama_makanan']} (ID: ${menu['id_menu']})');
    }
    
    print('📊 Cart now has ${_cartItems.length} unique items, ${totalItems} total items');
  }

  void updateQuantity(int index, int delta) {
    if (index < 0 || index >= _cartItems.length) return;
    
    _cartItems[index]['qty'] += delta;
    
    if (_cartItems[index]['qty'] <= 0) {
      print('🗑️ Removing item from cart: ${_cartItems[index]['nama_makanan']}');
      _cartItems.removeAt(index);
    } else {
      print('✏️ Updated qty for ${_cartItems[index]['nama_makanan']} to ${_cartItems[index]['qty']}');
    }
  }

  void removeItem(int index) {
    if (index < 0 || index >= _cartItems.length) return;
    print('🗑️ Removing item: ${_cartItems[index]['nama_makanan']}');
    _cartItems.removeAt(index);
  }

  void clear() {
    print('🧹 Clearing cart (${_cartItems.length} items)');
    _cartItems.clear();
  }

  int getTotalPrice() {
    final total = _cartItems.fold(
      0,
      (sum, item) {
        final harga = item['harga'] as int;
        final qty = item['qty'] as int;
        return sum + (harga * qty);
      },
    );
    print('💰 Total price: Rp $total');
    return total;
  }

  // Method untuk mendapatkan ID Stan dari item pertama
  int? getIdStan() {
    if (_cartItems.isEmpty) return null;
    return _cartItems.first['id_stan'] as int?;
  }

  // Method untuk mendapatkan data pesanan dalam format yang siap dikirim ke API
  // Format: List<Map<String, dynamic>> dengan struktur: [{"id_menu":1,"qty":2},{"id_menu":3,"qty":1}]
  List<Map<String, dynamic>> getPesananForAPI() {
    final pesananList = _cartItems.map((item) {
      return {
        'id_menu': item['id_menu'],
        'qty': item['qty'],
      };
    }).toList();
    
    print('📦 Pesanan List for API: $pesananList');
    return pesananList;
  }
}
