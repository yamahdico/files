import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Download and View PDF',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? filePath;

  Future<void> downloadPDF(String url) async {
    try {
      // درخواست مجوز ذخیره‌سازی
      if (await Permission.storage.request().isGranted) {
        // مسیر ذخیره فایل
        Directory? directory = await getExternalStorageDirectory();
        if (directory != null) {
          String fileName = "downloaded_file.pdf";
          String savePath = "${directory.path}/$fileName";

          // دانلود فایل با Dio
          Dio dio = Dio();
          await dio.download(url, savePath);

          setState(() {
            filePath = savePath;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("File downloaded to $savePath")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Storage permission denied!")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Download and View PDF')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                downloadPDF("https://fadak.ir/01.pdf");
              },
              child: Text("Download PDF"),
            ),
            if (filePath != null)
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PDFViewerPage(filePath: filePath!),
                    ),
                  );
                },
                child: Text("View PDF"),
              ),
          ],
        ),
      ),
    );
  }
}

class PDFViewerPage extends StatelessWidget {
  final String filePath;

  PDFViewerPage({required this.filePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("PDF Viewer")),
      body: PDFView(
        filePath: filePath,
      ),
    );
  }
}
