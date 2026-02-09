import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/commute_provider.dart';
import '../widgets/place_autocomplete_field.dart';
import '../widgets/commute_time_modal.dart';
import '../services/google_maps_service.dart';

class CommuteSetupScreen extends StatefulWidget {
  const CommuteSetupScreen({super.key});

  @override
  State<CommuteSetupScreen> createState() => _CommuteSetupScreenState();
}

class _CommuteSetupScreenState extends State<CommuteSetupScreen> {
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();
  final GoogleMapsService _mapsService = GoogleMapsService();
  
  bool _isCalculating = false;
  
  String? _mapImageUrl;
  bool _isLoadingMap = false;
  
  @override
  void initState() {
    super.initState();
  }
  
  Future<void> _loadCurrentLocation() async {
    final result = await _mapsService.getCurrentLocation();
    if (result['success'] == true && mounted) {
      setState(() {
        _fromController.text = result['address'];
      });
      _updateMapPreview();
    }
  }
  
  Future<void> _updateMapPreview() async {
    if (_fromController.text.isEmpty || _toController.text.isEmpty) {
      setState(() {
        _mapImageUrl = null;
      });
      return;
    }
    
    setState(() {
      _isLoadingMap = true;
    });
    
    try {
      final commuteProvider = Provider.of<CommuteProvider>(context, listen: false);
      final mode = commuteProvider.transportMode == TransportMode.car
          ? 'driving'
          : commuteProvider.transportMode == TransportMode.transit
              ? 'transit'
              : 'walking';
      
      // Get the map URL with route
      final mapUrl = await _mapsService.getStaticMapUrlWithRoute(
        origin: _fromController.text,
        destination: _toController.text,
        mode: mode,
        width: 800,
        height: 300,
      );
      
      if (mounted) {
        setState(() {
          _mapImageUrl = mapUrl;
          _isLoadingMap = false;
        });
      }
    } catch (e) {
      print('Error updating map preview: $e');
      if (mounted) {
        setState(() {
          _isLoadingMap = false;
        });
      }
    }
  }
  
