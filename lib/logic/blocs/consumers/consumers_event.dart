part of 'consumers_bloc.dart';

abstract class ConsumersEvent extends Equatable {
  const ConsumersEvent();
}

class ConsumerAdd extends ConsumersEvent {
  final Consumer consumer;

  const ConsumerAdd({required this.consumer});

  @override
  List<Object> get props => [consumer];
}

class ConsumerRemove extends ConsumersEvent {
  final String consumerId;

  const ConsumerRemove({required this.consumerId});

  @override
  List<Object> get props => [consumerId];
}

class ConsumerPaused extends ConsumersEvent {
  final String consumerId;

  const ConsumerPaused({required this.consumerId});

  @override
  List<Object> get props => [consumerId];
}

class ConsumerResumed extends ConsumersEvent {
  final String consumerId;

  const ConsumerResumed({required this.consumerId});

  @override
  List<Object> get props => [consumerId];
}
