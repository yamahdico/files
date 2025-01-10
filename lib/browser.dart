import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_launcher/url_launcher.dart';

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
      if (kIsWeb) {
        // در وب، فایل را در مرورگر باز کنید
        if (await canLaunchUrl(Uri.parse(url))) {
          await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Cannot open URL")),
          );
        }
      } else {
        // برای اندروید یا iOS
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
                downloadPDF(
                    "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf");
              },
              child: Text("Download PDF"),
            ),
            if (filePath != null && !kIsWeb)
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
