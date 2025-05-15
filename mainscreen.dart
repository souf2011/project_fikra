import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'NoiseRemovalProvider.dart';

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
                provider.UploadAudio();
              },
              child:
              Text(provider.isProcessing ? 'Processing...' : 'Upload Audio'),
            ),
            SizedBox(height: 10),

            // Record Button
            ElevatedButton(
              onPressed: provider.isProcessing
                  ? null
                  : () {
                if (provider.isRecording) {
                  provider.stopRecording();
                } else {
                  provider.startRecording();
                }
              },
              child: Text(provider.isRecording ? 'Stop Recording' : 'Start Recording'),
            ),

            SizedBox(height: 10),

            // Send recorded audio for processing
            ElevatedButton(
              onPressed: provider.isProcessing || provider.audioFilePath == null
                  ? null
                  : () {
                provider.sendRecordedAudioForProcessing();
              },
              child: Text('Process Recorded Audio'),
            ),
            SizedBox(height: 20),

            // Show recording status
            if (provider.isRecording) ...[
              Text('Recording...'),
              CircularProgressIndicator(),
            ],

            // Show processing status
            if (provider.isProcessing && !provider.isRecording) ...[
              Text('Processing...'),
              CircularProgressIndicator(),
            ],

            SizedBox(height: 20),

            // Show error message if any
            if (provider.errorMessage != null) ...[
              Text(
                provider.errorMessage!,
                style: TextStyle(color: Colors.red),
              ),
            ], SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                provider.playProcessedAudio();
              },
              child: Text("play prosseced audio"),
            ),SizedBox(height :30),
            ElevatedButton(
              onPressed: () {
                print("Play button pressed");
                provider.playRecordedAudio();
              },
              child: Text('Play Recorded Audio'),
            ),
            if (provider.processedAudioPath != null) ...[
              Text(
                'Processed audio saved at:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(provider.processedAudioPath!),
            ]
          ],
        ),
      ),
    );
  }
}
