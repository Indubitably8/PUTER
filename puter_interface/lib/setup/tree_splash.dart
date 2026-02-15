import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

class TreeSplash extends StatefulWidget {
  static const Color startColor = Color(0xff882222);
  static const Point<int> startPoint = Point(0, 0);
  static const int minStartNodes = 5;
  static const int maxStartNodes = 10;

  static const int minBranches = 5;
  static const int maxBranches = 8;
  static const int maxNodes = 2;

  static const double minColorChange = -.15;
  static const double maxColorChange = .15;

  static const int minBranchRadius = 10;
  static const int maxBranchRadius = 50;

  static const double minTheta = -pi * 3 / 8;
  static const double maxTheta = pi * 3 / 8;

  static const double branchWidth = 5;
  static const double branchPointSize = 2.5;

  static const double maxJitter = 3;
  static const Duration targetDelay = Duration(milliseconds: 500);

  static const double smoothness = .04;

  static const int maxTotalNodes = 1200;

  static const Duration frameDelay = Duration(milliseconds: 33);

  const TreeSplash({super.key});

  @override
  State<TreeSplash> createState() => _TreeSplashState();
}

class _TreeSplashState extends State<TreeSplash> {
  late final TreePoint root;
  final Random rng = Random();

  final ValueNotifier<int> _repaint = ValueNotifier<int>(0);

  final List<TreePoint> _nodes = [];
  final List<Color> _nodeColors = [];
  final Map<TreePoint, int> _indexOf = {};
  final List<Offset> _basePos = [];
  final List<Offset> _jitter = [];
  final List<Offset> _target = [];

  late final List<int> _parentIdx;
  late final List<int> _childIdx;
  late final List<Color> _childColor;

  late final Timer _targetTimer;
  late final Timer _frameTimer;

  @override
  void initState() {
    super.initState();

    root = TreePoint(color: TreeSplash.startColor, point: TreeSplash.startPoint)
      ..generateTree();

    _collectNodes(root);
    _buildBasePos();
    _buildEdges();

    _randomizeTargets();

    _frameTimer = Timer.periodic(TreeSplash.frameDelay, (_) {
      for (int i = 0; i < _nodes.length; i++) {
        final j = _jitter[i];
        final t = _target[i];
        _jitter[i] = Offset(
          j.dx + (t.dx - j.dx) * TreeSplash.smoothness,
          j.dy + (t.dy - j.dy) * TreeSplash.smoothness,
        );
      }
      _repaint.value++;
    });

    _targetTimer =
        Timer.periodic(TreeSplash.targetDelay, (_) => _randomizeTargets());
  }

  void _collectNodes(TreePoint n) {
    if (_nodes.length >= TreeSplash.maxTotalNodes) return;

    _indexOf[n] = _nodes.length;
    _nodes.add(n);

    _nodeColors.add(n.color);

    _jitter.add(Offset.zero);
    _target.add(Offset.zero);

    for (final c in n.children) {
      if (_nodes.length >= TreeSplash.maxTotalNodes) break;
      _collectNodes(c);
    }
  }

  void _buildBasePos() {
    _basePos.clear();
    _basePos.addAll(List.generate(_nodes.length, (i) {
        final p = _nodes[i].point;
        return Offset(p.x.toDouble(), p.y.toDouble());
      }));
  }

  void _buildEdges() {
    _parentIdx = <int>[];
    _childIdx = <int>[];
    _childColor = <Color>[];

    for (final parent in _nodes) {
      final int pI = _indexOf[parent]!;
      for (final child in parent.children) {
        final int ?cI = _indexOf[child];
        if (cI == null) continue;
        _parentIdx.add(pI);
        _childIdx.add(cI);
        _childColor.add(child.color);
      }
    }
  }

