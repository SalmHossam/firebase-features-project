import 'dart:io';
import 'dart:async';
import 'package:faculty_lab1/MyHomePage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
class Screen1 extends StatefulWidget {
  const Screen1({super.key, required this.userName});
  static const String routeName='Screen1';
  final String userName;
  @override
  State<Screen1> createState() => _Screen1State();
}

class _Screen1State extends State<Screen1> {
  double _uploadProgress=0.0;
  Future<void> storeDownloadUrl(String userName, String downloadURL) async {
    DatabaseReference ref = FirebaseDatabase.instance.ref(userName);
    await ref.set(downloadURL);
  }
  void showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Upload & Download',style: TextStyle(color: Colors.white),),backgroundColor:Colors.deepPurple),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            if(pickedFile!=null)
              Container(
                color: Colors.deepPurpleAccent,
                child: Center(
                    child :_isImageFile(pickedFile!.path)
                    ? Image.file(
                  File(pickedFile!.path!),
                  width: double.infinity,
                  fit: BoxFit.cover,
                )
                    : Text('Display File: ${pickedFile!.name}'),
                ),
              ),
              SizedBox(height: 30,),

            ElevatedButton(onPressed: () {
              selectFile();
            }, child:Row(children: [
              Icon(Icons.add_box_outlined),
              Text('select File')
            ],) ),
            SizedBox(height: 24,),
            LinearPercentIndicator(
              animation: true,
              lineHeight: 30,
              percent: _uploadProgress/100,
              center: new Text(
                _uploadProgress.toString() + "%",
                style: new TextStyle(
                    color: Colors.black,
                    fontSize: 20.0),
              ),
              progressColor: Colors.green,
              backgroundColor: Colors.grey,
            ),
            SizedBox(height: 24,),
            ElevatedButton(onPressed: () {
               uploadFile(widget.userName);
            }, child:Row(children: [
              Icon(Icons.upload_sharp),
              Text('Upload File')
            ],) ),

          ],
        ),
      ),
    );
  }

  PlatformFile?pickedFile;
  UploadTask?uploadTask;
  Future<void> uploadFile(String folder) async {
      final path = '$folder/${pickedFile!.name}';
      final file = File(pickedFile!.path!);

      final ref = FirebaseStorage.instance.ref().child(path);
      uploadTask = ref.putFile(file);

      uploadTask!.snapshotEvents.listen((TaskSnapshot snapshot) {
        setState(() {
          _uploadProgress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
        });
      });

      await uploadTask!.whenComplete(() async {
        final urlDownload = await ref.getDownloadURL();
        await storeDownloadUrl(widget.userName, urlDownload);
        showSnackBar("Uploaded Successfully", Colors.green);
      }).catchError((error, stackTrace) {
        print("Upload error: $error");
        showSnackBar("Upload Failed", Colors.red);
      });



  }


  Future selectFile()async{
    final result=await FilePicker.platform.pickFiles();
    if(result==null) return;
    setState(() {
      pickedFile=result.files.first;
    });
  }

  bool _isImageFile(path) {
    final List<String> imageExtensions = ['jpg', 'jpeg', 'png', 'gif'];
    String extension = path.split('.').last.toLowerCase();
    return imageExtensions.contains(extension);
  }
}
