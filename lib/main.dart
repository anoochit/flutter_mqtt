import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_mqtt/services/mqtt.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Flutter MQTT"),
      ),
      body: FutureBuilder(
        future: mqttSubscribe(topic: "hello"),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text("Error: ${snapshot.error}"),
            );
          }

          if (snapshot.connectionState == ConnectionState.done) {
            return StreamBuilder(
              stream: snapshot.data,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text("Error: ${snapshot.error}"),
                  );
                }

                if (snapshot.hasData) {
                  try {
                    List<MqttReceivedMessage<MqttMessage>> mqttRecieveMessage = snapshot.data;
                    MqttPublishMessage recieveMessage = mqttRecieveMessage[0].payload;
                    String payload = MqttPublishPayload.bytesToStringAsString(recieveMessage.payload.message);
                    return Center(
                      child: Text(payload),
                    );
                  } catch (e) {
                    return Center(
                      child: Text("Error: ${e.toString()}"),
                    );
                  }
                }

                return CircularProgressIndicator();
              },
            );
          }

          return CircularProgressIndicator();
        },
      ),
    );
  }
}
