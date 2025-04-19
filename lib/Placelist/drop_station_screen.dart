// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api, prefer_const_constructors
import 'package:easymotorbike/AppColors.dart/drop_station_provider.dart';
import 'package:easymotorbike/Screen/Complete.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DropStationsScreen extends StatefulWidget {
  const DropStationsScreen({super.key});

  @override
  _DropStationsScreenState createState() => _DropStationsScreenState();
}

class _DropStationsScreenState extends State<DropStationsScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      final provider = Provider.of<DropStationProvider>(context, listen: false);
      provider.fetchDropStations().then((_) {
        _showStationDialog();
      });
    });
  }

  void _showStationDialog() {
    final provider = Provider.of<DropStationProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Select a Drop Station"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: provider.stations.map((station) {
              return RadioListTile<int>(
                title: Text(station['name']),
                value: station['id'],
                groupValue: provider.selectedStationId,
                onChanged: (value) {
                  provider.selectStation(value!, station['name']);
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CompleteRideScreen(),
                    ),
                  );
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.shrink(),
    );
  }
}
