import 'package:flutter/widgets.dart';


class FormPageContent {
  final String title;
  final Widget dataInputWidget;
  final bool isRequired;
  final String formId;

  const FormPageContent({
    required this.formId, 
    required this.title,
    required this.dataInputWidget,
    required this.isRequired,
  });
}