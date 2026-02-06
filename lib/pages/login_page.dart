// GANTI SELURUH ISI FILE lib/pages/login_page.dart dengan ini:

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ukkkantin/services/api.dart';
import 'dart:convert';

import 'dashboard_siswa_page.dart';
import 'dashboard_stan_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String _selectedRole = 'siswa';

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      Map<String, dynamic> result;

      // Pastikan role yang dipilih benar
      print('🔑 Login sebagai: $_selectedRole');

      if (_selectedRole == 'siswa') {
        result = await ApiService.loginSiswa(
          username: _usernameController.text.trim(),
          password: _passwordController.text,
        );
      } else {
        result = await ApiService.loginStan(
          username: _usernameController.text.trim(),
          password: _passwordController.text,
        );
      }

      print('✅ Result: $result');

      // Cek login berhasil: ada access_token atau user
      bool isSuccess = result['access_token'] != null || 
                       result['user'] != null ||
                       result['success'] == true || 
                       result['status'] == true;

      if (isSuccess) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('role', _selectedRole);
        await prefs.setString('username', _usernameController.text.trim());
        
        // Simpan token jika ada
        if (result['access_token'] != null) {
          await prefs.setString('access_token', result['access_token']);
        }
        
        // Simpan user data
        if (result['user'] != null) {
          await prefs.setString('user_data', jsonEncode(result['user']));
          await prefs.setString('user_id', result['user']['id'].toString());
        }

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login berhasil!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Delay sedikit supaya snackbar keliatan
        await Future.delayed(const Duration(milliseconds: 500));

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => _selectedRole == 'siswa'
                ? const DashboardSiswaPage()
                : const DashboardStanPage(),
          ),
        );
      } else {
        if (!mounted) return;
        
        String errorMessage = result['message'] ?? 
                             result['error'] ?? 
                             result['msg'] ?? 
                             'Username atau password salah';
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      print('❌ Exception: $e');
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFB8C00),
              Color(0xFFF4511E),
              Color(0xFFE91E63),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Back button
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        
                        const Text(
                          'Masuk',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 30),
                        
                        // Role Selector
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() => _selectedRole = 'siswa');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _selectedRole == 'siswa'
                                      ? const Color(0xFFF4511E)
                                      : Colors.grey[300],
                                  foregroundColor: _selectedRole == 'siswa'
                                      ? Colors.white
                                      : Colors.black54,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text('Siswa'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() => _selectedRole = 'stan');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _selectedRole == 'stan'
                                      ? const Color(0xFFF4511E)
                                      : Colors.grey[300],
                                  foregroundColor: _selectedRole == 'stan'
                                      ? Colors.white
                                      : Colors.black54,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text('Admin Stan'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        
                        // Username Field
                        TextFormField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            labelText: 'Username',
                            prefixIcon: const Icon(Icons.person_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Username harus diisi';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        
                        // Password Field
                        TextFormField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password harus diisi';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 30),
                        
                        // Login Button
                        SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF4511E),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text(
                                    'Masuk',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}