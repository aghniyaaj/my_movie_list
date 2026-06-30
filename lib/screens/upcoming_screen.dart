import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../models/movie_model.dart';
import '../services/api_service.dart';
import 'detail_screen.dart';

class UpcomingScreen extends StatelessWidget {
  const UpcomingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgDark,
        elevation: 0,
        title: const Text('Mendatang (Upcoming)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white), 
      ),
      body: FutureBuilder<List<Movie>>(
        future: ApiService().getUpcomingMovies(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primaryRed));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Tidak ada data film.", style: TextStyle(color: AppColors.textGrey)));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, 
              childAspectRatio: 0.65, 
              crossAxisSpacing: 12, 
              mainAxisSpacing: 12
            ),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final movie = snapshot.data![index];
              return GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetailScreen(movie: movie))),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    AppConstants.tmdbImageBaseUrl + movie.posterPath,
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}