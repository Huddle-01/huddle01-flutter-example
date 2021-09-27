part of 'room_bloc.dart';

class RoomState extends Equatable {
  final String? activeSpeakerId;
  final String? state;
  final String? roomId;
  const RoomState({this.activeSpeakerId, this.state, this.roomId});

  static RoomState newActiveSpeaker(
    RoomState old, {
    String? activeSpeakerId,
  }) {
    return RoomState(
        roomId: old.roomId, state: old.state, activeSpeakerId: activeSpeakerId);
  }

  @override
  List<Object> get props => [activeSpeakerId!, state!, roomId!];
}
