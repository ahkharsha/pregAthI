import 'package:flutter/material.dart';
import 'package:pregathi/main.dart';
import 'package:pregathi/multi-language/classes/language.dart';
import 'package:pregathi/multi-language/classes/language_constants.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({Key? key}) : super(key: key);

  @override
  _LanguageSelectionScreenState createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  Language? selectedLanguage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Language'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: Language.languageList()
            .map(
              (language) => InkWell(
                onTap: () {
                  setState(() {
                    selectedLanguage = language;
                  });
                },
                child: Row(
                  children: [
                    Container(
                      width: 24.0,
                      height: 24.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: selectedLanguage == language
                            ? Colors.green // Selected color
                            : Colors.white, // Unselected color
                        border: Border.all(
                          color: Colors.green, // Border color
                        ),
                      ),
                      child: Center(
                        child: selectedLanguage == language
                            ? Icon(
                                Icons.check,
                                size: 16.0,
                                color: Colors.white, // Check icon color
                              )
                            : null,
                      ),
                    ),
                    SizedBox(width: 8.0),
                    Text(language.name),
                  ],
                ),
              ),
            )
            .toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (selectedLanguage != null) {
            Locale _locale = await setLocale(selectedLanguage!.languageCode);
            MyApp.setLocale(context, _locale);
            Navigator.pop(context); // Go back to the previous screen
          }
        },
        child: Icon(Icons.check),
      ),
    );
  }
}
