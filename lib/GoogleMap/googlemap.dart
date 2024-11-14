import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class Googlemap extends StatefulWidget {
  final LatLng cityPosition;

  Googlemap({required this.cityPosition, Key? key}) : super(key: key);

  @override
  GooglemapState createState() => GooglemapState();
}

class GooglemapState extends State<Googlemap> {
  late GoogleMapController _mapController;
  Location location = Location();
  Marker? _currentLocationMarker;

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _moveCamera(widget.cityPosition);
  }

  void _moveCamera(LatLng position) {
    _mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: position, zoom: 10.0),
      ),
    );
  }

  Future<void> goToCurrentLocation() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    LocationData locationData = await location.getLocation();
    LatLng currentLocation =
        LatLng(locationData.latitude!, locationData.longitude!);

    setState(() {
      _currentLocationMarker = Marker(
        markerId: MarkerId("currentLocation"),
        position: currentLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      );
    });

    _moveCamera(currentLocation);
  }

  void moveToPosition(LatLng position) {
    _moveCamera(position);
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      onMapCreated: _onMapCreated,
      initialCameraPosition: CameraPosition(
        target: widget.cityPosition,
        zoom: 10.0,
      ),
      markers: _currentLocationMarker != null ? {_currentLocationMarker!} : {},
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
    );
  }
}
