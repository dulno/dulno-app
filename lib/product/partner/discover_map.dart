import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart';

class OSMMap extends StatefulWidget {
  const OSMMap(
      {super.key,
      required this.data,
      required this.mapController,
      required this.latitude,
      required this.longitude,
      required this.radius,
      this.isFirstOpen = true,
      this.initialZoom = 6.0});

  final List<LatLng> data;
  final MapController mapController;
  final double latitude;
  final double longitude;
  final int radius;
  final bool isFirstOpen;
  final double initialZoom;

  @override
  OSMMapState createState() => OSMMapState();
}

class OSMMapState extends State<OSMMap> with SingleTickerProviderStateMixin {
  // Add a flag to control animation to widget.latitude and widget.longitude
  bool shouldAnimateToWidgetPosition = true;

  // Animation Controller for animating map movement
  late AnimationController _animationController;
  late Animation<double> _animation;

  final TextEditingController searchController = TextEditingController();

  // Define the target zoom level
  final double targetElementZoom = 16.0;

  // Start and target positions (Center of Germany) for animation
  LatLng _startCenter = const LatLng(51.1657, 10.4515);
  double _startZoom = 6.0;
  LatLng _targetCenter = const LatLng(51.1657, 10.4515);
  double _targetZoom = 6.0;

  // Duration of the animation
  final Duration _animationDuration = const Duration(milliseconds: 500);

  // Control visibility of the bottom sheet using ValueNotifier
  final ValueNotifier<bool> _showBottomSheet = ValueNotifier(false);

  double _calculateZoom() {
    if (widget.radius <= 5) return 15; // Close zoom for very small radius
    if (widget.radius <= 10) return 14;
    if (widget.radius <= 25) return 13;
    return 6; // Default for very large radius
  }

  void _animationsInitialization() {
    // Initialize the AnimationController
    _animationController = AnimationController(
      vsync: this,
      duration: _animationDuration,
    );

    // Define the initial animation (will be reset later)
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Listen to animation updates
    _animationController.addListener(() {
      final double progress = _animation.value;
      final double newLat = _startCenter.latitude +
          (_targetCenter.latitude - _startCenter.latitude) * progress;
      final double newLng = _startCenter.longitude +
          (_targetCenter.longitude - _startCenter.longitude) * progress;
      final double newZoom = _startZoom + (_targetZoom - _startZoom) * progress;

      // Adjust latitude so that the camera centers on the point when Map Popup is open
      const double cameraAdjust = 0.001;
      widget.mapController.move(LatLng(newLat - cameraAdjust, newLng), newZoom);
    });

    // Listen for animation completion to update start position
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Update the start position to be the new position
        _startCenter = _targetCenter;
        _startZoom = _targetZoom;

        // Show the bottom sheet widget after animation completes
        _showBottomSheet.value = true;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _animationsInitialization();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(OSMMap oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Trigger animation only if latitude, longitude, or zoom changes significantly
    if (oldWidget.latitude != widget.latitude ||
        oldWidget.longitude != widget.longitude) {
      setState(() {
        shouldAnimateToWidgetPosition = true;
      });
    }
  }

  // Function to animate the map movement
  void _animateMapMove(LatLng dest, double destZoom) {
    // If an animation is already running, stop it
    if (_animationController.isAnimating) {
      _animationController.stop();
    }
    // Capture the current map center and zoom
    _startCenter = widget.mapController.camera.center;
    _startZoom = widget.mapController.camera.zoom;

    _targetCenter = dest;
    _targetZoom = destZoom;

    // Reset the animation controller to start from the beginning
    _animationController.reset();

    // Define the animation from 0.0 to 1.0
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Start the animation
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    // Animate the map to widget.latitude and widget.longitude if the flag is true
    if (shouldAnimateToWidgetPosition) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _animateMapMove(LatLng(widget.latitude, widget.longitude),
            widget.isFirstOpen ? widget.initialZoom : _calculateZoom());
      });
    }

    // Convert the points into markers
    final List<Marker> markers = widget.data
        .map(
          (coordinates) => Marker(
            point: coordinates,
            height: 100.0,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  shouldAnimateToWidgetPosition =
                      false; // Disable widget animation
                });

                // Animate the map to the selected marker's location
                _animateMapMove(coordinates, targetElementZoom);
              },
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Image.asset(
                  'assets/images/pin.png',
                  height: 100,
                ),
              ),
            ),
          ),
        )
        .toList();

    return Stack(
      children: [
        FlutterMap(
          mapController: widget.mapController,
          options: MapOptions(
              initialCenter: _startCenter,
              initialZoom: _startZoom,
              minZoom: 3.0,
              maxZoom: 18.0,
              interactionOptions:
                  InteractionOptions(enableMultiFingerGestureRace: true)),
          children: [
            TileLayer(
              urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
              userAgentPackageName:
                  'com.dulno.app.kuB0u5QxTkBGK7LptkOxDoRpaZbMN1TZ',
              tileProvider: CancellableNetworkTileProvider(),
            ),
            MarkerLayer(
              markers: markers,
            ),
          ],
        ),
      ],
    );
  }
}
