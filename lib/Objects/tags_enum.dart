// Tags enum to match database
enum TagsEnum {
  science,
  research,
  maths,
  group,
  individual,
  hard,
  normal,
  easy
}

extension TagsEnumExtension on TagsEnum {
  String get databaseValue {
    switch (this) {
      case TagsEnum.science:
        return 'Science';
      case TagsEnum.research:
        return 'Research';
      case TagsEnum.maths:
        return 'Maths';
      case TagsEnum.group:
        return 'Group';
      case TagsEnum.individual:
        return 'Individual';
      case TagsEnum.hard:
        return 'Hard';
      case TagsEnum.normal:
        return 'Normal';
      case TagsEnum.easy:
        return 'Easy';
    }
  }
  
  String get displayName => databaseValue;
}
