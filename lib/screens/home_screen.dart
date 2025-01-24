import 'package:flutter/material.dart';
import 'package:movies_browser/screens/movie_details_screen.dart';
import 'package:movies_browser/screens/search_screen.dart';
import '../services/tmdb_service.dart';
import 'categories_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TMDBService _tmdbService = TMDBService();
  List<dynamic> _popularMovies = [];
  List<dynamic> _upcomingMovies = [];
  List<dynamic> _topRatedMovies = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMovies();
  }

  Future<void> _fetchMovies() async {
    try {
      final popularData = await _tmdbService.fetchPopularMovies();
      final upcomingData = await _tmdbService.fetchUpcomingMovies();
      final topRatedData = await _tmdbService.fetchTopRatedMovies();

      setState(() {
        _popularMovies = popularData['results'];
        _upcomingMovies = upcomingData['results'];
        _topRatedMovies = topRatedData['results'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching movies: $e')),
      );
    }
  }

  Widget _buildMovieSection(String title, List<dynamic> movies) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];
              return GestureDetector(
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
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: movie['poster_path'] != null
                            ? Image.network(
                                'https://image.tmdb.org/t/p/w200${movie['poster_path']}',
                                width: 100,
                                height: 150,
                                fit: BoxFit.cover,
                              )
                            : const Icon(Icons.image_not_supported, size: 100),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        movie['title'] ?? 'No Title',
                        style: const TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MovieTalk'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.category),
              title: const Text('Categories'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CategoriesScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.search),
              title: const Text('Search'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SearchScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                _buildMovieSection('Popular Movies', _popularMovies),
                _buildMovieSection('Upcoming Movies', _upcomingMovies),
                _buildMovieSection('Top Rated Movies', _topRatedMovies),
              ],
            ),
    );
  }
}
