import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pregathi/buttons/main_button.dart';
import 'package:pregathi/const/constants.dart';
import 'package:pregathi/multi-language/classes/language.dart';
import 'package:pregathi/multi-language/classes/language_constants.dart';
import 'package:pregathi/navigators.dart';
import 'package:sizer/sizer.dart';

import '../../main.dart';

class LanguageSelectionScreen extends StatefulWidget {
  final String? initialLanguageCode;

  const LanguageSelectionScreen({Key? key, this.initialLanguageCode})
      : super(key: key);

  @override
  _LanguageSelectionScreenState createState() =>
      _LanguageSelectionScreenState();
}

enum SingingCharacter { english, hindi, telugu, tamil, malayalam }

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  SingingCharacter? selectedLanguage;
  String? initialLanguageCode;

  @override
  void initState() {
    super.initState();
    if (widget.initialLanguageCode != null) {
      selectedLanguage = _getEnumForLanguageCode(widget.initialLanguageCode!);
    }
    getCurrentLang();
  }

  getCurrentLang() async {
    DocumentSnapshot userData = await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).get();
    setState(() {
      initialLanguageCode=userData['language'];
    });
  }

  SingingCharacter _getEnumForLanguageCode(String languageCode) {
    switch (languageCode) {
      case 'en':
        return SingingCharacter.english;
      case 'hi':
        return SingingCharacter.hindi;
      case 'te':
        return SingingCharacter.telugu;
      case 'ta':
        return SingingCharacter.tamil;
      case 'ma':
        return SingingCharacter.malayalam;
      default:
        return SingingCharacter.english;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
            ),
            color: Colors.white,
            onPressed: () => goBack(context)),
        title: Text(
          'Select Language',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: primaryColor,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
                  padding: const EdgeInsets.only(top:30, bottom: 20,),
                  child: Text(
                    'Choose your default language',
                    style:
                        TextStyle(fontSize: 15.sp, fontWeight: FontWeight.normal),
                  ),
                ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: Language.languageList()
                .map(
                  (language) => Padding(
                    padding:
                        const EdgeInsets.only(left: 15, right: 15, bottom: 10),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(color: Colors.black, width: 1),
                      ),
                      child: ListTile(
                        tileColor: boxColor,
                        contentPadding: EdgeInsets.zero,
                        title: RadioListTile<SingingCharacter>(
                          title: Text(language.name),
                          value: _getEnumForLanguageCode(language.languageCode),
                          groupValue: selectedLanguage,
                          onChanged: (SingingCharacter? value) {
                            setState(() {
                              selectedLanguage = value;
                            });
                          },
                          activeColor: textColor,
                          controlAffinity: ListTileControlAffinity.leading,
                          selected: selectedLanguage ==
                              _getEnumForLanguageCode(widget
                                  .initialLanguageCode ?? ''), 
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          SizedBox(
            height: 10,
          ),
          MainButton(
              title: 'Select',
              onPressed: () async {
                print('The initial language code is');
                print(widget.initialLanguageCode);
                if (selectedLanguage != null) {
                  Language selectedLang = Language.languageList().firstWhere(
                    (lang) {
                      FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).update({
                    'language':lang.languageCode,
                  });
                      return _getLanguageCodeForEnum(selectedLanguage!) ==
                          lang.languageCode;
                    },
                  );
                  

                  Locale _locale = await setLocale(selectedLang.languageCode);
                  MyApp.setLocale(context, _locale);
                  Navigator.pop(context);
                }
              }),
        ],
      ),
    );
  }

  String _getLanguageCodeForEnum(SingingCharacter character) {
    switch (character) {
      case SingingCharacter.english:
        return 'en';
      case SingingCharacter.hindi:
        return 'hi';
      case SingingCharacter.telugu:
        return 'te';
      case SingingCharacter.tamil:
        return 'ta';
      case SingingCharacter.malayalam:
        return 'ma';
      default:
        return 'en';
    }
  }
}
