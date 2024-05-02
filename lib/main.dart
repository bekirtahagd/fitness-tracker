// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          scaffoldBackgroundColor: const Color.fromARGB(255, 59, 54, 54)),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final controller = PageController(
    initialPage: 0,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: PageView.builder(
      itemBuilder: ((context, position) {
        return DetailPage(daysInPast: position);
      }),
      controller: controller,
      reverse: true,
      pageSnapping: true,
    ));
  }
}

class DetailPage extends StatefulWidget {
  const DetailPage({Key? key, required this.daysInPast}) : super(key: key);

  final int daysInPast;

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final double _elementMargin = 50;
  late var _date = DateTime.now().subtract(Duration(days: widget.daysInPast));

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 125.0, 0.0, 0.0),
      child: Column(
        children: [
          Text(
            (widget.daysInPast == 0)
                ? "Today"
                : (widget.daysInPast == 1)
                    ? "Yesterday"
                    : "${_date.day}-${_date.month}-${_date.year}",
            style: TextStyle(fontSize: 42.0, color: Colors.white70),
          ),
          SizedBox(
            height: 20,
          ),
          TrackingElement(
            iconData: Icons.directions_run,
            color: Color.fromARGB(255, 0, 8, 255),
            unit: 'm',
            max: 5000,
            date: _date,
          ),
          SizedBox(
            height: _elementMargin,
          ),
          TrackingElement(
            iconData: Icons.local_drink,
            color: Color.fromARGB(255, 13, 255, 0),
            unit: 'ml',
            max: 3000,
            date: _date,
          ),
          SizedBox(
            height: _elementMargin,
          ),
          TrackingElement(
            iconData: Icons.fastfood,
            color: Color.fromARGB(255, 255, 0, 0),
            unit: 'kcal',
            max: 3500,
            date: _date,
          ),
        ],
      ),
    );
  }
}

class TrackingElement extends StatefulWidget {
  const TrackingElement(
      {Key? key,
      required this.iconData,
      required this.color,
      required this.unit,
      required this.max,
      required this.date})
      : super(key: key);

  final IconData iconData;
  final Color color;
  final String unit;
  final double max;
  final DateTime date;

  @override
  State<TrackingElement> createState() => _TrackingElementState();
}

class _TrackingElementState extends State<TrackingElement> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  int _counter = 0;
  double _progress = 0;

  String _storageKey = '';

  void _incrementCounter() async {
    if (_counter < widget.max) {
      setState(() {
        _counter += 200;
        _updateProgress();
      });
      (await _prefs).setInt(_storageKey, _counter);
    }
  }

  void _updateProgress() {
    _progress = _counter / widget.max;
  }

  @override
  void initState() {
    super.initState();

    _storageKey =
        '${widget.date.day}-${widget.date.month}-${widget.date.year}_${widget.unit}';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _prefs.then((prefs) {
      setState(() {
        _counter = prefs.getInt(_storageKey) ?? 0;
        _updateProgress();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _incrementCounter,
      child: Column(
        children: <Widget>[
          Padding(
            padding:
                const EdgeInsetsDirectional.fromSTEB(32.0, 24.0, 32.0, 24.0),
            child: Row(
              children: <Widget>[
                Icon(
                  widget.iconData,
                  color: Colors.white70,
                  size: 50,
                ),
                Text(
                  "$_counter / ${widget.max.toInt()}${widget.unit}",
                  style: TextStyle(color: Colors.white70, fontSize: 33),
                ),
              ],
            ),
          ),
          LinearProgressIndicator(
            value: _progress,
            color: widget.color,
            backgroundColor: const Color.fromARGB(255, 103, 103, 103),
            minHeight: 8.0,
          )
        ],
      ),
    );
  }
}
