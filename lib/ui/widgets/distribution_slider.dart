import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:flutter_terra/models/terrarium.dart';

class DistributionSlider extends StatefulWidget {
  final double height;
  final double width;

  DistributionSlider({
    this.height = 80.0,
    this.width = 300.0
  });

  @override
  _DistributionSliderState createState() => _DistributionSliderState();
}

class _DistributionSliderState extends State<DistributionSlider> {
  @override
  Widget build(BuildContext context) {
    final dist = Provider.of<SimulationSettings>(context).distribution;
    final terrarium = Provider.of<Terrarium>(context, listen: false);

    return Container(
      height: widget.height,
      width: widget.width,
      child: _DistributionSliderRenderObjectWidget(terrarium)
    );
  }
}

class _DistributionSliderRenderObjectWidget extends LeafRenderObjectWidget {
  final Terrarium terrarium;

  _DistributionSliderRenderObjectWidget(this.terrarium);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderDistributionSlider(terrarium);
  }
}

class _RenderDistributionSlider extends RenderBox {
  final Terrarium terrarium;

  static const double _overlayRadius = 16.0;
  static const double _overlayDiameter = _overlayRadius * 2.0;
  static const double _thumbRadius = 6.0;
  static const double _preferredTrackWidth = 300.0;
  static const double _preferredTotalWidth = _preferredTrackWidth + 2 * _overlayDiameter;

  _RenderDistributionSlider(this.terrarium);

  @override
  bool get sizedByParent => true;

  @override
  void performResize() {
    size = new Size(
      constraints.hasBoundedWidth ? constraints.maxWidth : _preferredTotalWidth,
      constraints.hasBoundedHeight ? constraints.maxHeight : _overlayDiameter,
    );
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    return _preferredTotalWidth;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final trackHeight = size.height - (4 * _thumbRadius);

    final canvas = context.canvas;

    _drawBackground(canvas, trackHeight);
    _drawStripes(canvas, trackHeight);

    var widthOccupied = 0.0;

    for(var entry in terrarium.settings.distribution.entries) {
      final width = (entry.value * 0.01) * size.width;

      final rect = Rect.fromLTWH(widthOccupied, 0, width, trackHeight);
      final paint = Paint()
        ..color = terrarium.getCreature(entry.key).color
        ..style = PaintingStyle.fill;
      
      canvas.drawRect(rect, paint);
      widthOccupied += width;
    }
  }

  _drawBackground(Canvas canvas, double trackHeight) {
    final rect = Rect.fromLTWH(0, 0, size.width, trackHeight);
    final background = Paint()
      ..color = Colors.grey[200]
      ..style = PaintingStyle.fill;

    canvas.drawRect(rect, background);
  }

  _drawStripes(Canvas canvas, double trackHeight) {
    final path = Path();
    final lineCount = 10;
    final lineThickness = 2.0;
    final lineSpacing = (trackHeight - (lineCount * lineThickness)) / lineCount + lineThickness;

    var currentY = 0.0;

    for(var i = 0; i < lineCount; i++) {
      path.moveTo(0, currentY);
      path.lineTo(size.width, currentY);

      currentY += lineSpacing;
    }

    final stripePaint = Paint()
      ..color = Colors.red
      ..strokeWidth = lineThickness
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path, stripePaint);
  }
}