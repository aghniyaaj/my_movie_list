import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../models/movie_model.dart';
import '../services/api_service.dart';
import 'detail_screen.dart';
import 'genre_movies_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ApiService _api = ApiService();
  List<Movie> _searchResults = [];
  List<Map<String, dynamic>> _genres = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasSearched = false;
  bool _hasMore = true;
  int _currentPage = 1;
  String _lastQuery = '';

  @override
  void initState() {
    super.initState();
    _loadGenres();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore && _hasMore && _hasSearched) {
        _loadMoreResults();
      }
    }
  }

  void _loadGenres() async {
    try {
      final genres = await _api.getGenreList();
      if (mounted) setState(() => _genres = genres);
    } catch (e) {
      debugPrint("Error loading genres: $e");
    }
  }

  void _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() { _searchResults = []; _hasSearched = false; });
      return;
    }

    setState(() { _isLoading = true; _hasSearched = true; _currentPage = 1; _lastQuery = query.trim(); });

    try {
      final results = await _api.searchMovies(_lastQuery, page: 1);
      if (mounted) {
        setState(() {
          _searchResults = results;
          _hasMore = results.length >= 20;
        });
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _loadMoreResults() async {
    setState(() => _isLoadingMore = true);
    _currentPage++;

    try {
      final results = await _api.searchMovies(_lastQuery, page: _currentPage);
      if (mounted) {
        setState(() {
          _searchResults.addAll(results);
          _isLoadingMore = false;
          _hasMore = results.length >= 20;
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
        title: TextField(
          controller: _searchController,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Cari film atau genre favoritmu...',
            hintStyle: const TextStyle(color: AppColors.textGrey, fontSize: 14),
            prefixIcon: const Icon(Icons.search, color: AppColors.primaryRed),
            filled: true,
            fillColor: AppColors.cardDark,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 0),
          ),
          onSubmitted: _performSearch,
          onChanged: (val) {
            if (val.trim().isEmpty) {
              setState(() { _hasSearched = false; _searchResults = []; });
            }
          },
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryRed))
          : _hasSearched
              ? _buildSearchResults()
              : _buildGenreExplorer(),
    );
  }

  // Tampilan ketika belum mencari: Grid Genre
  Widget _buildGenreExplorer() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Jelajahi Genre', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _genres.map((genre) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => GenreMoviesScreen(genreId: genre['id'], genreName: genre['name']),
                  ));
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.cardDark,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.primaryRed.withValues(alpha: 0.3)),
                  ),
                  child: Text(genre['name'], style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // Tampilan hasil pencarian
  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return const Center(child: Text('Film tidak ditemukan.', style: TextStyle(color: AppColors.textGrey)));
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: _searchResults.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _searchResults.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator(color: AppColors.primaryRed, strokeWidth: 2)),
          );
        }

        final movie = _searchResults[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          leading: Container(
            width: 50,
            height: 75,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: AppColors.cardDark,
              image: movie.posterPath.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(AppConstants.tmdbImageBaseUrl + movie.posterPath),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: movie.posterPath.isEmpty
                ? const Icon(Icons.movie, color: Colors.white54)
                : null,
          ),
          title: Text(movie.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          subtitle: Text(
            movie.releaseDate.isNotEmpty ? movie.releaseDate.substring(0, 4) : 'Unknown',
            style: const TextStyle(color: AppColors.textGrey),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 16),
              const SizedBox(width: 4),
              Text(movie.voteAverage.toStringAsFixed(1), style: const TextStyle(color: Colors.white)),
            ],
          ),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => DetailScreen(movie: movie)));
          },
        );
      },
    );
  }
}
