import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants.dart';
import '../models/movie_model.dart';
import '../services/api_service.dart';
import '../services/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'main_nav.dart';
import 'genre_movies_screen.dart';

class DetailScreen extends StatefulWidget {
  final Movie movie;
  final bool scrollToReviews;
  final bool isUpcomingMovie;
  const DetailScreen({required this.movie, this.scrollToReviews = false, this.isUpcomingMovie = false});

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final FirebaseService _db = FirebaseService();
  final ApiService _api = ApiService();
  final _reviewCtrl = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<dynamic> _cast = [];
  int _runtime = 0;
  List<dynamic> _genres = [];
  String? _trailerKey;
  String _overview = '';
  bool _isWatched = false;
  bool _isWishlist = false;
  int _rating = 5;

  @override
  void initState() {
    super.initState();
    _overview = widget.movie.overview;
    _fetchCast();
    _fetchDetails();
    _fetchTrailer();
    _checkFirebaseStatus();
    
    if (widget.scrollToReviews) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted && _scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  void _fetchCast() async {
    final cast = await _api.getMovieCast(widget.movie.id);
    if (mounted) setState(() => _cast = cast);
  }

  void _fetchDetails() async {
    final details = await _api.getMovieDetails(widget.movie.id);
    if (mounted) {
      setState(() {
        _runtime = details['runtime'] ?? 0;
        _genres = details['genres'] ?? [];
        // Jika sinopsis Indonesia tersedia dari detail, gunakan itu
        if (details['overview'] != null && details['overview'].toString().trim().isNotEmpty) {
          _overview = details['overview'];
        }
      });
    }

    // Jika sinopsis masih kosong, coba ambil versi Bahasa Inggris
    if (_overview.trim().isEmpty) {
      final enDetails = await _api.getMovieDetailsEnglish(widget.movie.id);
      if (mounted && enDetails['overview'] != null && enDetails['overview'].toString().trim().isNotEmpty) {
        setState(() {
          _overview = enDetails['overview'];
        });
      }
    }
  }

  void _fetchTrailer() async {
    final key = await _api.getMovieTrailer(widget.movie.id);
    if (mounted) setState(() => _trailerKey = key);
  }

  void _checkFirebaseStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    
    try {
      final watchedDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).collection('watched').doc(widget.movie.id.toString()).get();
      final wishlistDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).collection('wishlist').doc(widget.movie.id.toString()).get();
      if (mounted) {
        setState(() {
          _isWatched = watchedDoc.exists;
          _isWishlist = wishlistDoc.exists;
        });
      }
    } catch (e) {
      debugPrint('Firebase Permission Error: $e');
    }
  }

  bool get _isUpcoming {
    if (widget.isUpcomingMovie) return true;
    if (widget.movie.releaseDate.isEmpty) return false;
    try {
      DateTime release = DateTime.parse(widget.movie.releaseDate);
      return release.isAfter(DateTime.now());
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Info Film
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(AppConstants.tmdbImageBaseUrl + widget.movie.posterPath, width: 120, height: 180, fit: BoxFit.cover)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.movie.title, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('${widget.movie.releaseDate.split('-')[0]} • ${_genres.isNotEmpty ? _genres[0]['name'] : 'Unknown'} • $_runtime min', style: const TextStyle(color: AppColors.textGrey, fontSize: 12)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _genres.take(3).map((g) => GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(
                              builder: (_) => GenreMoviesScreen(genreId: g['id'], genreName: g['name']),
                            ));
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.primaryRed),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(g['name'], style: const TextStyle(color: Colors.white, fontSize: 10)),
                          ),
                        )).toList(),
                      ),
                      const SizedBox(height: 16),
                      // Tombol Firebase (Wishlist/Watched)
                      Row(
                        children: [
                          Expanded(
                            child: _isUpcoming 
                                ? ElevatedButton.icon(
                                    onPressed: null,
                                    icon: const Icon(Icons.lock_clock, color: Colors.grey, size: 16),
                                    label: const Text('Belum Rilis', style: TextStyle(color: Colors.grey, fontSize: 12)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      side: const BorderSide(color: Colors.grey),
                                      padding: const EdgeInsets.symmetric(vertical: 12)
                                    ),
                                  )
                                : _buildActionButton('Watched', Icons.add, 'watched', _isWatched)
                          ),
                          const SizedBox(width: 10),
                          Expanded(child: _buildActionButton('Wishlist', Icons.add, 'wishlist', _isWishlist)),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 24),
            const Text('Sinopsis', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(_overview.isNotEmpty ? _overview : 'Sinopsis belum tersedia.', style: const TextStyle(color: AppColors.textGrey, height: 1.5)),
            const SizedBox(height: 24),

            // Cuplikan & Video (Trailer)
            if (_trailerKey != null) ...[
              const Text('Cuplikan & Video', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () async {
                  final url = Uri.parse('https://www.youtube.com/watch?v=$_trailerKey');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                },
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    image: DecorationImage(
                      image: NetworkImage('https://img.youtube.com/vi/$_trailerKey/hqdefault.jpg'),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.darken),
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Tombol Play
                      Positioned(
                        bottom: 16, left: 16,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: AppColors.primaryRed,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.play_arrow, color: Colors.white, size: 28),
                        ),
                      ),
                      // Label Trailer
                      Positioned(
                        bottom: 16, right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: Colors.black.withOpacity(0.7), borderRadius: BorderRadius.circular(6)),
                          child: const Text('Trailer', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Pemain Utama (Dari API)
            const Text('Pemain Utama', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _cast.length,
                itemBuilder: (context, index) {
                  final actor = _cast[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Column(
                      children: [
                        CircleAvatar(radius: 30, backgroundImage: actor['profile_path'] != null ? NetworkImage(AppConstants.tmdbImageBaseUrl + actor['profile_path']) : null),
                        const SizedBox(height: 8),
                        Text(actor['name'], style: const TextStyle(color: Colors.white, fontSize: 10)),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Form Ulasan Pengguna (Ke Firebase)
            const Text('Ulasan Pengguna', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.cardDark, borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: List.generate(5, (index) {
                      return IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: Icon(
                          index < _rating ? Icons.star : Icons.star_border,
                          color: _isWatched ? Colors.amber : Colors.grey,
                          size: 24,
                        ),
                        onPressed: _isWatched ? () {
                          setState(() {
                            _rating = index + 1;
                          });
                        } : null,
                      );
                    }),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _reviewCtrl, maxLines: 3,
                    enabled: _isWatched,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: _isWatched ? 'Tulis ulasan Anda di sini...' : 'Tandai \'Watched\' di atas untuk menulis ulasan...', 
                      hintStyle: const TextStyle(color: AppColors.textGrey), 
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), 
                      filled: true, fillColor: AppColors.bgDark
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isWatched ? AppColors.primaryRed : Colors.grey,
                      ),
                      onPressed: _isWatched ? () {
                        if (_reviewCtrl.text.isNotEmpty) {
                          _db.addReview(widget.movie.id, _reviewCtrl.text, _rating.toDouble());
                          _reviewCtrl.clear();
                          FocusScope.of(context).unfocus(); // Tutup keyboard
                        }
                      } : null,
                      child: const Text('Kirim', style: TextStyle(color: Colors.white)),
                    ),
                  )
                ],
              ),
            ),

            // Daftar Ulasan dari Firebase
            const SizedBox(height: 16),
            StreamBuilder<QuerySnapshot>(
              stream: _db.getReviews(widget.movie.id),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                return ListView.builder(
                  shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var review = snapshot.data!.docs[index];
                    var reviewData = review.data() as Map<String, dynamic>;
                    
                    // Cek apakah ulasan ini milik user yang sedang login
                    bool isMe = reviewData['userId'] == FirebaseAuth.instance.currentUser?.uid;
                    
                    // Jika milik user ini, prioritaskan nama/foto terbaru dari Auth
                    String displayUserName = isMe 
                        ? (FirebaseAuth.instance.currentUser?.displayName ?? reviewData['userName'] ?? 'User') 
                        : (reviewData['userName'] ?? 'User');
                        
                    String rawUserPic = reviewData.containsKey('userPic') && reviewData['userPic'] != null ? reviewData['userPic'] : '';
                    String displayUserPic = isMe 
                        ? (FirebaseAuth.instance.currentUser?.photoURL ?? rawUserPic) 
                        : rawUserPic;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: AppColors.cardDark, borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            backgroundColor: AppColors.primaryRed,
                            backgroundImage: displayUserPic.isNotEmpty ? NetworkImage('https://wsrv.nl/?url=$displayUserPic') : null,
                            child: displayUserPic.isEmpty ? Text(displayUserName.isNotEmpty ? displayUserName[0].toUpperCase() : 'U', style: const TextStyle(color: Colors.white)) : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(displayUserName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Row(
                                  children: List.generate(5, (starIndex) {
                                    return Icon(
                                      starIndex < (review['rating'] ?? 5).toInt() ? Icons.star : Icons.star_border,
                                      color: AppColors.primaryRed,
                                      size: 12,
                                    );
                                  }),
                                ),
                                const SizedBox(height: 8),
                                Text(review['review'], style: const TextStyle(color: AppColors.textGrey)),
                              ],
                            ),
                          )
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.bgDark,
        selectedItemColor: Colors.grey,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => MainNav(initialIndex: index)),
            (route) => false,
          );
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: 'My List'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, String collectionType, bool isActive) {
    return ElevatedButton.icon(
      onPressed: () async {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Harap login terlebih dahulu!')));
          return;
        }
        
        try {
          await _db.toggleMovie(widget.movie, collectionType);
          _checkFirebaseStatus();
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$label diperbarui')));
        } catch (e) {
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: Periksa Rules Firestore Anda')));
        }
      },
      icon: Icon(isActive ? Icons.check : icon, color: Colors.white, size: 16),
      label: Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive ? AppColors.primaryRed : Colors.transparent,
        side: BorderSide(color: isActive ? Colors.transparent : AppColors.primaryRed),
        padding: const EdgeInsets.symmetric(vertical: 12)
      ),
    );
  }
}