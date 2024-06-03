import 'package:bp/constant/routes/routes.dart';
import 'package:bp/provider/form_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'layouts/form_layout.dart';
import 'models/form_page_content.dart';

class FormPageView extends StatefulWidget {
  const FormPageView({super.key});

  @override
  State<FormPageView> createState() => _FormPageViewState();
}

class _FormPageViewState extends State<FormPageView> {
  late final PageController controller;
  Iterable<FormPageContent>? pages;
  String? errMsg;
  bool didFetch = false;
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    controller = PageController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final arg = ModalRoute.of(context)!.settings.arguments;
      if (arg is! Iterable<FormPageContent>) {
        errMsg = "잘못된 접근입니다.";
      } else {
        pages = arg;
      }
      if (mounted) {
        setState(() {
          didFetch = true;
        });
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  bool _isCurrentFormSatisfied(String formId) {
    if (formId == "photo-place") return true;
    try {
      final formModel = Provider.of<FormProvider>(context).getModelById(formId);
      return formModel.value != null;
    } catch (_) {}
    return false;
  }

  @override
  Widget build(BuildContext context) {
    if (!didFetch) {
      return const Scaffold(
        body: Column(children: [Spacer(), LinearProgressIndicator()]),
      );
    }
    if (errMsg != null || pages == null) {
      return Scaffold(
        body: Center(
          child: Text(errMsg ?? "알 수 없는 오류가 발생했습니다."),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: controller,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: pages!.length,
                itemBuilder: (BuildContext context, int index) {
                  return FormPageLayout(
                      formPageContent: pages!.elementAt(index));
                },
                onPageChanged: (int index) {
                  setState(() {
                    currentPage = index; // 현재 페이지 인덱스 업데이트
                  });
                },
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: FilledButton(
                    onPressed: currentPage > 0
                        ? () {
                            controller.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut);
                          }
                        : null,
                    child: const Text("이전"),
                  ),
                ),
                const SizedBox(
                  width: 8,
                ),
                Expanded(
                  flex: 3,
                  child: FilledButton(
                    onPressed: _nextButton(),
                    child: const Text("다음"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Function()? _nextButton() {
    if (pages!.elementAt(currentPage).isRequired) {
      if (!_isCurrentFormSatisfied(pages!.elementAt(currentPage).formId)) {
        return null;
      }
    }
    return () => _handleNextButtonAction();
  }

  void _handleNextButtonAction() {
    if (currentPage == pages!.length - 1) {
      Navigator.of(context).pushNamed(formSummaryRoute);
    } else {
      controller.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }
}
