import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:easyride/Drawer/drawer.dart';
import 'package:easyride/GoogleMap/googlemap.dart';
import 'package:easyride/HomeScreenWidget/BottomBar.dart';
import 'package:easyride/HomeScreenWidget/Cityselector.dart';
import 'package:easyride/HomeScreenWidget/FloatingButtons.dart';
import 'package:easyride/HomeScreenWidget/PromotionsBanner.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeScreen extends StatefulWidget {
  final String Mobile;
  final String Token;
  const HomeScreen({Key? key, required this.Mobile, required this.Token})
      : super(key: key);

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final GlobalKey<GooglemapState> _googleMapKey = GlobalKey();
  String _currentCityName = "Current Location";
  LatLng? _currentPosition;
  String loadingText = "Please wait Loading";
  int dotCount = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startLoadingAnimation();
    _requestLocationPermission(context);
  }

  void _startLoadingAnimation() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        dotCount = (dotCount + 1) % 4;
        loadingText = "Please wait, fetching location" + "." * dotCount;
      });
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _requestLocationPermission(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentPosition == null) {
      return Scaffold(
        drawer: Drawerscreen(Mobile: widget.Mobile, Token: widget.Token),
        body: Stack(
          children: [
            Positioned.fill(
              child: Center(
                child: SizedBox(
                  width: 200,
                  child: Text(
                    loadingText,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 50,
              left: 0,
              right: 0,
              child: PromotionsBanner(),
            ),
            Positioned(
              top: 150,
              left: 0,
              right: 0,
              child: CitySelector(
                cityName: _currentCityIndex == -1
                    ? _currentCityName
                    : _cities[_currentCityIndex].tr(),
                onBackPressed: () => _changeCity(-1),
                onForwardPressed: () => _changeCity(1),
              ),
            ),
            Positioned(
              right: 10,
              bottom: 200,
              child: FloatingButtons(
                onMyLocationPressed: () {
                  _googleMapKey.currentState?.goToCurrentLocation();
                  setState(() {
                    _currentCityIndex = -1;
                  });
                },
              ),
            ),
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: BottomBar(),
            ),
            Positioned(
              top: 390,
              left: -30,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(60),
                  color: Colors.white,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Builder(
                    builder: (BuildContext context) {
                      return InkWell(
                        onTap: () => Scaffold.of(context).openDrawer(),
                        child: CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.yellow,
                          child: Icon(
                            Icons.menu,
                            color: Colors.black,
                            size: 30,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      drawer: Drawerscreen(Mobile: widget.Mobile, Token: widget.Token),
      body: Stack(
        children: [
          Positioned.fill(
            child: Googlemap(
              key: _googleMapKey,
              cityPosition: _currentCityIndex == -1
                  ? _currentPosition ?? LatLng(0, 0)
                  : _cityPositions[_currentCityIndex],
            ),
          ),
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: PromotionsBanner(),
          ),
          Positioned(
            top: 150,
            left: 0,
            right: 0,
            child: CitySelector(
              cityName: _currentCityIndex == -1
                  ? _currentCityName
                  : _cities[_currentCityIndex].tr(),
              onBackPressed: () => _changeCity(-1),
              onForwardPressed: () => _changeCity(1),
            ),
          ),
          Positioned(
            right: 10,
            bottom: 200,
            child: FloatingButtons(
              onMyLocationPressed: () {
                _googleMapKey.currentState?.goToCurrentLocation();
                setState(() {
                  _currentCityIndex = -1;
                });
              },
            ),
          ),
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: BottomBar(),
          ),
          Positioned(
            top: 390,
            left: -30,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(60),
                color: Colors.white,
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Builder(
                  builder: (BuildContext context) {
                    return InkWell(
                      onTap: () => Scaffold.of(context).openDrawer(),
                      child: CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.yellow,
                        child: Icon(
                          Icons.menu,
                          color: Colors.black,
                          size: 30,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _requestLocationPermission(BuildContext context) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showLocationDialog(context);
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    LatLng currentLatLng = LatLng(position.latitude, position.longitude);
    setState(() {
      _currentPosition = currentLatLng;
      _currentCityName = "Your Location";
      _googleMapKey.currentState?.moveToPosition(currentLatLng);
    });
  }

  void _changeCity(int direction) {
    setState(() {
      _currentCityIndex = (_currentCityIndex + direction) % _cities.length;
      if (_currentCityIndex < 0) {
        _currentCityIndex = _cities.length - 1;
      }
      _googleMapKey.currentState
          ?.moveToPosition(_cityPositions[_currentCityIndex]);
    });
  }

  void _showLocationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Enable Location Services"),
          content: Text(
              "Location services are disabled. Please enable them to use the app."),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await Geolocator.openLocationSettings();
              },
              child: Text("Open Settings"),
            ),
          ],
        );
      },
    );
  }

  int _currentCityIndex = -1;
  final List<String> _cities = [
    "Kuala Lumpur, Malaysia",
    "New York City",
    "Delhi, India",
    "London, UK",
    "Tokyo, Japan",
    "Mathura, India"
  ];
  final List<LatLng> _cityPositions = [
    LatLng(3.1390, 101.6869),
    LatLng(40.7128, -74.0060),
    LatLng(28.6139, 77.2090),
    LatLng(51.5074, -0.1278),
    LatLng(35.6895, 139.6917),
    LatLng(27.4924, 77.6737),
  ];
}
