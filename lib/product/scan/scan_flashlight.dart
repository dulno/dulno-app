import 'package:torch_light/torch_light.dart';

class ScanFlashlight {
  void flashlight() async {
    try {
      await TorchLight.enableTorch();
      await Future.delayed(Duration(milliseconds: 200));
      await TorchLight.disableTorch();
    } catch (exception) {}
  }
}
