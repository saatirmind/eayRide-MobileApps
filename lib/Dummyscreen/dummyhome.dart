import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:easymotorbike/AppColors.dart/EasyrideAppColors.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class HomeScreen9 extends StatefulWidget {
  const HomeScreen9({super.key});

  @override
  State<HomeScreen9> createState() => _HomeScreen9State();
}

class _HomeScreen9State extends State<HomeScreen9> {
  int _selectedIndex = 2;

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
                    Container(
                      height: MediaQuery.of(context).size.height * 0.250,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
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
                    )
                  ],
                ),

                const SizedBox(height: 20),

                // Grid Cards
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  physics: const NeverScrollableScrollPhysics(),
                  children: const [
                    InfoCard(title: "Plans available", subtitle: "View plans"),
                    InfoCard(
                        title: "Refer a friend", subtitle: "Get free credits!"),
                    InfoCard(
                        title: "Half Beam mode", subtitle: "Decrease power"),
                    InfoCard(
                        title: "Reserve in advance", subtitle: "Secure a ride"),
                  ],
                ),

                const SizedBox(height: 80),
              ],
            ),
          ),

          // Convex Bottom Bar
          bottomNavigationBar: ConvexAppBar(
            style: TabStyle.react,
            backgroundColor: Colors.white,
            activeColor: Colors.deepPurple,
            color: Colors.grey,
            initialActiveIndex: _selectedIndex,
            items: const [
              TabItem(icon: Icons.home, title: 'Home'),
              TabItem(icon: Icons.account_balance_wallet, title: 'Payments'),
              TabItem(icon: Icons.qr_code_scanner, title: 'Scan QR'),
              TabItem(icon: Icons.support, title: 'Support'),
              TabItem(icon: Icons.menu, title: 'Menu'),
            ],
            onTap: (int index) {
              setState(() {
                _selectedIndex = index;
              });
              if (index == 0) {
                // Home tab
                print("Home clicked");
                // Navigator.push(...); // Optional: navigate
              } else if (index == 1) {
                // Payments tab
                print("Payments clicked");
              } else if (index == 2) {
                // Scan QR
                print("Scan QR clicked");
                // _scanQRCode(); // Function call
              } else if (index == 3) {
                print("Support clicked");
              } else if (index == 4) {
                print("Menu clicked");
              }
            },
          ),
        ),
      ],
    );
  }
}

class InfoCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const InfoCard({super.key, required this.title, required this.subtitle});

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
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}