  void _randomizeTargets() {
    for (int i = 0; i < _target.length; i++) {
      _target[i] = Offset(
        (rng.nextDouble() - 0.5) * 2 * TreeSplash.maxJitter,
        (rng.nextDouble() - 0.5) * 2 * TreeSplash.maxJitter,
      );
    }
  }

  @override
  void dispose() {
    _targetTimer.cancel();
    _frameTimer.cancel();
    _repaint.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomPaint(
        painter: _TreePainter(
          basePos: _basePos,
          jitter: _jitter,
          parentIdx: _parentIdx,
          childIdx: _childIdx,
          childColor: _childColor,
          nodeColor: _nodeColors,
          repaint: _repaint,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _TreePainter extends CustomPainter {
  _TreePainter({
    required this.basePos,
    required this.jitter,
    required this.parentIdx,
    required this.childIdx,
    required this.childColor,
    required this.nodeColor,
    required Listenable repaint,
  }) : super(repaint: repaint);

  final List<Offset> basePos;
  final List<Offset> jitter;

  final List<int> parentIdx;
  final List<int> childIdx;
  final List<Color> childColor;
  final List<Color> nodeColor;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(size.width / 2, size.height / 2);

    final linePaint = Paint()
      ..strokeWidth = TreeSplash.branchWidth
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()..style = PaintingStyle.fill;

    for (int e = 0; e < parentIdx.length; e++) {
      final pI = parentIdx[e];
      final cI = childIdx[e];

      final p = basePos[pI] + jitter[pI];
      final q = basePos[cI] + jitter[cI];

      linePaint.color = childColor[e].withAlpha(128);
      canvas.drawLine(p, q, linePaint);
    }

    for (int i = 0; i < basePos.length; i++) {
      final p = basePos[i] + jitter[i];
      dotPaint.color = nodeColor[i];
      canvas.drawCircle(p, TreeSplash.branchPointSize, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _TreePainter old) => false;
}

class TreePoint {
  static final Random rng = Random();

  TreePoint({required this.color, required this.point});

  final Color color;
  final Point<int> point;
  final List<TreePoint> children = [];

  void generateTree() {
    final int branches =
        _random(TreeSplash.minBranches, TreeSplash.maxBranches).round();
    final int nodes =
        _random(TreeSplash.minStartNodes, TreeSplash.maxStartNodes).round();

    for (int i = 0; i < nodes; i++) {
      final double red = _color(color.r);
      final double green = _color(color.g);
      final double blue = _color(color.b);

      final double theta = _random(-pi, pi);
      final double radius =
          _random(TreeSplash.minBranchRadius, TreeSplash.maxBranchRadius);

      final Color c = Color.from(alpha: 1, red: red, green: green, blue: blue);
      final Point<int> p = Point((point.x + radius * cos(theta)).round(),
          (point.y + radius * sin(theta)).round());

      children.add(TreePoint(color: c, point: p)..generateBranch(branches - 1));
    }
  }

  void generateBranch(int branches) {
    if (branches > 0) {
      final int nodes = _random(1, TreeSplash.maxNodes).round();

      for (int i = 0; i < nodes; i++) {
        final double red = _color(color.r);
        final double green = _color(color.g);
        final double blue = _color(color.b);

        final double theta = atan2(point.y, point.x) +
            _random(TreeSplash.minTheta, TreeSplash.maxTheta);
        final double radius =
            _random(TreeSplash.minBranchRadius, TreeSplash.maxBranchRadius);

        final Color c =
            Color.from(alpha: 1, red: red, green: green, blue: blue);
        final Point<int> p = Point((point.x + radius * cos(theta)).round(),
            (point.y + radius * sin(theta)).round());

        children
            .add(TreePoint(color: c, point: p)..generateBranch(branches - 1));
      }
    }
  }

  static double _color(double v) => max(
      0,
      min(v + _random(TreeSplash.minColorChange, TreeSplash.maxColorChange),
          1));

  static double _random(num min, num max) =>
      rng.nextDouble() * (max - min) + min;
}
