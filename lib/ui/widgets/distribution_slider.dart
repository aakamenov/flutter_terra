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

    final oldPos = _currentDragPos;
    _currentDragPos += details.primaryDelta;

    final isForward = details.primaryDelta > 0;

    final currentThumb = values[_activeThumb];

    final totalOccupied = values.entries.fold<double>(0.0, (current, next) => current += next.value.value);
    final maxValue = 1.0 - (totalOccupied - currentThumb.value);

    final difference = ((oldPos - _currentDragPos).abs() / size.width);
    final newValue = isForward ? currentThumb.value + difference : currentThumb.value - difference;

    currentThumb.value = newValue.clamp(0.01, maxValue + 0.01);

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
    _drawLabel(trackOffset);
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

    for(var entry in values.entries) {
      final width = entry.value.value * size.width;
      final rect = Rect.fromLTWH(widthOccupied, offset.dy, width, trackHeight);

      final color = entry.value.color;
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      
      _canvas.drawRect(rect, paint);
        
      widthOccupied += width;

      final thumbY = (_thumbRadius) + trackHeight + offset.dy;
      _drawThumb(Offset(widthOccupied, thumbY), color, entry.key);
    }
  }

  void _drawThumb(Offset offset, Color color, T key) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    _canvas.drawCircle(offset, _thumbRadius, paint);
    _visualData[key] = Rect.fromCircle(center: offset, radius: _thumbRadius * 2);
  }

  void _drawLabel(Offset trackOffset) {
    if(_activeThumb == null)
      return;
     
    final labelBoxRadius = 16.0;
    final distanceFromThumb = labelBoxRadius * 2;

    final activeThumb = values[_activeThumb];

    final color = activeThumb.color;
    final textColor = color.computeLuminance() >= 0.5 ? Colors.black : Colors.white;
    
    final valuePercentage = (activeThumb.value * 100).toInt();
    final painter = TextPainter(
      text: TextSpan(
        style: TextStyle(color: textColor),
        text: "$valuePercentage%"
      ),
      textDirection: TextDirection.ltr
    )
      ..layout();

    final thumbCenter = _visualData[_activeThumb].center;
    final offset = Offset(thumbCenter.dx, trackOffset.dy);

    final labelBox = Rect.fromCircle(center: Offset(offset.dx, offset.dy - distanceFromThumb), radius: labelBoxRadius);

    final path = Path();
    path.moveTo(offset.dx, offset.dy);
    path.lineTo(labelBox.centerLeft.dx, labelBox.centerLeft.dy);
    path.lineTo(labelBox.centerRight.dx, labelBox.centerRight.dy);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    _canvas.drawOval(labelBox, paint);
    _canvas.drawPath(path, paint);
    
    final textMargin = valuePercentage > 9 ? 3 : 7;
    painter.paint(_canvas, Offset(labelBox.centerLeft.dx + textMargin, labelBox.centerLeft.dy - labelBoxRadius / 2));
  }
}
