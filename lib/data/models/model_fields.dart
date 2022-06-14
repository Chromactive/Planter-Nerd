class UserFields {
  const UserFields._();

  static const String uid = "uid";
  static const String name = "name";
  static const String email = "email";
  static const String verificationSent = "verificationSent";
}

class PlantFields {
  const PlantFields._();

  static const String pid = "pid";
  static const String scientificName = "scientificName";
  static const String name = "plantName";
  static const String imageLink = "imageLink";
  static const String description = "description";
  static const String requirements = "requirements";

  static const String temperature = "temperature";
  static const String moisture = "moisture";
  static const String light = "light";
}

class PlanterFields {
  const PlanterFields._();

  static const String uid = "uid";
  static const String name = "name";
  static const String location = "location";
  static const String planterId = "planterId";
  static const String plantId = "plantId";
  static const String tasks = "tasks";
}

class RequirementFields {
  const RequirementFields._();

  static const String type = "type";
  static const String unit = "unit";
  static const String minValue = "minVal";
  static const String maxValue = "maxVal";
  static const String comment = "comment";
  static const String frequency = "frequency";
}

class TaskFields {
  const TaskFields._();

  static const String taskId = "taskId";
  static const String requirementType = "requirementType";
  static const String planterId = "planterId";
  static const String description = "descrition";
  static const String timestamp = "timestamp";
  static const String complete = "complete";
}
