// Platform-specific import - automatically selects the right implementation
export 'google_maps_service_mobile.dart'
  if (dart.library.html) 'google_maps_service_web.dart';
