  import 'dart:async';
import 'dart:io';
  import 'package:fein_app/dpk/model.dart';
  import 'package:fein_app/fein.dart';
  import 'package:fein_app/store/models_store.dart';
  import 'package:flutter/material.dart';


class ModelState extends ChangeNotifier {
  Model currentModel = Model(name: "", downloaded: false);
  String? currentModelPath;
  Uri currentUri = Uri(scheme: 'http', host: '127.0.0.1', port: 8080, path: "v1/chat/completions");
  Process? currentRunningModel;
  List<Model> currentModels = [];

  ModelState() {
    _initialize();
  }

  Future<void> _initialize() async {
    currentModels = await ModelsStore().getModels();
    currentModel = currentModels[0];
    if (currentModel.downloaded) currentModelPath = await ModelsStore().getOneModelFile(currentModel.name);
    _setUpProcess();
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
    currentModelPath = await ModelsStore().getOneModelFile(name);
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
    ModelsStore().createModel(model, modelId);

    notifyListeners();
  }

  Future<void> createModel(String name, String modelID) async {
    try {
      final controller = StreamController<double>.broadcast();
      final downloadStream = controller.stream;

      Model newModel = Model(
          name: name,
          downloaded: false,
          downloadStream: downloadStream,
      );
      
      currentModels.add(newModel);

      if (currentModels.length == 1) currentModel = newModel;

      notifyListeners();

      await for (var progress in ModelsStore().createModel(name, modelID)) {
        controller.add(progress);  
        print(progress);
      }
      
      await controller.close();
    } catch (e) {
      print('Error during download: $e');
    } finally {
      _setUpProcess();
    }

  }
}