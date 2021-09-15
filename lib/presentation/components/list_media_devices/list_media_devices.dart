import 'package:flutter/material.dart';
import 'package:huddle01_flutter/huddle01_flutter.dart';

class ListMediaDevices extends StatelessWidget {
  final List<MediaDeviceInfo> devices;
  final MediaDeviceInfo? selectedDevice;
  final Function(MediaDeviceInfo) onSelect;
  const ListMediaDevices({
    Key? key,
    required this.devices,
    this.selectedDevice,
    required this.onSelect,
  }) : super(key: key);

  void selectDevice(int index) {
    if (selectedDevice != devices[index]) {
      onSelect(devices[index]);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (devices.isNotEmpty) {
      return ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        itemCount: devices.length,
        itemBuilder: (context, index) => ListTile(
          key: Key(devices[index].deviceId),
          title: Text(devices[index].label),
          subtitle: Text('id: ${devices[index].deviceId}'),
          selected: selectedDevice == devices[index],
          onTap: () => selectDevice(index),
        ),
      );
    }

    return Text('No devices');
  }
}
