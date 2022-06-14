import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:planter_squared/data/models/garden.dart';
import 'package:planter_squared/data/models/model_fields.dart';
import 'package:planter_squared/data/util/firebase_service.dart';

class Task {
  Task({
    required this.taskId,
    required this.requirementType,
    required this.planterId,
    required this.timestamp,
    this.description,
    this.complete = false,
  });

  final String taskId;
  final RequirementType requirementType;
  final String planterId;
  final String? description;
  final Timestamp timestamp;
  bool complete;

  String get date => DateFormat('dd-MM-yyyy').format(timestamp.toDate());

  String get time => DateFormat('HH:MM').format(timestamp.toDate());

  Json json() => {
        TaskFields.taskId: taskId,
        TaskFields.requirementType: requirementType.index,
        TaskFields.planterId: planterId,
        TaskFields.description: description,
        TaskFields.timestamp: timestamp,
        TaskFields.complete: complete,
      };

  Task.load(Json data)
      : taskId = data[TaskFields.taskId],
        requirementType = RequirementType.values[data[TaskFields.requirementType]],
        planterId = data[TaskFields.planterId],
        description = data[TaskFields.description],
        timestamp = data[TaskFields.timestamp],
        complete = data[TaskFields.complete];
}
