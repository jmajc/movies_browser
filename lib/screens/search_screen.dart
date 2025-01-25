import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/tmdb_service.dart';
import 'movie_details_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TMDBService _tmdbService = TMDBService();
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  List<String> _searchHistory = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
  }

  Future<void> _loadSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _searchHistory = prefs.getStringList('searchHistory') ?? [];
    });
  }

  Future<void> _saveSearchQuery(String query) async {
    final prefs = await SharedPreferences.getInstance();
    if (!_searchHistory.contains(query)) {
      setState(() {
        _searchHistory.insert(0, query); // Dodaj na początek listy
      });
      await prefs.setStringList('searchHistory', _searchHistory);
    }
  }

  Future<void> _clearSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _searchHistory.clear();
    });
    await prefs.remove('searchHistory');
  }

  Future<void> _searchMedia() async {
    if (_searchController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final results = await _tmdbService.searchMedia(_searchController.text);
      await _saveSearchQuery(_searchController.text); // Zapisanie zapytania
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

  Widget _buildSearchHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Historia wyszukiwania',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: _clearSearchHistory,
                child: const Text('Wyczyść'),
              ),
            ],
          ),
        ),
        if (_searchHistory.isNotEmpty)
          ..._searchHistory.map((query) {
            return ListTile(
              title: Text(query),
              trailing: const Icon(Icons.history),
              onTap: () {
                _searchController.text = query;
                _searchMedia(); // Wyszukaj na podstawie historii
              },
            );
          }).toList(),
        if (_searchHistory.isEmpty) const Text('Brak historii wyszukiwania'),
      ],
    );
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
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      children: [
                        if (_searchResults.isEmpty)
                          Expanded(
                            child: SingleChildScrollView(
                              child: _buildSearchHistory(),
                            ),
                          )
                        else
                          Expanded(
                            child: ListView.builder(
                              itemCount: _searchResults.length,
                              itemBuilder: (context, index) {
                                final media = _searchResults[index];
                                final mediaType = media['media_type'];
                                if (mediaType != 'movie' && mediaType != 'tv') {
                                  return const SizedBox.shrink();
                                }
                                return ListTile(
                                  leading: media['poster_path'] != null
                                      ? Image.network(
                                          'https://image.tmdb.org/t/p/w200${media['poster_path']}',
                                          width: 50,
                                          fit: BoxFit.cover,
                                        )
                                      : const Icon(Icons.image_not_supported),
                                  title: Text(
                                    media['title'] ??
                                        media['name'] ??
                                        'Brak tytułu',
                                  ),
                                  subtitle: Text(
                                    mediaType == 'movie' ? 'Film' : 'Serial',
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            MovieDetailsScreen(
                                          id: media['id'],
                                          mediaType: mediaType,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
