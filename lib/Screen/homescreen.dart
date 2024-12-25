import 'dart:async';
import 'dart:convert';
import 'package:easyride/AppColors.dart/EasyrideAppColors.dart';
import 'package:easyride/settings/setting.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:easyride/Drawer/drawer.dart';
import 'package:easyride/GoogleMap/googlemap.dart';
import 'package:easyride/HomeScreenWidget/BottomBar.dart';
import 'package:easyride/HomeScreenWidget/PromotionsBanner.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  static final GlobalKey<HomeScreenState> homeScreenKey =
      GlobalKey<HomeScreenState>();
  final String Firstname;
  final String Mobile;
  final String Token;
  final String registered_date;

  const HomeScreen({
    Key? key,
    required this.Mobile,
    required this.Token,
    required this.Firstname,
    required this.registered_date,
  }) : super(key: key);

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  Future<void> Wallethistoryapi() async {
    final token = await getToken();
    print('Hit API Wallet HISTORY');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Token is missing. Please log in again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final String apiUrl = AppApi.getWallet;

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'token': token,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == true) {
          final Map<String, dynamic> responseData = data;

          setState(() {
            Walletamount =
                responseData['data']['user_wallet']['credit'].toString();
          });
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

  final GlobalKey<GooglemapState> _googleMapKey = GlobalKey();
  LatLng? _currentPosition;
  final LatLng _kualaLumpur = LatLng(3.139, 101.6869);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: Drawerscreen(
          Mobile: widget.Mobile,
          Token: widget.Token,
          Firstname: widget.Firstname,
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
          Positioned(
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
                            builder: (context) => SettingsScreen(),
                          ),
                        );
                      },
                      child: CircleAvatar(
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
          Positioned(
            bottom: 140,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Container(
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(1),
                      spreadRadius: 2,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Radio<int>(
                              value: 1,
                              groupValue: _selectedValue,
                              onChanged: (value) {
                                setState(() {
                                  _selectedValue = value!;
                                });
                              },
                            ),
                            Text(
                              "Tripwise",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: Row(
                            children: [
                              Radio<int>(
                                value: 2,
                                groupValue: _selectedValue,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedValue = value!;
                                  });
                                },
                              ),
                              Text(
                                "Minute-wise",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Text(
                        securityAmountLabel.isEmpty
                            ? 'Kindly select your pickup and drop locations before proceeding.'
                            : 'Security deposit: ($securityAmountLabel)',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    _selectedValue == 1
                        ? Padding(
                            padding: const EdgeInsets.only(left: 15.0),
                            child: Text(
                              securityAmountLabel.isEmpty
                                  ? ''
                                  : 'Tripwise → $securityAmountLabel + $finalPrice RM \n$totalAmountLabel (Minimum Amount in your Purse)',
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.only(left: 15.0),
                            child: Text(
                              'Minute-wise → 200 RM + 0.25 RM (P/M)\n220 RM (Minimum Amount in your Purse)',
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: BottomBar(
                pickupCity: _pickupCity,
                destinationCity: _destinationCity,
                Walletamount: Walletamount,
                finalPrice: finalPrice),
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
                        bool? isUpdated = true;
                        Scaffold.of(context).openDrawer();

                        if (isUpdated == true) {
                          Wallethistoryapi();
                        }
                      },
                      child: CircleAvatar(
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
          Positioned(
            top: 145,
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
                        SnackBar(
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
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            Icon(Icons.location_on),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _destinationCity?.split('(ID:')[0].trim() ??
                                    "Select Destination Location",
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
                  ],
                ),
              ],
            ),
          )
        ]));
  }

  int _selectedValue = 1;
  Set<Polyline> _polylines = {};
  String? _pickupCity;
  String? _destinationCity;

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
    initializeApp();
  }

  Future<void> initializeApp() async {
    _getCurrentLocation();
    _createMarkers();
    _initstateAPI();
    Wallethistoryapi();
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

    _getCurrentLocation();
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

  void _showLocationDialog() {
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
      String state = await getCurrentState();

      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);

        _markers.add(
          Marker(
            markerId: MarkerId('currentLocation'),
            position: _currentPosition!,
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueAzure),
            infoWindow: InfoWindow(title: state),
            onTap: () {
              _mapController.showMarkerInfoWindow(MarkerId('currentLocation'));
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

  Future<String> getCurrentState() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return 'Location services are disabled.';
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return 'Location permissions are denied.';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return 'Location permissions are permanently denied.';
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      String state = placemarks[0].administrativeArea ?? 'State not found';
      return state;
    } catch (e) {
      return 'Error occurred: $e';
    }
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
    final String state = await getCurrentState();
    final String apiUrl = AppApi.PickupDropLocation;

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
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
    final String state = await getCurrentState();

    final String apiUrl = AppApi.PickupDropLocation;

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
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
    final String state = await getCurrentState();

    final String apiUrl = AppApi.PickupDropLocation;

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
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
}
