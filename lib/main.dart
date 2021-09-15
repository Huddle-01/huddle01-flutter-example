import 'dart:developer' as dev;
import 'dart:math';

import 'package:english_words/english_words.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:huddle01_flutter/huddle01_flutter.dart';
import 'package:huddle01_flutter_example/logic/blocs/consumers/consumers_bloc.dart';
import 'package:huddle01_flutter_example/logic/blocs/me/me_bloc.dart';
import 'package:huddle01_flutter_example/logic/blocs/media_devices/media_devices_bloc.dart';
import 'package:huddle01_flutter_example/logic/blocs/peers/peers_bloc.dart';
import 'package:huddle01_flutter_example/logic/blocs/producers/producers_bloc.dart';
import 'package:huddle01_flutter_example/logic/blocs/room/room_bloc.dart';
import 'package:huddle01_flutter_example/presentation/enter_page.dart';
import 'package:huddle01_flutter_example/presentation/room.dart';
import 'package:random_string/random_string.dart';

import 'package:flutter/material.dart';

void main() {
  runApp(BlocProvider<MediaDevicesBloc>(
      create: (context) => MediaDevicesBloc()..add(MediaDeviceLoadDevices()),
      lazy: false,
      child: MyApp()));
}

class MyApp extends StatelessWidget {
  _setupEventListeners({
    required ConsumersBloc consumersBloc,
    required ProducersBloc producersBloc,
    required PeersBloc peersBloc,
    required MeBloc meBloc,
  }) {
    emitter.on('addConsumer', (consumer) {
      consumersBloc.add(ConsumerAdd(consumer: consumer));
    });
    emitter.on('removeConsumer', (consumerId) {
      consumersBloc.add(ConsumerRemove(consumerId: consumerId));
    });
    emitter.on('addProducer', (producer) {
      producersBloc.add(ProducerAdd(producer: producer));
      if (producer.source == 'webcam') {
        meBloc.add(MeSetWebcamInProgress(progress: true));
      }
    });
    emitter.on('removeProducer', (source) {
      producersBloc.add(ProducerRemove(source: source));
      if (source == 'webcam') {
        meBloc.add(MeSetWebcamInProgress(progress: false));
      }
    });
    emitter.on('addPeer', (peer) {
      peersBloc.add(PeerAdd(newPeer: peer));
    });
    emitter.on('removePeer', (peerId) {
      peersBloc.add(PeerRemove(peerId: peerId));
    });
    emitter.on('addPeerConsumer', (consumer) {
      peersBloc.add(
          PeerAddConsumer(peerId: consumer.peerId, consumerId: consumer.id));
    });
    emitter.on('removePeerConsumer', (peerId, consumerId) {
      peersBloc.add(PeerRemoveConsumer(peerId: peerId, consumerId: consumerId));
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      // ignore: missing_return
      onGenerateRoute: (settings) {
        if (settings.name == EnterPage.RoutePath) {
          return MaterialPageRoute(
            builder: (context) => EnterPage(),
          );
        }
        if (settings.name == '/room') {
          return MaterialPageRoute(
            builder: (context) => MultiBlocProvider(
                // just like multiprovider, we are providing all the blocs except the media devices one to the Room
                providers: [
                  BlocProvider<ProducersBloc>(
                    lazy: false,
                    create: (context) => ProducersBloc(),
                  ),
                  BlocProvider<ConsumersBloc>(
                    lazy: false,
                    create: (context) => ConsumersBloc(),
                  ),
                  BlocProvider<PeersBloc>(
                    lazy: false,
                    create: (context) => PeersBloc(
                      consumersBloc: context.read<ConsumersBloc>(),
                    ),
                  ),
                  BlocProvider<MeBloc>(
                    lazy: false,
                    create: (context) => MeBloc(
                        displayName: nouns[Random.secure().nextInt(2500)],
                        id: randomAlpha(8)),
                  ),
                  BlocProvider<RoomBloc>(
                    lazy: false,
                    create: (context) =>
                        RoomBloc(settings.arguments.toString()),
                  ),
                ],
                child: RepositoryProvider<HuddleClientRepository>(
                  // provider to provide room client as an object to all the child widgets of this
                  lazy: false,
                  create: (context) {
                    _setupEventListeners(
                      consumersBloc: context.read<ConsumersBloc>(),
                      producersBloc: context.read<ProducersBloc>(),
                      peersBloc: context.read<PeersBloc>(),
                      meBloc: context.read<MeBloc>(),
                    );
                    MediaDevicesBloc mediaDevicesBloc =
                        context.read<MediaDevicesBloc>();
                    String audioInputDeviceId =
                        mediaDevicesBloc.state.selectedAudioInput!.deviceId;
                    String videoInputDeviceId =
                        mediaDevicesBloc.state.selectedVideoInput!.deviceId;
                    final meState = context.read<MeBloc>().state;
                    String displayName = meState.displayName;
                    String id = meState.id;
                    final roomState = context.read<RoomBloc>().state;
                    String url = roomState.url!;

                    Uri uri = Uri.parse(url);

                    return HuddleClientRepository(
                      peerId: id,
                      // consumersBloc: context.read<ConsumersBloc>(),
                      displayName: displayName,
                      url: url != null
                          ? 'wss://${uri.host}:4443'
                          : 'wss://alpha.huddle01.com:4443',
                      roomId: uri.queryParameters['roomId'] ??
                          uri.queryParameters['roomid'] ??
                          randomAlpha(8).toLowerCase(),
                      // peersBloc: context.read<PeersBloc>(),
                      // producersBloc: context.read<ProducersBloc>(),
                      // meBloc: context.read<MeBloc>(),
                      // roomBloc: context.read<RoomBloc>(),
                      // mediaDevicesBloc: context.read<MediaDevicesBloc>(),
                      audioInputDeviceId: audioInputDeviceId,
                      videoInputDeviceId: videoInputDeviceId,
                    )..join();
                  },
                  child: Room(),
                )),
          );
        }
      },
    );
  }
}
