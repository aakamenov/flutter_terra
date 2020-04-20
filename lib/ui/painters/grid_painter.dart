import 'package:flutter/material.dart';
import 'package:flutter_terra/models/terrarium.dart';

class GridPainter extends CustomPainter {
  final Terrarium terrarium;

  GridPainter(this.terrarium);

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width / Terrarium.gridWidth;
    final height = size.height / Terrarium.gridHeight;
    final cellSize = Size(width, height);

    for(var x = 0; x < Terrarium.gridWidth; x++) {
      for(var y = 0; y < Terrarium.gridHeight; y++) {
        final cell = terrarium.cellAt(x, y);

        if(cell.isFree) {
          continue;
        }

        final rect = Offset(cellSize.width * y.toDouble(), cellSize.height * x.toDouble()) & cellSize;
        
        final paint = Paint();
        paint.color = cell.color;

        canvas.drawRect(rect, paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
