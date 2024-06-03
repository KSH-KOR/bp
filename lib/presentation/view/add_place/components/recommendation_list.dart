
import 'package:flutter/material.dart';

class RecommendationList extends StatelessWidget {
  const RecommendationList({
    super.key,
    required this.list,
    required this.onTap,
  });

  final Iterable<String> list;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: list.length,
      itemBuilder: (BuildContext context, int j) {
        return InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Text(
              list.elementAt(j),
              style: const TextStyle(color: Colors.black45),
            ),
          ),
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return const Divider();
      },
    );
  }
}
