import 'package:fein_app/states/internet_state.dart';
import 'package:fein_app/states/search_state.dart';
import 'package:fein_app/view/models/searchbar_huggingface.dart';
import 'package:fein_app/view/models/search_results.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ModelScreen extends StatelessWidget {
  const ModelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final searchProvider = Provider.of<SearchProvider>(context);

    return Scaffold(
      backgroundColor: Color(0xFF1b1b1b),
      appBar: AppBar(
        backgroundColor: Color(0xFF1b1b1b),
        title: Text('Download models'),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    backgroundColor: Color(0xFF1b1b1b),
                    title: Text('Information'),
                    content: SingleChildScrollView(
                      child: Container(
                        color: Color(0xFF1b1b1b),
                        width: double.maxFinite,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("- Before installing any model make sure that you are not installing malitious software."),
                            SizedBox(height: 8),
                            Text("- The app can only run models in .gguf format. (We are working on more formats)"),
                            SizedBox(height: 8),
                            Text("- You can check your download status under Home > Account"),
                          ],
                        ),
                      ),
                    ),
                    actions: [
                      TextButton(
                        style: TextButton.styleFrom(
                          side: BorderSide(
                            width: 1.0,
                            color: Color(0xFF2c2c2c)
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0)
                        ),
                        child: Text('Close', style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal),),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Center(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            children: [
              SizedBox(height: 10),
              SearchbarHuggingface(
                onSubmitted: (value) async {
                  searchProvider.updateSearch(value);
                },
              ),
              FutureBuilder(
                future: context.read<InternetState>().checkInternetStatus(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (snapshot.hasData) {
                    if (snapshot.data!) {
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(30),
                          child: SearchResults(),
                        ),
                      );
                    } else {
                      return Center(child: Text("No internet found"));
                    }
                  } else {
                    return Center(child: Text("No internet found"));
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
