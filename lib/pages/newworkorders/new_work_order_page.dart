// lib/pages/work_order/new_work_order_page.dart
import 'package:flutter/material.dart';
import 'new_work_order_form.dart';

/// WorkOrder model used across the module (adapt as needed).
class WorkOrder {
  final String id;
  final String carrier;
  final String flightNumber;
  final String aircraftType;
  final String gate;
  final String scheduledTime;
  final String requestedBy;
  final String contactNumber;
  final String department;
  final String priority;
  final String status;
  final String createdAt;
  final String estimatedCompletionTime;
  final String date;
  final Map<String, int> serviceQuantities;
  final Map<String, String> serviceNotes;
  final List<String> services;
  final String specialInstructions;

  WorkOrder({
    required this.id,
    required this.carrier,
    required this.flightNumber,
    required this.aircraftType,
    required this.gate,
    required this.scheduledTime,
    required this.requestedBy,
    required this.contactNumber,
    required this.department,
    required this.priority,
    required this.status,
    required this.createdAt,
    required this.estimatedCompletionTime,
    required this.date,
    required this.serviceQuantities,
    required this.serviceNotes,
    required this.services,
    required this.specialInstructions,
  });
}

class NewWorkOrderPage extends StatefulWidget {
  final VoidCallback? onBack;

  const NewWorkOrderPage({Key? key, this.onBack}) : super(key: key);

  @override
  State<NewWorkOrderPage> createState() => _NewWorkOrderPageState();
}

class _NewWorkOrderPageState extends State<NewWorkOrderPage> {
  WorkOrder? _submittedWorkOrder;
  bool _isSubmissionComplete = false;

  void _handleFormSubmit(WorkOrder wo) {
    // Simulate API + notification side-effects here if needed.
    setState(() {
      _submittedWorkOrder = wo;
      _isSubmissionComplete = true;
    });
  }

  void _startNew() {
    setState(() {
      _submittedWorkOrder = null;
      _isSubmissionComplete = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isSubmissionComplete && _submittedWorkOrder != null) {
      final wo = _submittedWorkOrder!;
      return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text('Work Order Submitted'),
          backgroundColor: Colors.green.shade700,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  // Success header
                  Column(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(color: Colors.green.shade100, shape: BoxShape.circle),
                        child: const Center(child: Icon(Icons.check_circle, size: 44, color: Colors.green)),
                      ),
                      const SizedBox(height: 12),
                      Text('Work Order Submitted Successfully', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.green.shade800)),
                      const SizedBox(height: 8),
                      const Text('Your request has been received and will be processed by the appropriate service teams.',
                          textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Summary card
                  Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          // header row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(children: [
                                const Icon(Icons.check_circle, color: Colors.green),
                                const SizedBox(width: 8),
                                const Text('Work Order Confirmation', style: TextStyle(fontWeight: FontWeight.w600)),
                              ]),
                              Chip(
                                label: Text(wo.status),
                                backgroundColor: Colors.green.shade50,
                                labelStyle: TextStyle(color: Colors.green.shade800),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // details grid
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Work Order Information', style: TextStyle(fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 8),
                                    _infoRow('Work Order #', wo.id),
                                    _infoRow('Submitted', wo.createdAt),
                                    _infoRow('Priority', wo.priority),
                                    _infoRow('Est. Completion', wo.estimatedCompletionTime),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Contact Information', style: TextStyle(fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 8),
                                    Row(children: [const Icon(Icons.person, size: 18, color: Colors.grey), const SizedBox(width: 8), Text(wo.requestedBy)]),
                                    const SizedBox(height: 6),
                                    Text(wo.contactNumber, style: const TextStyle(color: Colors.grey)),
                                    const SizedBox(height: 6),
                                    Text(wo.department, style: const TextStyle(color: Colors.grey)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Flight summary
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Divider(),
                              const SizedBox(height: 8),
                              const Text('Flight Information', style: TextStyle(fontWeight: FontWeight.w600)),
                              const SizedBox(height: 8),
                              Row(children: [const Icon(Icons.flight, size: 18, color: Colors.blue), const SizedBox(width: 8), Text('${wo.carrier} ${wo.flightNumber}')]),
                              if (wo.aircraftType.isNotEmpty) _infoRow('Aircraft', wo.aircraftType),
                              if (wo.gate.isNotEmpty) _infoRow('Gate', wo.gate),
                              if (wo.scheduledTime.isNotEmpty) _infoRow('Scheduled', wo.scheduledTime),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Next steps
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                      Text('Next Steps', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.blueAccent)),
                      SizedBox(height: 6),
                      Text('• Service teams have been automatically notified', style: TextStyle(color: Colors.blueAccent)),
                      Text('• You will receive SMS/email updates on progress', style: TextStyle(color: Colors.blueAccent)),
                      Text('• For urgent matters, contact Operations Center: ext. 2500', style: TextStyle(color: Colors.blueAccent)),
                      Text('• Track status in the Work Orders dashboard', style: TextStyle(color: Colors.blueAccent)),
                    ]),
                  ),
                  const SizedBox(height: 16),

                  // Actions
                  Wrap(spacing: 8, runSpacing: 8, alignment: WrapAlignment.center, children: [
                    ElevatedButton(
                      onPressed: _startNew,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade600),
                      child: const Text('Create Another Work Order'),
                    ),
                    OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.download), label: const Text('Download PDF Copy')),
                    OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.share), label: const Text('Share with Team')),
                    if (widget.onBack != null)
                      OutlinedButton.icon(onPressed: widget.onBack, icon: const Icon(Icons.arrow_back), label: const Text('Back to Dashboard')),
                  ]),

                  const SizedBox(height: 20),

                  // Emergency contact
                  Card(
                    margin: const EdgeInsets.only(top: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Center(
                        child: Column(
                          children: [
                            const Text('For urgent assistance or emergencies:', style: TextStyle(color: Colors.grey)),
                            const SizedBox(height: 6),
                            RichText(
                              text: TextSpan(
                                style: DefaultTextStyle.of(context).style,
                                children: const [
                                  TextSpan(text: 'Operations Center: ', style: TextStyle(fontWeight: FontWeight.w600)),
                                  TextSpan(text: 'ext. 2500', style: TextStyle(color: Colors.red)),
                                  TextSpan(text: '   |   '),
                                  TextSpan(text: 'Emergency Line: ', style: TextStyle(fontWeight: FontWeight.w600)),
                                  TextSpan(text: 'ext. 911', style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // otherwise show the form
    return Scaffold(
      appBar: AppBar(title: const Text('New Work Order Request')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1000), child: NewWorkOrderForm(onSubmit: _handleFormSubmit, onCancel: widget.onBack)),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: const TextStyle(color: Colors.grey)), Text(value, style: const TextStyle(fontFamily: 'monospace'))]),
    );
  }
}
