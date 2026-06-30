import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/constants.dart';
import '../models/movie_model.dart';
import '../services/api_service.dart';
import 'detail_screen.dart';
import 'trending_screen.dart'; 
import 'upcoming_screen.dart'; // KODE BARU: Import layar upcoming
import 'search_screen.dart';
import 'package:url_launcher/url_launcher.dart'; 

class HomeScreen extends StatefulWidget {
  final VoidCallback onNavigateToProfile; 

  const HomeScreen({Key? key, required this.onNavigateToProfile}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _api = ApiService();
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    String initial = 'U';
    if (user?.displayName != null && user!.displayName!.trim().isNotEmpty) {
      String name = user!.displayName!.trim();
      initial = name.length >= 2 ? name.substring(0, 2).toUpperCase() : name.toUpperCase();
    } else if (user?.email != null && user!.email!.length >= 2) {
      initial = user!.email!.substring(0, 2).toUpperCase();
    }

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
                    Image.asset(
                      'assets/images/logo.png', 
                      width: 50, 
                      height: 50, 
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.movie, size: 100, color: AppColors.primaryRed)
                    ),
                    
                    // Avatar Profil yang bisa diklik
                    GestureDetector(
                      onTap: widget.onNavigateToProfile, 
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primaryRed, width: 1.5), 
                        ),
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.cardDark,
                          backgroundImage: user?.photoURL != null ? NetworkImage('https://wsrv.nl/?url=${user!.photoURL!}') : null,
                          child: user?.photoURL == null 
                            ? Text(initial, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))
                            : null,
                        ),
                      ),
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
                
                // Mulai Menampilkan Data Film dengan FutureBuilder
                FutureBuilder<List<List<Movie>>>(
                  // KODE BARU: Menambahkan request getUpcomingMovies ke dalam Future.wait
                  future: Future.wait([
                    _api.getTrendingMovies(), 
                    _api.getPopularMovies(),
                    _api.getUpcomingMovies()
                  ]),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: AppColors.primaryRed));
                    }
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red));
                    }

                    // Menarik data dari index array snapshot
                    final trending = snapshot.data![0];
                    final popular = snapshot.data![1];
                    final upcoming = snapshot.data![2]; 
                    
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
                            GestureDetector(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const TrendingScreen()));
                              },
                              child: const Text('Lihat Semua', style: TextStyle(color: AppColors.primaryRed, fontSize: 12)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // List Film Tren (Horizontal)
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
                        
                        // 3. KODE BARU: Teks "Mendatang" & Tombol "Lihat Semua"
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Mendatang', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const UpcomingScreen()));
                              },
                              child: const Text('Lihat Semua', style: TextStyle(color: AppColors.primaryRed, fontSize: 12)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // List Film Mendatang (Horizontal - Meniru Sedang Tren)
                        SizedBox(
                          height: 160,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: upcoming.length > 10 ? 10 : upcoming.length,
                            itemBuilder: (context, index) {
                              final movie = upcoming[index];
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