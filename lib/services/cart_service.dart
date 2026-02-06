// BUAT FILE BARU: lib/services/cart_service.dart

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
    // Cek apakah item sudah ada di keranjang
    final existingIndex = _cartItems.indexWhere(
      (item) => item['id_menu'] == menu['id_menu'],
    );

    if (existingIndex >= 0) {
      // Tambah quantity jika sudah ada
      _cartItems[existingIndex]['qty']++;
    } else {
      // Tambah item baru
      _cartItems.add({
        'id_menu': menu['id_menu'],
        'nama_makanan': menu['nama_makanan'],
        'harga': menu['harga'],
        'qty': 1,
        'foto': menu['foto'],
        'id_stan': menu['id_stan'] ?? 1,
      });
    }
  }

  void updateQuantity(int index, int delta) {
    if (index < 0 || index >= _cartItems.length) return;
    
    _cartItems[index]['qty'] += delta;
    if (_cartItems[index]['qty'] <= 0) {
      _cartItems.removeAt(index);
    }
  }

  void removeItem(int index) {
    if (index < 0 || index >= _cartItems.length) return;
    _cartItems.removeAt(index);
  }

  void clear() {
    _cartItems.clear();
  }

  int getTotalPrice() {
    return _cartItems.fold(
      0,
      (sum, item) => sum + (item['harga'] as int) * (item['qty'] as int),
    );
  }
}