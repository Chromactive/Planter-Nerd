import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:planter_squared/data/models/model_fields.dart';
import 'package:planter_squared/data/repos.dart';
import 'package:planter_squared/data/util/constants.dart';
import 'package:planter_squared/data/util/firebase_service.dart';
import 'package:planter_squared/util.dart';

enum RequirementType { light, moisture, temperature }

extension RequirementColor on RequirementType {
  Color get color {
    switch (this) {
      case RequirementType.light:
        return Colors.amber[300]!;
      case RequirementType.moisture:
        return Colors.blue[400]!;
      case RequirementType.temperature:
        return Colors.red[400]!;
    }
  }
}

extension RequirementName on RequirementType {
  String get name {
    switch (this) {
      case RequirementType.light:
        return 'Light';
      case RequirementType.moisture:
        return 'Water';
      case RequirementType.temperature:
        return 'Temperature';
    }
  }
}

extension RequirementIcons on RequirementType {
  IconData get baseIcon {
    switch (this) {
      case RequirementType.light:
        return Icons.sunny;
      case RequirementType.moisture:
        return Icons.water_drop;
      case RequirementType.temperature:
        return Icons.thermostat;
    }
  }

  IconData get feedIcon {
    switch (this) {
      case RequirementType.light:
        return Icons.lightbulb;
      case RequirementType.moisture:
        return Icons.shower;
      case RequirementType.temperature:
        return CupertinoIcons.thermometer_sun;
    }
  }

  IconData get minIcon {
    switch (this) {
      case RequirementType.light:
        return CupertinoIcons.moon;
      case RequirementType.moisture:
        return Icons.water_drop;
      case RequirementType.temperature:
        return Icons.severe_cold;
    }
  }

