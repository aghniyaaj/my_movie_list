import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../models/movie_model.dart';
import '../services/api_service.dart';
import 'detail_screen.dart';

class TrendingScreen extends StatefulWidget {
  const TrendingScreen({Key? key}) : super(key: key);

  @override
  _TrendingScreenState createState() => _TrendingScreenState();
}

class _TrendingScreenState extends State<TrendingScreen> {
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

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore && _hasMore) {
        _fetchMoreMovies();
      }
    }
  }

  void _fetchMovies() async {
    try {
      final movies = await ApiService().getTrendingMovies(page: 1);
      if (mounted) {
        setState(() {
          _movies.addAll(movies);
          _isLoading = false;
          _hasMore = movies.length >= 20;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _fetchMoreMovies() async {
    setState(() => _isLoadingMore = true);
    _currentPage++;
    try {
      final movies = await ApiService().getTrendingMovies(page: _currentPage);
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
        elevation: 0,
        title: const Text('Sedang Tren', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryRed))
          : _movies.isEmpty
              ? const Center(child: Text("Tidak ada data film.", style: TextStyle(color: AppColors.textGrey)))
              : GridView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, 
                    childAspectRatio: 0.65, 
                    crossAxisSpacing: 12, 
                    mainAxisSpacing: 12
                  ),
                  itemCount: _movies.length + (_hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
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
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: movie.posterPath.isNotEmpty
                          ? Image.network(
                              AppConstants.tmdbImageBaseUrl + movie.posterPath,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: AppColors.cardDark,
                                child: const Icon(Icons.movie, color: Colors.grey),
                              ),
                            )
                          : Container(
                              color: AppColors.cardDark,
                              child: const Icon(Icons.movie, color: Colors.grey),
                            ),
                      ),
                    );
                  },
                ),
    );
  }
}