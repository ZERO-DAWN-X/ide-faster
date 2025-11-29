enum IdeStatus {
  available,      // Exists and can be moved
  notInstalled,   // Doesn't exist
  alreadyMoved,   // Already a junction
}

class IdeModel {
  final String id;
  final String name;
  final String appDataFolderName;
  final String destinationFolderName;
  bool isSelected;
  IdeStatus status;

  IdeModel({
    required this.id,
    required this.name,
    required this.appDataFolderName,
    required this.destinationFolderName,
    this.isSelected = false,
    this.status = IdeStatus.notInstalled,
  });
}

