// ignore_for_file: avoid_print
import '../AppColors.dart/EasyrideAppColors.dart';
import '../AppColors.dart/modal.dart';
import 'package:easymotorbike/DrawerWidget/fullmap.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:lottie/lottie.dart';

Future<Position> getCurrentLocation() async {
  print("🔍 Checking location service...");
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    await Geolocator.openLocationSettings();
    return Future.error('Location services are disabled.');
  }

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    print("📍 Location permission denied, requesting...");
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied');
    }
  }

  print("📍 Getting current position...");
  return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high);
}

class TouristScreen extends StatefulWidget {
  @override
  _TouristScreenState createState() => _TouristScreenState();
}

class _TouristScreenState extends State<TouristScreen> {
  List<TouristAttraction> _attractions = [];
  bool _isLoading = true;
  bool _noDataFound = false;
  @override
  void initState() {
    super.initState();
    print("🛫 initState called");
    fetchTouristAttractions();
  }

  Future<void> fetchTouristAttractions() async {
    try {
      Position position = await getCurrentLocation();
      print("✅ Location: ${position.latitude}, ${position.longitude}");

      final token = await AppApi.getToken();
      print("🔑 Token received: $token");

      var uri =
          Uri.parse('https://easymotorbike.asia/api/v1/tourist-attractions');
      var request = http.MultipartRequest('POST', uri);

      request.headers.addAll({
        'token': token!,
      });

      request.fields['latitude'] = position.latitude.toString();
      request.fields['longitude'] = position.longitude.toString();

      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      print("📥 Response received: ${response.statusCode}");
      print("📝 Response body: $responseData");

      if (response.statusCode == 200) {
        var decoded = jsonDecode(responseData);
        List data = decoded['data'][0];

        setState(() {
          _isLoading = false;
          if (data.isEmpty) {
            _noDataFound = true;
          } else {
            _attractions =
                data.map((item) => TouristAttraction.fromJson(item)).toList();
          }
        });
      } else {
        setState(() {
          _isLoading = false;
          _noDataFound = true;
        });
        print('❌ Failed to load data. Status: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _noDataFound = true;
      });
      print("🚨 Error in fetchTouristAttractions: $e");
    }
  }

  bool isValidImageUrl(String url) {
    return url.endsWith('.jpg') ||
        url.endsWith('.jpeg') ||
        url.endsWith('.png') ||
        url.endsWith('.webp') ||
        url.endsWith('.gif');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.white,
          shadowColor: Colors.black,
          elevation: 2,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () {
              Navigator.pop(context, true);
            },
          ),
          centerTitle: true,
          title: const Text(
            'Tourist Attractions',
            style: TextStyle(color: Colors.black),
          )),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _noDataFound
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Lottie.asset(
                        'assets/lang/nofound.json',
                        width: MediaQuery.of(context).size.width * 0.5,
                        height: MediaQuery.of(context).size.width * 0.5,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Oops! No tourist spots nearby 😔',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'You are not within 10km of any tourist attractions.',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _attractions.length,
                  itemBuilder: (context, index) {
                    final place = _attractions[index];

                    return Padding(
                      padding: const EdgeInsets.only(top: 5.0),
                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MapScreen4(
                                tileLat: place.latitude,
                                tileLng: place.longitude,
                              ),
                            ),
                          );
                        },
                        leading: isValidImageUrl(place.thumbnail)
                            ? GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => FullScreenImage(
                                          imageUrl: place.thumbnail),
                                    ),
                                  );
                                },
                                child: Image.network(
                                  place.thumbnail,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Container(
                                width: 50,
                                height: 50,
                                color: Colors.grey[300],
                                child: Icon(Icons.image_not_supported,
                                    color: Colors.grey[700]),
                              ),
                        title: Text(place.title),
                      ),
                    );
                  },
                ),
    );
  }
}

class FullScreenImage extends StatelessWidget {
  final String imageUrl;

  const FullScreenImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    print("🖼️ Full screen opened for: $imageUrl");
    return Scaffold(
      body: Center(
        child: imageUrl.isNotEmpty
            ? Image.network(imageUrl, fit: BoxFit.fill)
            : Text("No image available"),
      ),
    );
  }
}
