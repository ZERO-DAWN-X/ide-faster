class IdeModel {
  final String id;
  final String name;
  final String appDataFolderName;
  final String destinationFolderName;
  bool isSelected;

  IdeModel({
    required this.id,
    required this.name,
    required this.appDataFolderName,
    required this.destinationFolderName,
    this.isSelected = false,
  });
}

