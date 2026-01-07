import 'package:flutter/material.dart';
import 'signature_pad.dart';
import 'approval_success_page.dart';

class WorkOrderApprovalPage extends StatefulWidget {
  final String workOrderId;
  final String? currentUserRole;

  const WorkOrderApprovalPage({super.key, required this.workOrderId, this.currentUserRole});

  @override
  State<WorkOrderApprovalPage> createState() => _WorkOrderApprovalPageState();
}

class _WorkOrderApprovalPageState extends State<WorkOrderApprovalPage> {
  final GlobalKey<SignaturePadState> _signKey = GlobalKey();
  
  // Form State
  String _decision = 'Approve'; // Approve or Reject
  final _nameCtl = TextEditingController(text: "Krishanka Jayasundhara"); // Pre-filled for demo
  final _titleCtl = TextEditingController(text: "Supervisor");
  final _commentsCtl = TextEditingController();
  bool _hasSigned = false;
  bool _isSubmitting = false;

  void _submit() async {
    if (!_hasSigned) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Digital signature is required")));
      return;
    }

    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(seconds: 1)); // Simulate network

    if (!mounted) return;
    
    // Navigate to Success Page
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ApprovalSuccessPage(
          workOrderId: widget.workOrderId,
          supervisorName: _nameCtl.text,
          decision: _decision,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool allowed = widget.currentUserRole != null && (widget.currentUserRole == 'Supervisor' || widget.currentUserRole == 'Administrator');

    if (!allowed) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Work Order Approval"),
          backgroundColor: Colors.white,
          elevation: 1,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.block, size: 64, color: Colors.grey),
                const SizedBox(height: 12),
                const Text("You do not have permission to approve this work order.", style: TextStyle(fontSize: 16), textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text("Back")),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Work Order Approval"),
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: const Offset(0, 4))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text("Supervisor Review", style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 4),
                      Text("WO #${widget.workOrderId}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ]),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: Colors.orange.shade100, borderRadius: BorderRadius.circular(20)),
                      child: const Text("Medium Priority", style: TextStyle(fontSize: 12, color: Colors.brown)),
                    )
                  ],
                ),
                const Divider(height: 30),

                // Flight Info (Read Only)
                _sectionTitle(Icons.flight, "Work Order Details"),
                const SizedBox(height: 12),
                _readOnlyRow("Airline/Carrier", "Emirates", "Flight Number", "EK 650"),
                _readOnlyRow("Aircraft", "A330 B2", "Gate", "A12"),
                const SizedBox(height: 16),
                
                // Request Info
                _readOnlyField("Requested By", "Vismitha Gunasekara"),
                _readOnlyField("Department", "Ground Operations"),
                const SizedBox(height: 16),
                
                // Services List
                const Text("Requested Services", style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    "Ground Power Unit (GPU)", "Passenger Stairs", "VIP/CIP Lounge Access", "Priority Baggage"
                  ].map((s) => Chip(label: Text(s, style: const TextStyle(fontSize: 12)), backgroundColor: Colors.grey[100])).toList(),
                ),
                
                const SizedBox(height: 24),
                
                // --- Decision Section ---
                _sectionTitle(Icons.gavel, "Approval Decision"),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _decisionButton("Approve", Colors.green)),
                    const SizedBox(width: 12),
                    Expanded(child: _decisionButton("Reject", Colors.red)),
                  ],
                ),

                const SizedBox(height: 24),

                // Supervisor Details
                _sectionTitle(Icons.person, "Supervisor Details"),
                const SizedBox(height: 12),
                TextFormField(controller: _nameCtl, decoration: _inputDecor("Full Name *")),
                const SizedBox(height: 12),
                TextFormField(controller: _titleCtl, decoration: _inputDecor("Title/Position *")),
                const SizedBox(height: 12),
                TextFormField(controller: _commentsCtl, maxLines: 3, decoration: _inputDecor("Comments & Notes")),
                
                const SizedBox(height: 24),
                
                // Signature
                _sectionTitle(Icons.draw, "Digital Signature *"),
                const SizedBox(height: 8),
                SignaturePad(
                  key: _signKey,
                  onSigned: (hasSigned) => setState(() => _hasSigned = hasSigned),
                ),

                const SizedBox(height: 32),
                
                // Submit
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB71C1C),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: _isSubmitting 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                    : const Text("Submit Approval", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                 const SizedBox(height: 12),
                 OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text("Back to Work Orders")),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(IconData icon, String title) {
    return Row(children: [
      Icon(icon, size: 18, color: const Color(0xFFB71C1C)),
      const SizedBox(width: 8),
      Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
    ]);
  }

  Widget _readOnlyRow(String l1, String v1, String l2, String v2) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(l1, style: const TextStyle(color: Colors.grey, fontSize: 12)), Text(v1, style: const TextStyle(fontWeight: FontWeight.w500))])),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(l2, style: const TextStyle(color: Colors.grey, fontSize: 12)), Text(v2, style: const TextStyle(fontWeight: FontWeight.w500))])),
        ],
      ),
    );
  }

  Widget _readOnlyField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)), Text(value, style: const TextStyle(fontWeight: FontWeight.w500))]),
    );
  }

  Widget _decisionButton(String label, Color color) {
    final isSelected = _decision == label;
    return InkWell(
      onTap: () => setState(() => _decision = label),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
          color: isSelected ? color.withAlpha((0.1 * 255).round()) : Colors.white,
          border: Border.all(color: isSelected ? color : Colors.grey.shade300, width: isSelected ? 2.0 : 1.0),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isSelected ? Icons.check_circle : Icons.circle_outlined, size: 18, color: isSelected ? color : Colors.grey),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: isSelected ? color : Colors.grey[700], fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecor(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }
}