import 'package:flutter/material.dart';

class SectionFlightInfo extends StatelessWidget {
  final TextEditingController carrierCtl;
  final TextEditingController flightNoCtl;
  final TextEditingController timeCtl;
  final TextEditingController gateCtl;
  final String aircraftType;
  final ValueChanged<String> onAircraftChanged;
  final VoidCallback onPickDate;
  final DateTime serviceDate;
  final ValueChanged<TimeOfDay>? onTimePicked;
  
  // New Fields for Requester Info
  final TextEditingController requestedByCtl;
  final TextEditingController contactCtl;
  final String department;
  final ValueChanged<String?> onDepartmentChanged;
  final String priority;
  final ValueChanged<String?> onPriorityChanged;
  final bool isReadOnlyMode;

  const SectionFlightInfo({
    super.key,
    required this.carrierCtl,
    required this.flightNoCtl,
    required this.timeCtl,
    required this.gateCtl,
    required this.aircraftType,
    required this.onAircraftChanged,
    required this.onPickDate,
    required this.serviceDate,
    this.onTimePicked,
    required this.requestedByCtl,
    required this.contactCtl,
    required this.department,
    required this.onDepartmentChanged,
    required this.priority,
    required this.onPriorityChanged,
    this.isReadOnlyMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // --- Flight Information Card ---
        _buildCard(
          title: "Flight Information",
          icon: Icons.flight,
          child: Column(
            children: [
              _buildTextField(carrierCtl, "Airline/Carrier *", "e.g. Emirates"),
              const SizedBox(height: 12),
              _buildTextField(flightNoCtl, "Flight Number *", "e.g. EK 650"),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: aircraftType,
                      decoration: _inputDecoration("Aircraft Type"),
                      items: ["A320", "A330", "A350", "B777"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (v) { if (v != null) onAircraftChanged(v); },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: _buildTextField(gateCtl, "Gate", "e.g. A12")),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildTimePicker(context),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: onPickDate,
                      child: InputDecorator(
                        decoration: _inputDecoration("Service Date"),
                        child: Text("${serviceDate.day}/${serviceDate.month}/${serviceDate.year}"),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // --- Request Information Card ---
        _buildCard(
          title: "Request Information",
          icon: Icons.person_outline,
          child: Column(
            children: [
              _buildTextField(requestedByCtl, "Requested By *", "Your full name", readOnly: isReadOnlyMode),
              const SizedBox(height: 12),
              _buildTextField(contactCtl, "Contact Number *", "Extension or Mobile", readOnly: isReadOnlyMode),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: department,
                decoration: _inputDecoration("Department").copyWith(filled: isReadOnlyMode, fillColor: isReadOnlyMode ? Colors.grey.shade100 : null),
                items: ["Ground Operations", "Maintenance", "Cargo"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: isReadOnlyMode ? null : onDepartmentChanged,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: priority,
                decoration: _inputDecoration("Priority Level").copyWith(filled: isReadOnlyMode, fillColor: isReadOnlyMode ? Colors.grey.shade100 : null),
                items: ["Low", "Medium", "High", "Critical"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: isReadOnlyMode ? null : onPriorityChanged,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCard({required String title, required IconData icon, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController ctl, String label, String hint, {bool readOnly = false}) {
    return TextField(
      controller: ctl,
      readOnly: readOnly,
      style: readOnly
          ? const TextStyle(fontWeight: FontWeight.w300, color: Colors.black87)
          : const TextStyle(fontWeight: FontWeight.w400),
      decoration: _inputDecoration(label).copyWith(
        hintText: hint,
        hintStyle: const TextStyle(fontWeight: FontWeight.w300, color: Colors.grey),
        filled: readOnly,
        fillColor: readOnly ? Colors.grey.shade100 : null,
      ),
    );
  }

  Widget _buildTimePicker(BuildContext context) {
    return InkWell(
      onTap: () async {
        final TimeOfDay? picked = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: const Color(0xFFB71C1C),
                  onPrimary: Colors.white,
                  surface: Colors.white,
                  onSurface: Colors.black87,
                ),
                timePickerTheme: TimePickerThemeData(
                  backgroundColor: Colors.white,
                  hourMinuteShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  dayPeriodShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          final hour = picked.hourOfPeriod == 0 ? 12 : picked.hourOfPeriod;
          final minute = picked.minute.toString().padLeft(2, '0');
          final period = picked.period == DayPeriod.am ? 'AM' : 'PM';
          timeCtl.text = '$hour:$minute $period';
          if (onTimePicked != null) onTimePicked!(picked);
        }
      },
      child: InputDecorator(
        decoration: _inputDecoration("Scheduled Time").copyWith(
          suffixIcon: const Icon(Icons.access_time, color: Color(0xFFB71C1C)),
        ),
        child: Text(
          timeCtl.text.isEmpty ? '--:--' : timeCtl.text,
          style: TextStyle(
            color: timeCtl.text.isEmpty ? Colors.grey : Colors.black87,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
    );
  }
}