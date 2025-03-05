  import 'dart:io';
  import 'package:fein_app/dpk/model.dart';
  import 'package:fein_app/fein.dart';
  import 'package:fein_app/store/models_store.dart';
  import 'package:flutter/material.dart';


class ModelState extends ChangeNotifier {
  Model currentModel = Model(name: "DeepSeek-R1-Distill-Llama-8B-GGUF", downloaded: true);
  String? currentModelPath;
  Uri currentUri = Uri(scheme: 'http', host: '127.0.0.1', port: 8080, path: "v1/chat/completions");
  Process? currentRunningModel;
  List<Model> currentModels = [];

  ModelState() {
    _initialize();
  }

  Future<void> _initialize() async {
    currentModels = await ModelsStore().getModels();
    currentModelPath = await ModelsStore().getOneModelFile(currentModel.name);

    notifyListeners();
  }

  Future<void> _setUpProcess() async {
    currentRunningModel?.kill();

    try {
      Process? process = await ModelExecUtils().startModel(currentModel.name, currentModelPath!);
      currentRunningModel = process;
    } catch (e) {
      print("Failed to start model: $e");
    }
  }

  Future<void> changeModel(String name) async {
    bool downloaded = await ModelsStore().checkDownloadStatus(name);
    currentModel = Model(name: name, downloaded: downloaded);
    await ModelsStore().getOneModelFile(name);
    await _setUpProcess();
    notifyListeners();
  }

  Future<void> removeModelFromCurrentModels(String model) async {
    final newList = List<Model>.from(currentModels)..removeWhere((m) => m.name == model);
    currentModels = newList;
    await ModelsStore().deleteModel(model);
    if (model == currentModel.name) {
      currentModel = currentModels.isNotEmpty ? currentModels[0] : Model(name: "", downloaded: false);
    }
    notifyListeners();
  }

  Future<void> appendModelToCurrentModels(String model, String modelId) async {
    bool downloaded = await ModelsStore().checkDownloadStatus(model);
    currentModels.add(Model(name: model, downloaded: downloaded));
    
    await ModelsStore().createModel(model, modelId);

    notifyListeners();
  }

  Future<void> createModel(String name, String modelID) async {
    Stream<double> downloadStream = ModelsStore().createModel(name, modelID);
    
    currentModels.add(
      Model(
        name: name, 
        downloaded: false,
        downloadStream: downloadStream
      )
    );

    downloadStream.listen(
      (double progress) {},
      onDone: () {
        // Find the model in the list and update its `downloaded` status
        final modelIndex = currentModels.indexWhere((m) => m.name == name);
        if (modelIndex != -1) {
          final updatedModel = Model(
            name: name,
            downloaded: true, 
            downloadStream: null, 
          );

          currentModels[modelIndex] = updatedModel;
        }
      },
      onError: (error) {
        // Handle errors (optional)
        print("Download error: $error");
      },
    );
  }
}