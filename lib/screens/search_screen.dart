import 'package:flutter/material.dart';
import 'package:movies_browser/screens/movie_details_screen.dart';
import '../services/tmdb_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TMDBService _tmdbService = TMDBService();
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  bool _isLoading = false;

  Future<void> _searchMedia() async {
    if (_searchController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final results = await _tmdbService.searchMedia(_searchController.text);
      setState(() {
        _searchResults = results['results'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error searching media: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wyszukiwarka'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Wyszukaj film lub serial',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _searchMedia,
                ),
              ),
              onSubmitted: (value) => _searchMedia(),
            ),
            const SizedBox(height: 16),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Expanded(
                    child: ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final media = _searchResults[index];
                      final mediaType =
                          media['media_type']; // Typ: movie, tv, person
                      if (mediaType != 'movie' && mediaType != 'tv')
                        return Container();

                      return ListTile(
                        leading: media['poster_path'] != null
                            ? Image.network(
                                'https://image.tmdb.org/t/p/w200${media['poster_path']}',
                                width: 50,
                              )
                            : const Icon(Icons.image_not_supported),
                        title: Text(
                            media['title'] ?? media['name'] ?? 'Brak tytułu'),
                        subtitle:
                            Text(mediaType == 'movie' ? 'Film' : 'Serial'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MovieDetailsScreen(
                                id: media['id'],
                                mediaType: mediaType,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  )),
          ],
        ),
      ),
    );
  }
}
