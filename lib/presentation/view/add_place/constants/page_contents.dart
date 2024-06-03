import 'package:bp/presentation/view/add_place/pages/chip_selection_form.dart';
import 'package:bp/presentation/view/add_place/pages/file_pick_form.dart';
import 'package:bp/presentation/view/add_place/pages/search_place.dart';

import '../models/form_page_content.dart';

const List<FormPageContent> pageContents = [
  FormPageContent(
    dataInputWidget: SearchPlacePage(
      formId: 'search-place',
      formTitle: '장소검색',
    ),
    isRequired: true,
    title: "장소 검색",
    formId: 'search-place',
  ),
  FormPageContent(
    dataInputWidget: ChipSelectionForm(
      options: ["사장님이 친절해요", "가성비가 좋아요", "청결해요", "배달이 빨라요", "건강한 맛이에요"],
      formId: 'chip-selection-place',
      formTitle: '장소 리뷰',
    ),
    isRequired: true,
    title: "장소 리뷰",
    formId: 'chip-selection-place',
  ),
  FormPageContent(
    dataInputWidget: FilePickForm(),
    isRequired: true,
    title: "장소 사진들을 선택해주세요",
    formId: 'photo-place',
  ),
];
