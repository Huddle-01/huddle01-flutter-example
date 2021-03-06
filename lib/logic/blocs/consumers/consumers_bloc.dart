import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:huddle01_flutter/huddle01_flutter.dart';

part 'consumers_event.dart';
part 'consumers_state.dart';

class ConsumersBloc extends Bloc<ConsumersEvent, ConsumersState> {
  StreamController<ConsumersEvent>? subs;
  ConsumersBloc() : super(ConsumersState()) {
    subs = StreamController<ConsumersEvent>();
  }

  @override
  Stream<ConsumersState> mapEventToState(
    ConsumersEvent event,
  ) async* {
    if (event is ConsumerAdd) {
      yield* _mapConsumersAddToState(event);
      subs?.add(event);
    } else if (event is ConsumerRemove) {
      yield* _mapConsumersRemoveToState(event);
      subs?.add(event);
    } else if (event is ConsumerResumed) {
      yield* _mapConsumerResumedToState(event);
    } else if (event is ConsumerPaused) {
      yield* _mapConsumerPausedToState(event);
    }
  }

  Stream<ConsumersState> _mapConsumersAddToState(ConsumerAdd event) async* {
    final Map<String, Consumer> newConsumers =
        Map<String, Consumer>.of(state.consumers);
    final Map<String, RTCVideoRenderer> newRenderers =
        Map<String, RTCVideoRenderer>.of(state.renderers);
    newConsumers[event.consumer.id] = event.consumer;
    if (event.consumer.kind == 'video') {
      newRenderers[event.consumer.id] = RTCVideoRenderer();
      await newRenderers[event.consumer.id]!.initialize();
      newRenderers[event.consumer.id]!.srcObject =
          newConsumers[event.consumer.id]!.stream;
    }

    yield ConsumersState(consumers: newConsumers, renderers: newRenderers);
  }

  Stream<ConsumersState> _mapConsumersRemoveToState(
      ConsumerRemove event) async* {
    final Map<String, Consumer> newConsumers =
        Map<String, Consumer>.of(state.consumers);
    final Map<String, RTCVideoRenderer> newRenderers =
        Map<String, RTCVideoRenderer>.of(state.renderers);
    newConsumers.remove(event.consumerId);
    await newRenderers[event.consumerId]?.dispose();
    newRenderers.remove(event.consumerId);

    yield ConsumersState(consumers: newConsumers, renderers: newRenderers);
  }

  Stream<ConsumersState> _mapConsumerResumedToState(
      ConsumerResumed event) async* {
    final Map<String, Consumer> newConsumers =
        Map<String, Consumer>.of(state.consumers);
    newConsumers[event.consumerId]?.resume();

    yield ConsumersState(consumers: newConsumers, renderers: state.renderers);
  }

  Stream<ConsumersState> _mapConsumerPausedToState(
      ConsumerPaused event) async* {
    final Map<String, Consumer> newConsumers =
        Map<String, Consumer>.of(state.consumers);
    newConsumers[event.consumerId]?.pause();

    yield ConsumersState(consumers: newConsumers, renderers: state.renderers);
  }

  @override
  Future<void> close() async {
    await subs?.close();
    for (var r in state.renderers.values) {
      await r.dispose();
    }
    return super.close();
  }
}
