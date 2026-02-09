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
    required String jenis,
    required int harga,
    required String deskripsi,
    File? foto,
  }) async {
    try {
      print('🔵 Calling tambahmenu API...');
      print('Token: ${token.substring(0, 20)}...');
      print('Data: nama_makanan=$namaMakanan, jenis=$jenis, harga=$harga');
      
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

      if (foto != null) {
        print('📷 Adding foto: ${foto.path}');
        request.files.add(
          await http.MultipartFile.fromPath('foto', foto.path),
        );
      } else {
        print('⚠️ No foto uploaded');
      }

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
        print('No token provided');
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

  // Get All Stan (untuk Siswa) - POST /get_all_stan
  static Future<Map<String, dynamic>> getAllStan({
    String search = '',
  }) async {
    try {
      print('🔵 Calling get_all_stan API...');
      print('Search: "$search"');
      
      final response = await http.post(
        Uri.parse('$baseUrl/get_all_stan'),
        headers: {
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

  // ==================== ORDER ENDPOINTS ====================

  // Create Order / Checkout - POST pesan
  // GANTI METHOD createOrder di lib/services/api_service.dart
// Cari bagian // Create Order / Checkout dan ganti dengan ini:

  // Create Order / Checkout - GET pesan
  static Future<Map<String, dynamic>> createOrder({
    required String token,
    required int idStan,
    required List<Map<String, dynamic>> pesan,
  }) async {
    try {
      print('🔵 Calling pesan (create order) API...');
      print('Token: ${token.substring(0, 20)}...');
      print('ID Stan: $idStan');
      print('Pesan (from cart): $pesan');
      
      // Format data - hanya id_menu dan qty
      final pesanCleaned = pesan.map((item) {
        return {
          'id_menu': item['id_menu'],
          'qty': item['qty'],
        };
      }).toList();
      
      print('Pesan (cleaned): $pesanCleaned');
      
      // Build request data
      final requestData = {
        'id_stan': idStan,
        'pesan': pesanCleaned,
      };
      
      // Encode JSON
      final jsonString = jsonEncode(requestData);
      print('📤 Request JSON: $jsonString');
      
      // PERBAIKAN: Gunakan GET dengan query parameter seperti dokumentasi
      final encodedData = Uri.encodeComponent(jsonString);
      final url = '$baseUrl/pesan?data=$encodedData';
      
      print('📡 Calling URL (GET): ${url.length > 150 ? url.substring(0, 150) + '...' : url}');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'makerID': '1',
          'Accept': 'application/json',
        },
      );

      print('📡 Status Code: ${response.statusCode}');
      print('📦 Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final data = jsonDecode(response.body);
          if (data['success'] == true || 
              data['status'] == 'success' ||
              data['message']?.toString().toLowerCase().contains('berhasil') == true) {
            return {
              'success': true,
              'message': data['message'] ?? 'Pesanan berhasil dibuat',
              'data': data['data'],
            };
          } else {
            return data;
          }
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
          print('⚠️ Error 400 Data: $errorData');
          
          String errorMessage = 'Validasi gagal';
          if (errorData is Map) {
            if (errorData['message'] != null) {
              errorMessage = errorData['message'].toString();
            } else if (errorData['errors'] != null) {
              final errors = errorData['errors'];
              if (errors is Map) {
                errorMessage = errors.values
                    .map((e) => e is List ? e.join(', ') : e.toString())
                    .join('; ');
              }
            }
          }
          
          return {
            'success': false,
            'message': errorMessage,
          };
        } catch (e) {
          return {
            'success': false,
            'message': 'Validasi gagal: ${response.body}',
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
    required String status,
  }) async {
    try {
      print('🔵 Calling getorder/$status API (Admin)...');
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

  // Show Order (untuk Siswa) - GET showorder/{status}
  static Future<Map<String, dynamic>> showOrder({
    required String token,
    required String status,
  }) async {
    try {
      print('🔵 Calling showorder/$status API (Siswa)...');
      print('Token: ${token.substring(0, 20)}...');
      print('Status: $status');
      
      final response = await http.get(
        Uri.parse('$baseUrl/showorder/$status'),
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
    required String status,
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