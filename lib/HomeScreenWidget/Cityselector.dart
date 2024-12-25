import 'package:flutter/material.dart';

class CitySelector extends StatelessWidget {
  final String cityName;
  final VoidCallback onBackPressed;
  final VoidCallback onForwardPressed;

  const CitySelector({
    Key? key,
    required this.cityName,
    required this.onBackPressed,
    required this.onForwardPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Container(
        width: double.infinity,
        height: 45,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              iconSize: 16,
                              icon: Icon(Icons.arrow_back_ios),
                              onPressed: onBackPressed,
                            ))))),
            Expanded(
              flex: 2,
              child: Text(
                cityName,
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            Expanded(
                child: Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              iconSize: 16,
                              icon: Icon(Icons.arrow_forward_ios),
                              onPressed: onForwardPressed,
                            ))))),
          ],
        ),
      ),
    );
  }
}
