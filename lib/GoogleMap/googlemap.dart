// ignore_for_file: unused_element
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class Googlemap extends StatefulWidget {
  final LatLng cityPosition;
  final List<String> cities;
  final List<LatLng> cityPositions;

  const Googlemap(
      {required this.cityPosition,
      super.key,
      required this.cities,
      required this.cityPositions});

  @override
  GooglemapState createState() => GooglemapState();
}

class GooglemapState extends State<Googlemap> {
  late GoogleMapController _mapController;
  Location location = Location();
  Marker? _currentLocationMarker;
  Marker? _defaultLocationMarker;
  late List<Marker> _cityMarkers;

  @override
  void initState() {
    super.initState();
    _createCityMarkers();
    _defaultLocationMarker = Marker(
      markerId: const MarkerId("defaultLocation"),
      position: widget.cityPosition,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
    );
  }

  void _createCityMarkers() {
    _cityMarkers = [];
    for (int i = 0; i < widget.cities.length; i++) {
      _cityMarkers.add(Marker(
        markerId: MarkerId("city$i"),
        position: widget.cityPositions[i],
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose),
        infoWindow: InfoWindow(title: widget.cities[i]),
      ));
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _moveCamera(widget.cityPosition, 10);
  }

  void _moveCamera(
    LatLng position,
    double zoomLevel,
  ) {
    _mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: position, zoom: zoomLevel),
      ),
    );
  }

  Future<void> goToCurrentLocation() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    LocationData locationData = await location.getLocation();
    LatLng currentLocation =
        LatLng(locationData.latitude!, locationData.longitude!);

    setState(() {
      _currentLocationMarker = Marker(
        markerId: const MarkerId("currentLocation"),
        position: currentLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      );
      _defaultLocationMarker = null;
    });

    _moveCamera(currentLocation, 15);
  }

  void moveToPosition(LatLng position) {
    _moveCamera(position, 15.0);
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      onMapCreated: (GoogleMapController controller) {
        _mapController = controller;
      },
      initialCameraPosition: CameraPosition(
        target: widget.cityPosition,
        zoom: 10.0,
      ),
      markers: {
        if (_defaultLocationMarker != null) _defaultLocationMarker!,
        ..._cityMarkers,
        if (_currentLocationMarker != null) _currentLocationMarker!,
      },
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
    );
  }
}