  IconData get maxIcon {
    switch (this) {
      case RequirementType.light:
        return Icons.sunny;
      case RequirementType.moisture:
        return Icons.water;
      case RequirementType.temperature:
        return Icons.local_fire_department;
    }
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

class Requirement {
  const Requirement({
    required this.type,
    required this.range,
    required this.unit,
    required this.comment,
    required this.frequency,
    required this.measurePath,
  });

  final RequirementType type;
  final Range range;
  final String unit;
  final String comment;
  final String frequency;
  final String measurePath;

  String rangeToText() {
    String text;
    if (range.isSingleValue) {
      text = range.min.toStringAsFixed(2);
    } else {
      text = '${range.min.toStringAsFixed(2)}-${range.max.toStringAsFixed(2)}';
    }
    text = '$text $unit';
    if (type == RequirementType.light) {
      text = '$text of daylight';
    } else if (type == RequirementType.moisture) {
      text = '$text of water';
    }
    return text;
  }

  Future<bool> toggleMode(String planterId) async {
    final value = await FirebaseDatabase.instance
        .ref(DatabaseConstants.measureCollections)
        .child(planterId)
        .child(measurePath)
        .get();
    await FirebaseDatabase.instance
        .ref(DatabaseConstants.measureCollections)
        .child(planterId)
        .update({measurePath: !((value.value ?? false) as bool)});
    return (await FirebaseDatabase.instance
            .ref(DatabaseConstants.measureCollections)
            .child(planterId)
            .child(measurePath)
            .get())
        .value as bool;
  }

  Json json() => {
        RequirementFields.type: type.index,
        RequirementFields.unit: unit,
        RequirementFields.minValue: range.min,
        RequirementFields.maxValue: range.max,
        RequirementFields.comment: comment,
        RequirementFields.frequency: frequency,
      };

  Requirement.load(Json data)
      : type = RequirementType.values[data[RequirementFields.type]],
        unit = data[RequirementFields.unit],
        comment = data[RequirementFields.comment],
        frequency = data[RequirementFields.frequency],
        measurePath = RequirementType.values[data[RequirementFields.type]] == RequirementType.light
            ? DatabaseConstants.activateLight
            : RequirementType.values[data[RequirementFields.type]] == RequirementType.moisture
                ? DatabaseConstants.activateMoisture
                : DatabaseConstants.activateTemperature,
        range = Range(
            minValue: data[RequirementFields.minValue].toDouble(),
            maxValue: data[RequirementFields.maxValue].toDouble());
}

class Plant {
  const Plant({
    required this.pid,
    required this.scientificName,
    required this.plantName,
    required this.imageLink,
    required this.description,
    required this.requirements,
  });

  final String pid;
  final String scientificName;
  final String plantName;
  final String imageLink;
  final String description;
  final Map<String, Requirement> requirements;

  Json json() => {
        PlantFields.pid: pid,
        PlantFields.scientificName: scientificName,
        PlantFields.name: plantName,
        PlantFields.imageLink: imageLink,
        PlantFields.description: description,
        PlantFields.requirements: requirements,
      };

  Plant.load(Json data)
      : pid = data[PlantFields.pid],
        scientificName = data[PlantFields.scientificName],
        plantName = data[PlantFields.name],
        description = data[PlantFields.description],
        imageLink = data[PlantFields.imageLink],
        requirements = {} {
    final reqs = data[PlantFields.requirements];
    requirements[PlantFields.light] = Requirement.load(reqs[PlantFields.light]);
    requirements[PlantFields.moisture] = Requirement.load(reqs[PlantFields.moisture]);
    requirements[PlantFields.temperature] = Requirement.load(reqs[PlantFields.temperature]);
  }
}

class Planter {
  Planter({
    required this.planterId,
    required this.plantId,
    required this.name,
    required this.location,
    required this.temperatureRead,
    required this.lightRead,
    required this.moistureRead,
    required this.taskIds,
  })  : onMeasureChange = [],
        plant = plantDatabase.streamSingle(plantId);

  final String name;
  final String location;
  final String planterId;
  final String plantId;
  final List<String> taskIds;
  final Stream<Plant?> plant;

  List<VoidCallback> onMeasureChange;
  double temperatureRead;
  double lightRead;
  double moistureRead;

  bool isOutOfRequirement(Requirement requirement, double readValue) {
    return !requirement.range.contains(readValue);
  }

  bool isMeasureCloseToRequirementExtremities(Requirement requirement, double readValue) {
    double relative = requirement.range.convertToRelative(readValue);
    return relative < 0.05 || relative > 0.95;
  }

  bool isRequirementInDanger(Requirement requirement, double readValue) {
    return isOutOfRequirement(requirement, readValue) || isMeasureCloseToRequirementExtremities(requirement, readValue);
  }

  List<Requirement> getWarningRequirements(Plant plant) {
    return [
      if (isRequirementInDanger(plant.requirements[PlantFields.light]!, lightRead))
        plant.requirements[PlantFields.light]!,
      if (isRequirementInDanger(plant.requirements[PlantFields.moisture]!, moistureRead))
        plant.requirements[PlantFields.moisture]!,
      if (isRequirementInDanger(plant.requirements[PlantFields.temperature]!, temperatureRead))
        plant.requirements[PlantFields.temperature]!
    ];
  }

  bool hasWarning(Plant? plant) {
    if (plant == null) return false;
    return isRequirementInDanger(plant.requirements[PlantFields.light]!, lightRead) ||
        isRequirementInDanger(plant.requirements[PlantFields.moisture]!, moistureRead) ||
        isRequirementInDanger(plant.requirements[PlantFields.temperature]!, temperatureRead);
  }

  Json json() => {
        PlanterFields.name: name,
        PlanterFields.location: location,
        PlanterFields.planterId: planterId,
        PlanterFields.plantId: plantId,
        PlanterFields.tasks: taskIds,
      };

  Planter.load(Json data)
      : name = data[PlanterFields.name],
        location = data[PlanterFields.location],
        planterId = data[PlanterFields.planterId],
        plantId = data[PlanterFields.plantId],
        lightRead = 0.0,
        temperatureRead = 0.0,
        moistureRead = 0.0,
        taskIds = [],
        onMeasureChange = [],
        plant = plantDatabase.streamSingle(data[PlanterFields.plantId]) {
    FirebaseDatabase.instance
        .ref(DatabaseConstants.measureCollections)
        .child(planterId)
        .child(DatabaseConstants.measureMoisture)
        .onValue
        .listen((event) {
      try {
        moistureRead = event.snapshot.value as double;
      } catch (_) {
        try {
          moistureRead = (event.snapshot.value as int).toDouble();
        } catch (_) {}
      } finally {
        onMeasureChange.forEach((element) {
          element();
        });
      }
    });
    FirebaseDatabase.instance
        .ref(DatabaseConstants.measureCollections)
        .child(planterId)
        .child(DatabaseConstants.measureTemperature)
        .onValue
        .listen((event) {
      try {
        temperatureRead = event.snapshot.value as double;
      } catch (_) {
        try {
          temperatureRead = (event.snapshot.value as int).toDouble();
        } catch (_) {}
      } finally {
        onMeasureChange.forEach((element) {
          element();
        });
      }
    });
    FirebaseDatabase.instance
        .ref(DatabaseConstants.measureCollections)
        .child(planterId)
        .child(DatabaseConstants.measureLight)
        .onValue
        .listen((event) {
      try {
        lightRead = event.snapshot.value as double;
      } catch (_) {
        try {
          lightRead = (event.snapshot.value as int).toDouble();
        } catch (_) {}
      } finally {
        onMeasureChange.forEach((element) {
          element();
        });
      }
    });
    for (final task in data[PlanterFields.tasks]) {
      taskIds.add(task);
    }
  }
}
