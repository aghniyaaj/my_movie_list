import 'package:flutter/material.dart';
import '../core/constants.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgDark,
        elevation: 0,
        title: const Text('Pusat Bantuan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text('Ada yang bisa kami bantu hari ini?', style: TextStyle(color: AppColors.textGrey, fontSize: 14)),
            const SizedBox(height: 24),
            
            _buildFaqItem('Bagaimana cara menambahkan film ke Wishlist?', 'Anda dapat menekan tombol Wishlist di halaman detail film. Jika sudah login, data akan tersimpan ke koleksi Anda.'),
            _buildFaqItem('Apakah saya bisa mengubah ulasan film?', "Ya, Anda bisa mengubah ulasan dengan memperbarui jumlah bintang dan teks ulasan, lalu menekan tombol Kirim lagi."),
            _buildFaqItem('Bagaimana cara mengganti kata sandi?', 'Masuk ke menu Profil > Edit Profil, lalu isi kolom Ganti Password dan tekan Simpan Perubahan.'),
            
            const SizedBox(height: 32),
            const Text('Masih butuh bantuan?', style: TextStyle(color: AppColors.textGrey)),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fitur Customer Service sedang dalam pengembangan')));
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primaryRed),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Hubungi Customer Service', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildFaqItem(String title, String content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: AppColors.primaryRed,
          collapsedIconColor: AppColors.textGrey,
          title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: Text(content, style: const TextStyle(color: AppColors.textGrey, fontSize: 13, height: 1.5)),
            )
          ],
        ),
      ),
    );
  }
}
