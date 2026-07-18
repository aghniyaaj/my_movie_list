import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import '../core/constants.dart';
import '../services/firebase_service.dart';
import '../services/imgbb_service.dart'; 
import 'auth/login_screen.dart';
import 'review_history_screen.dart';
import 'help_center_screen.dart';

class ProfileScreen extends StatefulWidget {
  final Function(int) onNavigateToList;
  
  const ProfileScreen({Key? key, required this.onNavigateToList}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? user;
  int watchedCount = 0;
  int wishlistCount = 0;

  @override
  void initState() {
    super.initState();
    _initializeUserAndData();
  }

  void _initializeUserAndData() {
    try {
      user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final db = FirebaseFirestore.instance;
        
        db.collection('users').doc(user!.uid).collection('watched').snapshots().listen(
          (snap) {
            if (mounted) setState(() => watchedCount = snap.docs.length);
          },
          onError: (e) => debugPrint("Error Watched: $e"),
        );
        
        db.collection('users').doc(user!.uid).collection('wishlist').snapshots().listen(
          (snap) {
            if (mounted) setState(() => wishlistCount = snap.docs.length);
          },
          onError: (e) => debugPrint("Error Wishlist: $e"),
        );
      }
    } catch (e) {
      debugPrint("Error inisialisasi profil: $e");
    }
  }

  // Fungsi Pembantu untuk mendapatkan Inisial Nama
  String _getInitials() {
    String initial = 'U';
    String email = user?.email ?? '';
    if (user != null) {
      if (user!.displayName != null && user!.displayName!.trim().isNotEmpty) {
        String displayName = user!.displayName!.trim();
        initial = displayName.length >= 2 ? displayName.substring(0, 2).toUpperCase() : displayName.toUpperCase();
      } else if (email.length >= 2) {
        initial = email.substring(0, 2).toUpperCase();
      }
    }
    return initial;
  }

