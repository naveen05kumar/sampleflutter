//lib/widgets/video_player/video_player.dart
import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

class RTSPVideoPlayer extends StatefulWidget {
  final String rtspUrl;

  RTSPVideoPlayer({required this.rtspUrl});

  @override
  _RTSPVideoPlayerState createState() => _RTSPVideoPlayerState();
}

class _RTSPVideoPlayerState extends State<RTSPVideoPlayer> {
  late VlcPlayerController _vlcPlayerController;
  bool isError = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  @override
  void dispose() {
    _vlcPlayerController.dispose();
    super.dispose();
  }

  void _initializePlayer() {
    _vlcPlayerController = VlcPlayerController.network(
      widget.rtspUrl,
      hwAcc: HwAcc.full,
      autoPlay: true,
      options: VlcPlayerOptions(
        advanced: VlcAdvancedOptions([
          VlcAdvancedOptions.networkCaching(2000),
        ]),
        rtp: VlcRtpOptions([
          VlcRtpOptions.rtpOverRtsp(true),
        ]),
      ),
    );

    _vlcPlayerController.addListener(_onPlayerError);
  }

  void _onPlayerError() {
    if (_vlcPlayerController.value.hasError) {
      setState(() {
        isError = true;
        errorMessage = _vlcPlayerController.value.errorDescription ?? 'Unknown error';
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
                _initializePlayer();
              });
            },
            child: Text('Retry'),
          ),
        ],
      )
          : VlcPlayer(
        controller: _vlcPlayerController,
        aspectRatio: 16 / 9,
        placeholder: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}