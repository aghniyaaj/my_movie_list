import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../models/movie_model.dart';
import '../services/firebase_service.dart';
import 'detail_screen.dart';

class MyListScreen extends StatelessWidget {
  final int initialIndex;
  final VoidCallback? onBackToProfile;
  
  const MyListScreen({
    Key? key, 
    this.initialIndex = 0, 
    this.onBackToProfile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: initialIndex,
      child: Scaffold(
        backgroundColor: AppColors.bgDark,
        appBar: AppBar(
          backgroundColor: AppColors.bgDark,
          elevation: 0,
          // Tombol back HANYA muncul jika dipanggil dari halaman Profile
          leading: onBackToProfile != null
              ? IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: onBackToProfile,
                )
              : null,
          title: const Text('Daftar Saya', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          bottom: const TabBar(
            indicatorColor: AppColors.primaryRed,
            labelColor: AppColors.primaryRed,
            unselectedLabelColor: AppColors.textGrey,
            tabs: [Tab(text: 'Wishlist (Koleksi)'), Tab(text: 'Watched (Sudah Ditonton)')],
          ),
        ),
        body: const TabBarView(
          children: [
            _MovieListBuilder(listType: 'wishlist'),
            _MovieListBuilder(listType: 'watched'),
          ],
        ),
      ),
    );
  }
}

class _MovieListBuilder extends StatelessWidget {
  final String listType;
  const _MovieListBuilder({required this.listType});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Movie>>(
      stream: FirebaseService().getSavedMovies(listType),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("Belum ada film yang disimpan.", style: TextStyle(color: AppColors.textGrey)));
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, 
            childAspectRatio: 0.65, 
            crossAxisSpacing: 16, 
            mainAxisSpacing: 16
          ),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final movie = snapshot.data![index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => DetailScreen(movie: movie)),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12), 
                      image: DecorationImage(
                        image: NetworkImage(AppConstants.tmdbImageBaseUrl + movie.posterPath), 
                        fit: BoxFit.cover
                      )
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        movie.title, 
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14), 
                        overflow: TextOverflow.ellipsis
                      )
                    ),
                    GestureDetector(
                      onTap: () => FirebaseService().toggleMovie(movie, listType),
                      child: const Icon(Icons.delete_outline, color: AppColors.textGrey, size: 18),
                    ),
                  ],
                )
              ],
            ),
          );
          },
        );
      },
    );
  }
}