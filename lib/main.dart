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
    client = MqttServerClient('test.mosquitto.org', 'clientIdentifier1234');
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

    return client;
  }

  Stream<List<MqttReceivedMessage<MqttMessage>>> mqttSubscribe(String topic) {
    if (client.connectionStatus.state == MqttConnectionState.connected) {
      client.subscribe(topic, MqttQos.atLeastOnce);
      return client.updates;
    } else {
      return null;
    }
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
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            if (snapshot.hasData) {
              List<MqttReceivedMessage<MqttMessage>> mqttRecieveMessage = snapshot.data;
              MqttPublishMessage recieveMessage = mqttRecieveMessage[0].payload;
              String payload = MqttPublishPayload.bytesToStringAsString(recieveMessage.payload.message);

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
