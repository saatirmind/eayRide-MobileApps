// ignore_for_file: avoid_print
import 'dart:convert';
import 'package:easymotorbike/AppColors.dart/EasyrideAppColors.dart';
import 'package:easymotorbike/NewScreen/roadmap.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  List<Map<String, dynamic>> vehicleLocations = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchVehicleLocations();
  }

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> fetchVehicleLocations() async {
    final token = await getToken();
    print(token);
    if (token == null) {
      showErrorSnackBar('Token is missing. Please log in again.');
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(AppApi.Vehiclelocation),
        headers: {
          'Content-Type': 'application/json',
          'token': token,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final vehicles = data['data'] as List;

        setState(() {
          vehicleLocations = vehicles.map((vehicle) {
            return {
              'vehicle_no': vehicle['vehicle_no'],
              'booking_id': vehicle['booking_id'],
              'current_latitude':
                  double.tryParse(vehicle['current_latitude'].toString()) ??
                      0.0,
              'current_longitude':
                  double.tryParse(vehicle['current_longitude'].toString()) ??
                      0.0,
              'drop_latitude': double.tryParse(
                      vehicle['drop_location']['latitude'].toString()) ??
                  0.0,
              'drop_longitude': double.tryParse(
                      vehicle['drop_location']['longitude'].toString()) ??
                  0.0,
            };
          }).toList();
          isLoading = false;
        });
      } else {
        showErrorSnackBar('Failed to fetch vehicle locations');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      showErrorSnackBar('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<String> getLocationName(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        return place.locality ??
            place.subLocality ??
            place.name ??
            "Unknown location";
      } else {
        return "Unknown location";
      }
    } catch (e) {
      return "Error fetching location";
    }
  }

  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 4,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Parked Vehicle',
              style: TextStyle(
                color: Colors.green[500],
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Unparked Vehicle',
              style: TextStyle(
                color: Colors.red[500],
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : vehicleLocations.isEmpty
              ? const Center(
                  child: Text('No vehicle locations found.'),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: vehicleLocations.length,
                  itemBuilder: (context, index) {
                    final vehicle = vehicleLocations[index];
                    final isSameLocation = vehicle['current_latitude'] ==
                            vehicle['drop_latitude'] &&
                        vehicle['current_longitude'] ==
                            vehicle['drop_longitude'];

                    return FutureBuilder<List<String>>(
                      future: Future.wait([
                        getLocationName(
                          vehicle['current_latitude'],
                          vehicle['current_longitude'],
                        ),
                        getLocationName(
                          vehicle['drop_latitude'],
                          vehicle['drop_longitude'],
                        ),
                      ]),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(child: LinearProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return const Text("Error loading location data");
                        }

                        final currentLocation =
                            snapshot.data?[0] ?? "Unknown location";
                        final dropLocation =
                            snapshot.data?[1] ?? "Unknown location";

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10.0),
                          child: ListTile(
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Current Location:',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(currentLocation),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      const Text(
                                        'Drop Location:',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(dropLocation),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Text(
                              'Booking ID: ${vehicle['booking_id']}\nVehicle no.: ${vehicle['vehicle_no']}',
                              style: const TextStyle(color: Colors.white),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 8.0,
                              horizontal: 16.0,
                            ),
                            tileColor: isSameLocation
                                ? Colors.green[200]
                                : Colors.red[200],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.grey,
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => NextScreen(
                                    vehicleData: vehicle,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}
