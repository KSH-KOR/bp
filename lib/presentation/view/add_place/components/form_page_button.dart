
import 'package:flutter/material.dart';

class FormPageButton extends StatelessWidget {
  const FormPageButton({super.key, required this.controller});

  final PageController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.page == null) return const SizedBox.shrink();
    final page = controller.page!.toInt();
    return SizedBox(
      height: 60,
      width: double.infinity,
      child: Row(
        children: [
          if (page > 0)
            Expanded(
              flex: 1,
              child: InkWell(
                onTap: () {
                  controller.nextPage(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut);
                },
                child: Container(
                  color: Theme.of(context).disabledColor,
                  child: const Align(
                    alignment: Alignment.center,
                    child: Text(
                      "이전",
                      style: TextStyle(fontSize: 24, color: Colors.white70),
                    ),
                  ),
                ),
              ),
            ),
          Expanded(
            flex: 4,
            child: InkWell(
              onTap: () async {
                controller.nextPage(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut);
              },
              child: Container(
                color: Theme.of(context).primaryColor,
                child: const Align(
                  alignment: Alignment.center,
                  child: Text(
                    "다음",
                    style: TextStyle(fontSize: 24, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
