import 'package:flutter/material.dart';

import '../models/form_page_content.dart';

class FormPageLayout extends StatelessWidget {
  const FormPageLayout({super.key, required this.formPageContent});

  final FormPageContent formPageContent;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            formPageContent.title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        formPageContent.dataInputWidget,
      ],
    );
  }
}
