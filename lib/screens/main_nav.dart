import 'package:flutter/material.dart';
import '../core/constants.dart';
import 'home_screen.dart';
import 'my_list_screen.dart';
import 'profile_screen.dart';

class MainNav extends StatefulWidget {
  // KODE BARU: Menambahkan parameter initialIndex
  final int initialIndex;

  const MainNav({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  _MainNavState createState() => _MainNavState();
}

class _MainNavState extends State<MainNav> {
  late int _currentIndex; // KODE BARU: Menggunakan 'late' agar bisa diatur di initState
  int _myListInitialTab = 0; 
  bool _isFromProfile = false; 

  @override
  void initState() {
    super.initState();
    // KODE BARU: Mengatur tab awal berdasarkan parameter dari luar
    _currentIndex = widget.initialIndex; 
  }

  void _navigateToListFromProfile(int tabIndex) {
    setState(() {
      _currentIndex = 1; 
      _myListInitialTab = tabIndex;
      _isFromProfile = true; 
    });
  }

  void _backToProfile() {
    setState(() {
      _currentIndex = 2; 
      _isFromProfile = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomeScreen(
        onNavigateToProfile: () {
          setState(() {
            _currentIndex = 2; 
            _isFromProfile = false;
          });
        },
      ),
      MyListScreen(
        initialIndex: _myListInitialTab,
        onBackToProfile: _isFromProfile ? _backToProfile : null,
      ),
      ProfileScreen(onNavigateToList: _navigateToListFromProfile),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.cardDark,
        currentIndex: _currentIndex,
        selectedItemColor: AppColors.primaryRed,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            _isFromProfile = false; 
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