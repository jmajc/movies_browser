import 'package:dio/dio.dart';
import '../constants.dart';

class TMDBService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: TMDB_BASE_URL,
    headers: {
      'Authorization': 'Bearer $TMDB_READ_ACCESS_TOKEN',
      'Content-Type': 'application/json;charset=utf-8',
    },
  ));

  Future<Map<String, dynamic>> fetchPopularMovies() async {
    try {
      final response = await _dio.get('/movie/popular');
      return response.data;
    } catch (e) {
      throw Exception('Failed to load popular movies: $e');
    }
  }

  Future<Map<String, dynamic>> fetchMovieDetails(int movieId) async {
    try {
      final response = await _dio.get('/movie/$movieId');
      return response.data;
    } catch (e) {
      throw Exception('Failed to load movie details: $e');
    }
  }

  // Nadchodzące filmy
  Future<Map<String, dynamic>> fetchUpcomingMovies() async {
    try {
      final response = await _dio.get('/movie/upcoming');
      return response.data;
    } catch (e) {
      throw Exception('Failed to load upcoming movies: $e');
    }
  }

// Klasyczne filmy (np. na podstawie daty premiery)
  Future<Map<String, dynamic>> fetchClassicMovies() async {
    try {
      final response = await _dio.get('/discover/movie', queryParameters: {
        'primary_release_date.lte': '2000-01-01',
        'sort_by': 'release_date.desc',
      });
      print(response.data); // Wyświetl dane w konsoli
      return response.data;
    } catch (e) {
      throw Exception('Failed to load classic movies: $e');
    }
  }

  Future<Map<String, dynamic>> fetchTopRatedMovies() async {
    try {
      final response = await _dio.get('/movie/top_rated');
      return response.data;
    } catch (e) {
      throw Exception('Failed to load top-rated movies: $e');
    }
  }

  Future<List<dynamic>> fetchGenres(String mediaType) async {
    try {
      final response = await _dio.get('/genre/$mediaType/list');
      return response.data['genres'];
    } catch (e) {
      throw Exception('Failed to load genres: $e');
    }
  }

  Future<Map<String, dynamic>> fetchMoviesByGenre(
      int genreId, String mediaType) async {
    try {
      final response = await _dio.get('/discover/$mediaType', queryParameters: {
        'with_genres': genreId,
        'sort_by': 'popularity.desc',
      });
      return response.data;
    } catch (e) {
      throw Exception('Failed to load movies by genre: $e');
    }
  }

  Future<Map<String, dynamic>> searchMovies(String query) async {
    try {
      final response = await _dio.get('/search/movie', queryParameters: {
        'query': query,
      });
      return response.data;
    } catch (e) {
      throw Exception('Failed to search movies: $e');
    }
  }

  Future<Map<String, dynamic>> searchMedia(String query) async {
    try {
      final response = await _dio.get('/search/multi', queryParameters: {
        'query': query,
      });
      return response.data;
    } catch (e) {
      throw Exception('Failed to search media: $e');
    }
  }

  Future<Map<String, dynamic>> fetchTvDetails(int tvId) async {
    try {
      final response = await _dio.get('/tv/$tvId');
      return response.data;
    } catch (e) {
      throw Exception('Failed to load TV details: $e');
    }
  }

  Future<List<dynamic>> fetchTrailers(int id, String mediaType) async {
    final response = await _dio.get('/$mediaType/$id/videos');
    return response.data['results'] ?? [];
  }
}
