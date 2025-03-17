import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'NoiseRemovelProvider.dart'; // Import the provider

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NoiseRemovalProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Audio Noise Remover'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Upload Audio Button
            ElevatedButton(
              onPressed: provider.isProcessing
                  ? null
                  : () {
                // You can add file picker here to pick the audio
                // For example, using the `file_picker` package
                print('Upload functionality needs to be implemented');
              },
              child: Text(provider.isProcessing ? 'Processing...' : 'Upload Audio'),
            ),
            SizedBox(height: 10),

            // Button to start/stop recording
            ElevatedButton(
              onPressed: provider.isProcessing
                  ? null
                  : (provider.isRecording ? provider.stopRecording : provider.startRecording),
              child: Text(provider.isRecording ? 'Stop Recording' : 'Start Recording'),
            ),
            SizedBox(height: 10),

            // Show recording status
            if (provider.isRecording) ...[
              Text('Recording...'),
              CircularProgressIndicator(),
            ],

            // Show error message if any
            if (provider.errorMessage != null) ...[
              Text(provider.errorMessage!, style: TextStyle(color: Colors.red)),
            ],

            SizedBox(height: 20),

            // Show Play Recorded Audio button if audio is recorded
            if (provider.audioFilePath != null) ...[
              ElevatedButton(
                onPressed: () {
                  // Handle playing the recorded audio
                  print('Play Recorded Audio');
                },
                child: Text('Play Recorded Audio'),
              ),
            ],

            // Show Processed Audio Button if available
            if (provider.processedAudioPath != null) ...[
              ElevatedButton(
                onPressed: () {
                  // Handle playing the processed audio
                  print('Play Processed Audio');
                },
                child: Text('Play Processed Audio'),
              ),
            ],

            // Upload the recorded audio for processing
            if (provider.audioFilePath != null && !provider.isProcessing) ...[
              ElevatedButton(
                onPressed: provider.uploadAudio,
                child: Text('Upload and Process Audio'),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
