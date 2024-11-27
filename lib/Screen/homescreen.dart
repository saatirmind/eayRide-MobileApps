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
  final String Firstname;
  final String Mobile;
  final String Token;

  const HomeScreen({
    Key? key,
    required this.Mobile,
    required this.Token,
    required this.Firstname,
  }) : super(key: key);

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final GlobalKey<GooglemapState> _googleMapKey = GlobalKey();
  String _currentCityName = '';
  LatLng? _currentPosition;

  int _currentCityIndex = -1;

  final List<String> _cities = [
    "Bukit Bintang Walk",
    "Ceylonz Suites, Persiaran Raja Chulan",
    "Scarletz Suites, Jalan Yap Kwan Seng",
    "Central Market",
    "The Colony by Infinitum, Chow Kit",
    "The Mansion, Brickfields",
    "Batu Caves",
    "Thean Hou Temple, Persiaran Endah"
  ];

  final List<LatLng> _cityPositions = [
    LatLng(3.1460887463338447, 101.71770362698292),
    LatLng(3.150236, 101.705465),
    LatLng(3.159932, 101.712492),
    LatLng(3.142896, 101.695771),
    LatLng(3.162606, 101.695721),
    LatLng(3.134852, 101.685504),
    LatLng(3.235014, 101.683455),
    LatLng(3.121977, 101.687094),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _currentPosition = LatLng(3.1390, 101.6869);
    _currentCityName = "Kaula Lumpur, Malaysia";
    _requestLocationPermission(context);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
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
    return Scaffold(
      drawer: Drawerscreen(
        Mobile: widget.Mobile,
        Token: widget.Token,
        Firstname: widget.Firstname,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Googlemap(
              key: _googleMapKey,
              cityPosition: _currentCityIndex == -1
                  ? _currentPosition ?? LatLng(0, 0)
                  : _cityPositions[_currentCityIndex],
              cities: _cities,
              cityPositions: _cityPositions,
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
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
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
}
