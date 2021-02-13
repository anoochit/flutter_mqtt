import 'dart:developer';

import 'package:flutter/material.dart';
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

MqttServerClient client;

class _HomePageState extends State<HomePage> {
  mqttConnect() async {
    // init client
    client = new MqttServerClient('192.168.1.42', 'clientIdentifier1234');
    client.keepAlivePeriod = 60;
    client.autoReconnect = true;
    client.onConnected = onConnected;
    client.onDisconnected = onDisconnected;

    // let's connect to mqtt broker
    try {
      await client.connect();
    } on NoConnectionException catch (e) {
      log(e.toString());
    }
  }

  Stream<List<MqttReceivedMessage<MqttMessage>>> mqttSubscribe(String topic) {
    client.subscribe(topic, MqttQos.exactlyOnce);
    return client.updates;
  }

  void onDisconnected() {
    log('Disconnected');
  }

  void onConnected() {
    log('Connected');
  }

  @override
  void initState() {
    super.initState();
    mqttConnect();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Flutter MQTT"),
      ),
      body: Container(
        child: StreamBuilder(
          stream: mqttSubscribe('hello'),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              List<MqttReceivedMessage<MqttMessage>> mqttRecieveMessage =
                  snapshot.data;
              MqttPublishMessage recieveMessage = mqttRecieveMessage[0].payload;
              String payload = MqttPublishPayload.bytesToStringAsString(
                  recieveMessage.payload.message);

              return Center(
                child: Text(payload),
              );
            }

            return Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
