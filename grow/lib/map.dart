import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

class MapTestPage extends StatefulWidget {
  final LatLng? initialPosition;
  final String? initialAddress;

  const MapTestPage({
    Key? key,
    this.initialPosition,
    this.initialAddress,
  }) : super(key: key);

  @override
  _MapTestPageState createState() => _MapTestPageState();
}

class _MapTestPageState extends State<MapTestPage> {
  final MapController _mapController = MapController();
  late LatLng _currentPosition = const LatLng(31.9539, 35.9106);
  LatLng? _selectedLocation;
  String? _selectedAddress;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _debounce;
  bool _isLoadingCurrentLocation = false;
  bool _isLoadingSearch = false;
  final List<Marker> _markers = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await _getCurrentLocation();
    if (widget.initialPosition != null) {
      setState(() {
        _selectedLocation = widget.initialPosition;
        _mapController.move(_selectedLocation!, 13.0);
        _selectedAddress = _formatLocation(_selectedLocation!);
      });

      _addMarker(_selectedLocation!);
    } else if (widget.initialAddress != null &&
        widget.initialAddress!.isNotEmpty) {
      await _searchAddress(widget.initialAddress!);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _addMarker(LatLng position) {
    setState(() {
      _markers.clear();
      _markers.add(
        Marker(
          point: position,
          width: 50.0,
          height: 50.0,
          child: const Icon(
            Icons.location_pin,
            size: 50.0,
            color: Colors.red,
          ),
        ),
      );
    });
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingCurrentLocation = true;
    });
    try {
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() {
          _isLoadingCurrentLocation = false;
        });
        _currentPosition = const LatLng(31.9539, 35.9106);
        _mapController.move(_currentPosition, 13.0);
        return;
      }
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _isLoadingCurrentLocation = false;
        _currentPosition = LatLng(position.latitude, position.longitude);
      });
      _mapController.move(_currentPosition, 13.0);
    } catch (e) {
      setState(() {
        _isLoadingCurrentLocation = false;
      });
      print("Error getting the current location: $e");
      _currentPosition = const LatLng(31.9539, 35.9106);
      _mapController.move(_currentPosition, 13.0);
    }
  }

  Future<void> _searchAddress(String address) async {
    setState(() {
      _isLoadingSearch = true;
    });
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        LatLng searchedLocation =
            LatLng(locations.first.latitude, locations.first.longitude);
        setState(() {
          _isLoadingSearch = false;
          _currentPosition = searchedLocation;
          _mapController.move(searchedLocation, 13.0);
          _selectedLocation = searchedLocation;
          _selectedAddress = _formatLocation(searchedLocation);
        });

        _addMarker(searchedLocation);
      } else {
        setState(() {
          _isLoadingSearch = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Could not find the location.")),
        );
      }
    } catch (e) {
      setState(() {
        _isLoadingSearch = false;
      });
      print("Error searching the address: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not find the location.")),
      );
    }
  }

  String _formatLocation(LatLng point) {
    return "${point.latitude}, ${point.longitude}";
  }

  Future<void> _getAddressFromCoordinates(LatLng point) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(point.latitude, point.longitude);
      if (placemarks.isNotEmpty) {
        setState(() {
          _selectedAddress = _formatAddress(placemarks.first);
        });
      } else {
        setState(() {
          _selectedAddress = "Could not get the address";
        });
      }
    } catch (e) {
      print('Error getting address: $e');
      _selectedAddress = "Could not get the address";
    }
  }

  String _formatAddress(Placemark placemark) {
    return "${placemark.name ?? ''}, ${placemark.street ?? ''}, ${placemark.locality ?? ''}, ${placemark.administrativeArea ?? ''}, ${placemark.country ?? ''}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  focusNode: _searchFocusNode,
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'ابحث عن عنوان',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _selectedAddress = null;
                                _selectedLocation = null;
                                _markers.clear();
                              });
                              _mapController.move(_currentPosition, 13.0);
                            },
                          )
                        : null,
                  ),
                  onChanged: (value) {
                    if (_debounce?.isActive ?? false) _debounce!.cancel();
                    _debounce = Timer(const Duration(milliseconds: 500), () {
                      if (value.isNotEmpty) {
                        _searchAddress(value);
                      }
                    });
                  },
                ),
              ),
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: _currentPosition,
                        initialZoom: 13.0,
                        onTap: (tapPosition, point) {
                          setState(() {
                            _selectedLocation = point;
                            _selectedAddress = _formatLocation(point);
                          });
                          _addMarker(point);
                        },
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                          subdomains: const ['a', 'b', 'c'],
                        ),
                        MarkerLayer(
                          markers: _markers,
                        ),
                      ],
                    ),
                    if (_isLoadingSearch) const CircularProgressIndicator(),
                  ],
                ),
              ),
              if (_selectedAddress != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    '${_selectedAddress!}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
            ],
          ),
          if (_isLoadingCurrentLocation)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_selectedLocation == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("يرجى اختيار موقع على الخريطة.")),
            );
            return;
          }
          Navigator.pop(context, {
            "latitude": _selectedLocation?.latitude,
            "longitude": _selectedLocation?.longitude,
            "address": _selectedAddress,
          });
        },
        child: const Icon(Icons.check),
      ),
    );
  }
}
