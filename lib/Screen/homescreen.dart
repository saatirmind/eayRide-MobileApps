// ignore_for_file: non_constant_identifier_names, unused_element, deprecated_member_use, use_build_context_synchronously, avoid_print, prefer_final_fields
import 'dart:async';
import 'package:easymotorbike/AppColors.dart/EasyrideAppColors.dart';
import 'package:easymotorbike/AppColors.dart/stationprovider.dart';
import 'package:easymotorbike/AppColors.dart/tripprovide.dart';
import 'package:easymotorbike/AppColors.dart/userprovider.dart';
import 'package:easymotorbike/AppColors.dart/walletapi.dart';
import 'package:easymotorbike/settings/setting.dart';
import 'package:easymotorbike/Drawer/drawer.dart';
import 'package:easymotorbike/GoogleMap/googlemap.dart';
import 'package:easymotorbike/HomeScreenWidget/BottomBar.dart';
import 'package:easymotorbike/HomeScreenWidget/PromotionsBanner.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  final String Mobile;
  final String Token;
  final String registered_date;

  const HomeScreen({
    super.key,
    required this.Mobile,
    required this.Token,
    required this.registered_date,
  });

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final GlobalKey<GooglemapState> _googleMapKey = GlobalKey();
  LatLng? _currentPosition;
  final LatLng _kualaLumpur = const LatLng(3.139, 101.6869);

  @override
  Widget build(BuildContext context) {
    final tripProvider = Provider.of<TripProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
        drawer: Drawerscreen(
          Mobile: widget.Mobile,
          Token: widget.Token,
          Firstname: userProvider.firstName,
          registered_date: widget.registered_date,
        ),
        body: Stack(children: [
          Positioned.fill(
            child: GoogleMap(
              key: _googleMapKey,
              initialCameraPosition: CameraPosition(
                target: _currentPosition ?? _kualaLumpur,
                zoom: 12,
              ),
              onMapCreated: (controller) {
                _mapController = controller;
              },
              markers: _markers,
              polylines: _polylines,
            ),
          ),
          const Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: PromotionsBanner(),
          ),
          Positioned(
            top: 350,
            right: -30,
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
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SettingsScreen(),
                          ),
                        );
                      },
                      child: const CircleAvatar(
                        radius: 30,
                        backgroundColor: EasyrideColors.buttonColor,
                        child: Icon(
                          Icons.settings,
                          color: EasyrideColors.buttontextColor,
                          size: 30,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          const Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: BottomBar(),
          ),
          Positioned(
            top: 350,
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
                      onTap: () {
                        GetProfile(context);

                        Scaffold.of(context).openDrawer();
                      },
                      child: const CircleAvatar(
                        radius: 30,
                        backgroundColor: EasyrideColors.buttonColor,
                        child: Icon(
                          Icons.menu,
                          color: EasyrideColors.buttontextColor,
                          size: 30,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          if (isBottomSheetbutton)
            Positioned(
              bottom: 280,
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
                        onTap: () {
                          final stationProvider = Provider.of<StationProvider>(
                              context,
                              listen: false);
                          if (stationProvider.stations.isNotEmpty) {
                            _showBottomSheet(context, stationProvider.stations);
                          }
                        },
                        child: const CircleAvatar(
                          radius: 30,
                          backgroundColor: EasyrideColors.buttonColor,
                          child: Icon(
                            Icons.directions_transit,
                            color: EasyrideColors.buttontextColor,
                            size: 30,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          Positioned(
            top: 150,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10.0,
              ),
              child: Container(
                height: 155,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(1),
                      spreadRadius: 2,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: tripProvider.tripTypes.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                        children: [
                          ...List.generate(
                            (tripProvider.tripTypes.length / 2).ceil(),
                            (index) {
                              int firstIndex = index * 2;
                              int secondIndex = firstIndex + 1;
                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Expanded(
                                    child: RadioListTile<String>(
                                      title: Text(tripProvider
                                          .tripTypes[firstIndex]["name"]),
                                      value: tripProvider.tripTypes[firstIndex]
                                              ["id"]
                                          .toString(),
                                      groupValue: tripProvider.selectedTripType,
                                      onChanged: (value) {
                                        tripProvider
                                            .setSelectedTripType(value!);
                                      },
                                    ),
                                  ),
                                  if (secondIndex <
                                      tripProvider.tripTypes.length)
                                    Expanded(
                                      child: RadioListTile<String>(
                                        title: Text(tripProvider
                                            .tripTypes[secondIndex]["name"]),
                                        value: tripProvider
                                            .tripTypes[secondIndex]["id"]
                                            .toString(),
                                        groupValue:
                                            tripProvider.selectedTripType,
                                        onChanged: (value) {
                                          tripProvider
                                              .setSelectedTripType(value!);
                                        },
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 2),
                          Builder(
                            builder: (context) {
                              final selectedTrip =
                                  tripProvider.tripTypes.firstWhere(
                                (trip) =>
                                    trip["id"].toString() ==
                                    tripProvider.selectedTripType,
                                orElse: () => null,
                              );

                              return selectedTrip != null
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Text(
                                          "Selected Type: ${selectedTrip["name"]}",
                                        ),
                                        Text(
                                            "Rent: ${selectedTrip["price_label"]}"),
                                      ],
                                    )
                                  : Container();
                            },
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ]));
  }

  bool isBottomSheetbutton = false;

  final Set<Polyline> _polylines = {};

  late GoogleMapController _mapController;

  Set<Marker> _markers = {};

  final List<String> _places = [
    "Bukit Bintang Walk",
    "Ceylonz Suites, Persiaran Raja Chulan",
    "Scarletz Suites, Jalan Yap Kwan Seng",
    "Central Market",
    "The Colony by Infinitum, Chow Kit",
    "The Mansion, Brickfields",
    "Batu Caves",
    "Thean Hou Temple, Persiaran Endah",
  ];

  final List<LatLng> _locations = [
    const LatLng(3.1460887463338447, 101.71770362698292),
    const LatLng(3.150236, 101.705465),
    const LatLng(3.159932, 101.712492),
    const LatLng(3.142896, 101.695771),
    const LatLng(3.162606, 101.695721),
    const LatLng(3.134852, 101.685504),
    const LatLng(3.235014, 101.683455),
    const LatLng(3.121977, 101.687094),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _requestLocationPermission();
    initializeApp();
    Provider.of<WalletProvider>(context, listen: false)
        .fetchWalletHistory(context);
    Provider.of<TripProvider>(context, listen: false).fetchTripTypes(context);
  }

  Future<void> initializeApp() async {
    _getCurrentLocation();
    _createMarkers();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _requestLocationPermission();
    }
  }

  Future<void> _requestLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showLocationDialog();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) return;
    }
  }

  void _createMarkers() {
    _markers = _locations.asMap().entries.map((entry) {
      int index = entry.key;
      LatLng location = entry.value;
      return Marker(
        markerId: MarkerId(_places[index]),
        position: location,
        infoWindow: InfoWindow(
          title: _places[index],
          snippet: "Click to select",
        ),
      );
    }).toSet();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);

        _markers.add(
          Marker(
            markerId: const MarkerId('currentLocation'),
            position: _currentPosition!,
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueAzure),
            infoWindow: const InfoWindow(title: 'You are here'),
            onTap: () {
              _mapController
                  .showMarkerInfoWindow(const MarkerId('currentLocation'));
            },
          ),
        );
      });
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('latitude', position.latitude);
      await prefs.setDouble('longitude', position.longitude);

      _mapController.animateCamera(
        CameraUpdate.newLatLngZoom(_currentPosition!, 12),
      );

      Future.delayed(const Duration(milliseconds: 500), () {
        _mapController.showMarkerInfoWindow(const MarkerId('currentLocation'));
      });
      await Provider.of<StationProvider>(context, listen: false)
          .fetchStations(position.latitude, position.longitude);

      Future.delayed(const Duration(milliseconds: 50), () {
        final stationProvider =
            Provider.of<StationProvider>(context, listen: false);
        if (stationProvider.stations.isNotEmpty) {
          _showBottomSheet(context, stationProvider.stations);
        }
      });
    } catch (e) {
      debugPrint("Error fetching location: $e");
    }
  }

  void _showLocationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Location Service Disabled"),
          content: const Text("Please enable location services to continue."),
          actions: [
            TextButton(
              onPressed: () async {
                await Geolocator.openLocationSettings();
                Navigator.of(context).pop();
              },
              child: const Text("Enable"),
            ),
          ],
        );
      },
    );
  }

  void _showBottomSheet(BuildContext context, List<String> stations) {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.black.withOpacity(0.00001),
        isScrollControlled: true,
        isDismissible: false,
        enableDrag: false,
        builder: (context) {
          return GestureDetector(
            onTap: () {
              setState(() {
                isBottomSheetbutton = true;
                Navigator.pop(context);
              });
            },
            behavior: HitTestBehavior.opaque,
            child: Stack(
              children: [
                Container(color: Colors.transparent),
                DraggableScrollableSheet(
                  initialChildSize: 0.25,
                  minChildSize: 0.25,
                  maxChildSize: 0.25,
                  builder: (BuildContext context,
                      ScrollController scrollController) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Center(
                            child: Text(
                              "Nearby Stations",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Expanded(
                            child: ListView.builder(
                              controller: scrollController,
                              itemCount: stations.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  title: Text(stations[index]),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        });
  }
}
