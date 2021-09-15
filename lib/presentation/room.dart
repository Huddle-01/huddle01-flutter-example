import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:huddle01_flutter/huddle01_flutter.dart';
import 'package:huddle01_flutter_example/logic/blocs/media_devices/media_devices_bloc.dart';
import 'package:huddle01_flutter_example/logic/blocs/room/room_bloc.dart';
import 'package:huddle01_flutter_example/presentation/components/me/renderMe.dart';
import 'package:huddle01_flutter_example/presentation/components/others/renderOthers.dart';
import 'package:huddle01_flutter_example/presentation/voice_audio_settings.dart';

class Room extends StatefulWidget {
  const Room({Key? key}) : super(key: key);

  @override
  _RoomState createState() => _RoomState();
}

class _RoomState extends State<Room> {
  late StreamSubscription<MediaDevicesState> _mediaDevicesBlocSubscription;
  late String audioInputDeviceId;
  late String videoInputDeviceId;

  @override
  void dispose() {
    super.dispose();
    _mediaDevicesBlocSubscription.cancel();
  }

  @override
  void initState() {
    super.initState();
    audioInputDeviceId =
        context.read<MediaDevicesBloc>().state.selectedAudioInput!.deviceId;
    videoInputDeviceId =
        context.read<MediaDevicesBloc>().state.selectedVideoInput!.deviceId;
    _mediaDevicesBlocSubscription = context
        .read<MediaDevicesBloc>()
        .stream
        .listen((MediaDevicesState state) async {
      if (state.selectedAudioInput != null &&
          state.selectedAudioInput!.deviceId != audioInputDeviceId) {
        await context.read<HuddleClientRepository>().disableMic();
        context.read<HuddleClientRepository>().enableMic();
      }

      if (state.selectedVideoInput != null &&
          state.selectedVideoInput!.deviceId != videoInputDeviceId) {
        await context.read<HuddleClientRepository>().disableWebcam();
        context.read<HuddleClientRepository>().enableWebcam();
      }
    });
  }

  setStreamListener(context) {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Builder(
          builder: (context) {
            String url = context.select((RoomBloc bloc) => bloc.state.url!);
            return Text(Uri.parse(url).queryParameters['roomId']!);
          },
        ),
        actions: [
          IconButton(
            onPressed: () {
              String url = context.read<RoomBloc>().state.url!;
              Clipboard.setData(ClipboardData(text: url));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Room link copied to clipboard'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            icon: Icon(Icons.copy),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: context.read<MediaDevicesBloc>(),
                    child: AudioVideoSettings(),
                  ),
                ),
              );
            },
            icon: Icon(Icons.settings),
          ),
        ],
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            context.read<HuddleClientRepository>().close();
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          RenderOther(),
          RenderMe(),
        ],
      ),
    );
  }
}
