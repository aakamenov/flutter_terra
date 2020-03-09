import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:flutter_terra/models/terrarium.dart';

class DistributionSlider extends StatefulWidget {
  final double height;
  final double width;

  DistributionSlider({
    this.height = 84.0,
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
      margin: EdgeInsets.all(10),
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

  Canvas _canvas;

  static const double _overlayRadius = 16.0;
  static const double _overlayDiameter = _overlayRadius * 2.0;
  static const double _thumbRadius = 8.0;
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
    final trackOffset = Offset(0.0, 2 * _thumbRadius) + offset;
    final trackHeight = size.height - (4 * _thumbRadius);

    _canvas = context.canvas;

    _drawBackground(trackHeight, trackOffset);
    _drawStripes(trackHeight, trackOffset);
    _drawTrack(trackHeight, trackOffset);
  }

  _drawBackground(double trackHeight, Offset offset) {
    final rect = offset & Size(size.width, trackHeight);
    final background = Paint()
      ..color = Colors.grey[200]
      ..style = PaintingStyle.fill;

    _canvas.drawRect(rect, background);
  }

  _drawStripes(double trackHeight, Offset offset) {
    final path = Path();
    final lineCount = 10;
    final lineThickness = 2.0;
    final lineSpacing = (trackHeight - (lineCount * lineThickness)) / lineCount + lineThickness;

    var currentY = offset.dy + lineSpacing;

    for(var i = 0; i < lineCount - 1; i++) {
      path.moveTo(offset.dx, currentY);
      path.lineTo(size.width + offset.dx, currentY);

      currentY += lineSpacing;
    }

    final stripePaint = Paint()
      ..color = Colors.red
      ..strokeWidth = lineThickness
      ..style = PaintingStyle.stroke;

    _canvas.drawPath(path, stripePaint);
  }

  _drawTrack(double trackHeight, Offset offset) {
    var widthOccupied = offset.dx;
    var index = 0;

    for(var entry in terrarium.settings.distribution.entries) {
      final width = (entry.value * 0.01) * size.width;
      final rect = Rect.fromLTWH(widthOccupied, offset.dy, width, trackHeight);

      final color = terrarium.getCreature(entry.key).color;
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      
      _canvas.drawRect(rect, paint);

      widthOccupied += width;

      final thumbY = index.isEven ? offset.dy - _thumbRadius : (_thumbRadius) + trackHeight + offset.dy;
      _drawThumb(Offset(widthOccupied, thumbY), color);

      index++;
    }
  }

  _drawThumb(Offset offset, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    _canvas.drawCircle(offset, _thumbRadius, paint);
  }
}
