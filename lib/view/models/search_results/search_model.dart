import 'package:fein_app/fein.dart';
import 'package:fein_app/states/model_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchModel extends StatefulWidget {
  final HuggingFaceModel huggingFaceModel;

  const SearchModel({super.key, required this.huggingFaceModel});

  @override
  _HoverEffectModelState createState() => _HoverEffectModelState();
}


class _HoverEffectModelState extends State<SearchModel> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    ModelState modelProvider = Provider.of<ModelState>(context);
  
    return SizedBox(
      width: double.infinity,
      child: MouseRegion(
        onEnter: (_) {
          setState(() {
            isHovered = true; 
          });
        },
        onExit: (_) {
          setState(() {
            isHovered = false; 
          });
        },
        cursor: SystemMouseCursors.click, // Change cursor to pointer on hover
        child: AnimatedContainer(
          duration: Duration(milliseconds: 150), 
          decoration: BoxDecoration(
            color: Color(0xFF101010),
            border: Border.all(
              width: 1.0,
              color: Color(0xFF2c2c2c)
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: EdgeInsets.all(30),
          child: Container(
            decoration: BoxDecoration(
              color: Color(0x00000000), // Set your background color here
              borderRadius: BorderRadius.circular(8), // Optional: Adds rounded corners
            ),
            padding: EdgeInsets.all(16), // Optional: Adds padding inside the container
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getNameFromID(widget.huggingFaceModel.modelId),
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          SizedBox(height: 5),
                          Text(widget.huggingFaceModel.author),
                          SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text("Downloads: ${widget.huggingFaceModel.downloads}",
                                  style: TextStyle(color: Color(0xFF6d6c6e))),
                              SizedBox(width: 8),
                              Text("Likes: ${widget.huggingFaceModel.likes}",
                                  style: TextStyle(color: Color(0xFF6d6c6e))),
                            ],
                          ),
                        ],
                      ),
                    ),
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
                      onPressed: () {
                        modelProvider.createModel(_getNameFromID(widget.huggingFaceModel.modelId), widget.huggingFaceModel.modelId);
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
                                      Text("${_getNameFromID(widget.huggingFaceModel.modelId)} is being downloaded"),
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
                                  child: Text('OK', style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal),),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Text("Download", style: TextStyle(color: Colors.white),),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  } 

  String _getNameFromID(String modelID) {
    List<String> parts = modelID.split('/');
    return parts[1]; 
  }

}