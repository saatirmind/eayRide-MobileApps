import 'package:easyride/Payment/cardscreen.dart';
import 'package:easyride/Placelist/placelist.dart';
import 'package:flutter/material.dart';

class PaymentMethodScreen extends StatefulWidget {
  const PaymentMethodScreen({Key? key}) : super(key: key);

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  List<Map<String, String>> savedCards = [
    {'type': 'Visa', 'lastFour': '9629'},
    {'type': 'Touch n Go', 'lastFour': '****'},
  ];

  int selectedIndex = 0;

  void addNewCard(String cardNumber) {
    setState(() {
      savedCards.add({
        'type': 'Custom',
        'lastFour': cardNumber.substring(cardNumber.length - 4)
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment Method"),
      ),
      body: Column(
        children: [
          // Top content
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: const Text(
              "Customize your payment method",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Debit/Credit Card',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: InkWell(
                  onTap: () async {
                    final newCardNumber = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddCardScreen(),
                      ),
                    );
                    if (newCardNumber != null) {
                      addNewCard(newCardNumber);
                    }
                  },
                  child: Text(
                    '+ Add Card',
                    style: TextStyle(color: Colors.red, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
          // Card List
          Expanded(
            child: ListView.builder(
              itemCount: savedCards.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Radio(
                    value: index,
                    groupValue: selectedIndex,
                    onChanged: (int? value) {
                      setState(() {
                        selectedIndex = value!;
                      });
                    },
                  ),
                  title: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        Image.asset(
                          savedCards[index]['type'] == 'Visa'
                              ? 'assets/visacardlogo.webp'
                              : 'assets/touchngo_logo.png',
                          width: 50,
                          height: 50,
                        ),
                        Text(
                          "************${savedCards[index]['lastFour']}",
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  trailing: TextButton(
                    onPressed: () {
                      setState(() {
                        savedCards.removeAt(index);
                      });
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                    child: const Text("Remove"),
                  ),
                );
              },
            ),
          ),
          // Bottom Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 60.0,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _isLoading ? null : _navigateToPlacelist,
                child: _isLoading
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                      )
                    : const Text(
                        "Start to Ride",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _isLoading = false;

  void _navigateToPlacelist() async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 3));

    setState(() {
      _isLoading = false;
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Placelist(),
      ),
    );
  }
}
