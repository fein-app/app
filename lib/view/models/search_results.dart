import 'package:fein_app/fein.dart';
import 'package:fein_app/states/model_state.dart';
import 'package:fein_app/states/search_state.dart';
import 'package:fein_app/store/models_store.dart';
import 'package:fein_app/view/models/search_results/search_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchResults extends StatelessWidget {
  const SearchResults({super.key}); 

  @override
  Widget build(BuildContext context) {
    final SearchProvider searchProvider = Provider.of<SearchProvider>(context);
    final List<HuggingFaceModel> recommendedModels = context.watch<ModelState>().recommendedModels; 

    if (searchProvider.search.isNotEmpty) {
      return Column(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            child: Padding(padding: EdgeInsets.only(left: 15), child: Text("Search results", style: TextStyle(fontSize: 16),),),
          ),
          Expanded(
            child: FutureBuilder(
              future: ModelsStore().search(searchProvider.search),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  if (snapshot.data != null) {
                    List<HuggingFaceModel> searchResults = snapshot.data!;

                    return ListView(
                      children: searchResults.map((model) {
                        return SizedBox(
                          width: double.infinity,
                          child: MouseRegion(
                            child: GestureDetector(
                              onTap: () {
                                // Implement model info
                              },
                              child: Padding(
                                padding: EdgeInsets.all(15),
                                child: SearchModel(
                                  huggingFaceModel: model
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  } else {
                    return Center(
                      child: Text("No models found"),
                    );
                  }
                } else {
                  return Center(child: Text("No models"));
                }
              }
            ),
          )

        ],
      );
    } else {         
      return Column(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            child: Padding(padding: EdgeInsets.only(left: 15), child: Text("Recommended", style: TextStyle(fontSize: 16),),),
          ),
          Expanded(
            child: ListView(
              children: recommendedModels.map((model) {
                return SizedBox(
                  width: double.infinity,
                  child: MouseRegion(
                    child: GestureDetector(
                      onTap: () {
                        // Implement model info
                      },
                      child: Padding(
                        padding: EdgeInsets.all(15),
                        child: SearchModel(
                          huggingFaceModel: model
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      );
    }
       
  }
}