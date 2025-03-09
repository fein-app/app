  import 'dart:async';
  import 'dart:io';
  import 'package:fein_app/dpk/model_utils.dart';
  import 'package:fein_app/fein.dart';
  import 'package:fein_app/store/models_store.dart';
  import 'package:flutter/material.dart';
  import 'package:connectivity_plus/connectivity_plus.dart';

class ModelState extends ChangeNotifier {
  Model currentModel = Model(name: "", downloaded: false);
  String? currentModelPath;
  Uri currentUri = Uri(scheme: 'http', host: '127.0.0.1', port: 8080, path: "v1/chat/completions");
  Process? currentRunningModel;
  List<Model> currentModels = [];
  final Completer<void> _initCompleter = Completer<void>();
  Future<void> get initialized => _initCompleter.future;
  List<HuggingFaceModel> recommendedModels = [
    HuggingFaceModel(
      id: "unsloth/DeepSeek-R1-GGUF", 
      author: "unsloth", 
      likes: 974, 
      trendingScore: 30,
      downloads: 5106262, 
      libraryName: "transformers",
      modelId: "unsloth/DeepSeek-R1-GGUF",
    ),
    HuggingFaceModel(
      id: "unsloth/DeepSeek-R1-Distill-Llama-8B-GGUF", 
      author: "unsloth", 
      likes: 244, 
      trendingScore: 5,
      downloads: 362622, 
      libraryName: "transformers",
      modelId: "unsloth/DeepSeek-R1-Distill-Llama-8B-GGUF",
    ),
    HuggingFaceModel(
      id: "unsloth/DeepSeek-R1-Distill-Qwen-1.5B-GGUF", 
      author: "unsloth", 
      likes: 98, 
      trendingScore: 3,
      downloads: 312853, 
      libraryName: "transformers",
      modelId: "unsloth/DeepSeek-R1-Distill-Qwen-1.5B-GGUF",
    ),
  ];

  ModelState() {
    _initialize();
  }

  Future<void> _initialize() async {
    currentModels = await ModelsStore().getModels();
    if(currentModels.isNotEmpty) {
      currentModel = currentModels[0];  
    } else {
      currentModel = Model(name: "", downloaded: false);
    }
    if (currentModel.downloaded)  {
      currentModelPath = await ModelsStore().getOneModelFile(currentModel.name);
    } else {
      currentModelPath = "";
    }
    _setUpProcess();
    _initCompleter.complete();
    notifyListeners();
  }

  Future<void> _setUpProcess() async {
    currentRunningModel?.kill();

    try {
      print(currentModelPath);
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
    if (currentModels.any((model) => model.name == name)) return;
    try {
      final controller = StreamController<double>.broadcast();
      final downloadStream = controller.stream;

      Model newModel = Model(
          name: name,
          downloaded: false,
          downloadStream: downloadStream,
      );

      currentModels.add(newModel);
      if (currentModels.length == 1) changeModel(name);

      notifyListeners();

      double? lastProgress;
      DateTime? lastEmittedTime = DateTime.now();
      await for (var progress in ModelsStore().createModel(name, modelID)) {
        controller.add(progress);  

        final timeSinceLastEmission = DateTime.now().difference(lastEmittedTime!);

        if (timeSinceLastEmission.inMinutes >= 1) {
          List<ConnectivityResult> connectivityResults = await Connectivity().checkConnectivity();
          if (connectivityResults.contains(ConnectivityResult.none)) return; 
          break;
        }
      }

      ModelsStore().createFinishedFile(name);
      await controller.close();
      currentModels.where((model) => model.name == newModel.name).forEach((model) {
        model.downloadStream = null;
      });
    } catch (e) {
      print('Error during download: $e');
    } finally {
      _setUpProcess();
    }
  }
}