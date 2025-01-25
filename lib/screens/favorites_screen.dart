import 'package:flutter/material.dart';
import '../services/tmdb_service.dart';
import '../services/favorites_service.dart';
import 'movie_details_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final FavoritesService _favoritesService = FavoritesService();
  final TMDBService _tmdbService = TMDBService();
  List<Map<String, dynamic>> _favorites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final favoriteIds = await _favoritesService.getFavorites();
    final List<Map<String, dynamic>> loadedFavorites = [];

    for (final id in favoriteIds) {
      try {
        // Pobieranie szczegółów filmu
        final movieDetails = await _tmdbService.fetchMovieDetails(id);
        loadedFavorites.add(movieDetails);
      } catch (e) {
        // Ignorowanie błędów i kontynuowanie
        debugPrint('Failed to load details for movie ID $id: $e');
      }
    }

    setState(() {
      _favorites = loadedFavorites;
      _isLoading = false;
    });
  }

  Future<void> _removeFavorite(int id) async {
    await _favoritesService.removeFavorite(id);
    setState(() {
      _favorites.removeWhere((movie) => movie['id'] == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ulubione Filmy'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favorites.isEmpty
              ? const Center(child: Text('Brak ulubionych filmów.'))
              : ListView.builder(
                  itemCount: _favorites.length,
                  itemBuilder: (context, index) {
                    final movie = _favorites[index];
                    return ListTile(
                      leading: movie['poster_path'] != null
                          ? Image.network(
                              'https://image.tmdb.org/t/p/w200${movie['poster_path']}',
                              width: 50,
                              fit: BoxFit.cover,
                            )
                          : const Icon(Icons.image_not_supported),
                      title: Text(movie['title'] ?? 'Brak tytułu'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _removeFavorite(movie['id']),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MovieDetailsScreen(
                              id: movie['id'],
                              mediaType: 'movie',
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
