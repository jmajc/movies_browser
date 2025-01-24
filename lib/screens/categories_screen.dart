import 'package:flutter/material.dart';
import '../services/tmdb_service.dart';
import 'category_movies_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({Key? key}) : super(key: key);

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final TMDBService _tmdbService = TMDBService();
  List<dynamic> _movieGenres = [];
  List<dynamic> _tvGenres = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchGenres();
  }

  Future<void> _fetchGenres() async {
    try {
      final movieGenres = await _tmdbService.fetchGenres('movie');
      final tvGenres = await _tmdbService.fetchGenres('tv');

      setState(() {
        _movieGenres = movieGenres;
        _tvGenres = tvGenres;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading genres: $e')),
      );
    }
  }

  Widget _buildGenreSection(
      String title, List<dynamic> genres, String mediaType) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: genres.length,
          itemBuilder: (context, index) {
            final genre = genres[index];
            return ListTile(
              title: Text(genre['name']),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CategoryMoviesScreen(
                      genreId: genre['id'],
                      genreName: genre['name'],
                      mediaType: mediaType,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kategorie'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                _buildGenreSection('Kategorie Filmów', _movieGenres, 'movie'),
                _buildGenreSection('Kategorie Seriali', _tvGenres, 'tv'),
              ],
            ),
    );
  }
}
