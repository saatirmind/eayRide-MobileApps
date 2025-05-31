import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MapScreen4 extends StatefulWidget {
  final double tileLat;
  final double tileLng;

  MapScreen4({required this.tileLat, required this.tileLng});

  @override
  _MapScreen4State createState() => _MapScreen4State();
}

class _MapScreen4State extends State<MapScreen4> {
  late GoogleMapController mapController;
  LatLng? currentLatLng;

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
  }

  Future<void> getCurrentLocation() async {
    Location location = Location();
    var locData = await location.getLocation();

    setState(() {
      currentLatLng = LatLng(locData.latitude!, locData.longitude!);
    });
  }

  @override
  Widget build(BuildContext context) {
    LatLng tileLatLng = LatLng(widget.tileLat, widget.tileLng);

    if (currentLatLng == null) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    Set<Marker> markers = {
      Marker(
        markerId: MarkerId('current'),
        position: currentLatLng!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: InfoWindow(title: "You"),
      ),
      Marker(
        markerId: MarkerId('destination'),
        position: tileLatLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(title: "Destination"),
      ),
    };

    Set<Polyline> polylines = {
      Polyline(
        polylineId: PolylineId('route'),
        color: Colors.blue,
        width: 5,
        points: [currentLatLng!, tileLatLng],
      ),
    };

    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: currentLatLng!,
          zoom: 14,
        ),
        markers: markers,
        polylines: polylines,
        onMapCreated: (controller) {
          mapController = controller;
        },
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }
}
