import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/tmdb_service.dart';
import '../services/favorites_service.dart';

class MovieDetailsScreen extends StatefulWidget {
  final int id;
  final String mediaType;

  const MovieDetailsScreen({
    Key? key,
    required this.id,
    required this.mediaType,
  }) : super(key: key);

  @override
  State<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen> {
  final TMDBService _tmdbService = TMDBService();
  final FavoritesService _favoritesService = FavoritesService();
  Map<String, dynamic>? _details;
  List<dynamic> _trailers = [];
  bool _isFavorite = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    try {
      final details = widget.mediaType == 'movie'
          ? await _tmdbService.fetchMovieDetails(widget.id)
          : await _tmdbService.fetchTvDetails(widget.id);
      final isFavorite = await _favoritesService.isFavorite(widget.id);
      final trailers =
          await _tmdbService.fetchTrailers(widget.id, widget.mediaType);

      setState(() {
        _details = details;
        _isFavorite = isFavorite;
        _trailers = trailers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading details: $e')),
      );
    }
  }

  Future<void> _toggleFavorite() async {
    if (_isFavorite) {
      await _favoritesService.removeFavorite(widget.id);
    } else {
      await _favoritesService.addFavorite(widget.id);
    }
    setState(() {
      _isFavorite = !_isFavorite;
    });
  }

  void _playTrailer(String key) async {
    final url = 'https://www.youtube.com/watch?v=$key';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch trailer: $url')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_details?['title'] ?? _details?['name'] ?? 'Details'),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.red : Colors.white,
            ),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_details?['poster_path'] != null)
                    Center(
                      child: Image.network(
                        'https://image.tmdb.org/t/p/w500${_details!['poster_path']}',
                        fit: BoxFit.cover,
                      ),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    _details?['title'] ?? _details?['name'] ?? 'No Title',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.mediaType == 'movie' ? 'Release Date' : 'First Air Date'}: ${_details?[widget.mediaType == 'movie' ? 'release_date' : 'first_air_date'] ?? 'No Data'}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.mediaType == 'movie' ? 'Runtime' : 'Episode Runtime'}: ${_details?['episode_run_time'] != null ? (_details!['episode_run_time'] as List).isNotEmpty ? "${_details!['episode_run_time'][0]} min" : 'No Data' : "${_details?['runtime'] ?? 'No Data'}"}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Genres: ${_details?['genres'] != null ? (_details!['genres'] as List).map((genre) => genre['name']).join(', ') : 'No Data'}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Average Rating: ${_details?['vote_average']?.toString() ?? 'No Data'}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Vote Count: ${_details?['vote_count']?.toString() ?? 'No Data'}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Overview:',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _details?['overview'] ?? 'No Description',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Trailers:',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_trailers.isNotEmpty)
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _trailers.length,
                      itemBuilder: (context, index) {
                        final trailer = _trailers[index];
                        if (trailer['site'] == 'YouTube') {
                          return ListTile(
                            leading: const Icon(Icons.play_circle_fill),
                            title: Text(trailer['name']),
                            onTap: () => _playTrailer(trailer['key']),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    )
                  else
                    const Text('No trailers available.'),
                ],
              ),
            ),
    );
  }
}
