import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../services/firebase_service.dart';
import '../main_nav.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _isLoading = false;
  
  // 1. TAMBAH VARIABEL INI UNTUK VISIBILITAS PASSWORD
  bool _isObscure = true;

  void _register() async {
    setState(() => _isLoading = true);
    try {
      await FirebaseService().register(_emailCtrl.text.trim(), _passCtrl.text.trim(), _nameCtrl.text.trim());
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => MainNav()), (route) => false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Daftar Gagal: $e')));
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('My Movie List', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            
            _buildTextField('Nama Pengguna', 'Masukkan Nama Anda', _nameCtrl, false),
            const SizedBox(height: 20),
            _buildTextField('Email', 'Masukkan Email Anda', _emailCtrl, false),
            const SizedBox(height: 20),
            _buildTextField('Password', 'Buat Kata Sandi Anda', _passCtrl, true),
            
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _isLoading ? null : _register,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryRed, padding: const EdgeInsets.symmetric(vertical: 16)),
              child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('DAFTAR AKUN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 20),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Sudah punya akun? ', style: TextStyle(color: AppColors.textGrey)),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Text('Masuk', style: TextStyle(color: AppColors.primaryRed, fontWeight: FontWeight.bold)),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  // 2. UBAH FUNGSI INI
  Widget _buildTextField(String label, String hint, TextEditingController ctrl, bool isPass) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textGrey)),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          // Ubah obscureText agar bergantung pada _isObscure
          obscureText: isPass ? _isObscure : false,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade600),
            filled: true,
            fillColor: AppColors.cardDark,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            // Ubah Icon menjadi IconButton agar bisa diklik
            suffixIcon: isPass 
                ? IconButton(
                    icon: Icon(
                      _isObscure ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _isObscure = !_isObscure; // Membalik status saat diklik
                      });
                    },
                  ) 
                : null,
          ),
        ),
      ],
    );
  }
}