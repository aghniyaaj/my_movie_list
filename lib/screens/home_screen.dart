import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/constants.dart';
import '../models/movie_model.dart';
import '../services/api_service.dart';
import 'detail_screen.dart';
import 'trending_screen.dart'; 
import 'search_screen.dart';
import 'package:url_launcher/url_launcher.dart'; 

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _api = ApiService();
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    // Ambil inisial nama biar foto profilnya keren (bukan sekadar KS terus)
    String initial = 'KS';
    if (user?.displayName != null && user!.displayName!.trim().isNotEmpty) {
      String name = user!.displayName!.trim();
      initial = name.length >= 2 ? name.substring(0, 2).toUpperCase() : name.toUpperCase();
    } else if (user?.email != null && user!.email!.length >= 2) {
      initial = user!.email!.substring(0, 2).toUpperCase();
    }

    // Di sini KITA TIDAK PAKAI BottomNavigationBar karena sudah diurus main_nav.dart
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header (Logo & Profil)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('M', style: TextStyle(color: AppColors.primaryRed, fontSize: 24, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
                    CircleAvatar(
                      backgroundColor: AppColors.cardDark, 
                      child: Text(initial, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text('Halo Petualang Film!', style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
                const Text('Temukan Tontonanmu', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                
                // Search Bar
                GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen()));
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.cardDark,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.search, color: AppColors.primaryRed),
                        SizedBox(width: 10),
                        Text('Cari film atau genre favoritmu...', style: TextStyle(color: AppColors.textGrey, fontSize: 14)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Mulai Menampilkan Data Film
                FutureBuilder<List<List<Movie>>>(
                  future: Future.wait([_api.getTrendingMovies(), _api.getPopularMovies()]),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: AppColors.primaryRed));
                    }
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red));
                    }

                    final trending = snapshot.data![0];
                    final popular = snapshot.data![1];
                    final featured = trending.isNotEmpty ? trending[0] : null;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. Film Unggulan (Featured) Paling Atas
                        if (featured != null) GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetailScreen(movie: featured))),
                          child: Container(
                            height: 270, width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              image: DecorationImage(
                                image: NetworkImage(AppConstants.tmdbImageBaseUrl + featured.backdropPath), 
                                fit: BoxFit.cover, 
                                colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.darken)
                              ),
                            ),
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), 
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryRed,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Text('FEATURED', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))
                                    ),
                                    const SizedBox(width: 12),
                                    const Icon(Icons.star, color: Colors.amber, size: 14),
                                    const SizedBox(width: 4),
                                    Text(featured.voteAverage.toStringAsFixed(1), style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(featured.title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                                Text(featured.overview, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: () async {
                                      final trailerKey = await _api.getMovieTrailer(featured.id);
                                      if (trailerKey != null) {
                                        final url = Uri.parse('https://www.youtube.com/watch?v=$trailerKey');
                                        if (await canLaunchUrl(url)) {
                                          await launchUrl(url, mode: LaunchMode.externalApplication);
                                        } else {
                                          if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tidak bisa membuka trailer')));
                                        }
                                      } else {
                                        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Trailer tidak ditemukan')));
                                      }
                                    },
                                    icon: const Icon(Icons.play_arrow, color: AppColors.primaryRed),
                                    label: const Text('Watch Trailer', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.black.withOpacity(0.5),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                        side: const BorderSide(color: AppColors.primaryRed),
                                      ),
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // 2. Teks "Sedang Tren" & Tombol "Lihat Semua"
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Sedang Tren', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                            
                            // INI TOMBOL LIHAT SEMUA YANG SUDAH DIPERBAIKI (BISA DIKLIK)
                            GestureDetector(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const TrendingScreen()));
                              },
                              child: const Text('Lihat Semua', style: TextStyle(color: AppColors.primaryRed, fontSize: 12)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // 3. List Film Tren (Horizontal)
                        SizedBox(
                          height: 160,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: trending.length > 10 ? 10 : trending.length,
                            itemBuilder: (context, index) {
                              final movie = trending[index];
                              return GestureDetector(
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetailScreen(movie: movie))),
                                  child: Container(
                                    width: 110, margin: const EdgeInsets.only(right: 12),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12), 
                                      image: DecorationImage(
                                        image: NetworkImage(AppConstants.tmdbImageBaseUrl + movie.posterPath), fit: BoxFit.cover
                                      )
                                    ),
                                    alignment: Alignment.topRight,
                                    padding: const EdgeInsets.all(6),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.7),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.star, color: Colors.amber, size: 10),
                                          const SizedBox(width: 4),
                                          Text(movie.voteAverage.toStringAsFixed(1), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ),
                                  ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 24),

                        // 4. List Film Populer (Grid Vertical)
                        const Text('Film Populer', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        GridView.builder(
                          physics: const NeverScrollableScrollPhysics(), shrinkWrap: true,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3, childAspectRatio: 0.7, crossAxisSpacing: 10, mainAxisSpacing: 10
                          ),
                          itemCount: popular.length > 6 ? 6 : popular.length,
                          itemBuilder: (context, index) {
                            final movie = popular[index];
                            return GestureDetector(
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetailScreen(movie: movie))),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8), 
                                  image: DecorationImage(
                                    image: NetworkImage(AppConstants.tmdbImageBaseUrl + movie.posterPath), fit: BoxFit.cover
                                  )
                                ),
                                alignment: Alignment.topRight,
                                padding: const EdgeInsets.all(6),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.star, color: Colors.amber, size: 10),
                                      const SizedBox(width: 4),
                                      Text(movie.voteAverage.toStringAsFixed(1), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}