import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../models/movie_model.dart';
import '../services/api_service.dart';
import 'detail_screen.dart';

class GenreMoviesScreen extends StatefulWidget {
  final int genreId;
  final String genreName;
  const GenreMoviesScreen({Key? key, required this.genreId, required this.genreName}) : super(key: key);

  @override
  _GenreMoviesScreenState createState() => _GenreMoviesScreenState();
}

class _GenreMoviesScreenState extends State<GenreMoviesScreen> {
  final List<Movie> _movies = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _fetchMovies();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  // Deteksi jika user scroll hampir sampai bawah
  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      // Muat halaman berikutnya
      if (!_isLoadingMore && _hasMore) {
        _fetchMoreMovies();
      }
    }
  }

  // Muat halaman pertama
  void _fetchMovies() async {
    try {
      final movies = await ApiService().getMoviesByGenre(widget.genreId, page: 1);
      if (mounted) {
        setState(() {
          _movies.addAll(movies);
          _isLoading = false;
          _hasMore = movies.length >= 20; // Jika kurang dari 20, berarti sudah habis
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Muat halaman berikutnya
  void _fetchMoreMovies() async {
    setState(() => _isLoadingMore = true);
    _currentPage++;

    try {
      final movies = await ApiService().getMoviesByGenre(widget.genreId, page: _currentPage);
      if (mounted) {
        setState(() {
          _movies.addAll(movies);
          _isLoadingMore = false;
          _hasMore = movies.length >= 20;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgDark,
        title: Text('Genre: ${widget.genreName}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryRed))
          : _movies.isEmpty
              ? const Center(child: Text('Tidak ada film ditemukan.', style: TextStyle(color: AppColors.textGrey)))
              : GridView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, childAspectRatio: 0.55, crossAxisSpacing: 12, mainAxisSpacing: 12,
                  ),
                  itemCount: _movies.length + (_hasMore ? 1 : 0), // +1 untuk loading indicator di bawah
                  itemBuilder: (context, index) {
                    // Jika index terakhir dan masih ada data, tampilkan loading
                    if (index == _movies.length) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(color: AppColors.primaryRed, strokeWidth: 2),
                        ),
                      );
                    }

                    final movie = _movies[index];
                    return GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetailScreen(movie: movie))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                image: movie.posterPath.isNotEmpty
                                    ? DecorationImage(image: NetworkImage(AppConstants.tmdbImageBaseUrl + movie.posterPath), fit: BoxFit.cover)
                                    : null,
                                color: AppColors.cardDark,
                              ),
                              alignment: Alignment.topRight,
                              padding: const EdgeInsets.all(6),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.7), borderRadius: BorderRadius.circular(8)),
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
                          ),
                          const SizedBox(height: 6),
                          Text(movie.title, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
