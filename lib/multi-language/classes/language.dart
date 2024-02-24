class Language {
  final int id;
  final String flag;
  final String name;
  final String languageCode;

  Language(this.id, this.flag, this.name, this.languageCode);

  static List<Language> languageList() {
    return <Language>[
      Language(1, "", "English", "en"),
      Language(2, "", "हिंदी", "hi"),
      Language(3, '', "తెలుగు", "te"),
      Language(4, '', "தமிழ்","ta"),
      Language(5, '', "മലയാളം","ma")
    ];
  }
}