import 'package:fein_app/fein.dart';
import 'package:flutter/material.dart';

class DownloadProgressBar extends StatelessWidget {
  final Model model;
  
  const DownloadProgressBar({
    super.key,
    required this.model,
  });

  @override
  Widget build(BuildContext context) {
    if (model.downloadStream != null) {
      return StreamBuilder<double>(
        stream: model.downloadStream,
        initialData: 0.0,
        builder: (context, snapshot) {
          final double progress = snapshot.data ?? 0.0;
          
          return Container(
            width: double.infinity,
            height: 2,
            decoration: BoxDecoration(
              color: Colors.grey[300],
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                color: Colors.blue,
              ),
            ),
          );
        },
      );
    } else {
      return Container(
        width: double.infinity,
        height: 2,
        color: model.downloaded ? Color(0xFF00FF00) : Color(0xFFFF0000)
      );
    }
  }
}