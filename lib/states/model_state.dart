  import 'dart:io';
  import 'package:fein_app/dpk/model.dart';
  import 'package:fein_app/store/models_store.dart';
  import 'package:flutter/material.dart';


class ModelState extends ChangeNotifier {
  String currentModel = "DeepSeek-R1";
  String? currentModelPath;
  Uri currentUri = Uri(scheme: 'http', host: '127.0.0.1', port: 8080, path: "v1/chat/completions");
  Process? currentRunningModel;
  List<String> currentModels = [];

  ModelState() {
    _initialize();
  }

  Future<void> _initialize() async {
    currentModels = await ModelsStore().getModels();
    currentModelPath = await ModelsStore().getOneModelFile(currentModel);
    notifyListeners();
  }

  Future<void> _setUpProcess() async {
    currentRunningModel?.kill();

    try {
      Process? process = await Model().startModel(currentModel, currentModelPath!);
      currentRunningModel = process;
    } catch (e) {
      print("Failed to start model: $e");
    }
  }

  Future<void> changeModel(String name) async {
    currentModel = name;
    await ModelsStore().getOneModelFile(name);
    await _setUpProcess();
    notifyListeners();
  }

  Future<void> removeModelFromCurrentModels(String model) async {
    final newList = List<String>.from(currentModels)..remove(model);
    currentModels = newList;
    await ModelsStore().deleteModel(model);
    if (model == currentModel) {
      currentModel = currentModels.isNotEmpty ? currentModels[0] : "";
    }
    notifyListeners();
  }

  Future<void> appendModelToCurrentModels(String model, String modelId) async {
    currentModels.add(model);
    
    await ModelsStore().createModel(model, modelId);

    notifyListeners();
  }
  
}