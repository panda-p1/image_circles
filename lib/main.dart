import 'dart:math';
import 'dart:ui';
import 'dart:core';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

final double _imageSize = 400;
final double _radiusKoef = 0.7;
const double _sigmaX = 10.0; // from 0-10 blur effect
const double _sigmaY = 10.0; // from 0-10 blur effect

class _MyAppState extends State<MyApp> with TickerProviderStateMixin {
  List<Offset> offsets = [];
  late List<Animation<double>> animations;
  late List<AnimationController> controllers;
  List<int> deleteIndexes = [];

  Tween<double> _rotationTween = Tween(begin: 0, end: _radiusKoef * (_imageSize / 2));
  @override
  void initState() {
    super.initState();

    controllers = [AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),)
    ];

    animations = [
      _rotationTween.animate(controllers[offsets.length])
        ..addListener(() {
          setState(() {});
        })
        ..addStatusListener((status) {
          if (status == AnimationStatus.dismissed) {
            controllers[offsets.length].forward();
          }
        }),

    ];

  }
  @override
  Widget build(BuildContext context) {

    final painter = Hole(radius: animations.map((e) => e.value).toList(), clickPos: offsets, deviation: _imageSize/2);
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
        home: Scaffold(
        body: Stack(
          children: [
            Center(
              child: Listener(

                onPointerDown: (event) {
                  controllers[offsets.length].repeat();
                  controllers[offsets.length].forward();
                  offsets.add(event.localPosition);

                  controllers.add(AnimationController(
                    vsync: this,
                    duration: Duration(milliseconds: 300),));

                  animations.add(_rotationTween.animate(controllers[offsets.length])
                    ..addListener(() {
                      setState(() {});
                    })
                    ..addStatusListener((status) {
                      if (status == AnimationStatus.dismissed) {
                        controllers[offsets.length].forward();
                      }
                    }));

                },
                onPointerUp: (event) async {
                  int fingerIndex = offsets.length - 1;
                  var helpObj = {0: 100000.0};
                  for(var i = 0; i < offsets.length; i++) {
                    var rst = sqrt(pow(event.localPosition.dx - offsets[i].dx, 2) + pow(event.localPosition.dy - offsets[i].dy, 2));
                    if(rst < helpObj.values.toList()[0] ){
                      helpObj = {i: rst};
                    }
                  }

                  fingerIndex = helpObj.keys.toList()[0];

                  controllers[fingerIndex].reverse();
                  offsets.removeAt(fingerIndex);
                  controllers.removeAt(fingerIndex);
                  animations.removeAt(fingerIndex);
                },
                child: Container(
                  width: _imageSize,
                  height: _imageSize,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/zWUUFxRd.jpeg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            Center(
              child: Stack(
                children: animations.map((e) {
                  return AnimatedBuilder(
                    animation: e,
                    builder: (_, snapshot) {
                      return BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: _sigmaX/animations.length, sigmaY: _sigmaY/animations.length),

                        child: CustomPaint(
                          painter: painter,
                          size: Size.square(1),
                        ),
                      );
                    },
                  );
                }).toList()
              ),
            ),
          ]
        )
      )
    );
  }
}

class Hole extends CustomPainter {
  final List<double> radius;
  List<Offset>? clickPos;
  final double deviation;
  Hole({required this.radius, this.clickPos, required this.deviation});

  setPos(List<Offset> pos) {
    clickPos = pos;
  }

  @override
  void paint(Canvas canvas, Size size, ) {
    if(clickPos == null) return;
    double blurRadius = 10;

    for(var i = 0; i < clickPos!.length; i++) {

      canvas.drawCircle(
        Offset(clickPos![i].dx - deviation,clickPos![i].dy - deviation),
        radius[i],
        Paint()
        ..blendMode = BlendMode.clear
        ..maskFilter = MaskFilter.blur(BlurStyle.solid, blurRadius),
      );
    }

  }

  @override
  bool shouldRepaint(Hole oldDelegate) => true;
}
