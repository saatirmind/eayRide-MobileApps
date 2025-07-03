// ignore_for_file: sort_child_properties_last

/*// ignore_for_file: non_constant_identifier_names, unused_element, deprecated_member_use, use_build_context_synchronously, avoid_print, prefer_final_fields, sort_child_properties_last
import 'dart:async';
import 'dart:convert';
import 'package:easymotorbike/AppColors.dart/EasyrideAppColors.dart';
import 'package:easymotorbike/AppColors.dart/tripprovide.dart';
import 'package:easymotorbike/AppColors.dart/userprovider.dart';
import 'package:easymotorbike/AppColors.dart/walletapi.dart';
import 'package:easymotorbike/DrawerWidget/Tourist_attraction.dart';
import 'package:easymotorbike/settings/setting.dart';
import 'package:easymotorbike/Drawer/drawer.dart';
import 'package:easymotorbike/GoogleMap/googlemap.dart';
import 'package:easymotorbike/HomeScreenWidget/BottomBar.dart';
import 'package:easymotorbike/HomeScreenWidget/PromotionsBanner.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
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
            top: 420,
            right: -10,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    EasyrideColors.buttonColor,
                    EasyrideColors.buttonColor
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                // boxShadow: [
                //   BoxShadow(
                //     color: Colors.black26,
                //     blurRadius: 6,
                //     offset: Offset(0, 3),
                //   ),
                // ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(0.0),
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
            top: 420,
            left: -10,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    EasyrideColors.buttonColor,
                    EasyrideColors.buttonColor
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.all(0),
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
          // if (isBottomSheetbutton)
          //   Positioned(
          //     bottom: 280,
          //     left: -30,
          //     child: Container(
          //       decoration: BoxDecoration(
          //         borderRadius: BorderRadius.circular(60),
          //         color: Colors.white,
          //       ),
          //       child: Padding(
          //         padding: const EdgeInsets.all(8.0),
          //         child: Builder(
          //           builder: (BuildContext context) {
          //             return InkWell(
          //               onTap: () {
          //                 final stationProvider = Provider.of<StationProvider>(
          //                     context,
          //                     listen: false);
          //                 if (stationProvider.stations.isNotEmpty) {
          //                   _showBottomSheet(context, stationProvider.stations);
          //                 }
          //               },
          //               child: const CircleAvatar(
          //                 radius: 30,
          //                 backgroundColor: EasyrideColors.buttonColor,
          //                 child: Icon(
          //                   Icons.directions_transit,
          //                   color: EasyrideColors.buttontextColor,
          //                   size: 30,
          //                 ),
          //               ),
          //             );
          //           },
          //         ),
          //       ),
          //     ),
          //   ),
          Positioned(
            top: 150,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 18.0,
              ),
              child: Container(
                height: 110,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  // boxShadow: [
                  //   BoxShadow(
                  //     color: Colors.grey.withOpacity(1),
                  //     spreadRadius: 2,
                  //     blurRadius: 4,
                  //     offset: const Offset(0, 2),
                  //   ),
                  // ],
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
                          const Divider(height: 1),
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
                                            "Rent: ${selectedTrip["price_label"]} Per Minute"),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 6),
                                          child: Row(
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          TouristScreen(),
                                                    ),
                                                  );
                                                },
                                                child: const Row(
                                                  children: [
                                                    Icon(Icons.place,
                                                        color: Colors.blue),
                                                    SizedBox(width: 4),
                                                    Text(
                                                      "Tourist Attractions",
                                                      style: TextStyle(
                                                        color: Colors.blue,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
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
          Positioned(
            top: 280,
            left: 10,
            right: 10,
            child: Column(
              children: [
                PopupMenuButton<String>(
                  onSelected: (value) async {
                    setState(() {
                      _pickupCity = value;
                    });
                    String? PselectedId;
                    if (_pickupCity != null) {
                      final parts = _pickupCity!.split('(ID:');
                      if (parts.length > 1) {
                        PselectedId = parts[1].replaceAll(')', '').trim();
                      }
                    }
                    if (_pickupCity == _destinationCity) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              "Pickup and Destination cannot be the same!"),
                          backgroundColor: EasyrideColors.Alertsank,
                        ),
                      );
                      setState(() {
                        _destinationCity = null;
                      });
                    } else {
                      await _saveCity(
                          'pickupCity', _pickupCity?.split('(ID:')[0].trim());
                      if (PselectedId != null) {
                        _selectpickupstateAPI(PselectedId);
                        _createPolylines();
                      }
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    return _pickupLocationapi.map((place) {
                      final parts = place.split('(ID:');
                      final displayName = parts[0].trim();
                      return PopupMenuItem<String>(
                        value: place,
                        child: Text(
                          displayName,
                          style: TextStyle(
                            color: EasyrideColors.Dropertext,
                          ),
                        ),
                      );
                    }).toList();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Icon(Icons.location_on),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _pickupCity?.split('(ID:')[0].trim() ??
                                "Select Pickup Location",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        Icon(Icons.keyboard_arrow_down),
                      ],
                    ),
                  ),
                  offset: Offset(0, 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  color: EasyrideColors.buttonColor,
                ),
                SizedBox(
                  height: 5,
                ),
                Column(
                  children: [
                    PopupMenuButton<String>(
                      onSelected: (value) async {
                        setState(() {
                          _destinationCity = value;
                        });
                        String? DselectedId;
                        if (_destinationCity != null) {
                          final parts = _destinationCity!.split('(ID:');
                          if (parts.length > 1) {
                            DselectedId = parts[1].replaceAll(')', '').trim();
                          }
                        }
                        if (_pickupCity == _destinationCity) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  "Pickup and Destination cannot be the same!"),
                              backgroundColor: Colors.red,
                            ),
                          );
                          setState(() {
                            _destinationCity = null;
                          });
                        } else {
                          await _saveCity('destinationCity',
                              _destinationCity?.split('(ID:')[0].trim());
                          if (DselectedId != null) {
                            _selectdropstateAPI(DselectedId);
                            _createPolylines();
                            await Future.delayed(Duration(seconds: 2));

                            await _selectdropstateAPI(DselectedId);

                            _createPolylines();
                          }
                        }
                      },
                      itemBuilder: (BuildContext context) {
                        return _dropLocationapi.map((place) {
                          final parts = place.split('(ID:');
                          final displayName = parts[0].trim();
                          return PopupMenuItem<String>(
                              value: place,
                              child: Text(
                                displayName,
                                style: TextStyle(
                                  color: EasyrideColors.Dropertext,
                                ),
                              ));
                        }).toList();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: const Row(
                          children: [
                            Icon(Icons.location_on),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                //_destinationCity?.split('(ID:')[0].trim() ??
                                "Select Destination Location",
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                            Icon(Icons.keyboard_arrow_down),
                          ],
                        ),
                      ),
                      offset: const Offset(0, 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      color: EasyrideColors.buttonColor,
                    ),
                  ],
                ),
              ],
            ),
          )
        ]));
  }

  bool isBottomSheetbutton = false;

  final Set<Polyline> _polylines = {};

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
    _getCurrentLocationV1();
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

  Future<void> _getCurrentLocationV1() async {
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

      // Future.delayed(const Duration(milliseconds: 500), () {
      //   _mapController.showMarkerInfoWindow(const MarkerId('currentLocation'));
      // });
      // await Provider.of<StationProvider>(context, listen: false)
      //     .fetchStations(position.latitude, position.longitude);

      // Future.delayed(const Duration(milliseconds: 50), () {
      //   final stationProvider =
      //       Provider.of<StationProvider>(context, listen: false);
      //   if (stationProvider.stations.isNotEmpty) {
      //     _showBottomSheet(context, stationProvider.stations);
      //   }
      // });
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

  // void _showBottomSheet(BuildContext context, List<String> stations) {
  //   showModalBottomSheet(
  //       context: context,
  //       backgroundColor: Colors.black.withOpacity(0.00001),
  //       isScrollControlled: true,
  //       isDismissible: false,
  //       enableDrag: false,
  //       builder: (context) {
  //         return GestureDetector(
  //           onTap: () {
  //             setState(() {
  //               isBottomSheetbutton = true;
  //               Navigator.pop(context);
  //             });
  //           },
  //           behavior: HitTestBehavior.opaque,
  //           child: Stack(
  //             children: [
  //               Container(color: Colors.transparent),
  //               DraggableScrollableSheet(
  //                 initialChildSize: 0.25,
  //                 minChildSize: 0.25,
  //                 maxChildSize: 0.25,
  //                 builder: (BuildContext context,
  //                     ScrollController scrollController) {
  //                   return Container(
  //                     padding: const EdgeInsets.all(16),
  //                     decoration: const BoxDecoration(
  //                       color: Colors.white,
  //                       borderRadius:
  //                           BorderRadius.vertical(top: Radius.circular(20)),
  //                     ),
  //                     child: Column(
  //                       crossAxisAlignment: CrossAxisAlignment.start,
  //                       children: [
  //                         const Center(
  //                           child: Text(
  //                             "Nearby Stations",
  //                             style: TextStyle(
  //                                 fontSize: 18, fontWeight: FontWeight.bold),
  //                           ),
  //                         ),
  //                         const SizedBox(height: 10),
  //                         Expanded(
  //                           child: ListView.builder(
  //                             controller: scrollController,
  //                             itemCount: stations.length,
  //                             itemBuilder: (context, index) {
  //                               return ListTile(
  //                                 title: Text(stations[index]),
  //                               );
  //                             },
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   );
  //                 },
  //               ),
  //             ],
  //           ),
  //         );
  //       });
  // }

  int _selectedValue = 1;
  String? _pickupCity;
  String? _destinationCity;

  late GoogleMapController _mapController;

  Future<void> _createPolylines() async {
    if (_selectedStartLocation != null && _selectedEndLocation != null) {
      final route =
          await _getRoute(_selectedStartLocation!, _selectedEndLocation!);
      if (route != null) {
        setState(() {
          _polylines.add(Polyline(
            polylineId: PolylineId("route"),
            color: Colors.blue,
            width: 5,
            points: route,
          ));
        });

        _mapController.animateCamera(CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(
                _selectedStartLocation!.latitude <
                        _selectedEndLocation!.latitude
                    ? _selectedStartLocation!.latitude
                    : _selectedEndLocation!.latitude,
                _selectedStartLocation!.longitude <
                        _selectedEndLocation!.longitude
                    ? _selectedStartLocation!.longitude
                    : _selectedEndLocation!.longitude),
            northeast: LatLng(
                _selectedStartLocation!.latitude >
                        _selectedEndLocation!.latitude
                    ? _selectedStartLocation!.latitude
                    : _selectedEndLocation!.latitude,
                _selectedStartLocation!.longitude >
                        _selectedEndLocation!.longitude
                    ? _selectedStartLocation!.longitude
                    : _selectedEndLocation!.longitude),
          ),
          50,
        ));
      }
    }
  }

  Future<List<LatLng>?> _getRoute(LatLng start, LatLng end) async {
    String directionsUrl = AppApi.getDirectionsUrl(
        start.latitude, start.longitude, end.latitude, end.longitude);
    try {
      final response = await http.get(Uri.parse(directionsUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final route = data['routes'][0]['overview_polyline']['points'];
          return _decodePoly(route);
        }
      }
    } catch (e) {
      debugPrint("Error fetching route: $e");
    }
    return null;
  }

  List<LatLng> _decodePoly(String encoded) {
    List<LatLng> polylinePoints = [];
    int index = 0;
    int len = encoded.length;
    int lat = 0;
    int lng = 0;

    while (index < len) {
      int b;
      int shift = 0;
      int result = 0;
      do {
        b = encoded.codeUnitAt(index) - 63;
        index++;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      int dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index) - 63;
        index++;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      int dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      polylinePoints.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return polylinePoints;
  }

  void _updateMapPosition(
      String selectedCity, LatLng position, int selectedIndex) {
    setState(() {
      _selectedStartLocation = position;
    });
    _mapController.animateCamera(CameraUpdate.newLatLngZoom(position, 10));
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _initstateAPI();

        _markers.add(
          Marker(
            markerId: MarkerId('currentLocation'),
            position: _currentPosition!,
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueAzure),
            infoWindow: InfoWindow(title: 'You are here'),
            onTap: () {
              _mapController.showMarkerInfoWindow(MarkerId('currentLocation'));
            },
          ),
        );
      });

      _mapController.animateCamera(
        CameraUpdate.newLatLngZoom(_currentPosition!, 12),
      );

      Future.delayed(Duration(milliseconds: 500), () {
        _mapController.showMarkerInfoWindow(MarkerId('currentLocation'));
      });
    } catch (e) {
      debugPrint("Error fetching location: $e");
    }
  }

  Future<void> _saveCity(String key, String? value) async {
    if (value != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
    }
  }

  Future<String?> getSavedState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('StartState');
  }

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> _initstateAPI() async {
    final token = await getToken();

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Token is missing. Please log in again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    String tripWiseValue = _selectedValue == 1 ? 'trip_wise' : 'minute_wise';
    final String? state = await getSavedState();
    if (state == null) {
      print('State is missing. Please set a state first.');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(AppApi.PickupDropLocation),
        headers: {
          'Content-Type': 'application/json',
          'token': token,
        },
        body: jsonEncode({
          'state': 'Uttar Pradesh',
          'trip_type': tripWiseValue,
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true) {
          final Map<String, dynamic> data = jsonDecode(response.body);

          setState(() {
            HomeScreen = data['data']['pickup_locations'];

            _pickupLocationapi = HomeScreen.map((location) {
              final name = location['name'] ?? 'Unknown';
              final id = location['id'] ?? 'N/A';
              return '$name (ID: $id)';
            }).toList();
          });

          List pickupLocationsapi = data['data']['pickup_locations'];
          print('Pickup Locations: $pickupLocationsapi');
          for (var location in pickupLocationsapi) {
            print('Location Name: ${location['name']}');
            print('Latitude: ${location['latitude']}');
            print('Longitude: ${location['longitude']}');
          }
        } else {
          print('Error: ${data['message']}');
        }
      } else {
        print('Server Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error occurred: $error');
    }
  }

  List<dynamic> HomeScreen = [];
  List<String> _pickupLocationapi = [];
  List<String> _dropLocationapi = [];

  Future<void> _selectpickupstateAPI(String PselectedId) async {
    final token = await getToken();

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Token is missing. Please log in again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    String tripWiseValue = _selectedValue == 1 ? 'trip_wise' : 'minute_wise';
    final String? state = await getSavedState();
    if (state == null) {
      print('State is missing. Please set a state first.');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(AppApi.PickupDropLocation),
        headers: {
          'Content-Type': 'application/json',
          'token': token,
        },
        body: jsonEncode({
          'state': 'Uttar Pradesh',
          'trip_type': tripWiseValue,
          'pickup_location': PselectedId,
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true) {
          final Map<String, dynamic> data = jsonDecode(response.body);
          final Map<String, dynamic> responseData = data;

          setState(() {
            selectedlocationp = responseData['data']['selected_pickup_location']
                    ['id']
                .toString();
            pickuplat = double.parse(responseData['data']
                    ['selected_pickup_location']['latitude']
                .toString());
            pickuplong = double.parse(responseData['data']
                    ['selected_pickup_location']['longitude']
                .toString());
            _selectedStartLocation = LatLng(pickuplat, pickuplong);
            _markers.add(Marker(
                markerId: MarkerId('pickup_location'),
                position: _selectedStartLocation!,
                infoWindow: InfoWindow(
                  title: 'Pickup Location',
                  snippet: 'Latitude: $pickuplat, Longitude: $pickuplong',
                )));

            HomeScreen = data['data']['drop_locations'];

            _dropLocationapi = HomeScreen.map((location) {
              final name = location['name'] ?? 'Unknown';
              final id = location['id'] ?? 'N/A';
              return '$name (ID: $id)';
            }).toList();
          });

          List _dropLocationsapi = data['data']['drop_locations'];
          print('Drop Locations: $_dropLocationsapi');
          for (var location in _dropLocationsapi) {
            print('Location Name: ${location['name']}');
            print('Latitude: ${location['latitude']}');
            print('Longitude: ${location['longitude']}');
          }
        } else {
          print('Error: ${data['message']}');
        }
      } else {
        print('Server Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error occurred: $error');
    }
  }

  String securityAmountLabel = '';
  String destination = '';
  String finalPrice = '';
  String totalAmountLabel = '';
  String selectedlocationp = '';
  String selectedlocationw = '';
  String Walletamount = '';
  dynamic pickuplat = '';
  dynamic pickuplong = '';
  dynamic droplat = '';
  dynamic droplong = '';
  LatLng? _selectedStartLocation;
  LatLng? _selectedEndLocation;
  String selectedlocationd = '';

  Future<void> _selectdropstateAPI(String DselectedId) async {
    final token = await getToken();
    print('HIT API SELECTED STATE API');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Token is missing. Please log in again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    String tripWiseValue = _selectedValue == 1 ? 'trip_wise' : 'minute_wise';
    final String? state = await getSavedState();
    if (state == null) {
      print('State is missing. Please set a state first.');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(AppApi.PickupDropLocation),
        headers: {
          'Content-Type': 'application/json',
          'token': token,
        },
        body: jsonEncode({
          'state': 'Uttar Pradesh',
          'trip_type': tripWiseValue,
          'pickup_location': selectedlocationp,
          'drop_location': DselectedId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == true) {
          final Map<String, dynamic> responseData = data;

          setState(() {
            selectedlocationw =
                responseData['data']['selected_drop_location']['id'].toString();
            securityAmountLabel = responseData['data']['security_amount_label'];
            destination = responseData['data']['destination_lebal'];
            finalPrice = responseData['data']['final_price'].toString();
            totalAmountLabel = responseData['data']['total_amount_lebal'];
            selectedlocationd =
                responseData['data']['selected_drop_location']['id'].toString();

            droplat = double.parse(responseData['data']
                    ['selected_drop_location']['latitude']
                .toString());
            droplong = double.parse(responseData['data']
                    ['selected_drop_location']['longitude']
                .toString());

            _selectedEndLocation = LatLng(droplat, droplong);
            _markers.add(Marker(
                markerId: MarkerId('drop_location'),
                position: _selectedEndLocation!,
                infoWindow: InfoWindow(
                  title: 'Drop Location',
                  snippet: 'Latitude: $droplat, Longitude: $droplong',
                )));
            _markers.add(Marker(
                markerId: MarkerId('pickup_location'),
                position: _selectedStartLocation!,
                infoWindow: InfoWindow(
                  title: 'Pickup Location',
                  snippet: 'Latitude: $pickuplat, Longitude: $pickuplong',
                )));
          });
          saveLocationToSharedPreferences(
              _selectedStartLocation!, _selectedEndLocation!);
          _saveSelectedcity();
        } else {
          print('Error: ${data['message']}');
        }
      } else {
        print('Server Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error occurred: $error');
    }
  }

  Future<void> _saveSelectedcity() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('selectedlocationd', selectedlocationd);
    await prefs.setString('selectedlocationp', selectedlocationp);
  }

  Future<void> saveLocationToSharedPreferences(
      LatLng startLocation, LatLng endLocation) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setDouble('start_latitude', startLocation.latitude);
    await prefs.setDouble('start_longitude', startLocation.longitude);

    await prefs.setDouble('end_latitude', endLocation.latitude);
    await prefs.setDouble('end_longitude', endLocation.longitude);
  }
}*/

