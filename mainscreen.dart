import 'package:flutter/material.dart';
import 'package:project_fikra/uploascreen.dart';
import 'package:provider/provider.dart';
import 'NoiseRemovalProvider.dart';
import 'recordingscreen.dart';

class MainScreen extends StatelessWidget {
  final VoidCallback onRecordPressed;
  final VoidCallback onUploadPressed;

  const MainScreen({
    Key? key,
    required this.onRecordPressed,
    required this.onUploadPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Noise Reduction App'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => recordingscreen()),
                  );
                },
                icon: Icon(Icons.mic),
                label: Text("Record Audio"),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  textStyle: TextStyle(fontSize: 18),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => uploadscreen()),
                  );


                },
                icon: Icon(Icons.upload_file),
                label: Text("Upload Audio"),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  textStyle: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
