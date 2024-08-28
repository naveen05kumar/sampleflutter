//video_player.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketVideoPlayer extends StatefulWidget {
  final String webSocketUrl;
  final String authToken; // Add auth token parameter

  WebSocketVideoPlayer({required this.webSocketUrl, required this.authToken});

  @override
  _WebSocketVideoPlayerState createState() => _WebSocketVideoPlayerState();
}

class _WebSocketVideoPlayerState extends State<WebSocketVideoPlayer> {
  late WebSocketChannel _channel;
  Image? _currentFrame;
  List<Map<String, dynamic>> _detectedFaces = [];
  bool isError = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeWebSocket();
  }

  void _initializeWebSocket() {
    final wsUrl = '${widget.webSocketUrl}?token=${widget.authToken}'; // Include token in the URL
    print('Initializing WebSocket with URL: $wsUrl');
    try {
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      _channel.stream.listen(
            (message) {
          final data = jsonDecode(message);
          setState(() {
            if (data['frame'] != null) {
              _currentFrame = Image.memory(
                base64Decode(data['frame']),
                gaplessPlayback: true,
              );
            }
            if (data['detected_faces'] != null) {
              _detectedFaces = List<Map<String, dynamic>>.from(data['detected_faces']);
            }
          });
        },
        onError: (error) {
          print('WebSocket error: $error');
          setState(() {
            isError = true;
            errorMessage = error.toString();
          });
        },
        onDone: () {
          print('WebSocket connection closed.');
          setState(() {
            isError = true;
            errorMessage = 'WebSocket connection closed.';
          });
        },
      );
    } catch (e) {
      print('Error initializing WebSocket: $e');
      setState(() {
        isError = true;
        errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: isError
          ? Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Error: $errorMessage'),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              setState(() {
                isError = false;
                errorMessage = '';
                _initializeWebSocket();
              });
            },
            child: Text('Retry'),
          ),
        ],
      )
          : _currentFrame != null
          ? Stack(
        children: [
          _currentFrame!,
          ..._detectedFaces.map((face) {
            return Positioned(
              left: face['coordinates']['left'].toDouble(),
              top: face['coordinates']['top'].toDouble(),
              child: Container(
                width: (face['coordinates']['right'] - face['coordinates']['left']).toDouble(),
                height: (face['coordinates']['bottom'] - face['coordinates']['top']).toDouble(),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.red, width: 2),
                ),
                child: Text(face['name'], style: TextStyle(color: Colors.red)),
              ),
            );
          }).toList()
        ],
      )
          : CircularProgressIndicator(),
    );
  }

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }
}
