import 'package:bp/presentation/styles/color_manager.dart';
import 'package:bp/presentation/styles/text_style_manager.dart';
import 'package:bp/presentation/widgets/rounded_corner_container.dart';
import 'package:bp/presentation/widgets/space.dart';
import 'package:bp/provider/place_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchTextField extends StatefulWidget {
  const SearchTextField({super.key});

  @override
  State<SearchTextField> createState() => _SearchTextFieldState();
}

class _SearchTextFieldState extends State<SearchTextField> {
  late final TextEditingController controller;
  PlaceProvider? provider;
  late final FocusNode focusNode;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
    focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.addListener(() {
        provider!.setSearchKeyword(controller.text);
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    provider!.setSearchKeyword(null, shouldNotify: false);
    focusNode.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    provider = Provider.of<PlaceProvider>(context, listen: false);
    return TextField(
      autofocus: false,
      focusNode: focusNode,
      controller: controller,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.zero,
        filled: true,
        fillColor: ColorManager.grey03,
        border: const OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.all(
            Radius.circular(12),
          ),
        ),
        hintText: "검색어",
        hintMaxLines: 1,
        hintStyle: TextStyleManager.body5.copyWith(color: ColorManager.grey09),
        prefixIcon: const Icon(
          Icons.search,
          color: ColorManager.grey09,
        ),
        counterText: "",
        suffix:
            Provider.of<PlaceProvider>(context, listen: true).hasSearchKeyword
                ? IconButton(
                    onPressed: () {
                      controller.clear();
                      Provider.of<PlaceProvider>(context, listen: false)
                          .clearKeywordFilters(shouldNotify: true);
                    },
                    icon: const Icon(Icons.close),
                  )
                : null,
      ),
    );
  }
}

class CategoryChipHorizontalListView extends StatelessWidget {
  const CategoryChipHorizontalListView(
      {super.key, this.categories, this.enableFilter = true});

  final List<String>? categories;
  final bool enableFilter;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PlaceProvider>(context);
    final sc = provider.selectedCategory;

    final categories = this.categories ?? provider.categories;

    if (categories == null || categories.isEmpty) {
      return const SizedBox.shrink();
    }

    bool isSelected(String category) {
      return sc?.contains(category) == true;
    }

    return SizedBox(
      height: 36,
      child: Row(
        children: [
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (BuildContext context, int index) {
                return InkWell(
                  onTap: enableFilter
                      ? () {
                          Provider.of<PlaceProvider>(context, listen: false)
                              .setCategory(categories.elementAt(index));
                        }
                      : null,
                  child: RoundedCornerContainer(
                    color: enableFilter
                        ? (isSelected(categories.elementAt(index))
                            ? ColorManager.primary
                            : null)
                        : null,
                    boxRadius: 8,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Center(
                        child: Text(
                          categories.elementAt(index),
                          style: TextStyleManager.body3.copyWith(
                              color: enableFilter
                                  ? (isSelected(categories.elementAt(index))
                                      ? ColorManager.white
                                      : ColorManager.black)
                                  : ColorManager.black),
                        ),
                      ),
                    ),
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return const AddHorizontalSpace(4);
              },
            ),
          ),
          if (enableFilter && provider.hasCategoryFilter)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: InkWell(
                onTap: () {
                  Provider.of<PlaceProvider>(context, listen: false)
                      .clearCatrgoryFilters(shouldNotify: true);
                },
                child: const RoundedCornerContainer(
                  boxRadius: 8,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14),
                    child: Center(child: Icon(Icons.close)),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class CategoryChipPannel extends StatefulWidget {
  const CategoryChipPannel(
      {super.key, this.categories, this.enableFilter = true});

  final List<String>? categories;
  final bool enableFilter;

  @override
  State<CategoryChipPannel> createState() => _CategoryChipPannelState();
}

class _CategoryChipPannelState extends State<CategoryChipPannel> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PlaceProvider>(context);
    final sc = provider.selectedCategory;

    final categories = widget.categories ?? provider.categories;

    if (categories == null || categories.isEmpty) {
      return const SizedBox.shrink();
    }

    bool isSelected(String category) {
      return sc?.contains(category) == true;
    }

    return RoundedCornerContainer(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  expanded = !expanded;
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Text(
                      "태그로 필터링해보세요!",
                      style: TextStyleManager.body3,
                    ),
                    const Spacer(),
                    Icon(expanded ? Icons.expand_less : Icons.expand_more),
                    Text(expanded ? "줄이기" : "펼치기")
                  ],
                ),
              ),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: expanded ? 200 : 50),
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: List.generate(
                    categories.length,
                    (index) => InkWell(
                      onTap: widget.enableFilter
                          ? () {
                              Provider.of<PlaceProvider>(context, listen: false)
                                  .setCategory(categories.elementAt(index));
                            }
                          : null,
                      child: RoundedCornerContainer(
                        color: widget.enableFilter
                            ? (isSelected(categories.elementAt(index))
                                ? ColorManager.primary
                                : null)
                            : null,
                        boxRadius: 8,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          child: Text(
                            categories.elementAt(index),
                            style: TextStyleManager.body3.copyWith(
                                color: widget.enableFilter
                                    ? (isSelected(categories.elementAt(index))
                                        ? ColorManager.white
                                        : ColorManager.black)
                                    : ColorManager.black),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
