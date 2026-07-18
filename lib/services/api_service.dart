import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants.dart';
import '../models/movie_model.dart';

class ApiService {
  Future<List<Movie>> getTrendingMovies({int page = 1}) async {
    final response = await http.get(Uri.parse('${AppConstants.tmdbBaseUrl}/trending/movie/week?api_key=${AppConstants.tmdbApiKey}&language=id-ID&page=$page'));
    if (response.statusCode == 200) {
      final List results = json.decode(response.body)['results'];
      return results.map((e) => Movie.fromJson(e)).toList();
    }
    throw Exception('Gagal memuat film trending');
  }

  Future<List<Movie>> getPopularMovies() async {
    final response = await http.get(Uri.parse('${AppConstants.tmdbBaseUrl}/movie/popular?api_key=${AppConstants.tmdbApiKey}&language=id-ID'));
    if (response.statusCode == 200) {
      final List results = json.decode(response.body)['results'];
      return results.map((e) => Movie.fromJson(e)).toList();
    }
    throw Exception('Gagal memuat film populer');
  }

  Future<List<Movie>> getUpcomingMovies({int page = 1}) async {
    final response = await http.get(Uri.parse('${AppConstants.tmdbBaseUrl}/movie/upcoming?api_key=${AppConstants.tmdbApiKey}&language=id-ID&page=$page'));
    if (response.statusCode == 200) {
      final List results = json.decode(response.body)['results'];
      return results.map((e) => Movie.fromJson(e)).toList();
    }
    throw Exception('Gagal memuat film mendatang');
  }

  // Mengambil daftar pemain (Cast)
  Future<List<dynamic>> getMovieCast(int movieId) async {
    final response = await http.get(Uri.parse('${AppConstants.tmdbBaseUrl}/movie/$movieId/credits?api_key=${AppConstants.tmdbApiKey}&language=id-ID'));
    if (response.statusCode == 200) {
      return json.decode(response.body)['cast'].take(10).toList(); // Ambil 10 pemain saja
    }
    return [];
  }

  // Mencari film berdasarkan query
  Future<List<Movie>> searchMovies(String query, {int page = 1}) async {
    final response = await http.get(Uri.parse('${AppConstants.tmdbBaseUrl}/search/movie?api_key=${AppConstants.tmdbApiKey}&language=id-ID&query=$query&page=$page'));
    if (response.statusCode == 200) {
      final List results = json.decode(response.body)['results'];
      return results.map((e) => Movie.fromJson(e)).toList();
    }
    return [];
  }

  // Mendapatkan YouTube Trailer Key
  Future<String?> getMovieTrailer(int movieId) async {
    final response = await http.get(Uri.parse('${AppConstants.tmdbBaseUrl}/movie/$movieId/videos?api_key=${AppConstants.tmdbApiKey}&language=en-US'));
    if (response.statusCode == 200) {
      final List results = json.decode(response.body)['results'];
      if (results.isNotEmpty) {
        // Cari video yang merupakan Trailer dari YouTube
        final trailer = results.firstWhere(
          (video) => video['site'] == 'YouTube' && video['type'] == 'Trailer',
          orElse: () => results[0] // fallback jika tidak ada trailer spesifik
        );
        return trailer['key'];
      }
    }
    return null;
  }

  // Mendapatkan Detail Film Tambahan (Durasi & Genre)
  Future<Map<String, dynamic>> getMovieDetails(int movieId) async {
    final response = await http.get(Uri.parse('${AppConstants.tmdbBaseUrl}/movie/$movieId?api_key=${AppConstants.tmdbApiKey}&language=id-ID'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    return {};
  }

  // Fallback: Ambil detail film dalam Bahasa Inggris (untuk sinopsis yang kosong di id-ID)
  Future<Map<String, dynamic>> getMovieDetailsEnglish(int movieId) async {
    final response = await http.get(Uri.parse('${AppConstants.tmdbBaseUrl}/movie/$movieId?api_key=${AppConstants.tmdbApiKey}&language=en-US'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    return {};
  }

  // Mendapatkan daftar film berdasarkan Genre ID
  Future<List<Movie>> getMoviesByGenre(int genreId, {int page = 1}) async {
    final response = await http.get(Uri.parse('${AppConstants.tmdbBaseUrl}/discover/movie?api_key=${AppConstants.tmdbApiKey}&language=id-ID&with_genres=$genreId&sort_by=popularity.desc&page=$page'));
    if (response.statusCode == 200) {
      final List results = json.decode(response.body)['results'];
      return results.map((e) => Movie.fromJson(e)).toList();
    }
    return [];
  }

  // Mendapatkan daftar semua Genre dari TMDB
  Future<List<Map<String, dynamic>>> getGenreList() async {
    final response = await http.get(Uri.parse('${AppConstants.tmdbBaseUrl}/genre/movie/list?api_key=${AppConstants.tmdbApiKey}&language=id-ID'));
    if (response.statusCode == 200) {
      final List results = json.decode(response.body)['genres'];
      return results.cast<Map<String, dynamic>>();
    }
    return [];
  }
}