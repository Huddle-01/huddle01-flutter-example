import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:huddle01_flutter/huddle01_flutter.dart';
import 'package:huddle01_flutter_example/logic/blocs/consumers/consumers_bloc.dart';
import 'package:huddle01_flutter_example/logic/blocs/peers/peers_bloc.dart';
import 'package:huddle01_flutter_example/presentation/components/others/other.dart';

class RenderOther extends StatelessWidget {
  const RenderOther({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Map<String, Peer> peers =
        context.select((PeersBloc bloc) => bloc.state.peers);
    final Map<String, Consumer> consumers =
        context.select((ConsumersBloc bloc) => bloc.state.consumers);
    final Map<String, RTCVideoRenderer> renderers =
        context.select((ConsumersBloc bloc) => bloc.state.renderers);

    return GridView.count(
      crossAxisCount: 2,
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      children: peers.values.map((Peer peer) {
        if (peer.consumers.isNotEmpty) {
          String? id = peer.consumers.firstWhere(
            (cId) => consumers[cId]?.kind == 'video',
            orElse: () => 'null',
          );
          if (id != 'null') {
            return Other(
              key: Key(peer.id! + id),
              peer: peer,
              video: consumers[id]!,
              renderer: renderers[id]!,
            );
          }
        }
        return Other(
          key: Key(peer.id!),
          peer: peer,
        );
      }).toList(),
    );
  }
}
