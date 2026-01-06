import 'dart:convert';
import 'package:flutter/material.dart';
import '../../services/tailor_service.dart';
import '../../models/order_model.dart';
import 'order_tracking_page.dart';

class FabricHandoverScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const FabricHandoverScreen({super.key, this.userData});

  @override
  State<FabricHandoverScreen> createState() => _FabricHandoverScreenState();
}

class _FabricHandoverScreenState extends State<FabricHandoverScreen> {
  String selectedOption = "pickup";
  String? selectedAddressId;
  String selectedTime = "";
  DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
  bool isPlacingOrder = false;

  List<Map<String, String>> addresses = [];

  final timeSlots = [
    "9:00 AM - 11:00 AM",
    "11:00 AM - 1:00 PM",
    "2:00 PM - 4:00 PM",
    "4:00 PM - 6:00 PM",
    "6:00 PM - 8:00 PM",
  ];

  @override
  void initState() {
    super.initState();
  }

  bool get canContinue {
    if (selectedOption == "pickup") {
      return selectedAddressId != null && selectedTime.isNotEmpty;
    }
    return true;
  }

  /* ---------------- ADD ADDRESS SHEET ---------------- */
  void addAddressSheet() {
    final labelCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    final cityCtrl = TextEditingController();
    final pinCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Add Pickup Address",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
                controller: labelCtrl,
                decoration: const InputDecoration(labelText: "Label")),
            const SizedBox(height: 10),
            TextField(
                controller: addressCtrl,
                decoration: const InputDecoration(labelText: "Full Address")),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                    child: TextField(
                        controller: cityCtrl,
                        decoration:
                        const InputDecoration(labelText: "City"))),
                const SizedBox(width: 10),
                Expanded(
                    child: TextField(
                        controller: pinCtrl,
                        decoration:
                        const InputDecoration(labelText: "Pincode"))),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (addressCtrl.text.isEmpty) return;
                final id = DateTime.now().millisecondsSinceEpoch.toString();
                setState(() {
                  addresses.add({
                    "id": id,
                    "label": labelCtrl.text,
                    "address":
                    "${addressCtrl.text}, ${cityCtrl.text} - ${pinCtrl.text}"
                  });
                  selectedAddressId = id;
                });
                Navigator.pop(context);
              },
              child: const Text("Save & Select"),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /* ---------------- PLACE ORDER ---------------- */
  Future<void> placeOrder() async {
    if (!canContinue || isPlacingOrder) return;

    setState(() => isPlacingOrder = true);

    try {
      final orderData = {
        "customerName": widget.userData?["name"] ?? "Guest",
        "customerPhone": widget.userData?["phone"] ?? "",
        "tailorId": widget.userData?["selectedTailorId"],
        "garmentType": widget.userData?["garmentType"],
        "totalAmount": widget.userData?["basePrice"] ?? 0,
        "handoverType": selectedOption,
        "pickupAddress": selectedOption == "pickup"
            ? addresses
            .firstWhere((e) => e["id"] == selectedAddressId)["address"]
            : null,
        "pickupDate":
        selectedOption == "pickup" ? selectedDate.toString() : null,
        "pickupTime": selectedOption == "pickup" ? selectedTime : null,
      };

      final data = await TailorService.postOrder(orderData);
      final order = Order.fromJson(data);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (_) =>
                OrderTrackingPage(order: order, userData: widget.userData)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => isPlacingOrder = false);
    }
  }

  /* ---------------- UI ---------------- */
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Confirm Handover")),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  /* PICKUP */
                  OptionCard(
                    selected: selectedOption == "pickup",
                    title: "Tailor Pickup From Home",
                    subtitle:
                    "Tailor will visit you for fabric & measurements",
                    icon: Icons.home,
                    onTap: () => setState(() => selectedOption = "pickup"),
                    expanded: selectedOption == "pickup"
                        ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Pickup Address",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold)),
                            TextButton(
                                onPressed: addAddressSheet,
                                child: const Text("+ Add New"))
                          ],
                        ),
                        ...addresses.map((a) => ListTile(
                          title: Text(a["label"] ?? ""),
                          subtitle: Text(a["address"] ?? ""),
                          trailing: selectedAddressId == a["id"]
                              ? const Icon(Icons.check_circle)
                              : null,
                          onTap: () => setState(
                                  () => selectedAddressId = a["id"]),
                        )),
                        const SizedBox(height: 10),
                        const Text("Select Time Slot",
                            style:
                            TextStyle(fontWeight: FontWeight.bold)),
                        Wrap(
                          spacing: 8,
                          children: timeSlots
                              .map((t) => ChoiceChip(
                            label: Text(t),
                            selected: selectedTime == t,
                            onSelected: (_) =>
                                setState(() => selectedTime = t),
                          ))
                              .toList(),
                        ),
                      ],
                    )
                        : null,
                  ),

                  const SizedBox(height: 16),

                  /* DROP */
                  OptionCard(
                    selected: selectedOption == "drop",
                    title: "Drop at Tailor's Shop",
                    subtitle:
                    "Visit the shop to hand over fabric personally",
                    icon: Icons.store,
                    onTap: () => setState(() => selectedOption = "drop"),
                    expanded: selectedOption == "drop"
                        ? ListTile(
                      leading: const Icon(Icons.store),
                      title: Text(
                          widget.userData?["selectedTailorName"] ??
                              "Tailor"),
                      subtitle: Text(
                          widget.userData?["selectedTailorAddress"] ??
                              ""),
                    )
                        : null,
                  ),
                ],
              ),
            ),
          ),

          /* BOTTOM */
          Padding(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton(
              onPressed: canContinue ? placeOrder : null,
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52)),
              child: isPlacingOrder
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Confirm Order"),
            ),
          ),
        ],
      ),
    );
  }
}

/* ---------------- OPTION CARD ---------------- */
class OptionCard extends StatelessWidget {
  final bool selected;
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final Widget? expanded;

  const OptionCard(
      {super.key,
        required this.selected,
        required this.title,
        required this.subtitle,
        required this.icon,
        required this.onTap,
        this.expanded});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border:
          Border.all(color: selected ? Colors.purple : Colors.grey.shade300),
        ),
        child: Column(
          children: [
            ListTile(
              leading: Icon(icon),
              title: Text(title),
              subtitle: Text(subtitle),
              trailing:
              Icon(selected ? Icons.expand_less : Icons.expand_more),
            ),
            if (expanded != null)
              Padding(padding: const EdgeInsets.all(16), child: expanded),
          ],
        ),
      ),
    );
  }
}
