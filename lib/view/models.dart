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
        title: Text('Download new models'),
      ),

      body: Center(
        child: SizedBox(
          width: double.infinity, // 70% of screen width
          child: Column(
            children: [
              SizedBox(
                height: 10,
              ),

              SearchbarHuggingface(
                onSubmitted: (value) async {
                  searchProvider.updateSearch(value);
                }
              ),

              FutureBuilder(
                future: context.read<InternetState>().checkInternetStatus(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (snapshot.hasData) {
                    if (snapshot.data!)  {
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
                }
              ),

              Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Color(0xFF2c2c2c), // Change to your desired color
                      width: 1.0, // Thickness of the border
                    ),
                  ),
                ),
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // Aligns content to the left
                    children: [
                      Text("- Please make sure on HuggingFace that you do not install malicious software"),
                      Text("- The app can only run models .gguf format. (We are working on more formats)"),
                      Text("- You can check your download status under Home > Account"),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
