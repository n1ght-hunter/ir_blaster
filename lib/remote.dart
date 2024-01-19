import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:ir_sensor_plugin/ir_sensor_plugin.dart';
import 'package:yaml/yaml.dart';

class Remote {
  String name;
  String description;
  List<List<HashMap<String, String>>> layout;

  Remote({
    required this.name,
    required this.description,
    required this.layout,
  });

  factory Remote.fromyaml(dynamic yaml) {
    List<List<HashMap<String, String>>> layout = [];

    for (var i = 0; i < yaml['layout'].length; i++) {
      List<HashMap<String, String>> layoutRow = [];
      for (var j = 0; j < yaml['layout'][i].length; j++) {
        HashMap<String, String> layoutItem = HashMap();

        YamlMap row = yaml['layout'][i][j];

        row.forEach((key, value) {
          layoutItem[key] = value;
        });

        layoutRow.add(layoutItem);
      }
      layout.add(layoutRow);
    }

    return Remote(
      name: yaml['name'],
      description: yaml['description'],
      layout: layout,
    );
  }
}

class RemotePage extends StatelessWidget {
  final Remote remote;

  RemotePage({required this.remote});

  @override
  Widget build(BuildContext context) {
    return Center(
      // child: Text("test"),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            remote.description,
          ),
          for (var i = 0; i < remote.layout.length; i++)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var j = 0; j < remote.layout[i].length; j++)
                  for (var key in remote.layout[i][j].entries)
                    TextButton(
                      onPressed: () async {
                        await IrSensorPlugin.transmitString(pattern: key.value);
                      },
                      child: Text(key.key),
                    ),
              ],
            ),
        ],
      ),
    );
  }
}
