import 'package:bp/model/place/place_zip.dart';
import 'package:bp/presentation/styles/color_manager.dart';
import 'package:bp/presentation/styles/text_style_manager.dart';
import 'package:bp/presentation/view/profile/components/profile_image.dart';
import 'package:bp/presentation/view/share/share_view.dart';
import 'package:bp/presentation/widgets/space.dart';
import 'package:bp/provider/auth_provider.dart';
import 'package:bp/provider/dynamic_link.dart';
import 'package:bp/service/share_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PlacesZipTile extends StatelessWidget {
  const PlacesZipTile({super.key, required this.placeZip});

  final PlaceZip placeZip;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: ColorManager.grey01,
      child: ExpansionTile(
        backgroundColor: ColorManager.grey01,
        title: Row(
          children: [
            ProfileImage(url: placeZip.creatorProfileUrl, size: 50),
            const AddHorizontalSpace(8),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    placeZip.title ?? "${placeZip.creatorName ?? "익명"}의 장소 모음",
                    style: TextStyleManager.body5,
                  ),
                  const AddVerticalSpace(4),
                  Text(
                    placeZip.categories.map((e) => "#$e").join(" "),
                    style: TextStyleManager.body2
                        .copyWith(color: ColorManager.primary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            DateFormat(
                    'yyyy년 MM월 dd일에 "${placeZip.creatorName ?? "익명"}"님께서 공유했어요.')
                .format(placeZip.createdAt),
            style: TextStyleManager.body3,
          ),
        ),
        childrenPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AddHorizontalSpace(double.infinity),
              if (placeZip.description != null)
                Text(
                  placeZip.description!,
                  style: TextStyleManager.body3,
                  textAlign: TextAlign.start,
                ),
            ],
          ),
          FittedBox(
            child: Row(
              children: [
                TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (BuildContext context) {
                      return PlaceListInZipView(
                        placeZip: placeZip,
                      );
                    }));
                  },
                  icon: const Icon(Icons.open_in_new),
                  label: const Text("펼쳐보기"),
                ),
                TextButton.icon(
                  onPressed: () {
                    ShareService.copyToClipboard(placeZip.toPrettyString());
                  },
                  icon: const Icon(Icons.save_alt_rounded),
                  label: const Text("저장하기"),
                ),
                TextButton.icon(
                  onPressed: () async {
                    final name =
                        Provider.of<AppAuthProvider>(context, listen: false)
                            .user
                            ?.name;
                    final link =
                        await Provider.of<DynamicLink>(context, listen: false)
                            .getShortLink('shared-place-zip', placeZip.id);
                    ShareService.sharePlaceZip(
                        shareName: name ?? "발품 사용자", link: link);
                  },
                  icon: const Icon(Icons.ios_share),
                  label: const Text("공유하기"),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
