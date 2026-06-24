import 'package:flutter/material.dart';
import '../core/constants.dart';
import 'home_screen.dart';
import 'my_list_screen.dart';
import 'profile_screen.dart';

class MainNav extends StatefulWidget {
  final int initialIndex;
  const MainNav({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  _MainNavState createState() => _MainNavState();
}

class _MainNavState extends State<MainNav> {
  late int _currentIndex;
  int _myListInitialTab = 0; 
  bool _isFromProfile = false; // Tanda apakah kita masuk ke List dari Profile

  // Fungsi untuk pindah ke My List dari Profile
  void _navigateToListFromProfile(int tabIndex) {
    setState(() {
      _currentIndex = 1; // Index 1 adalah My List
      _myListInitialTab = tabIndex;
      _isFromProfile = true; // Munculkan tombol back khusus
    });
  }

  // Fungsi untuk tombol back khusus di My List agar balik ke Profile
  void _backToProfile() {
    setState(() {
      _currentIndex = 2; // Index 2 adalah Profile
      _isFromProfile = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    // Daftar layar yang ditampilkan
    final List<Widget> screens = [
      HomeScreen(),
      // Halaman My List menerima data tab awal & fungsi back
      MyListScreen(
        initialIndex: _myListInitialTab,
        onBackToProfile: _isFromProfile ? _backToProfile : null,
      ),
      // Halaman Profile menerima fungsi untuk melompat ke List
      ProfileScreen(onNavigateToList: _navigateToListFromProfile),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.bgDark,
        currentIndex: _currentIndex,
        selectedItemColor: AppColors.primaryRed,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            _isFromProfile = false; // Reset tombol back jika pindah manual dari bawah
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: 'My List'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}