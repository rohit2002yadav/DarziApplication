import 'package:flutter/material.dart';
import '../services/tailor_service.dart';

class UpdateStatusSheet extends StatefulWidget {
  final String orderId;
  final String currentStatus;
  final VoidCallback onUpdate;

  const UpdateStatusSheet({
    super.key,
    required this.orderId,
    required this.currentStatus,
    required this.onUpdate,
  });

  @override
  State<UpdateStatusSheet> createState() => _UpdateStatusSheetState();
}

class _UpdateStatusSheetState extends State<UpdateStatusSheet> {
  bool _isLoading = false;

  final List<String> _statuses = [
    "CUTTING",
    "STITCHING",
    "FINISHING",
    "READY",
    "DELIVERED",
  ];

  Future<void> _updateStatus(String status) async {
    setState(() => _isLoading = true);
    try {
      await TailorService.updateStatus(widget.orderId);
      widget.onUpdate();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update status: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            "Update Progress",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          if (_isLoading)
            const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
          else
            ..._statuses.map((status) {
              final isCurrent = widget.currentStatus == status;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ElevatedButton(
                  onPressed: isCurrent ? null : () => _updateStatus(status),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isCurrent ? Colors.grey.shade300 : theme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: isCurrent ? Colors.black38 : Colors.white,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }).toList(),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "CANCEL",
              style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
