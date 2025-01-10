import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Scan {
  static const MethodChannel _channel = const MethodChannel('chavesgu/scan');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<String?> parse(String path) async {
    final String? result = await _channel.invokeMethod('parse', path);
    return result;
  }
}

class ScanView extends StatefulWidget {
  ScanView({
    this.controller,
    this.onCapture,
    this.onException,
    this.scanLineColor = Colors.green,
    this.scanAreaScale = 0.7,
  })  : assert(scanAreaScale <= 1.0, 'scanAreaScale must <= 1.0'),
        assert(scanAreaScale > 0.0, 'scanAreaScale must > 0.0');

  final ScanController? controller;
  final CaptureCallback? onCapture;
  final ExceptionCallback? onException;
  final Color scanLineColor;
  final double scanAreaScale;

  @override
  State<StatefulWidget> createState() => _ScanViewState();
}

class _ScanViewState extends State<ScanView> {
  MethodChannel? _channel;

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return UiKitView(
        viewType: 'chavesgu/scan_view',
        creationParamsCodec: StandardMessageCodec(),
        creationParams: {
          "r": widget.scanLineColor.red,
          "g": widget.scanLineColor.green,
          "b": widget.scanLineColor.blue,
          "a": widget.scanLineColor.opacity,
          "scale": widget.scanAreaScale,
        },
        onPlatformViewCreated: (id) {
          _onPlatformViewCreated(id);
        },
      );
    } else {
      return AndroidView(
        viewType: 'chavesgu/scan_view',
        creationParamsCodec: StandardMessageCodec(),
        creationParams: {
          "r": widget.scanLineColor.red,
          "g": widget.scanLineColor.green,
          "b": widget.scanLineColor.blue,
          "a": widget.scanLineColor.opacity,
          "scale": widget.scanAreaScale,
        },
        onPlatformViewCreated: (id) {
          _onPlatformViewCreated(id);
        },
      );
    }
  }

  void _onPlatformViewCreated(int id) {
    _channel = MethodChannel('chavesgu/scan/method_$id');
    _channel?.setMethodCallHandler((MethodCall call) async {
      switch(call.method) {
        case 'onCaptured':
          if (widget.onCapture != null)
            widget.onCapture!(call.arguments.toString());
          break;
        case 'scanDrawViewException':
          if (widget.onException != null)
            widget.onException!(call.arguments.toString());
          break;
        default:
          break;
      }
    });
    widget.controller?._channel = _channel;
  }
}

typedef CaptureCallback(String data);

typedef ExceptionCallback(String exception);

class ScanArea {
  const ScanArea(this.width, this.height);

  final double width;
  final double height;
}

class ScanController {
  MethodChannel? _channel;

  ScanController();

  void resume() {
    _channel?.invokeMethod("resume");
  }

  void pause() {
    _channel?.invokeMethod("pause");
  }

  void toggleTorchMode() {
    _channel?.invokeMethod("toggleTorchMode");
  }
}
