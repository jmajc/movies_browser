import 'package:flutter/material.dart';
import '../services/tmdb_service.dart';

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
  Map<String, dynamic>? _details;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    try {
      final data = widget.mediaType == 'movie'
          ? await _tmdbService.fetchMovieDetails(widget.id)
          : await _tmdbService.fetchTvDetails(widget.id);
      setState(() {
        _details = data;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_details?['title'] ?? _details?['name'] ?? 'Szczegóły'),
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
                    _details?['title'] ?? _details?['name'] ?? 'Brak tytułu',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Data premiery: ${_details?['release_date'] ?? 'Brak danych'}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    'Czas trwania: ${_details?['runtime'] != null ? "${_details!['runtime']} min" : 'Brak danych'}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Gatunki: ${_details?['genres'] != null ? (_details!['genres'] as List).map((genre) => genre['name']).join(', ') : 'Brak danych'}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _details?['overview'] ?? 'Brak opisu',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Średnia ocena: ${_details?['vote_average']?.toString() ?? 'Brak'}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        'Liczba głosów: ${_details?['vote_count']?.toString() ?? 'Brak'}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Status: ${_details?['status'] ?? 'Brak danych'}',
                    style: const TextStyle(
                        fontSize: 16, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
    );
  }
}
