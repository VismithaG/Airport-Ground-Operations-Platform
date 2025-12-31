import 'package:flutter/material.dart';

class SignaturePad extends StatefulWidget {
  final ValueChanged<bool> onSigned; // Callback to notify parent when signed

  const SignaturePad({super.key, required this.onSigned});

  @override
  State<SignaturePad> createState() => SignaturePadState();
}

class SignaturePadState extends State<SignaturePad> {
  List<Offset?> points = [];

  void clear() {
    setState(() {
      points.clear();
      widget.onSigned(false);
    });
  }

  bool get hasSignature => points.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          // The Drawing Area
          GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                RenderBox renderBox = context.findRenderObject() as RenderBox;
                points.add(renderBox.globalToLocal(details.globalPosition));
                widget.onSigned(true);
              });
            },
            onPanEnd: (details) {
              points.add(null); // End of line
            },
            child: CustomPaint(
              painter: _SignaturePainter(points),
              size: Size.infinite,
            ),
          ),
          
          // Background Placeholder Text
          if (points.isEmpty)
            const Center(
              child: Text(
                "Click/touch and drag to sign",
                style: TextStyle(color: Colors.grey),
              ),
            ),

          // Clear Button
          Positioned(
            bottom: 8,
            right: 8,
            child: OutlinedButton.icon(
              onPressed: clear,
              icon: const Icon(Icons.clear, size: 14),
              label: const Text("Clear", style: TextStyle(fontSize: 12)),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _SignaturePainter extends CustomPainter {
  final List<Offset?> points;
  _SignaturePainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.0;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_SignaturePainter oldDelegate) => true;
}