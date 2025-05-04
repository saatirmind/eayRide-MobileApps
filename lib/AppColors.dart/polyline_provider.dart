import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PolylineProvider extends ChangeNotifier {
  Set<Polyline> _polylines = {};

  Set<Polyline> get polylines => _polylines;

  void setPolyline(Set<Polyline> polyline) {
    _polylines = polyline;
    notifyListeners();
  }

  void clearPolylines() {
    _polylines.clear();
    notifyListeners();
  }
}
