import 'dart:async';
import 'dart:js' as js;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class GoogleMapsService {
  static const String apiKey = 'AIzaSyDz1lX6X6_L-uzPlx17dWfWFIgxZn6BqmY';
  
  Future<List<Map<String, String>>> getPlaceSuggestions(String input) async {
    if (input.isEmpty) return [];
    
    try {
      await _waitForGoogleMaps();
      
      final google = js.context['google'];
      if (google == null) return [];
      
      final maps = google['maps'];
      final places = maps['places'];
      final AutocompleteService = places['AutocompleteService'];
      if (AutocompleteService == null) return [];
      
      final service = js.context.callMethod('eval', ['new google.maps.places.AutocompleteService()']) as js.JsObject;
      final completer = Completer<List<Map<String, String>>>();
      
      final request = js.JsObject.jsify({'input': input});
      final callbackId = 'callback_${DateTime.now().millisecondsSinceEpoch}';
      
      js.context[callbackId] = (predictions, status) {
        try {
          if (status == 'OK' && predictions != null) {
            final results = <Map<String, String>>[];
            final predictionsList = js.JsArray.from(predictions);
            for (var i = 0; i < predictionsList.length; i++) {
              final pred = predictionsList[i] as js.JsObject;
              results.add({
                'description': pred['description'] as String,
                'placeId': pred['place_id'] as String,
              });
            }
            completer.complete(results);
          } else {
            completer.complete([]);
          }
        } finally {
          js.context.deleteProperty(callbackId);
        }
      };
      
      service.callMethod('getPlacePredictions', [request, js.context[callbackId]]);
      
      return completer.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          js.context.deleteProperty(callbackId);
          return <Map<String, String>>[];
        },
      );
    } catch (e) {
      return [];
    }
  }
  
  Future<Map<String, dynamic>> getDirections({
    required String origin,
    required String destination,
    String mode = 'driving',
  }) async {
    try {
      await _waitForGoogleMaps();
      
      final google = js.context['google'];
      if (google == null) {
        return {'success': false, 'error': 'Google Maps API not loaded'};
      }
      
      final maps = google['maps'];
      final DirectionsService = maps['DirectionsService'];
      if (DirectionsService == null) {
        return {'success': false, 'error': 'DirectionsService not available'};
      }
      
      final service = js.context.callMethod('eval', ['new google.maps.DirectionsService()']) as js.JsObject;
      final completer = Completer<Map<String, dynamic>>();
      
      String travelMode = 'DRIVING';
      switch (mode.toLowerCase()) {
        case 'walking': travelMode = 'WALKING'; break;
        case 'transit': travelMode = 'TRANSIT'; break;
        case 'bicycling': travelMode = 'BICYCLING'; break;
        default: travelMode = 'DRIVING';
      }
      
      final request = js.JsObject.jsify({
        'origin': origin,
        'destination': destination,
        'travelMode': travelMode,
      });
      
      final callbackId = 'callback_${DateTime.now().millisecondsSinceEpoch}';
      
      final callbackCode = '''
        function(result, status) {
          try {
            if (status === 'OK' && result !== null && result.routes && result.routes.length > 0) {
              var route = result.routes[0];
              if (route.legs && route.legs.length > 0) {
                var leg = route.legs[0];
                var overviewPolyline = route.overview_polyline;
                var polylinePoints = '';
                
                if (overviewPolyline && overviewPolyline.points) {
                  polylinePoints = String(overviewPolyline.points);
                } else if (route.steps && window.google && window.google.maps && window.google.maps.geometry && window.google.maps.geometry.encoding) {
                  var path = [];
                  for (var i = 0; i < route.steps.length; i++) {
                    if (route.steps[i].path) {
                      for (var j = 0; j < route.steps[i].path.length; j++) {
                        path.push(route.steps[i].path[j]);
                      }
                    }
                  }
                  if (path.length > 0) {
                    polylinePoints = window.google.maps.geometry.encoding.encodePath(path);
                  }
                }
                
                window['$callbackId']({
                  success: true,
                  polyline: polylinePoints,
                  distance: leg.distance ? Number(leg.distance.value) : 0,
                  distanceText: leg.distance ? String(leg.distance.text) : '',
                  duration: leg.duration ? Number(leg.duration.value) : 0,
                  durationText: leg.duration ? String(leg.duration.text) : '',
                  startAddress: leg.start_address || '',
                  endAddress: leg.end_address || ''
                });
                return;
              }
            }
            window['$callbackId']({
              success: false,
              error: status !== 'OK' ? status : 'No routes found'
            });
          } catch (e) {
            window['$callbackId']({
              success: false,
              error: 'JavaScript error: ' + (e.message || e.toString())
            });
          }
        }
      ''';
      
      final callback = js.context.callMethod('eval', ['($callbackCode)']);
      if (callback == null) {
        return {'success': false, 'error': 'Failed to create callback'};
      }
      
      js.context[callbackId] = (data) {
        try {
          if (data == null) {
            completer.complete({'success': false, 'error': 'No data received'});
            return;
          }
          
          final dataObj = data as js.JsObject;
          final success = dataObj['success'] as bool? ?? false;
          
          if (success) {
            final polyline = dataObj['polyline'] as String?;
            final distance = dataObj['distance'];
            final duration = dataObj['duration'];
            
            completer.complete({
              'success': true,
              'polyline': polyline ?? '',
              'distance': distance is int ? distance : (distance as num?)?.toInt() ?? 0,
              'distanceText': dataObj['distanceText'] as String? ?? '',
              'duration': duration is int ? duration : (duration as num?)?.toInt() ?? 0,
              'durationText': dataObj['durationText'] as String? ?? '',
              'startAddress': dataObj['startAddress'] as String? ?? '',
              'endAddress': dataObj['endAddress'] as String? ?? '',
            });
          } else {
            completer.complete({
              'success': false,
              'error': dataObj['error'] as String? ?? 'Unknown error',
            });
          }
        } catch (e) {
          completer.complete({'success': false, 'error': 'Failed to process: $e'});
        } finally {
          js.context.deleteProperty(callbackId);
        }
      };
      
      service.callMethod('route', [request, callback]);
      
      return completer.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          js.context.deleteProperty(callbackId);
          return {'success': false, 'error': 'Request timeout'};
        },
      );
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
  
  Future<Map<String, dynamic>> calculateRoute({
    required String origin,
    required String destination,
    String mode = 'driving',
  }) async {
    final result = await getDirections(
      origin: origin,
      destination: destination,
      mode: mode,
    );
    
    if (result['success'] == true) {
      final distance = result['distance'];
      final duration = result['duration'];
      final distanceInt = distance is int ? distance : (distance as num?)?.toInt() ?? 0;
      final durationInt = duration is int ? duration : (duration as num?)?.toInt() ?? 0;
      
      return {
        'success': true,
        'distance': distanceInt,
        'distanceText': result['distanceText'] ?? '',
        'duration': durationInt,
        'durationText': result['durationText'] ?? '',
        'durationMinutes': (durationInt / 60).round(),
      };
    }
    
    return result;
  }
  
  Future<Map<String, dynamic>> getPlaceDetails(String placeId) async {
    try {
      await _waitForGoogleMaps();
      
      final google = js.context['google'];
      if (google == null) {
        return {'success': false, 'error': 'Google Maps API not loaded'};
      }
      
      final maps = google['maps'];
      final places = maps['places'];
      final PlacesService = places['PlacesService'];
      if (PlacesService == null) {
        return {'success': false, 'error': 'PlacesService not available'};
      }
      
      final serviceCode = '''
        (function() {
          var div = document.createElement('div');
          return new google.maps.places.PlacesService(div);
        })()
      ''';
      final service = js.context.callMethod('eval', [serviceCode]) as js.JsObject;
      final completer = Completer<Map<String, dynamic>>();
      
      final request = js.JsObject.jsify({
        'placeId': placeId,
        'fields': ['name', 'formatted_address', 'geometry'],
      });
      
      final callbackId = 'callback_${DateTime.now().millisecondsSinceEpoch}';
      js.context[callbackId] = (place, status) {
        try {
          if (status == 'OK' && place != null) {
            final placeObj = place as js.JsObject;
            final geometry = placeObj['geometry'] as js.JsObject;
            final location = geometry['location'] as js.JsObject;
            
            completer.complete({
              'success': true,
              'name': placeObj['name'] as String,
              'address': placeObj['formatted_address'] as String,
              'lat': location.callMethod('lat', []) as double,
              'lng': location.callMethod('lng', []) as double,
            });
          } else {
            completer.complete({'success': false, 'error': status.toString()});
          }
        } finally {
          js.context.deleteProperty(callbackId);
        }
      };
      
      service.callMethod('getDetails', [request, js.context[callbackId]]);
      
      return completer.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          js.context.deleteProperty(callbackId);
          return {'success': false, 'error': 'Request timeout'};
        },
      );
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
  
  String getStaticMapUrl({
    required String origin,
    required String destination,
    int width = 600,
    int height = 300,
    int zoom = 13,
  }) {
    final encodedOrigin = Uri.encodeComponent(origin);
    final encodedDestination = Uri.encodeComponent(destination);
    
    return 'https://maps.googleapis.com/maps/api/staticmap'
        '?size=${width}x$height'
        '&markers=color:blue|label:A|$encodedOrigin'
        '&markers=color:red|label:B|$encodedDestination'
        '&path=weight:5|color:0x4285F4|$encodedOrigin|$encodedDestination'
        '&key=$apiKey';
  }
  
  Future<String?> getStaticMapUrlWithRoute({
    required String origin,
    required String destination,
    String mode = 'driving',
    int width = 600,
    int height = 300,
  }) async {
    try {
      final directions = await getDirections(
        origin: origin,
        destination: destination,
        mode: mode,
      );
      
      if (directions['success'] == true) {
        final polyline = directions['polyline'] as String?;
        
        if (polyline != null && polyline.isNotEmpty) {
          return 'https://maps.googleapis.com/maps/api/staticmap'
              '?size=${width}x$height'
              '&markers=color:blue|label:A|${Uri.encodeComponent(origin)}'
              '&markers=color:red|label:B|${Uri.encodeComponent(destination)}'
              '&path=enc:$polyline'
              '&key=$apiKey';
        }
      }
      
      return getStaticMapUrl(
        origin: origin,
        destination: destination,
        width: width,
        height: height,
      );
    } catch (e) {
      return getStaticMapUrl(
        origin: origin,
        destination: destination,
        width: width,
        height: height,
      );
    }
  }
  
  Future<Map<String, dynamic>> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return {'success': false, 'error': 'Location services are disabled.'};
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return {'success': false, 'error': 'Location permissions are denied.'};
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return {'success': false, 'error': 'Location permissions are permanently denied.'};
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

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
      return {'success': false, 'error': e.toString()};
    }
  }
  
  bool _isGoogleMapsLoaded() {
    try {
      final google = js.context['google'];
      return google != null && google['maps'] != null;
    } catch (e) {
      return false;
    }
  }
  
  Future<void> _waitForGoogleMaps() async {
    if (_isGoogleMapsLoaded()) return;
    
    int attempts = 0;
    while (!_isGoogleMapsLoaded() && attempts < 50) {
      await Future.delayed(const Duration(milliseconds: 100));
      attempts++;
    }
    if (!_isGoogleMapsLoaded()) {
      throw Exception('Google Maps API failed to load');
    }
  }
}
