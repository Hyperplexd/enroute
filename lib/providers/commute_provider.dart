import 'package:flutter/foundation.dart';
import '../services/google_maps_service.dart';

enum TransportMode { car, transit, walk }

class CommuteProvider with ChangeNotifier {
  final GoogleMapsService _mapsService = GoogleMapsService();
  
  String _fromLocation = 'Current Location';
  String _toLocation = '';
  String? _fromPlaceId;
  String? _toPlaceId;
  TransportMode _transportMode = TransportMode.car;
  int _commuteTimeMinutes = 0;
  double _distanceKm = 0.0;
  String _distanceText = '';
  String _durationText = '';
  
  String get fromLocation => _fromLocation;
  String get toLocation => _toLocation;
  String? get fromPlaceId => _fromPlaceId;
  String? get toPlaceId => _toPlaceId;
  TransportMode get transportMode => _transportMode;
  int get commuteTimeMinutes => _commuteTimeMinutes;
  double get distanceKm => _distanceKm;
  String get distanceText => _distanceText;
  String get durationText => _durationText;
  
  void setFromLocation(String location, {String? placeId}) {
    _fromLocation = location;
    _fromPlaceId = placeId;
    notifyListeners();
  }
  
  void setToLocation(String location, {String? placeId}) {
    _toLocation = location;
    _toPlaceId = placeId;
    notifyListeners();
  }
  
  void setTransportMode(TransportMode mode) {
    _transportMode = mode;
    notifyListeners();
  }
  
  Future<Map<String, dynamic>> calculateCommute() async {
    // Get the mode string for API
    String mode = 'driving';
    switch (_transportMode) {
      case TransportMode.car:
        mode = 'driving';
        break;
      case TransportMode.transit:
        mode = 'transit';
        break;
      case TransportMode.walk:
        mode = 'walking';
        break;
    }
    
    // Call the real Google Maps API
    final result = await _mapsService.getDirections(
      origin: _fromLocation,
      destination: _toLocation,
      mode: mode,
    );
    
    if (result['success'] == true) {
      _commuteTimeMinutes = (result['duration'] / 60).round();
      _distanceKm = (result['distance'] / 1000);
      _distanceText = result['distanceText'] ?? '';
      _durationText = result['durationText'] ?? '';
      notifyListeners();
      
      return {
        'success': true,
        'minutes': _commuteTimeMinutes,
        'distance': _distanceKm,
        'distanceText': _distanceText,
        'durationText': _durationText,
      };
    } else {
      return {
        'success': false,
        'error': result['error'] ?? 'Unable to calculate route',
      };
    }
  }
  
  void setCommuteTimeManually(int minutes) {
    _commuteTimeMinutes = minutes;
    notifyListeners();
  }
  
  void setSavedPlace(String placeName, String address) {
    _toLocation = address;
    notifyListeners();
  }
}

