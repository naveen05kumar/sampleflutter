// lib/screens/stream_screen.dart

import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class StreamScreen extends StatefulWidget {
  @override
  _StreamScreenState createState() => _StreamScreenState();
}

class _StreamScreenState extends State<StreamScreen> {
  WebSocketChannel? channel;
  Image? currentImage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final String streamUrl = ModalRoute.of(context)!.settings.arguments as String;
    channel = WebSocketChannel.connect(Uri.parse(streamUrl));
    channel!.stream.listen((data) {
      setState(() {
        currentImage = Image.memory(data);
      });
    });
  }

  @override
  void dispose() {
    channel?.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Live Stream'),
      ),
      body: Center(
        child: currentImage ?? CircularProgressIndicator(),
      ),
    );
  }
}
