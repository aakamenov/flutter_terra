import 'dart:math';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

typedef void DistributionSliderValueChanged<T>(T key, double value);

class DistributionSliderValueData {
  final Color color;

  double get value => _value;

  set value(double value) {
    assert(value >= 0.0 && value <= 1.0);
    _value = value;
  }

  double _value;

  DistributionSliderValueData({ @required this.color, @required value }) {
    this.value = value;
  }
}

class DistributionSlider<TKey> extends StatefulWidget {
  final double height;
  final double width;
  final DistributionSliderValueChanged<TKey> onChanged;
  final Map<TKey, DistributionSliderValueData> values;

  DistributionSlider({
    this.height = 84.0,
    this.width = 300.0,
    @required this.onChanged,
    @required this.values
  }) :
    assert(height > 0),
    assert(width > 0),
    assert(onChanged != null),
    assert(values != null);

  @override
  _DistributionSliderState<TKey> createState() => _DistributionSliderState<TKey>();
}

class _DistributionSliderState<T> extends State<DistributionSlider<T>> {
  @override
  Widget build(BuildContext context) {  
    return Container(
      margin: EdgeInsets.all(10),
      height: widget.height,
      width: widget.width,
      child: _DistributionSliderRenderObjectWidget<T>(
        values: widget.values,
        onChanged: widget.onChanged,
      )
    );
  }
}

class _DistributionSliderRenderObjectWidget<T> extends LeafRenderObjectWidget {
  final Map<T, DistributionSliderValueData> values;
  final DistributionSliderValueChanged<T> onChanged;

  _DistributionSliderRenderObjectWidget({ @required this.values, @required this.onChanged});

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderDistributionSlider<T>(
      values: values,
      onChanged: onChanged
    );
  }
}

class _RenderDistributionSlider<T> extends RenderBox {
  final Map<T, DistributionSliderValueData> values; 
  final DistributionSliderValueChanged<T> onChanged;

  Canvas _canvas;
  HorizontalDragGestureRecognizer _dragGestureRecognizer;
  double _currentDragPos = 0.0;
  Map<T, Rect> _visualData = {};
  T _activeThumb;

  static const double _overlayRadius = 16.0;
  static const double _overlayDiameter = _overlayRadius * 2.0;
  static const double _thumbRadius = 8.0;
  static const double _preferredTrackWidth = 300.0;
  static const double _preferredTotalWidth = _preferredTrackWidth + 2 * _overlayDiameter;

  _RenderDistributionSlider({ @required this.values, @required this.onChanged } ) {
    _dragGestureRecognizer = HorizontalDragGestureRecognizer()
      ..onStart = _onDragStart
      ..onEnd = _onDragEnd
      ..onUpdate = _onDragUpdate
      ..onCancel = _onDragCancel;
  }

  @override
  bool get sizedByParent => true;

  @override
  bool hitTestSelf(Offset position) => true;

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
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if(event is! PointerDownEvent)
      return;

    final hitPoint = Point(entry.localPosition.dx, entry.localPosition.dy);

    _activeThumb = _visualData.entries.first.key;
    var closestDistance = double.infinity;

    for(var entry in _visualData.entries) {
      final rect = entry.value;

      final distance = hitPoint.distanceTo(Point(rect.center.dx, rect.center.dy));

      if(closestDistance > distance) {
        _activeThumb = entry.key;
        closestDistance = distance;
      }
    }
    
    _dragGestureRecognizer.addPointer(event);
  }

  void _onDragStart(DragStartDetails details) {
    _currentDragPos = details.localPosition.dx;
  }

  void _onDragUpdate(DragUpdateDetails details) {
    assert(_activeThumb != null);
    assert(values.containsKey(_activeThumb));

    _currentDragPos += details.primaryDelta;

    final currentThumb = values[_activeThumb];
    final totalOccupied = values.entries.fold<double>(0.0, (current, next) => current += next.value.value);

    final maxValue = 1.0 - (totalOccupied - currentThumb.value);
    
    currentThumb.value = (_currentDragPos / size.width).clamp(0.01, maxValue);

    markNeedsPaint();
  }

  void _onDragCancel() {
    _handleDragEnd();
  }

  void _onDragEnd(DragEndDetails details) {
    _handleDragEnd();
  }

  void _handleDragEnd() {
    onChanged(_activeThumb, values[_activeThumb]._value);
    
    _currentDragPos = 0.0;
    _activeThumb = null;
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

  void _drawBackground(double trackHeight, Offset offset) {
    final rect = offset & Size(size.width, trackHeight);
    final background = Paint()
      ..color = Colors.grey[200]
      ..style = PaintingStyle.fill;

    _canvas.drawRect(rect, background);
  }

  void _drawStripes(double trackHeight, Offset offset) {
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

  void _drawTrack(double trackHeight, Offset offset) {
    var widthOccupied = offset.dx;
    var index = 0;

    for(var entry in values.entries) {
      final width = entry.value.value * size.width;
      final rect = Rect.fromLTWH(widthOccupied, offset.dy, width, trackHeight);

      final color = entry.value.color;
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      
      _canvas.drawRect(rect, paint);
        
      widthOccupied += width;

      final thumbY = index.isEven ? offset.dy - _thumbRadius : (_thumbRadius) + trackHeight + offset.dy;
      _drawThumb(Offset(widthOccupied, thumbY), color, entry.key);
      
      index++;
    }
  }

  void _drawThumb(Offset offset, Color color, T key) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    _canvas.drawCircle(offset, _thumbRadius, paint);
    _visualData[key] = Rect.fromCircle(center: offset, radius: _thumbRadius * 2);
  }
}