// ignore_for_file: non_constant_identifier_names, unused_element, deprecated_member_use, use_build_context_synchronously, avoid_print, prefer_final_fields
import 'dart:async';
import 'package:easymotorbike/AppColors.dart/EasyrideAppColors.dart';
import 'package:easymotorbike/AppColors.dart/dropapi.dart';
import 'package:easymotorbike/AppColors.dart/pickupapi.dart';
import 'package:easymotorbike/AppColors.dart/tripprovide.dart';
import 'package:easymotorbike/AppColors.dart/userprovider.dart';
import 'package:easymotorbike/AppColors.dart/walletapi.dart';
import 'package:easymotorbike/DrawerWidget/Tourist_attraction.dart';
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
    return SafeArea(
      child: Scaffold(
          drawer: Drawerscreen(),
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
            Positioned(
              top: MediaQuery.of(context).padding.top + 25,
              left: 0,
              right: 0,
              child: const PromotionsBanner(),
            ),
            // Positioned(
            //   top: 420,
            //   right: -10,
            //   child: Container(
            //     decoration: BoxDecoration(
            //       gradient: const LinearGradient(
            //         colors: [
            //           EasyrideColors.buttonColor,
            //           EasyrideColors.buttonColor
            //         ],
            //         begin: Alignment.topLeft,
            //         end: Alignment.bottomRight,
            //       ),
            //       borderRadius: BorderRadius.circular(18),
            //       // boxShadow: [
            //       //   BoxShadow(
            //       //     color: Colors.black26,
            //       //     blurRadius: 6,
            //       //     offset: Offset(0, 3),
            //       //   ),
            //       // ],
            //     ),
            //     child: Padding(
            //       padding: const EdgeInsets.all(0.0),
            //       child: Builder(
            //         builder: (BuildContext context) {
            //           return InkWell(
            //             onTap: () {
            //               Navigator.push(
            //                 context,
            //                 MaterialPageRoute(
            //                   builder: (context) => const SettingsScreen(),
            //                 ),
            //               );
            //             },
            //             child: const CircleAvatar(
            //               radius: 30,
            //               backgroundColor: EasyrideColors.buttonColor,
            //               child: Icon(
            //                 Icons.settings,
            //                 color: EasyrideColors.buttontextColor,
            //                 size: 30,
            //               ),
            //             ),
            //           );
            //         },
            //       ),
            //     ),
            //   ),
            // ),
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 25,
              left: 0,
              right: 0,
              child: const BottomBar(),
            ),
            // Positioned(
            //   top: 420,
            //   left: -10,
            //   child: Container(
            //     decoration: BoxDecoration(
            //       gradient: const LinearGradient(
            //         colors: [
            //           EasyrideColors.buttonColor,
            //           EasyrideColors.buttonColor
            //         ],
            //         begin: Alignment.topLeft,
            //         end: Alignment.bottomRight,
            //       ),
            //       borderRadius: BorderRadius.circular(18),
            //     ),
            //     child: Padding(
            //       padding: const EdgeInsets.all(0),
            //       child: Builder(
            //         builder: (BuildContext context) {
            //           return InkWell(
            //             onTap: () {
            //               // GetProfile(context);

            //               Scaffold.of(context).openDrawer();
            //             },
            //             child: const CircleAvatar(
            //               radius: 30,
            //               backgroundColor: EasyrideColors.buttonColor,
            //               child: Icon(
            //                 Icons.menu,
            //                 color: EasyrideColors.buttontextColor,
            //                 size: 30,
            //               ),
            //             ),
            //           );
            //         },
            //       ),
            //     ),
            //   ),
            // ),
            Positioned(
              top: 10,
              left: 10,
              child: GestureDetector(
                onTap: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 20),
                ),
              ),
            ),

            Positioned(
              top: MediaQuery.of(context).padding.top + 130,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18.0,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    // boxShadow: [
                    //   BoxShadow(
                    //     color: Colors.grey.withOpacity(1),
                    //     spreadRadius: 2,
                    //     blurRadius: 4,
                    //     offset: const Offset(0, 2),
                    //   ),
                    // ],
                  ),
                  child: tripProvider.tripTypes.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : Column(
                          children: [
                            // ...List.generate(
                            //   (tripProvider.tripTypes.length / 2).ceil(),
                            //   (index) {
                            //     int firstIndex = index * 2;
                            //     int secondIndex = firstIndex + 1;
                            //     return Row(
                            //       mainAxisAlignment:
                            //           MainAxisAlignment.spaceEvenly,
                            //       children: [
                            //         Expanded(
                            //           child: RadioListTile<String>(
                            //             title: Text(tripProvider
                            //                 .tripTypes[firstIndex]["name"]),
                            //             value: tripProvider
                            //                 .tripTypes[firstIndex]["id"]
                            //                 .toString(),
                            //             groupValue:
                            //                 tripProvider.selectedTripType,
                            //             onChanged: (value) {
                            //               tripProvider
                            //                   .setSelectedTripType(value!);
                            //             },
                            //           ),
                            //         ),
                            //         if (secondIndex <
                            //             tripProvider.tripTypes.length)
                            //           Expanded(
                            //             child: RadioListTile<String>(
                            //               title: Text(tripProvider
                            //                   .tripTypes[secondIndex]["name"]),
                            //               value: tripProvider
                            //                   .tripTypes[secondIndex]["id"]
                            //                   .toString(),
                            //               groupValue:
                            //                   tripProvider.selectedTripType,
                            //               onChanged: (value) {
                            //                 tripProvider
                            //                     .setSelectedTripType(value!);
                            //               },
                            //             ),
                            //           ),
                            //       ],
                            //     );
                            //   },
                            // ),

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
                                              "${selectedTrip["price_label"]} Per KM"),
                                          // 'RM 0.80 Per KM'),
                                          const Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 6),
                                            child: Row(
                                              children: [
                                                Text(
                                                  "Min RM 20 to start the ride",
                                                  style: TextStyle(),
                                                ),
                                              ],
                                            ),
                                          ),
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
            Positioned(
              top: MediaQuery.of(context).padding.top + 160,
              left: 10,
              right: 10,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    // ----------- Pickup Dropdown -------------
                    PopupMenuButton<String>(
                      onSelected: (value) async {
                        final parts = value.split('(ID:');
                        setState(() {
                          _pickupCity = parts[0].trim();
                          _pickupId = parts.length > 1
                              ? parts[1].replaceAll(')', '').trim()
                              : null;
                          _dropCity = null;
                          _dropLocationapi.clear();
                        });

                        // ✅ Save to SharedPreferences
                        if (_pickupId != null) {
                          final prefs = await SharedPreferences.getInstance();

                          // ✅ Find the selected model by ID
                          final selectedPickupModel = locations.firstWhere(
                            (model) => model.id.toString() == _pickupId,
                            orElse: () => LocationModel(
                              id: 0,
                              name: '',
                              state: 0,
                              status: 0,
                              latitude: 0.0,
                              longitude: 0.0,
                            ),
                          );

                          // ✅ Save to SharedPreferences
                          await prefs.setString('pickupCityId', _pickupId!);
                          await prefs.setDouble(
                              'pickup_latitude', selectedPickupModel.latitude);
                          await prefs.setDouble('pickup_longitude',
                              selectedPickupModel.longitude);

                          print(
                              '✅ Saved Pickup Location: ${selectedPickupModel.latitude}, ${selectedPickupModel.longitude}');
                        }

                        if (_pickupId != null) {
                          final dropList =
                              await fetchDropLocationByPickupId(_pickupId!);
                          setState(() {
                            _dropLocationModelList = dropList;
                            _dropLocationapi = dropList
                                .map((e) => '${e.name} (ID: ${e.id})')
                                .toList();
                          });
                        }
                      },
                      itemBuilder: (BuildContext context) {
                        return locations.map((location) {
                          return PopupMenuItem<String>(
                            value: '${location.name} (ID: ${location.id})',
                            child: Text(location.name),
                          );
                        }).toList();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _pickupCity ?? "Select Pickup Location",
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                            const Icon(Icons.keyboard_arrow_down),
                          ],
                        ),
                      ),
                      offset: const Offset(0, 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      color: Colors.white,
                    ),

                    const SizedBox(height: 5),

                    // ---------- Destination Dropdown ------------
                    PopupMenuButton<String>(
                      onSelected: (value) async {
                        final parts = value.split('(ID:');
                        final selectedName = parts[0].trim();
                        final selectedId = parts.length > 1
                            ? parts[1].replaceAll(')', '').trim()
                            : null;

                        if (_pickupCity == selectedName) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  "Pickup and Destination cannot be the same!"),
                              backgroundColor: Colors.red,
                            ),
                          );
                          setState(() {
                            _dropCity = null;
                          });
                        } else {
                          setState(() {
                            _dropCity = selectedName;
                          });

                          if (selectedId != null) {
                            final selectedModel =
                                _dropLocationModelList.firstWhere(
                              (model) => model.id.toString() == selectedId,
                              orElse: () => LocationdropModel(
                                id: 0,
                                state: 0,
                                name: '',
                                status: 0,
                                latitude: 0.0,
                                longitude: 0.0,
                              ),
                            );

                            if (selectedModel.latitude != null &&
                                selectedModel.longitude != null) {
                              final prefs =
                                  await SharedPreferences.getInstance();
                              await prefs.setString(
                                  'destinationCityId', selectedId);
                              await prefs.setDouble(
                                  'end_latitude', selectedModel.latitude!);
                              await prefs.setDouble(
                                  'end_longitude', selectedModel.longitude!);

                              print(
                                  'Selected Destination: $selectedName (ID: $selectedId)');
                              print(
                                  'End Latitude: ${selectedModel.latitude}, End Longitude: ${selectedModel.longitude}');
                            } else {
                              print(
                                  '❌ Latitude or Longitude is null for this drop location!');
                            }
                          }
                        }
                      },
                      itemBuilder: (BuildContext context) {
                        return _dropLocationapi.map((location) {
                          return PopupMenuItem<String>(
                            value: location,
                            child: Text(location.split('(ID:')[0]),
                          );
                        }).toList();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _dropCity ?? "Select Destination Location",
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                            const Icon(Icons.keyboard_arrow_down),
                          ],
                        ),
                      ),
                      offset: const Offset(0, 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            )
          ])),
    );
  }

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

  String? _pickupCity;
  String? _pickupId;

  String? _dropCity;

  List<LocationModel> locations = [];
  List<LocationdropModel> dropLocations = [];
  List<String> _dropLocationapi = [];
  List<LocationdropModel> _dropLocationModelList = [];

  @override
  void initState() {
    super.initState();
    loadUserData();
    WidgetsBinding.instance.addObserver(this);
    _requestLocationPermission();
    fetchPickupDropLocation().then((value) {
      setState(() {
        locations = value;
      });
    });
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

  String? mobile;
  String? token;
  String? registeredDate;
  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      mobile = widget.Mobile.isNotEmpty
          ? widget.Mobile
          : prefs.getString('mobileno') ?? '';

      token = widget.Token.isNotEmpty
          ? widget.Token
          : prefs.getString('token') ?? '';

      registeredDate = widget.registered_date.isNotEmpty
          ? widget.registered_date
          : prefs.getString('registereddate') ?? '';
    });
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
}
