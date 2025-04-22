import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';

class NoiseRemovalProvider with ChangeNotifier {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
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
    _initRecorder();
    _initPlayer();
  }

  Future<void> _initRecorder() async {
    try {
      await Permission.microphone.request();
      await _recorder.openRecorder();
    } catch (e) {
      _errorMessage = 'Échec de l\'initialisation du micro : $e';
      notifyListeners();
    }
  }
  Future<void> _initPlayer() async {
    await _player.openPlayer();
  }

  Future<void> startRecording() async {
    try {
      var micStatus = await Permission.microphone.status;
      if (!micStatus.isGranted) {
        micStatus = await Permission.microphone.request();
        if (!micStatus.isGranted) {
          _errorMessage = 'Permission micro refusée';
          notifyListeners();
          return;
        }
      }

      if (_recorder.isRecording) return;

      final dir = await getApplicationDocumentsDirectory();
      _audioFilePath = '${dir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.aac';

      await _recorder.startRecorder(toFile: _audioFilePath);
      _isRecording = true;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erreur au démarrage de l’enregistrement : $e';
      notifyListeners();
    }
  }

  Future<void> stopRecording() async {
    try {
      if (!_recorder.isRecording) return;
      await _recorder.stopRecorder();
      _isRecording = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erreur à l\'arrêt de l\'enregistrement : $e';
      notifyListeners();
    }
  }

  /// Upload a picked audio file for processing
  Future<void> UploadAudio() async {
    _isProcessing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Show file picker dialog for custom audio types
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['aac', 'mp3', 'wav', 'm4a'],
      );

      if (result != null && result.files.single.path != null) {
        String pickedFilePath = result.files.single.path!;

        var uri = Uri.parse('http://192.168.56.1:5000/remove_noise');

        var request = http.MultipartRequest('POST', uri);
        request.files.add(await http.MultipartFile.fromPath('file', pickedFilePath));

        var response = await request.send();

        // If response is 200, process the returned file
        if (response.statusCode == 200) {
          final bytes = await response.stream.toBytes();  // Get processed audio as bytes

          // Save the processed audio locally
          final dir = await getApplicationDocumentsDirectory();
          final outFile = File('${dir.path}/processed_audio.wav');
          await outFile.writeAsBytes(bytes);

          _processedAudioPath = outFile.path; // Store the path of processed audio
          _errorMessage = null; // Clear any previous error
        } else {
          var responseBody = await response.stream.bytesToString();
          _errorMessage = 'Upload failed: ${response.reasonPhrase} - $responseBody';
        }
      } else {
        _errorMessage = 'No file selected.';
      }
    } catch (e) {
      _errorMessage = 'Error uploading file: $e';
    } finally {
      _isProcessing = false;
      notifyListeners(); // Update UI
    }
  }


  /// Send the recorded audio to the backend
  Future<void> sendRecordedAudioForProcessing() async {
    _isProcessing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Check if audio file is selected (either recorded or uploaded)
      if (audioFilePath == null) {
        _errorMessage = 'No audio file selected.';
        _isProcessing = false;
        notifyListeners();
        return; // Exit if no file is selected
      }

      // Prepare the request to send the audio file for processing
      var uri = Uri.parse('http://192.168.56.1:5000/remove_noise'); // Update IP if needed

      var request = http.MultipartRequest('POST', uri);
      request.files.add(await http.MultipartFile.fromPath('file', audioFilePath!));

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final bytes = await response.stream.toBytes();

        // Save processed audio locally
        final dir = await getApplicationDocumentsDirectory();
        final outFile = File('${dir.path}/processed_audio.wav');
        await outFile.writeAsBytes(bytes);

        _processedAudioPath = outFile.path; // Store the path of processed audio
        _errorMessage = null; // Clear any previous errors
      } else {
        _errorMessage = 'Processing failed: ${response.reasonPhrase} - $responseBody';
      }
    } catch (e) {
      _errorMessage = 'Error processing file: $e';
    } finally {
      _isProcessing = false;
      notifyListeners(); // Update UI
    }
  }
  Future<void> playRecordedAudio() async {
    try {
      if (_audioFilePath == null) {
        _errorMessage = 'Aucun fichier audio à lire.';
        notifyListeners();
        return;
      }

      // Ensure the player is open
      if (!_player.isOpen()) {
        await _player.openPlayer();
      }

      // Stop any existing playback first
      if (_player.isPlaying) {
        await _player.stopPlayer();
      }

      await _player.startPlayer(
        fromURI: _audioFilePath!,
        codec: Codec.aacADTS, // Adjust codec if needed based on your file type
        whenFinished: () {
          notifyListeners(); // To update UI when finished
        },
      );

      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erreur de lecture de l’audio : $e';
      notifyListeners();
    }
  }


  @override
  void dispose() {
    _recorder.closeRecorder();
    _player.closePlayer();
    super.dispose();
  }
}
