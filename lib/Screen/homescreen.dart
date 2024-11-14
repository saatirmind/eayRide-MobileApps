import 'package:easy_localization/easy_localization.dart';
import 'package:easyride/Drawer/drawer.dart';
import 'package:easyride/GoogleMap/googlemap.dart';
import 'package:easyride/HomeScreenWidget/BottomBar.dart';
import 'package:easyride/HomeScreenWidget/Cityselector.dart';
import 'package:easyride/HomeScreenWidget/FloatingButtons.dart';
import 'package:easyride/HomeScreenWidget/PromotionsBanner.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final GlobalKey<GooglemapState> _googleMapKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const Drawerscreen(),
      body: Stack(
        children: [
          Positioned.fill(
              child: Googlemap(
            key: _googleMapKey,
            cityPosition: _cityPositions[_currentCityIndex],
          )),
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
              cityName: _cities[_currentCityIndex].tr(),
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

  int _currentCityIndex = 0;
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
}
