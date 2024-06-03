import 'package:flutter/material.dart';

class ColorManager {
  static const Color primary = Color.fromARGB(255, 159, 91, 244);
  static const Color black = Color.fromARGB(255, 0, 0, 0);
  static const Color navy = Color.fromARGB(255, 47, 51, 86);
  static const Color black1 = Color.fromARGB(255, 80, 85, 92);
  static const Color grey09 = Color.fromARGB(255, 151, 151, 151);
  static const Color grey = Color.fromARGB(252, 185, 186, 195);
  static const Color grey04 = Color.fromARGB(255, 214, 214, 224);
  static const Color grey03 = Color.fromARGB(255, 229, 229, 238);
  static const Color grey02 = Color.fromARGB(255, 242, 242, 247);
  static const Color grey01 = Color.fromARGB(255, 248, 248, 250);
  static const Color white = Color.fromARGB(255, 255, 255, 255);
  static const Color red = Color.fromARGB(255, 234, 34, 34);

  static Color red01 = HexColor.fromHex("#FDE2E2");
  static Color red02 = HexColor.fromHex("#FFF7F7");
  static Color grey05 = HexColor.fromHex("#D6D6E0");
  static Color green01 = HexColor.fromHex("#E1F4E1");
  static Color green02 = HexColor.fromHex("#F4FDF4");
  static Color green = HexColor.fromHex("#119216");

  static Color darkBlueColor = HexColor.fromHex("#3A57E8");
  static Color shadowColor = HexColor.fromHex("#000000");

  static Color secondary = HexColor.fromHex("#9BA5B7");

  static const Color widgetBackgroundColor = Color(0x66E5E9F4);
  static Color widgetTextColor = HexColor.fromHex("#979797");

  static Color userChatColor = HexColor.fromHex("#F6F0FF");
  static Color botChatColor = HexColor.fromHex("#FFFFFF");

  static Color buttonDefaultColor = HexColor.fromHex("#E5E9F4");

  static Color chatBackgroundColor = HexColor.fromHex("#FAFBFD");
  static Color dividerGreyColor = HexColor.fromHex("#8A92A6");

  static Color botCardColorMedia = HexColor.fromHex("#FFF9F9");
  static Color botCardColorHistorical = HexColor.fromHex("#FFFBEC");
  static Color botCardColorPersonal = HexColor.fromHex("#EEF7FE");

  static Color cupertinoDialogOkColor = HexColor.fromHex("#2A67DE");
  static Color cupertinoDialogCancelColor = HexColor.fromHex("#DD3737");

  static Color error = HexColor.fromHex("#DD3737");
  static Color point = HexColor.fromHex("#EA6F29");

  static Color textFieldbackgroundColor = HexColor.fromHex("#FFFFFF");

  static Color buttonDisable = HexColor.fromHex("#F4B794");

  static Color chatBG = HexColor.fromHex("#FAF7FF");
  static Color chatTime = HexColor.fromHex("#BAB9C3");
  static Color chatDate = HexColor.fromHex("#50555C");
  static Color iconColor = HexColor.fromHex("2F3356");
  static Color thumnailError = HexColor.fromHex("D6D6E0");
}

extension HexColor on Color {
  static Color fromHex(String hexColorString) {
    hexColorString = hexColorString.replaceAll('#', '');
    if (hexColorString.length == 6) {
      hexColorString = "FF$hexColorString"; // 8 char with opacity 100%
    }
    return Color(int.parse(hexColorString, radix: 16));
  }
}
