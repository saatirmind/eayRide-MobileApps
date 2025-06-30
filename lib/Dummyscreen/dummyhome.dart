// ignore_for_file: deprecated_member_use, use_build_context_synchronously
import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:easymotorbike/AppColors.dart/EasyrideAppColors.dart';
import 'package:easymotorbike/Screen/homescreen.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../HomeScreenWidget/dummysubscrabstion.dart';

class HomeScreen9 extends StatefulWidget {
  const HomeScreen9({super.key});

  @override
  State<HomeScreen9> createState() => _HomeScreen9State();
}

class _HomeScreen9State extends State<HomeScreen9> {
  GoogleMapController? _mapController;
  Marker? _userMarker;
  LatLng? _userLocation;

  @override
  void initState() {
    super.initState();
    _setUserLocation();
  }

  Future<void> _setUserLocation() async {
    Position position = await AppApi.getCurrentLocation();
    _userLocation = LatLng(position.latitude, position.longitude);

    _userMarker = Marker(
      markerId: const MarkerId('user_location'),
      position: _userLocation!,
      infoWindow: const InfoWindow(title: 'You are here'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
    );

    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: _userLocation!,
          zoom: 16,
        ),
      ),
    );

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: const Text(
              'Welcome to Easymotorbike',
              style: TextStyle(color: Colors.black),
            ),
            centerTitle: false,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.250,
                        width: double.infinity,
                        child: GoogleMap(
                          initialCameraPosition: const CameraPosition(
                            target: LatLng(28.6139, 77.2090),
                            zoom: 12,
                          ),
                          onMapCreated: (GoogleMapController controller) {
                            _mapController = controller;
                          },
                          markers: _userMarker != null ? {_userMarker!} : {},
                          myLocationEnabled: true,
                          myLocationButtonEnabled: true,
                          zoomControlsEnabled: false,
                        ),
                      ),
                    ),

                    Positioned.fill(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HomeScreen(
                                  Mobile: '',
                                  Token: '',
                                  registered_date: '',
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    // 3️⃣ Overlay label
                    Positioned(
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: EasyrideColors.vibrantGreen,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          "Tap to see nearby vehicle.",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SubscriptionScreen(),
                          ),
                        );
                      },
                      child: const InfoCard(
                        title: "Plans available",
                        subtitle: "View plans",
                        iconData: Icons.card_membership,
                      ),
                    ),
                    const InfoCard(
                      title: "Refer a friend",
                      subtitle: "Get free credits!",
                      iconData: Icons.group_add,
                    ),
                    const InfoCard(
                      title: "EasyMotorbike mode",
                      subtitle: "Decrease power",
                      iconData: Icons.motorcycle,
                    ),
                    const InfoCard(
                      title: "Reserve in advance",
                      subtitle: "Secure a ride",
                      iconData: Icons.schedule_send,
                    ),
                    InkWell(
                      onTap: () {
                        fetchAndShowBanner(context, 'ride');
                      },
                      child: const InfoCard(
                        title: "How to Ride",
                        subtitle: "Learn to ride",
                        iconData: Icons.directions_bike,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        fetchAndShowBanner(context, 'park');
                      },
                      child: const InfoCard(
                        title: "How to Park",
                        subtitle: "Learn to park",
                        iconData: Icons.local_parking,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class InfoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData iconData;

  const InfoCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.iconData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            blurRadius: 5,
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 📝 Title
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          // 📄 Subtitle
          Text(
            subtitle,
            style: const TextStyle(fontSize: 13),
          ),
          const Spacer(),
          // 🖼️ Icon
          Center(
            child: Icon(
              iconData,
              size: 48,
              color: EasyrideColors.vibrantGreen,
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

Future<void> fetchAndShowBanner(BuildContext context, String type) async {
  try {
    final response = await http.get(
      Uri.parse('https://easymotorbike.asia/api/v1/park-or-ride?type=$type'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['status'] == true &&
          data['data'] != null &&
          data['data']['banners'] != null &&
          data['data']['banners'].isNotEmpty) {
        final bannerList = data['data']['banners'] as List;
        final imageUrls = bannerList.map((e) => e['image'].toString()).toList();

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FullScreenImageScreen(imageUrls: imageUrls),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No banner found.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${response.statusCode}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Exception: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

class FullScreenImageScreen extends StatefulWidget {
  final List<String> imageUrls;

  const FullScreenImageScreen({super.key, required this.imageUrls});

  @override
  State<FullScreenImageScreen> createState() => _FullScreenImageScreenState();
}

class _FullScreenImageScreenState extends State<FullScreenImageScreen> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          CarouselSlider.builder(
            itemCount: widget.imageUrls.length,
            itemBuilder: (context, index, realIndex) {
              return GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Center(
                  child: Image.network(
                    widget.imageUrls[index],
                    fit: BoxFit.fill,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return const CircularProgressIndicator(
                          color: Colors.white);
                    },
                  ),
                ),
              );
            },
            options: CarouselOptions(
              height: double.infinity,
              viewportFraction: 1.0,
              enableInfiniteScroll: true,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 3),
              onPageChanged: (index, reason) {
                setState(() {
                  currentIndex = index;
                });
              },
            ),
          ),
          Positioned(
            bottom: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: widget.imageUrls.asMap().entries.map((entry) {
                final isActive = currentIndex == entry.key;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: isActive ? 12 : 8,
                  height: isActive ? 12 : 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: currentIndex == entry.key
                        ? Colors.black
                        : Colors.black.withOpacity(0.5),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