  Future<void> _getCurrentLocation() async {
    // Show loading indicator
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            SizedBox(width: 16),
            Text('Getting current location...'),
          ],
        ),
        duration: Duration(seconds: 2),
      ),
    );
    
    final result = await _mapsService.getCurrentLocation();
    
    if (mounted) {
      if (result['success'] == true) {
        final commuteProvider = Provider.of<CommuteProvider>(context, listen: false);
        setState(() {
          _fromController.text = result['address'];
        });
        commuteProvider.setFromLocation(result['address'], placeId: null);
        
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location updated!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error'] ?? 'Unable to get location'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }
  
  Future<void> _calculateCommute(CommuteProvider commuteProvider) async {
    setState(() {
      _isCalculating = true;
    });
    
    try {
      // Calculate commute using real API
      final result = await commuteProvider.calculateCommute();
      
      setState(() {
        _isCalculating = false;
      });
      
      if (!mounted) return;
      
      if (result['success'] == true) {
        // Show modal with result
        await showDialog(
          context: context,
          barrierDismissible: false,
          barrierColor: Colors.transparent, // We handle blur in the modal
          builder: (context) => CommuteTimeModal(
            initialMinutes: result['minutes'],
            distanceKm: result['distance'],
            distanceText: result['distanceText'],
            durationText: result['durationText'],
            fromLocation: _fromController.text,
            toLocation: _toController.text,
            onTimeChanged: (minutes) {
              commuteProvider.setCommuteTimeManually(minutes);
            },
            onConfirm: () {
              // Navigate to home screen
              if (mounted) {
                Navigator.pushReplacementNamed(context, '/degrees');
              }
            },
          ),
        );
      } else {
        // Show error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error'] ?? 'Unable to calculate route'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isCalculating = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final commuteProvider = Provider.of<CommuteProvider>(context);
    
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top App Bar
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back),
                          iconSize: 24,
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.05),
                          ),
                        ),
                        const Expanded(
                          child: Text(
                            'Plan Your Commute',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 44), // Balance the back button
                      ],
                    ),
                  ),
                  
                  // Headline
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 1),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Where are we going today?',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'We\'ll tailor the podcast length to your trip.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Commute Inputs Card
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceDark,
                        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                        border: Border.all(
                          color: AppTheme.borderDark,
                          width: 1,
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Dotted Line Connector
                          Positioned(
                            left: 10,
                            top: 60,
                            bottom: 37,
                            child: Container(
                              child: CustomPaint(
                                painter: DashedLinePainter(),
                              ),
                            ),
                          ),
                          Column(
                            children: [
                              // From Input
                              Row(
                                // 1. This aligns the children vertically in the center
                                crossAxisAlignment: CrossAxisAlignment.center, 
                                children: [
                                  Container(
                                    width: 20,
                                    height: 20,
                                    margin: const EdgeInsets.only(top: 20.0),
                                    alignment: Alignment.center,
                                    child: const Icon(
                                      Icons.my_location,
                                      color: AppTheme.primary,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: PlaceAutocompleteField(
                                      controller: _fromController,
                                      label: 'From',
                                      hintText: 'Enter start location',
                                      icon: Icons.my_location,
                                      iconColor: AppTheme.primary,
                                      showCurrentLocationButton: true,
                                      onCurrentLocationTap: _getCurrentLocation,
                                      onPlaceSelected: (description, placeId) {
                                        commuteProvider.setFromLocation(description, placeId: placeId);
                                        _updateMapPreview();
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 7),
                              // To Input
                              Row(
                                children: [
                                  Container(
                                    width: 20,
                                    height: 20,
                                    margin: const EdgeInsets.only(top: 20.0),
                                    alignment: Alignment.center,
                                    child: const Icon(
                                      Icons.location_on,
                                      color: Colors.red,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: PlaceAutocompleteField(
                                      controller: _toController,
                                      label: 'To',
                                      hintText: 'Enter destination',
                                      icon: Icons.location_on,
                                      iconColor: Colors.red,
                                      onPlaceSelected: (description, placeId) {
                                        commuteProvider.setToLocation(description, placeId: placeId);
                                        _updateMapPreview();
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Saved Places
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Saved Places',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildSavedPlaceChip(Icons.home, 'Home', commuteProvider, "129 Dellbrook Ave, San Francisco, CA 94131, USA"),
                              const SizedBox(width: 12),
                              _buildSavedPlaceChip(Icons.work, 'Work', commuteProvider, "345 Spear St, San Francisco, CA 94105, United States"),
                              const SizedBox(width: 12),
                              _buildSavedPlaceChip(Icons.fitness_center, 'Gym', commuteProvider, "2145 Market St, San Francisco, CA 94114, United States"),
                              const SizedBox(width: 12),
                              _buildSavedPlaceChip(Icons.school, 'Campus', commuteProvider, "50 Frida Kahlo Way, San Francisco, CA 94112, United States"),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Transport Mode
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Transport Mode',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          height: 48,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceDark,
                            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildTransportModeButton(
                                Icons.directions_car,
                                'Car',
                                TransportMode.car,
                                commuteProvider,
                              ),
                              _buildTransportModeButton(
                                Icons.directions_bus,
                                'Transit',
                                TransportMode.transit,
                                commuteProvider,
                              ),
                              _buildTransportModeButton(
                                Icons.directions_walk,
                                'Walk',
                                TransportMode.walk,
                                commuteProvider,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Map Preview
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: GestureDetector(
                      onTap: _mapImageUrl != null ? () {
                        // Optional: Open full-screen map view
                      } : null,
                      child: Container(
                        height: 180,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                          border: Border.all(
                            color: AppTheme.borderDark,
                          ),
                          color: AppTheme.surfaceDark,
                          image: _mapImageUrl != null
                              ? DecorationImage(
                                  image: NetworkImage(_mapImageUrl!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: _isLoadingMap
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppTheme.primary,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Loading route...',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade400,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : _mapImageUrl == null
                                ? Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          AppTheme.surfaceDark,
                                          AppTheme.surfaceDark.withOpacity(0.7),
                                        ],
                                      ),
                                    ),
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.map_outlined,
                                            size: 48,
                                            color: Colors.grey.shade600,
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            'Enter both locations to see route',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey.shade400,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          AppTheme.backgroundDark.withOpacity(0.85),
                                        ],
                                      ),
                                    ),
                                    alignment: Alignment.bottomLeft,
                                    padding: const EdgeInsets.all(12),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.route,
                                          size: 16,
                                          color: AppTheme.primary,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Route preview',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade300,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 100), // Space for button
                ],
              ),
            ),
            
            // Sticky Bottom Button with Progress Bar
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppTheme.backgroundDark.withOpacity(0),
                        AppTheme.backgroundDark,
                        AppTheme.backgroundDark,
                      ],
                    ),
                  ),
                  child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Loading Indicator
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: _isCalculating ? 70 : 0,
                      child: _isCalculating
                          ? Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceDark,
                                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                                border: Border.all(
                                  color: AppTheme.borderDark,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppTheme.primary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Calculating route...',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey.shade300,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                    
                    // Calculate Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isCalculating
                            ? null
                            : () async {
                                if (_toController.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Please enter a destination'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }
                                
                                await _calculateCommute(commuteProvider);
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          elevation: 8,
                          disabledBackgroundColor: Colors.grey.shade700,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                          ),
                          shadowColor: AppTheme.primary.withOpacity(0.25),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(_isCalculating ? Icons.hourglass_empty : Icons.schedule),
                            const SizedBox(width: 8),
                            Text(
                              _isCalculating ? 'Calculating...' : 'Calculate Commute Time',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSavedPlaceChip(IconData icon, String label, CommuteProvider provider, String address) {
    return InkWell(
      onTap: () {
        _toController.text = address;
        provider.setSavedPlace(address, '$address Address');
        _updateMapPreview();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark,
          border: Border.all(
            color: AppTheme.borderDark,
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: Colors.grey.shade400),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade200,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTransportModeButton(
    IconData icon,
    String label,
    TransportMode mode,
    CommuteProvider provider,
  ) {
    final isSelected = provider.transportMode == mode;
    
    return Expanded(
      child: InkWell(
        onTap: () {
          provider.setTransportMode(mode);
          _updateMapPreview();
        },
        child: Container(
          height: 45,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryGradient.colors[0] : Colors.transparent,
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? Colors.white : Colors.grey.shade400,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.white : Colors.grey.shade400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade600
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const dashHeight = 5.0;
    const dashSpace = 3.0;
    double startY = 0;

    while (startY < size.height) {
      canvas.drawLine(
        Offset(0, startY),
        Offset(0, startY + dashHeight),
        paint,
      );
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

