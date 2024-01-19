import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:ir_blaster/remote.dart';
import 'package:yaml/yaml.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:ir_sensor_plugin/ir_sensor_plugin.dart';

const laskoOnOff =
    '0000 006D 0000 000C 002E 000E 002E 000E 000E 002E 002E 000E 002E 000E 000E 002E 000E 002E 000E 002E 000E 002E 000E 002E 000E 002E 002E 010D';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<Remote> _remotes = [];
  bool _hasIrEmitter = false;
  String? _selectedRemote;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    final manifestContent = await rootBundle.loadString('AssetManifest.json');

    final Map<String, dynamic> manifestMap = json.decode(manifestContent);

    final List<Remote> remotesYaml = await Future.wait(manifestMap.keys
        .where((String key) => key.contains('assets/'))
        .where((String key) => key.contains('.yaml'))
        .toList()
        .map((e) async =>
            Remote.fromyaml(loadYaml(await rootBundle.loadString(e)))));

    // Platform messages may fail, so we use a try/catch PlatformException.
    bool irEmitter = await IrSensorPlugin.hasIrEmitter;

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _remotes = remotesYaml;
      _hasIrEmitter = irEmitter;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<DropdownMenuItem<String>> remotesNames = _remotes
        .map(
            (e) => DropdownMenuItem<String>(value: e.name, child: Text(e.name)))
        .toList();

    return MaterialApp(
      theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.purple, brightness: Brightness.dark)),
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Ir Blaster'),
          ),
          body: _hasIrEmitter
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    DropdownButton(
                        value: _selectedRemote,
                        items: remotesNames,
                        onChanged: (String? value) {
                          setState(() {
                            _selectedRemote = value;
                          });
                        }),
                    if (_selectedRemote != null)
                      RemotePage(
                          remote: _remotes
                              .firstWhere((e) => e.name == _selectedRemote))
                    else
                      const Text('Select a remote')
                  ],
                )
              : const Text('No IR Emitter found')),
    );
  }
}
