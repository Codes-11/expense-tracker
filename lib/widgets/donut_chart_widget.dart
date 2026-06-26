import 'package:flutter/material.dart';
import 'dart:math' as math;

class DonutChartWidget extends StatelessWidget {
  final Map<String, double> data;
  final double size;

  const DonutChartWidget({
    super.key,
    required this.data,
    this.size = 180,
  });

  static const List<Color> _palette = [
    Color(0xFF6C5CE7),
    Color(0xFFFF7675),
    Color(0xFF00B894),
    Color(0xFFFDCB6E),
    Color(0xFF0984E3),
    Color(0xFFE17055),
    Color(0xFF74B9FF),
    Color(0xFFA29BFE),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = data.values.fold<double>(0, (a, b) => a + b);

    if (data.isEmpty || total == 0) {
      return SizedBox(
        height: size,
        child: Center(
          child: Text(
            'No data yet',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    final entries = data.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return Row(
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _DonutPainter(
              values: entries.map((e) => e.value).toList(),
              colors: List.generate(
                entries.length,
                (i) => _palette[i % _palette.length],
              ),
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
            ),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: entries.take(6).toIndexed().map((indexed) {
              final i = indexed.$1;
              final entry = indexed.$2;
              final pct = (entry.value / total * 100);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: _palette[i % _palette.length],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        entry.key,
                        style: theme.textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${pct.toStringAsFixed(0)}%',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

extension _Indexed<T> on Iterable<T> {
  Iterable<(int, T)> toIndexed() {
    var i = 0;
    return map((e) => (i++, e));
  }
}

class _DonutPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;
  final Color backgroundColor;

  _DonutPainter({
    required this.values,
    required this.colors,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final total = values.fold<double>(0, (a, b) => a + b);
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final strokeWidth = radius * 0.34;
    final rect = Rect.fromCircle(center: center, radius: radius - strokeWidth / 2);

    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawArc(rect, 0, 2 * math.pi, false, bgPaint);

    double startAngle = -math.pi / 2;
    for (var i = 0; i < values.length; i++) {
      final sweep = total == 0 ? 0.0 : (values[i] / total) * 2 * math.pi;
      final paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(rect, startAngle, sweep - 0.02, false, paint);
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) => true;
}