  // POP-UP EDIT PROFIL SESUAI FIGMA (BOTTOM SHEET)
  void _showEditProfileBottomSheet() {
    final TextEditingController nameCtrl = TextEditingController(text: user?.displayName ?? '');
    final TextEditingController emailCtrl = TextEditingController(text: user?.email ?? '');
    final TextEditingController passwordCtrl = TextEditingController();
    
    bool isUpdating = false;
    // 1. TAMBAH VARIABEL INI UNTUK VISIBILITAS PASSWORD DI POP-UP
    bool isObscure = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, 
      backgroundColor: AppColors.cardDark,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateSheet) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24, right: 24, top: 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle Bar
                    Container(
                      width: 40, height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(color: AppColors.textGrey, borderRadius: BorderRadius.circular(2)),
                    ),
                    
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 24),
                        const Text('Edit Profil', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(color: AppColors.bgDark, shape: BoxShape.circle),
                            child: const Icon(Icons.close, color: AppColors.textGrey, size: 16),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Foto Profil dengan Ikon Kamera
                    GestureDetector(
                      onTap: () async {
                        final picker = ImagePicker();
                        final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                        if (image != null) {
                          setStateSheet(() => isUpdating = true);
                          try {
                            String? imageUrl = await ImgbbService.uploadImage(image);
                            
                            if (imageUrl != null) {
                              await user?.updatePhotoURL(imageUrl);

                              // Update juga foto profil di semua review sebelumnya
                              try {
                                final watchedSnap = await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(user!.uid)
                                    .collection('watched')
                                    .get();
                                
                                for (var movieDoc in watchedSnap.docs) {
                                  String movieId = movieDoc.id;
                                  final reviewSnap = await FirebaseFirestore.instance
                                      .collection('movies')
                                      .doc(movieId)
                                      .collection('reviews')
                                      .where('userId', isEqualTo: user!.uid)
                                      .get();
                                      
                                  for (var reviewDoc in reviewSnap.docs) {
                                    await reviewDoc.reference.update({'userPic': imageUrl});
                                  }
                                }
                              } catch (e) {
                                debugPrint("Error update userPic di reviews: $e");
                              }

                              await user?.reload();
                              user = FirebaseAuth.instance.currentUser;
                              
                              setState(() {}); 
                              setStateSheet(() {}); 
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Foto profil berhasil diperbarui!')));
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal mendapatkan link dari ImgBB.')));
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                          }
                          setStateSheet(() => isUpdating = false);
                        }
                      },
                      child: Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.primaryRed, width: 2)),
                            child: CircleAvatar(
                              radius: 40,
                              backgroundColor: AppColors.bgDark,
                              backgroundImage: user?.photoURL != null ? NetworkImage('https://wsrv.nl/?url=${user!.photoURL!}') : null,
                              child: user?.photoURL == null 
                                ? Text(_getInitials(), style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold))
                                : null,
                            ),
                          ),
                          Positioned(
                            bottom: 0, right: 0,
                            child: CircleAvatar(
                              radius: 14, backgroundColor: AppColors.primaryRed,
                              child: const Icon(Icons.camera_alt, color: Colors.white, size: 14),
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    _buildDialogTextField('Nama Lengkap', nameCtrl, false),
                    const SizedBox(height: 16),
                    _buildDialogTextField('Email (Tidak bisa diubah)', emailCtrl, false, enabled: false),
                    const SizedBox(height: 16),
                    
                    // 2. UBAH PEMANGGILAN FIELD PASSWORD
                    _buildDialogTextField(
                      'Ganti Password (Kosongkan jika tidak)', 
                      passwordCtrl, 
                      true, 
                      isObscure: isObscure,
                      onToggleVisibility: () {
                        setStateSheet(() {
                          isObscure = !isObscure;
                        });
                      }
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Tombol Simpan Perubahan
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isUpdating ? null : () async {
                          setStateSheet(() => isUpdating = true);
                          try {
                            if (nameCtrl.text.trim() != user?.displayName) {
                              String newName = nameCtrl.text.trim();
                              await user?.updateDisplayName(newName);
                              
                              // Update juga username di semua review sebelumnya
                              try {
                                final watchedSnap = await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(user!.uid)
                                    .collection('watched')
                                    .get();
                                
                                for (var movieDoc in watchedSnap.docs) {
                                  String movieId = movieDoc.id;
                                  final reviewSnap = await FirebaseFirestore.instance
                                      .collection('movies')
                                      .doc(movieId)
                                      .collection('reviews')
                                      .where('userId', isEqualTo: user!.uid)
                                      .get();
                                      
                                  for (var reviewDoc in reviewSnap.docs) {
                                    await reviewDoc.reference.update({'userName': newName});
                                  }
                                }
                              } catch (e) {
                                debugPrint("Error update username di reviews: $e");
                              }
                            }
                            if (passwordCtrl.text.isNotEmpty) {
                              await user?.updatePassword(passwordCtrl.text);
                            }
                            
                            await user?.reload();
                            user = FirebaseAuth.instance.currentUser;
                            
                            setState(() {});
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil berhasil diperbarui!')));
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e. Coba login ulang jika error password.')));
                          }
                          setStateSheet(() => isUpdating = false);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryRed,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: isUpdating 
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('Simpan Perubahan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            );
          }
        );
      }
    );
  }

  // 3. UBAH FUNGSI BUILD FIELD AGAR MENDUKUNG TOMBOL MATA
  Widget _buildDialogTextField(
    String label, 
    TextEditingController controller, 
    bool isPassword, {
    bool enabled = true,
    bool isObscure = false,
    VoidCallback? onToggleVisibility,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textGrey, fontSize: 12)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: isPassword ? isObscure : false,
          enabled: enabled,
          style: TextStyle(color: enabled ? Colors.white : AppColors.textGrey, fontSize: 14),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.bgDark,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            suffixIcon: isPassword 
                ? IconButton(
                    icon: Icon(
                      isObscure ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: onToggleVisibility,
                  )
                : null,
          ),
        ),
      ],
    );
  }

  void _showLogoutConfirm() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.cardDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Column(
            children: [
              Icon(Icons.exit_to_app, color: AppColors.primaryRed, size: 32),
              SizedBox(height: 12),
              Text('Keluar Akun?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
          content: const Text(
            'Apakah Anda yakin ingin keluar dari aplikasi? Anda harus login kembali untuk mengakses daftar film Anda.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textGrey, fontSize: 14),
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.textGrey),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Batal', style: TextStyle(color: Colors.white)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context); 
                try {
                  await FirebaseService().logout(); 
                  if (mounted) {
                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => LoginScreen()), (route) => false);
                  }
                } catch (e) {
                  debugPrint("Gagal logout: $e");
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryRed,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Ya, Keluar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    try {
      String initial = _getInitials();
      String displayName = 'Pengguna';
      String email = 'Tidak ada email';

      if (user != null) {
        email = user!.email ?? email;
        if (user!.displayName != null && user!.displayName!.trim().isNotEmpty) {
          displayName = user!.displayName!.trim();
        }
      }

      return Scaffold(
        backgroundColor: AppColors.bgDark,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Profil Saya', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 32),

                  // Foto Profil Utama
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.primaryRed, width: 2)),
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: AppColors.cardDark,
                      backgroundImage: user?.photoURL != null ? NetworkImage('https://wsrv.nl/?url=${user!.photoURL!}') : null,
                      child: user?.photoURL == null 
                        ? Text(initial, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold))
                        : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(displayName, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(email, style: const TextStyle(color: AppColors.textGrey, fontSize: 14)),
                  const SizedBox(height: 32),

                  // Box Statistik Film
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(color: AppColors.cardDark, borderRadius: BorderRadius.circular(16)),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => widget.onNavigateToList(1), 
                            child: Column(
                              children: [
                                Text(watchedCount.toString(), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                const Text('Film Ditonton', style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
                              ],
                            ),
                          ),
                        ),
                        Container(width: 1, height: 40, color: Colors.grey.shade800),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => widget.onNavigateToList(0), 
                            child: Column(
                              children: [
                                Text(wishlistCount.toString(), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                const Text('Wishlist', style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Menu Tambahan
                  _buildMenuOption(Icons.person_outline, 'Edit Profil', _showEditProfileBottomSheet),
                  _buildMenuOption(Icons.chat_bubble_outline, 'Riwayat Ulasan', () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ReviewHistoryScreen()));
                  }),
                  _buildMenuOption(Icons.help_outline, 'Pusat Bantuan', () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpCenterScreen()));
                  }),
                  
                  const SizedBox(height: 24),
                  
                  // Tombol Keluar Akun
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _showLogoutConfirm,
                      icon: const Icon(Icons.logout, color: Colors.white, size: 20),
                      label: const Text('Keluar Akun', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryRed,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } catch (e) {
      return Scaffold(
        backgroundColor: AppColors.bgDark,
        body: Center(child: Text('Error: $e', style: const TextStyle(color: Colors.red))),
      );
    }
  }

  Widget _buildMenuOption(IconData icon, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(color: const Color.fromRGBO(31, 38, 51, 1), borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textGrey, size: 20),
            const SizedBox(width: 16),
            Expanded(child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 14))),
            const Icon(Icons.chevron_right, color: AppColors.textGrey),
          ],
        ),
      ),
    );
  }
}