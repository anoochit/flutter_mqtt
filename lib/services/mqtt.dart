import 'dart:developer';

import 'package:flutter_mqtt/const.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

MqttServerClient client;

Future<Stream<List<MqttReceivedMessage<MqttMessage>>>> mqttSubscribe({String topic}) async {
  // init client
  client = MqttServerClient(MQTT_HOST, MQTT_CLIENTID);
  client.port = MQTT_PORT;
  client.autoReconnect = true;

  // let's connect to mqtt broker
  try {
    await client.connect();
    // if connected, subscribe to a topic
    if (client.connectionStatus.state == MqttConnectionState.connected) {
      // subscribe to topic
      client.subscribe(topic, MqttQos.atLeastOnce);
      // return the stream
      return client.updates;
    } else {
      return null;
    }
  } on NoConnectionException catch (e) {
    log(e.toString());
  }
}
