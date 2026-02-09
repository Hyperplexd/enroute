import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class GoogleMapsService {
  static const String apiKey = 'GOOGLE_MAPS_API_KEY';
  
  /// Calculate distance and duration between two locations
  Future<Map<String, dynamic>> calculateRoute({
    required String origin,
    required String destination,
    String mode = 'driving', // driving, transit, walking
  }) async {
    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/distancematrix/json'
        '?origins=$origin'
        '&destinations=$destination'
        '&mode=$mode'
        '&key=$apiKey',
      );
      
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK' && data['rows'][0]['elements'][0]['status'] == 'OK') {
          final element = data['rows'][0]['elements'][0];
          
          return {
            'success': true,
            'distance': element['distance']['value'], // in meters
            'distanceText': element['distance']['text'],
            'duration': element['duration']['value'], // in seconds
            'durationText': element['duration']['text'],
            'durationMinutes': (element['duration']['value'] / 60).round(),
          };
        }
      }
      
      return {
        'success': false,
        'error': 'Unable to calculate route',
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
  
  /// Get autocomplete suggestions for a place
  Future<List<Map<String, String>>> getPlaceSuggestions(String input) async {
    if (input.isEmpty) return [];
    
    try {
      // URL encode the input to handle special characters
      final encodedInput = Uri.encodeComponent(input);
      
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json'
        '?input=$encodedInput'
        '&key=$apiKey',
      );
      
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timed out');
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Check for API errors
        if (data['status'] == 'REQUEST_DENIED') {
          print('Google Places API Error: ${data['error_message'] ?? "REQUEST_DENIED"}');
          print('Please check:');
          print('1. API key is correct');
          print('2. Places API is enabled in Google Cloud Console');
          print('3. Billing is enabled for your project');
          print('4. API key restrictions allow this request');
          return [];
        }
        
        if (data['status'] == 'INVALID_REQUEST') {
          print('Invalid request to Places API: ${data['error_message'] ?? "Unknown error"}');
          return [];
        }
        
        if (data['status'] == 'OK') {
          final predictions = data['predictions'] as List;
          
          return predictions.map((prediction) {
            return {
              'description': prediction['description'] as String,
              'placeId': prediction['place_id'] as String,
            };
          }).toList();
        } else if (data['status'] == 'ZERO_RESULTS') {
          // No results found, but not an error
          return [];
        }
      } else {
        print('HTTP Error ${response.statusCode}: ${response.body}');
      }
      
      return [];
    } catch (e) {
      print('Error getting place suggestions: $e');
      if (e.toString().contains('Failed host lookup') || 
          e.toString().contains('SocketException')) {
        print('Network error: Please check your internet connection');
      } else if (e.toString().contains('ClientException')) {
        print('CORS or network error. If running on web, this is a known Flutter web limitation.');
        print('Consider using a proxy server or running on mobile/desktop instead.');
      }
      return [];
    }
  }
  
  /// Get place details from place ID
  Future<Map<String, dynamic>> getPlaceDetails(String placeId) async {
    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/details/json'
        '?place_id=$placeId'
        '&fields=name,formatted_address,geometry'
        '&key=$apiKey',
      );
      
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK') {
          final result = data['result'];
          return {
            'success': true,
            'name': result['name'],
            'address': result['formatted_address'],
            'lat': result['geometry']['location']['lat'],
            'lng': result['geometry']['location']['lng'],
          };
        }
      }
      
      return {'success': false};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
  
  /// Generate static map URL with route visualization
  String getStaticMapUrl({
    required String origin,
    required String destination,
    int width = 600,
    int height = 300,
    int zoom = 13,
  }) {
    // URL encode the locations
    final encodedOrigin = Uri.encodeComponent(origin);
    final encodedDestination = Uri.encodeComponent(destination);
    
    // Build the Static Maps API URL with route path
    final url = 'https://maps.googleapis.com/maps/api/staticmap'
        '?size=${width}x$height'
        '&markers=color:blue|label:A|$encodedOrigin'
        '&markers=color:red|label:B|$encodedDestination'
        '&path=weight:5|color:0x4285F4|$encodedOrigin|$encodedDestination'
        '&key=$apiKey';
    
    return url;
  }
  
  /// Generate static map URL with route polyline for more accurate path
  Future<String?> getStaticMapUrlWithRoute({
    required String origin,
    required String destination,
    String mode = 'driving',
    int width = 600,
    int height = 300,
  }) async {
    try {
      // Get directions to retrieve the polyline
      final directions = await getDirections(
        origin: origin,
        destination: destination,
        mode: mode,
      );
      
      if (directions['success'] == true && directions['polyline'] != null) {
        final polyline = directions['polyline'] as String;
        
        // Build URL with polyline
        final url = 'https://maps.googleapis.com/maps/api/staticmap'
            '?size=${width}x$height'
            '&markers=color:blue|label:A|${Uri.encodeComponent(origin)}'
            '&markers=color:red|label:B|${Uri.encodeComponent(destination)}'
            '&path=enc:$polyline'
            '&key=$apiKey';
        
        return url;
      }
      
      // Fallback to simple path if directions fail
      return getStaticMapUrl(
        origin: origin,
        destination: destination,
        width: width,
        height: height,
      );
    } catch (e) {
      print('Error generating map with route: $e');
      return getStaticMapUrl(
        origin: origin,
        destination: destination,
        width: width,
        height: height,
      );
    }
  }
  
  /// Get directions between two locations
  Future<Map<String, dynamic>> getDirections({
    required String origin,
    required String destination,
    String mode = 'driving',
  }) async {
    try {
      final encodedOrigin = Uri.encodeComponent(origin);
      final encodedDestination = Uri.encodeComponent(destination);
      
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json'
        '?origin=$encodedOrigin'
        '&destination=$encodedDestination'
        '&mode=$mode'
        '&key=$apiKey',
      );
      
      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK' && data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          final leg = route['legs'][0];
          
          return {
            'success': true,
            'polyline': route['overview_polyline']['points'],
            'distance': leg['distance']['value'], // in meters
            'distanceText': leg['distance']['text'],
            'duration': leg['duration']['value'], // in seconds
            'durationText': leg['duration']['text'],
            'startAddress': leg['start_address'],
            'endAddress': leg['end_address'],
          };
        } else {
          print('Directions API error: ${data['status']}');
          if (data['error_message'] != null) {
            print('Error message: ${data['error_message']}');
          }
        }
      }
      
      return {'success': false};
    } catch (e) {
      print('Error getting directions: $e');
      return {'success': false, 'error': e.toString()};
    }
  }
  
  /// Get current location
  Future<Map<String, dynamic>> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return {
          'success': false,
          'error': 'Location services are disabled.',
        };
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return {
            'success': false,
            'error': 'Location permissions are denied.',
          };
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return {
          'success': false,
          'error': 'Location permissions are permanently denied.',
        };
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Reverse geocode to get address
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String address = '';
        
        if (place.street != null && place.street!.isNotEmpty) {
          address = place.street!;
        }
        if (place.locality != null && place.locality!.isNotEmpty) {
          address += address.isEmpty ? place.locality! : ', ${place.locality}';
        }
        if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
          address += address.isEmpty ? place.administrativeArea! : ', ${place.administrativeArea}';
        }

        return {
          'success': true,
          'address': address.isEmpty ? 'Current Location' : address,
          'lat': position.latitude,
          'lng': position.longitude,
        };
      }

      return {
        'success': true,
        'address': 'Current Location',
        'lat': position.latitude,
        'lng': position.longitude,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
}

