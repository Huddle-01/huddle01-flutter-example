part of 'room_bloc.dart';

abstract class RoomEvent extends Equatable {
  const RoomEvent();
}

class RoomSetActiveSpeakerId extends RoomEvent {
  final String speakerId;

  const RoomSetActiveSpeakerId({required this.speakerId});

  @override
  List<Object> get props => [speakerId];
}
