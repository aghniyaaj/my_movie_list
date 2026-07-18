import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/constants.dart';
import '../models/movie_model.dart';
import '../services/api_service.dart';
import 'detail_screen.dart';

class ReviewHistoryScreen extends StatefulWidget {
  const ReviewHistoryScreen({Key? key}) : super(key: key);

  @override
  _ReviewHistoryScreenState createState() => _ReviewHistoryScreenState();
}

class _ReviewHistoryScreenState extends State<ReviewHistoryScreen> {
  List<Map<String, dynamic>> _reviews = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      // Ambil semua film yang sudah di-watched oleh user
      final watchedSnap = await FirebaseFirestore.instance
          .collection('users').doc(user.uid).collection('watched').get();

      List<Map<String, dynamic>> allReviews = [];

      // Untuk setiap film, cek apakah user punya review di situ
      for (var doc in watchedSnap.docs) {
        final movieId = doc.id;
        final reviewSnap = await FirebaseFirestore.instance
            .collection('movies').doc(movieId).collection('reviews')
            .where('userId', isEqualTo: user.uid)
            .get();
        
        for (var reviewDoc in reviewSnap.docs) {
          final reviewData = reviewDoc.data();
          reviewData['movieId'] = int.tryParse(movieId) ?? 0;
          allReviews.add(reviewData);
        }
      }

      // Sort berdasarkan timestamp (terbaru dulu)
      allReviews.sort((a, b) {
        final aTime = a['timestamp'] as Timestamp?;
        final bTime = b['timestamp'] as Timestamp?;
        if (aTime == null || bTime == null) return 0;
        return bTime.compareTo(aTime);
      });

      if (mounted) {
        setState(() {
          _reviews = allReviews;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading reviews: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgDark,
        title: const Text('Ulasan Saya', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryRed))
          : _reviews.isEmpty
              ? const Center(child: Text("Belum ada ulasan.", style: TextStyle(color: AppColors.textGrey)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _reviews.length,
                  itemBuilder: (context, index) {
                    final data = _reviews[index];
                    final movieId = data['movieId'] as int;
                    final rating = (data['rating'] ?? 0).toInt();

                    // Timestamp formatting
                    String dateStr = '';
                    if (data['timestamp'] != null) {
                      final date = (data['timestamp'] as Timestamp).toDate();
                      dateStr = '${date.day} ${_getMonthName(date.month)} ${date.year}';
                    }

                    return FutureBuilder<Map<String, dynamic>>(
                      future: ApiService().getMovieDetails(movieId),
                      builder: (context, movieSnapshot) {
                        final movieData = movieSnapshot.data ?? {};
                        final title = movieData['title'] ?? 'Film #$movieId';
                        final posterPath = movieData['poster_path'];

                        return GestureDetector(
                          onTap: () {
                            if (movieData.isNotEmpty) {
                              final movie = Movie.fromJson(movieData);
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => DetailScreen(movie: movie, scrollToReviews: true)),
                              );
                            }
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(color: AppColors.cardDark, borderRadius: BorderRadius.circular(16)),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Poster
                                Container(
                                  width: 80,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    color: Colors.blueGrey.shade900,
                                    borderRadius: BorderRadius.circular(8),
                                    image: posterPath != null
                                        ? DecorationImage(image: NetworkImage(AppConstants.tmdbImageBaseUrl + posterPath), fit: BoxFit.cover)
                                        : null,
                                  ),
                                  child: posterPath == null ? const Center(child: Icon(Icons.movie, color: Colors.grey)) : null,
                                ),
                                const SizedBox(width: 16),
                                // Detail
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: List.generate(5, (starIndex) {
                                          return Icon(
                                            starIndex < rating ? Icons.star : Icons.star_border,
                                            color: AppColors.primaryRed,
                                            size: 16,
                                          );
                                        }),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        data['review'] ?? '',
                                        style: const TextStyle(color: AppColors.textGrey, fontSize: 13, height: 1.4),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 12),
                                      Align(
                                        alignment: Alignment.bottomRight,
                                        child: Text(dateStr, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return months[month - 1];
  }
}