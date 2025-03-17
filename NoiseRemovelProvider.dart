import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart'; // Flutter Sound package
import 'package:http/http.dart' as http; // HTTP package for API requests
import 'dart:io'; // For file handling

class NoiseRemovalProvider with ChangeNotifier {
  FlutterSoundRecorder? _recorder;
  bool _isRecording = false;
  bool _isProcessing = false;
  String? _audioFilePath;
  String? _processedAudioPath;
  String? _errorMessage;

  bool get isRecording => _isRecording;
  bool get isProcessing => _isProcessing;
  String? get audioFilePath => _audioFilePath;
  String? get processedAudioPath => _processedAudioPath;
  String? get errorMessage => _errorMessage;

  NoiseRemovalProvider() {
    _recorder = FlutterSoundRecorder();
  }

  Future<void> initRecorder() async {
    try {
      await _recorder?.openAudioSession();
    } catch (e) {
      print("Error opening audio session: $e");
    }
  }
  Future<void> startRecording() async {
    try {
      await _recorder!.startRecorder(
        toFile: 'audio_${DateTime.now().millisecondsSinceEpoch}.aac',
      );
      _isRecording = true;
      _audioFilePath = 'audio_${DateTime.now().millisecondsSinceEpoch}.aac';
      notifyListeners(); // Notify listeners to update the UI
    } catch (e) {
      _errorMessage = 'Error starting recording: $e';
      notifyListeners();
    }
  }

  // Function to stop recording audio
  Future<void> stopRecording() async {
    try {
      await _recorder!.stopRecorder();
      _isRecording = false;
      notifyListeners(); // Notify listeners to update the UI
    } catch (e) {
      _errorMessage = 'Error stopping recording: $e';
      notifyListeners();
    }
  }

  // Function to upload audio file to backend
  Future<void> uploadAudio() async {
    if (_audioFilePath == null) return;

    try {
      _isProcessing = true;
      _errorMessage = null;
      notifyListeners();

      var uri = Uri.parse('http://127.0.0.1:5000/remove_noise');
      var request = http.MultipartRequest('POST', uri);
      request.files.add(await http.MultipartFile.fromPath('file', _audioFilePath!));

      var response = await request.send();
      if (response.statusCode == 200) {
        _processedAudioPath = 'http://127.0.0.1:5000/processed_audio.wav'; // Modify based on actual response
        _isProcessing = false;
      } else {
        _errorMessage = 'Failed to process the file. Please try again.';
        _isProcessing = false;
      }
      notifyListeners(); // Notify listeners to update the UI
    } catch (e) {
      _errorMessage = 'Error uploading file: $e';
      _isProcessing = false;
      notifyListeners();
    }
  }

  // Function to dispose the recorder session
  void disposeRecorder() {
    _recorder?.closeAudioSession();
    super.dispose();
  }
}
