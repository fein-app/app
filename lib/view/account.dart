import 'package:fein_app/fein.dart';
import 'package:fein_app/states/model_state.dart';
import 'package:fein_app/store/models_store.dart';
import 'package:fein_app/view/account/download_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Account extends StatelessWidget {
  const Account({super.key});
  
  @override
  Widget build(BuildContext context) {
    ModelState modelState = Provider.of<ModelState>(context);
    
    return Scaffold(
      backgroundColor: Color(0xFF1b1b1b),
      appBar: AppBar(
        backgroundColor: Color(0xFF1b1b1b),
        title: Text("Account"),
      ),
    
      body: Padding(
        padding: EdgeInsets.all(30),
        child: Column(
          children: [
            Container(
              alignment: Alignment.centerLeft,
              child: Text("Current models", style: TextStyle(fontSize: 16),),
            ),

            SizedBox(
              height: 10,
            ),

            Expanded(
              child: FutureBuilder(
                future: ModelsStore().getModels(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (snapshot.hasData) {
                    List<Model> models = snapshot.data!;
                    return ListView.separated(
                      itemCount: models.length,
                      separatorBuilder: (context, index) => SizedBox(height: 10), // Add spacing between items
                      itemBuilder: (context, index) {
                        String model = models[index].name;
                        return Container(
                          decoration: BoxDecoration(
                            color: Color(0xFF101010),
                            border: Border.all(
                              width: 1,
                              color: Color(0xFF2c2c2c),
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Padding(
                            padding: EdgeInsets.only(left: 15, top: 10, right: 15, bottom: 10),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(model),
                                    TextButton(
                                      style: TextButton.styleFrom(
                                        backgroundColor: Color(0x00000000),
                                        side: BorderSide(
                                          width: 1.0,
                                          color: Color(0xFF2c2c2c)
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(30),
                                        ),
                                        padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 20.0)
                                      ),
                                      onPressed: () => modelState.removeModelFromCurrentModels(model),
                                      child: Text("Delete", style: TextStyle(color: Colors.white),)
                                    ),
                                  ],
                                ),
                                DownloadProgressBar(model: models[index]),
                              ],
                            )  
                          ),
                        );
                      },
                    );
                  } else {
                    return Center(child: Text("No models"));
                  }
                }
              )
            ) 
          ],
        ),
      ),
    );
  }
}