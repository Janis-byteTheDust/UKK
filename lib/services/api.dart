// GANTI SELURUH ISI FILE lib/services/api_service.dart dengan ini:

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';

class ApiService {
  static const String baseUrl = 'https://ukk-p2.smktelkom-mlg.sch.id/api';
  
  // ==================== AUTH ENDPOINTS ====================
  
  // Login Siswa
  static Future<Map<String, dynamic>> loginSiswa({
    required String username,
    required String password,
  }) async {
    try {
      print('🔵 Calling login_siswa API...');
      print('Username: $username');
      
      final response = await http.post(
        Uri.parse('$baseUrl/login_siswa'),
        headers: {
          'Content-Type': 'application/json',
          'makerID': '1',
        },
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      print('📡 Status Code: ${response.statusCode}');
      print('📦 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('❌ Error: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  // Login Stan
  static Future<Map<String, dynamic>> loginStan({
    required String username,
    required String password,
  }) async {
    try {
      print('🔵 Calling login_stan API...');
      print('Username: $username');
      
      final response = await http.post(
        Uri.parse('$baseUrl/login_stan'),
        headers: {
          'Content-Type': 'application/json',
          'makerID': '1',
        },
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      print('📡 Status Code: ${response.statusCode}');
      print('📦 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('❌ Error: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  // Register Siswa
  static Future<Map<String, dynamic>> registerSiswa({
    required String namaSiswa,
    required String alamat,
    required String telp,
    required String username,
    required String password,
    File? foto,
  }) async {
    try {
      print('🔵 Calling register_siswa API...');
      print('Data: nama_siswa=$namaSiswa, alamat=$alamat, telp=$telp, username=$username');
      
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/register_siswa'),
      );

      request.headers['makerID'] = '1';

      request.fields['nama_siswa'] = namaSiswa;
      request.fields['alamat'] = alamat;
      request.fields['telp'] = telp;
      request.fields['username'] = username;
      request.fields['password'] = password;

      print('📤 Fields: ${request.fields}');

      if (foto != null) {
        print('📷 Adding foto: ${foto.path}');
        request.files.add(
          await http.MultipartFile.fromPath('foto', foto.path),
        );
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print('📡 Status Code: ${response.statusCode}');
      print('📦 Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        return {
          'success': false,
          'message': 'Server error ${response.statusCode}: ${response.body}',
        };
      }
    } catch (e) {
      print('❌ Error: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  // Register Stan
  static Future<Map<String, dynamic>> registerStan({
    required String namaStan,
    required String namaPemilik,
    required String telp,
    required String username,
    required String password,
  }) async {
    try {
      print('🔵 Calling register_stan API...');
      print('Data: nama_stan=$namaStan, nama_pemilik=$namaPemilik, telp=$telp, username=$username');
      
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/register_stan'),
      );

      request.headers['makerID'] = '1';

      request.fields['nama_stan'] = namaStan;
      request.fields['nama_pemilik'] = namaPemilik;
      request.fields['telp'] = telp;
      request.fields['username'] = username;
      request.fields['password'] = password;

      print('📤 Fields: ${request.fields}');

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print('📡 Status Code: ${response.statusCode}');
      print('📦 Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        return {
          'success': false,
          'message': 'Server error ${response.statusCode}: ${response.body}',
        };
      }
    } catch (e) {
      print('❌ Error: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  // ==================== MENU ENDPOINTS ====================

  // Tambah Menu (Admin Stan) - POST /tambahmenu
  static Future<Map<String, dynamic>> tambahMenu({
    required String token,
    required String namaMakanan,
    required String jenis, // "makanan" atau "minuman"
    required int harga,
    required String deskripsi,
    File? foto,
  }) async {
    try {
      print('🔵 Calling tambahmenu API...');
      print('Token: ${token.substring(0, 20)}...');
      print('Data: nama_makanan=$namaMakanan, jenis=$jenis, harga=$harga');
      
      // Cek apakah ada foto (untuk web, foto akan null)
      if (foto != null) {
        // Pakai MultipartRequest (untuk mobile)
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('$baseUrl/tambahmenu'),
        );

        request.headers['Authorization'] = 'Bearer $token';
        request.headers['makerID'] = '1';

        request.fields['nama_makanan'] = namaMakanan;
        request.fields['jenis'] = jenis;
        request.fields['harga'] = harga.toString();
        request.fields['deskripsi'] = deskripsi;

        print('📤 Fields: ${request.fields}');
        print('📷 Adding foto: ${foto.path}');
        
        request.files.add(
          await http.MultipartFile.fromPath('foto', foto.path),
        );

        var streamedResponse = await request.send();
        var response = await http.Response.fromStream(streamedResponse);

        print('📡 Status Code: ${response.statusCode}');
        print('📦 Response Body: ${response.body}');

        if (response.statusCode == 200 || response.statusCode == 201) {
          return jsonDecode(response.body);
        } else {
          return {
            'success': false,
            'message': 'Server error ${response.statusCode}: ${response.body}',
          };
        }
      } else {
        // Tanpa foto (untuk web atau jika tidak upload foto)
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('$baseUrl/tambahmenu'),
        );

        request.headers['Authorization'] = 'Bearer $token';
        request.headers['makerID'] = '1';

        request.fields['nama_makanan'] = namaMakanan;
        request.fields['jenis'] = jenis;
        request.fields['harga'] = harga.toString();
        request.fields['deskripsi'] = deskripsi;

        print('📤 Fields: ${request.fields}');
        print('⚠️ No foto uploaded');

        var streamedResponse = await request.send();
        var response = await http.Response.fromStream(streamedResponse);

        print('📡 Status Code: ${response.statusCode}');
        print('📦 Response Body: ${response.body}');

        if (response.statusCode == 200 || response.statusCode == 201) {
          return jsonDecode(response.body);
        } else {
          return {
            'success': false,
            'message': 'Server error ${response.statusCode}: ${response.body}',
          };
        }
      }
    } catch (e) {
      print('❌ Error: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  // Show Menu - POST /showmenu (untuk Admin Stan ONLY)
  static Future<Map<String, dynamic>> showMenu({
    String? token,
  }) async {
    try {
      print('🔵 Calling showmenu API...');
      if (token != null && token.isNotEmpty) {
        try {
          print('Token: ${token.substring(0, 20)}...');
        } catch (_) {
          print('Token present');
        }
      } else {
        print('No token provided; calling showmenu without Authorization');
      }
      
      final headers = {
        'makerID': '1',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.post(
        Uri.parse('$baseUrl/showmenu'),
        headers: headers,
      );

      print('📡 Status Code: ${response.statusCode}');
      print('📦 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Token tidak valid atau expired. Silakan login ulang.',
          'data': [],
        };
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
          'data': [],
        };
      }
    } catch (e) {
      print('❌ Error: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
        'data': [],
      };
    }
  }

  // ==================== MENU SISWA ENDPOINTS ====================

  // Get Menu Food (untuk Siswa) - POST /getmenufood
  static Future<Map<String, dynamic>> getMenuFood({
    required String token,
    String search = '',
  }) async {
    try {
      print('🔵 Calling getmenufood API...');
      print('Token: ${token.substring(0, 20)}...');
      print('Search: "$search"');
      
      final response = await http.post(
        Uri.parse('$baseUrl/getmenufood'),
        headers: {
          'Authorization': 'Bearer $token',
          'makerID': '1',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'search': search,
        },
      );

      print('📡 Status Code: ${response.statusCode}');
      print('📦 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Token tidak valid atau expired. Silakan login ulang.',
          'data': [],
        };
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
          'data': [],
        };
      }
    } catch (e) {
      print('❌ Error: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
        'data': [],
      };
    }
  }

  // Get Menu Drink (untuk Siswa) - POST /getmenudrink
  static Future<Map<String, dynamic>> getMenuDrink({
    required String token,
    String search = '',
  }) async {
    try {
      print('🔵 Calling getmenudrink API...');
      print('Token: ${token.substring(0, 20)}...');
      print('Search: "$search"');
      
      final response = await http.post(
        Uri.parse('$baseUrl/getmenudrink'),
        headers: {
          'Authorization': 'Bearer $token',
          'makerID': '1',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'search': search,
        },
      );

      print('📡 Status Code: ${response.statusCode}');
      print('📦 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Token tidak valid atau expired. Silakan login ulang.',
          'data': [],
        };
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
          'data': [],
        };
      }
    } catch (e) {
      print('❌ Error: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
        'data': [],
      };
    }
  }

  // Get Menu/Pesan - GET /pesan (DEPRECATED - gunakan showMenu)
  static Future<Map<String, dynamic>> getPesan({
    required String token,
  }) async {
    // Redirect ke showMenu
    return showMenu(token: token);
  }

  // Get Menu untuk Admin (alternative endpoint jika ada)
  static Future<Map<String, dynamic>> getMenuAdmin({
    required String token,
  }) async {
    try {
      print('🔵 Calling menu admin API...');
      print('Token: ${token.substring(0, 20)}...');
      
      // Coba beberapa kemungkinan endpoint
      final endpoints = ['menu', 'admin/menu', 'stan/menu', 'getmenu'];
      
      for (var endpoint in endpoints) {
        print('🔄 Trying endpoint: $endpoint');
        
        final response = await http.get(
          Uri.parse('$baseUrl/$endpoint'),
          headers: {
            'Authorization': 'Bearer $token',
            'makerID': '1',
            'Accept': 'application/json',
          },
        );

        print('📡 Status Code: ${response.statusCode} for $endpoint');

        if (response.statusCode == 200) {
          print('✅ Success with endpoint: $endpoint');
          print('📦 Response Body: ${response.body}');
          return jsonDecode(response.body);
        }
      }

      // Kalau semua gagal
      return {
        'success': false,
        'message': 'Tidak ada endpoint yang valid',
        'data': [],
      };
    } catch (e) {
      print('❌ Error: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
        'data': [],
      };
    }
  }

  // ==================== ORDER ENDPOINTS ====================

  // Create Order / Checkout - GET pesan dengan JSON body
  static Future<Map<String, dynamic>> createOrder({
    required String token,
    required int idStan,
    required List<Map<String, dynamic>> pesan, // [{id_menu: 3, qty: 1}]
  }) async {
    try {
      print('🔵 Calling pesan (create order) API...');
      print('Token: ${token.substring(0, 20)}...');
      print('ID Stan: $idStan');
      print('Pesan: $pesan');
      
      // Build request body sebagai JSON
      final requestBody = {
        'id_stan': idStan,
        'pesan': pesan,
      };
      
      final jsonBody = jsonEncode(requestBody);
      print('📤 Request Body (JSON): $jsonBody');
      
      // GET request dengan JSON body menggunakan Request object
      // Karena http.get() tidak support body, kita buat custom request
      final request = http.Request('GET', Uri.parse('$baseUrl/pesan'));
      
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'makerID': '1',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      });
      
      request.body = jsonBody;
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('📡 Status Code: ${response.statusCode}');
      print('📦 Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final data = jsonDecode(response.body);
          return data;
        } catch (e) {
          print('⚠️ Response is not JSON: ${response.body}');
          return {
            'success': true,
            'message': 'Pesanan berhasil dibuat',
          };
        }
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Token tidak valid atau expired. Silakan login ulang.',
        };
      } else if (response.statusCode == 400) {
        try {
          final errorData = jsonDecode(response.body);
          print('❌ Validation Error: $errorData');
          return {
            'success': false,
            'message': 'Validasi gagal: ${errorData.toString()}',
          };
        } catch (e) {
          return {
            'success': false,
            'message': 'Server error 400: ${response.body}',
          };
        }
      } else {
        return {
          'success': false,
          'message': 'Server error ${response.statusCode}: ${response.body}',
        };
      }
    } catch (e, stackTrace) {
      print('❌ Error: $e');
      print('Stack trace: $stackTrace');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  // Get Order by Status (untuk Admin Stan) - GET getorder/{status}
  static Future<Map<String, dynamic>> getOrderByStatus({
    required String token,
    required String status, // dimasak, diantar, sampai, belum dikonfirm
  }) async {
    try {
      print('🔵 Calling getorder/$status API...');
      print('Token: ${token.substring(0, 20)}...');
      print('Status: $status');
      
      final response = await http.get(
        Uri.parse('$baseUrl/getorder/$status'),
        headers: {
          'Authorization': 'Bearer $token',
          'makerID': '1',
          'Accept': 'application/json',
        },
      );

      print('📡 Status Code: ${response.statusCode}');
      print('📦 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Token tidak valid atau expired. Silakan login ulang.',
          'data': [],
        };
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
          'data': [],
        };
      }
    } catch (e) {
      print('❌ Error: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
        'data': [],
      };
    }
  }

  // Update Order Status (untuk Admin Stan) - PUT updatestatus/{id}
  static Future<Map<String, dynamic>> updateOrderStatus({
    required String token,
    required int orderId,
    required String status, // belum dikonfirm, dimasak, diantar, sampai
  }) async {
    try {
      print('🔵 Calling updatestatus/$orderId API...');
      print('Token: ${token.substring(0, 20)}...');
      print('New Status: $status');
      
      final response = await http.put(
        Uri.parse('$baseUrl/updatestatus/$orderId'),
        headers: {
          'Authorization': 'Bearer $token',
          'makerID': '1',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'status': status,
        },
      );

      print('📡 Status Code: ${response.statusCode}');
      print('📦 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Token tidak valid atau expired. Silakan login ulang.',
        };
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('❌ Error: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }
}