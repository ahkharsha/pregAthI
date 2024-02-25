class UserModel {
  String id;
  String name;
  String email;
  String childAge;
  String childGender;
  String complication;
  String numOfTimesPregnant;
  String parentType;
  DateTime dueDate;
  String weight;
  bool isPregnant;
  List<String> notes;
  List<String> medicalHistory;

  UserModel(
      {required this.id,
      required this.name,
      required this.email,
      required this.childAge,
      required this.childGender,
      required this.complication,
      required this.dueDate,
      required this.numOfTimesPregnant,
      required this.weight,
      required this.notes,
      required this.parentType,
      required this.medicalHistory,
      required this.isPregnant});
}