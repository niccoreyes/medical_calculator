import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  int _bpm = 0;
  int _ticks = 0;
  int _totalMs = 0;
  int _totalSeconds = 0;
  int _countdown = 60;
  final int _interval = 100; //set to more than 100ms to compensate for mobile
  bool _timerisRunning = false;

  //For animation
  double circleSize = 200.00;
  void _updateState() {
    setState(() {
      circleSize = 150.00;
    });
  }

  Timer _timer = Timer.periodic(Duration(milliseconds: 100), (timer) {});
  void _startTimer() {
    HapticFeedback.vibrate();
    _updateState();
    if (_counter != 0) {
      _ticks++;
      _bpm = (_ticks.toDouble() / _totalMs.toDouble() * 60000).round(); //1000
      _totalSeconds = (_totalMs / 1000).round();
    }
    _counter = 0;
    if (_timerisRunning == false) {
      _timerisRunning = true;
      _timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
        setState(() {
          _counter += 100;
          _totalMs += 100;
          if (_countdown > 0) {
            _countdown = (60 - _totalMs.toDouble() / 1000).toInt();
          }
        });
      });
    }
  }

  void _reset() {
    try {
      _timer.cancel();
      _timerisRunning = false;
    } catch (e) {}
    setState(() {
      _counter = 0;
      _ticks = 0;
      _bpm = 0;
      _totalMs = 0;
      _totalSeconds = 0;
      _countdown = 60;
    });
  }

  void _pause() {
    setState(() {
      _timer.cancel();
      _timerisRunning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Beats Counter app"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ColoredText("$_bpm\nBPM", 50.0),
            //ColoredText("$_ticks ticks", 15.0),
            //ColoredText("$_totalSeconds total seconds", 15.0),
            ColoredText("$_countdown seconds remaining", 20.0),
            //ColoredText("$_totalMs total millis", 15.0),
            // ColoredText("$_counter ms", 15.0,
            //     color: Color.fromARGB(255, 85, 85, 85)),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                height: 250,
                width: 250,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      constraints: BoxConstraints.expand(),
                      decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Color.fromARGB(71, 235, 243, 252)
                                  .withOpacity(.2),
                              blurRadius: 32,
                              offset: Offset(40, 20),
                            ),
                            BoxShadow(
                              color: Color(0xFFFFFFFF).withOpacity(1),
                              blurRadius: 32,
                              offset: Offset(-20, -10),
                            )
                          ],
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                              colors: [
                                Color.fromARGB(255, 181, 220, 255),
                                Color.fromARGB(255, 207, 230, 250)
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomCenter)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: Container(
                        constraints: BoxConstraints.expand(),
                        decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF3F6080).withOpacity(.2),
                                blurRadius: 32,
                                offset: Offset(40, 20),
                              ),
                              BoxShadow(
                                color: Color(0xFFFFFFFF).withOpacity(1),
                                blurRadius: 32,
                                offset: Offset(-20, -10),
                              )
                            ],
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                                colors: [
                                  Color.fromARGB(255, 78, 170, 250),
                                  Color.fromARGB(255, 38, 125, 206)
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomCenter)),
                      ),
                    ),
                    Transform.rotate(
                      angle: 2 * pi / 60 * -_countdown,
                      child: Container(
                        constraints: BoxConstraints.expand(),
                        child: CustomPaint(
                          painter: ClockPainter(),
                        ),
                      ),
                    ),
                    paddedButton(
                        "",
                        _startTimer,
                        (!_timerisRunning) ? Icons.play_arrow : Icons.touch_app,
                        240.0,
                        true),
                  ],
                ),
              ),
            ),
            //paddedButton("", _reset, Icons.restart_alt_rounded, 50.0, false),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                smallButton(_reset, Icons.restart_alt_rounded),
                smallButton(_pause, Icons.pause),
              ],
            ),
            //paddedButton("", _pause, Icons.pause, 50.0, false)
          ],
        ),
      ),
    );
  }

  Padding smallButton(_task, _icon) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Ink(
        height: 60,
        width: 60,
        decoration: const ShapeDecoration(
            color: Colors.lightBlue, shape: CircleBorder()),
        child: IconButton(
          onPressed: _task,
          icon: Icon(_icon),
          color: Colors.white,
        ),
      ),
    );
  }

  Text ColoredText(text_variable, fsize, {dynamic color = Colors.green}) {
    return Text(text_variable,
        textAlign: TextAlign.center,
        style: TextStyle(
            color: color, fontWeight: FontWeight.bold, fontSize: fsize));
  }

  Padding paddedButton(_text, onPressTHIS, _icon, _height, bool big) {
    return Padding(
        padding: const EdgeInsets.all(5.0),
        child: ElevatedButton.icon(
          icon: Icon(
            _icon,
            size: (big) ? 100.0 : 30.0,
          ),
          style: ElevatedButton.styleFrom(
              primary: (big) ? Colors.transparent : Colors.blue,
              shadowColor: (big) ? Colors.transparent : Colors.blue,
              onSurface: Colors.red,
              minimumSize: Size((big) ? _height : 10.0, _height),
              shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular((big) ? _height : 200.0))),
          onPressed: () => onPressTHIS(),
          label: Text(_text, style: TextStyle(fontSize: 20)),
        ));
  }
}

class ClockPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double centerX = size.width / 2;
    double centerY = size.height / 2;
    Offset center = Offset(centerX, centerY);
    double radius = min(centerY, centerX);

    final Paint secLinePaint = Paint()
      ..color = Color.fromARGB(255, 255, 248, 248)
      ..strokeWidth = 4;
    final Paint bluePaint = Paint()
      ..color = Color.fromARGB(255, 243, 33, 33)
      ..strokeWidth = 10;
    //canvas.drawRect(Rect.fromLTWH(centerX, centerY, 100, 100), bluePaint);
    canvas.drawLine(
        Offset(centerX, 0), Offset(centerX, centerY - 65), secLinePaint);
    //canvas.drawLine(Offset(centerX, 0), Offset(centerX, 12), bluePaint);
    canvas.drawCircle(Offset(centerX, 3), 5, bluePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    //throw UnimplementedError();
    return true;
  }
}
