import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

const appId = "42766e6d3d2945719a923106cfc0f7c2";
String token = "";
//"007eJxTYHDWOBcoslNAiMOcv/3u8sKA2LWl3hsn7YnMqTlyIvq/nJACg4mRuZlZqlmKcYqRpYmpuaFloqWRsaGBWXJaskGaebLR1s0zkxsCGRnk648xMjJAIIjPwmBoYGDAwAAAf4YcYg==";
String channel = "video_sample_1";

void main() => runApp(const MaterialApp(home: MyApp()));

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int? _remoteUid;
  bool _localUserJoined = false;
  late RtcEngine _engine;
  static const platform = MethodChannel('samples.flutter.dev/battery');
  TextEditingController mycontroller = TextEditingController();
  ChannelMediaOptions channelOptions = ChannelMediaOptions();

  @override
  void initState() {
    super.initState();
    //_getBatteryLevel();
    initAgora();
  }

  Future<void> _getBatteryLevel(String channelName) async {
    String batteryLevel;
    try {
      final String result = await platform
          .invokeMethod('getBatteryLevel', {"channel": channelName});
      batteryLevel = result;
    } on PlatformException catch (e) {
      batteryLevel = "Failed to get battery level: '${e.message}'.";
    }
    setState(() {
      token = batteryLevel;
      print("newlyGenerated token $token");
    });
  }

  Future<void> initAgora() async {
    // retrieve permissions
    await [Permission.microphone, Permission.camera].request();

    channelOptions.publishMediaPlayerAudioTrack; // = publishMediaPlayer;
    channelOptions.publishMediaPlayerVideoTrack; // = publishMediaPlayer;
    //create the engine
    _engine = createAgoraRtcEngine();
    await _engine.initialize(const RtcEngineContext(
      appId: appId,
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    ));

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint("local user ${connection.localUid} joined");
          setState(() {
            _localUserJoined = true;
          });
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          debugPrint("remote user $remoteUid joined");
          setState(() {
            _remoteUid = remoteUid;
          });
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          debugPrint("remote user $remoteUid left channel");
          setState(() {
            _remoteUid = null;
          });
        },
        onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
          debugPrint(
              '[onTokenPrivilegeWillExpire] connection: ${connection.toJson()}, token: $token');
        },
      ),
    );

    await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    await _engine.enableVideo();
    await _engine.startPreview();
    await _engine.joinChannel(
      token: token,
      channelId: channel,
      uid: 0,
      options: channelOptions,
    );
  }

  // Create UI with local view and remote view
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agora Video Call'),
      ),
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Column(
              children: [
                TextField(
                  controller: mycontroller,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Channel Name',
                    hintText: 'Enter Channel Name',
                  ),
                ),
                ElevatedButton(
                  child: const Text('Join'),
                  onPressed: () async {
                    if (mycontroller.text.isEmpty) {
                      return;
                    }
                    // _engine.leaveChannel();
                    channel = mycontroller.text.toString();
                    _getBatteryLevel(channel);

                    /*if(_engine == null){
                      initAgora();
                    }else{*/
                    await _engine.leaveChannel();
                    await _engine.stopPreview();
                    await _engine.setClientRole(
                        role: ClientRoleType.clientRoleBroadcaster);
                    await _engine.enableVideo();
                    await _engine.startPreview();
                    await _engine.joinChannel(
                      token: token,
                      channelId: channel,
                      uid: 0,
                      options: channelOptions,
                    );

                    // }
                  },
                )
              ],
            ),
          ),
          Center(
            child: Container(height: 300, width: 300, child: _remoteVideo()),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: SizedBox(
                width: 100,
                height: 150,
                child: Center(
                  child: _localUserJoined
                      ? AgoraVideoView(
                          controller: VideoViewController(
                            rtcEngine: _engine,
                            canvas: const VideoCanvas(uid: 0),
                          ),
                        )
                      : const CircularProgressIndicator(),
                ),
              ),
            ),
          ),
          _remoteUid != null
              ? Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        color: Colors.red),
                    child: IconButton(
                        onPressed: () {
                          _engine.leaveChannel();
                        },
                        icon: const Icon(Icons.call_end)),
                  ),
                )
              : Container(),
          Align(alignment: Alignment.bottomCenter, child: Text(token))
        ],
      ),
    );
  }

  // Display remote user's video
  Widget _remoteVideo() {
    if (_remoteUid != null) {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: _engine,
          canvas: VideoCanvas(uid: _remoteUid),
          connection: RtcConnection(channelId: channel),
        ),
      );
    } else {
      return const Text(
        'Please wait for remote user to join',
        textAlign: TextAlign.center,
      );
    }
  }
}
