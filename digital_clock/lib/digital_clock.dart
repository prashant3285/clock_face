// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:math';

import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum _Element {
  background,
  text,
  shadow,
}

final _lightTheme = {
  _Element.background: Colors.white,
  _Element.text: Colors.white,
};

final _darkTheme = {
  _Element.background: Colors.black,
  _Element.text: Colors.white,
};

/// A basic digital clock.
///
/// You can do better than this!
class DigitalClock extends StatefulWidget {
  const DigitalClock(this.model);

  final ClockModel model;

  @override
  _DigitalClockState createState() => _DigitalClockState();
}

class _DigitalClockState extends State<DigitalClock>
    with TickerProviderStateMixin {
  DateTime _dateTime = DateTime.now();
  Timer _timer;
  AnimationController rotationController;
  Color colorOval;
  Color colorRect;
  @override
  void initState() {
    rotationController = AnimationController(
        duration: const Duration(milliseconds: 60000), vsync: this);
    super.initState();
    widget.model.addListener(_updateModel);
    _updateTime();
    _updateModel();

    rotationController.repeat();
  }

  @override
  void didUpdateWidget(DigitalClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    rotationController.dispose();
    widget.model.removeListener(_updateModel);
    widget.model.dispose();
    super.dispose();
  }

  void _updateModel() {
    setState(() {
      // Cause the clock to rebuild when the model changes.
    });
  }

  void _updateTime() {
    setState(() {
      colorOval = Color((Random().nextDouble() * 0xFFFFFF).toInt() << 0)
          .withOpacity(1.0);
      colorRect = Color((Random().nextDouble() * 0xFFFFFF).toInt() << 0)
          .withOpacity(1.0);
      _dateTime = DateTime.now();
      // Update once per minute. If you want to update every second, use the
      // following code.
      _timer = Timer(
        Duration(minutes: 1) -
            Duration(seconds: _dateTime.second) -
            Duration(milliseconds: _dateTime.millisecond),
        _updateTime,
      );
      // Update once per second, but make sure to do it at the beginning of each
      // new second, so that the clock is accurate.
      // _timer = Timer(
      //   Duration(seconds: 1) - Duration(milliseconds: _dateTime.millisecond),
      //   _updateTime,
      // );
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).brightness == Brightness.light
        ? _lightTheme
        : _darkTheme;
    final hour =
        DateFormat(widget.model.is24HourFormat ? 'HH' : 'hh').format(_dateTime);
    final minute = DateFormat('mm').format(_dateTime);
    final fontSize = MediaQuery.of(context).size.width / 3.5;

    return Container(
      color: colors[_Element.background],
      child: (Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Stack(
            children: <Widget>[
              RotationTransition(
                turns: Tween(begin: 0.0, end: 1.0).animate(rotationController),
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(25.0),
                      topRight: Radius.circular(25.0),
                      bottomRight: Radius.circular(25.0),
                    ),
                    child: Container(
                      color: colorRect,
                      width: fontSize,
                      height: fontSize,
                    ),
                  ),
                ),
              ),
              Center(
                child: Container(
                    width: fontSize,
                    height: fontSize,
                    child: Center(
                      child: Text(
                        hour,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: fontSize / 1.3,
                        ),
                      ),
                    )),
              )
            ],
          ),
          Stack(
            children: <Widget>[
              RotationTransition(
                turns: Tween(begin: 1.0, end: 0.0).animate(rotationController),
                child: Center(
                  child: ClipOval(
                    child: Container(
                      color: colorOval,
                      width: fontSize,
                      height: fontSize * 1.5,
                    ),
                  ),
                ),
              ),
              Center(
                child: Container(
                    width: fontSize,
                    height: fontSize,
                    child: Center(
                      child: Text(
                        minute,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: fontSize / 1.3,
                        ),
                      ),
                    )),
              )
            ],
          )
        ],
      )),
    );
  }
}
