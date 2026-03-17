import 'package:flutter/material.dart';

class ApprovalSuccessPage extends StatelessWidget {
  final String workOrderId;
  final String supervisorName;
  final String decision;

  const ApprovalSuccessPage({
    super.key,
    required this.workOrderId,
    required this.supervisorName,
    required this.decision,
  });

  @override
  Widget build(BuildContext context) {
    final isApproved = decision == 'Approve';
    final color = isApproved ? Colors.green : Colors.red;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(isApproved ? Icons.check_circle : Icons.cancel, color: color, size: 80),
                const SizedBox(height: 24),
                Text("Work Order $decision${isApproved ? 'd' : 'ed'}", 
                  textAlign: TextAlign.center, 
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)
                ),
                const SizedBox(height: 16),
                const Text(
                  "Your decision has been recorded and processed successfully.", 
                  textAlign: TextAlign.center, 
                  style: TextStyle(color: Colors.grey)
                ),
                const SizedBox(height: 32),
                
                // Summary Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    border: Border.all(color: Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _row("Work Order", "#$workOrderId"),
                      const Divider(),
                      _row("Decision", decision.toUpperCase(), valueColor: color),
                      const Divider(),
                      _row("Supervisor", supervisorName),
                      const Divider(),
                      _row("Time", DateTime.now().toString().split('.')[0]),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFB71C1C), foregroundColor: Colors.white, padding: const EdgeInsets.all(16)),
                    child: const Text("Back to Dashboard"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: valueColor ?? Colors.black87)),
        ],
      ),
    );
  }
}