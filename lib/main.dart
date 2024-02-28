import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:agora_videocall/ads.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:permission_handler/permission_handler.dart';

import 'nativeAds.dart';

const appId = '0e8b0af5c9f1402fb512409523678b1d';
const token =
    '007eJxTYODd0fzg/qaAa/Fr3Fb2sLzNKnKXOunX8/3jiYzK8B+RnPMUGAxSLZIMEtNMky3TDE0MjNKSTA2NTAwsTY2MzcwtkgxTZllcSW0IZGTYYsvNwAiFID4PQ1pmUXFJckZiXl5qDgMDAMmfI2o=';
const channel = 'firstchannel';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  loadAd();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Agora Video Call',debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const NativeAds(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int? remoteUid;
  bool localUserJoined = false;

   RtcEngine? engine;

  @override
  void initState() {
    initAgora();
    super.initState();

  }


  @override
  Future<void> dispose() async {
    super.dispose();
    _dispose();
  }

  Future<void> _dispose() async {
    await engine!.leaveChannel();
    await engine!.release();
  }


  Future<void> initAgora() async {
    await [Permission.microphone, Permission.camera].request();
     engine = createAgoraRtcEngine();
    await engine!.initialize(const RtcEngineContext(appId: appId,channelProfile: ChannelProfileType.channelProfileLiveBroadcasting));

    engine!.registerEventHandler(RtcEngineEventHandler(
      onJoinChannelSuccess: (RtcConnection connection, int uid) {
        print("local user $uid joined");
        setState(() {
          localUserJoined = true;
        });
      },
      onUserJoined: (RtcConnection connection, int uid, int elapsed) {
        print("remote user $uid joined");
        setState(() {
          remoteUid = uid;

        });
      },
      onUserOffline: (RtcConnection connection, int uid, UserOfflineReasonType reason) {
        print("remote user $uid left channel");
        setState(() {
          remoteUid = null;
        });
      },
      onLeaveChannel: (RtcConnection connection,RtcStats stats){
        setState(() {
          localUserJoined = false;
          engine!.leaveChannel();
        });
      }
    ));

    await engine!.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    await engine!.enableVideo();
    await engine!.startPreview();

    await engine!.joinChannel(token: token, channelId: channel, uid: 0, options: const ChannelMediaOptions());
  }

  Widget remoteVideo() {

    if (engine != null && remoteUid != null) {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: engine!,
          canvas: VideoCanvas(uid: remoteUid),
          connection: const RtcConnection(channelId: channel),
        ),
      );
    } else {
      return const Text(
        'Please wait for remote user to join',
        textAlign: TextAlign.center,style: TextStyle(color: Colors.black),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agora Video Call'),
      ),
      body: Stack(
        children: [
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                remoteVideo(),
                Positioned(bottom: 50,
                    child: InkWell(onTap: (){
                      engine!.leaveChannel();
                      setState(() {
                        localUserJoined = false;
                        remoteUid = null;
                      });
                    },child: Container(height: 50,width: 50,decoration: const BoxDecoration(shape: BoxShape.circle,color: Colors.red),child: const Icon(Icons.call_end,color: Colors.white,),)))
              ],
            ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              width: 100,
              height: 100,
              child: Center(
                child: localUserJoined
                    ? AgoraVideoView(
                        controller: VideoViewController(
                          rtcEngine: engine!,
                          canvas:  const VideoCanvas(uid: 0),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ),

        ],
      ),
    );
  }
}
