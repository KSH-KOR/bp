import 'package:bp/presentation/styles/color_manager.dart';
import 'package:bp/presentation/styles/text_style_manager.dart';
import 'package:bp/provider/form_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChipSelectionForm extends StatelessWidget {
  const ChipSelectionForm(
      {super.key,
      required this.options,
      required this.formId,
      required this.formTitle});

  final List<String> options;
  final String formId;
  final String formTitle;

  void _onTap(BuildContext context, int index) {
    final provider = Provider.of<FormProvider>(context, listen: false);
    try {
      final model = provider.getModelById(formId);
      if (model.value is! List) throw Exception();
      if ((model.value as List).contains(options[index])) {
        (model.value as List).remove(options[index]);
      } else {
        (model.value as List).add(options[index]);
      }
      if (model.value.isEmpty) {
        provider.removeModelById(formId);
      } else {
        provider.setFormData(model);
      }
    } catch (_) {
      provider.setFormData(FormDataModel(
        id: formId,
        displayTitle: formTitle,
        value: [options[index]],
      ));
    }
  }

  bool isSelected(BuildContext context, int index) {
    try {
      final model = Provider.of<FormProvider>(context).getModelById(formId);
      return model.value.contains(options[index]);
    } catch (_) {}
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          Expanded(
            child: ListView.separated(
              itemCount: options.length,
              itemBuilder: (BuildContext context, int index) {
                return SelectableChip(
                  isSelcted: isSelected(context, index),
                  onTap: () => _onTap(context, index),
                  title: options[index],
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return const SizedBox(
                  height: 8,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SelectableChip extends StatelessWidget {
  const SelectableChip(
      {super.key,
      required this.title,
      required this.onTap,
      required this.isSelcted});

  final String title;
  final void Function() onTap;
  final bool isSelcted;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
          backgroundColor: isSelcted ? ColorManager.primary : null),
      onPressed: onTap,
      child: SizedBox(
        width: double.infinity,
        child: Text(
          title,
          style: TextStyleManager.body6
              .copyWith(color: isSelcted ? ColorManager.white : null),
        ),
      ),
    );
  }
}
