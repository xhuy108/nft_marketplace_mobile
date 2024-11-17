import 'package:flutter/material.dart';
import 'package:nft_marketplace_mobile/config/themes/app_palette.dart';

class CollectionItem {
  final String name;
  final String image;
  final String smallImage;
  final bool isVerified;

  CollectionItem({
    required this.name,
    required this.image,
    required this.smallImage,
    required this.isVerified,
  });
}

class CollectionCard extends StatelessWidget {
  final CollectionItem collection;

  const CollectionCard({
    super.key,
    required this.collection,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: const Color(0xFFffffff),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Color(0xFFE4E4E4),
              offset: Offset(4, 4),
              blurRadius: 20,
            )
          ]),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main Image
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(collection.image),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          // Bottom Info Section
          Container(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Small Image
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: AssetImage(collection.smallImage),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Collection Name and Verified Badge
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          collection.name,
                          style: const TextStyle(
                            color: AppPalette.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (collection.isVerified) ...[
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.verified,
                          color: Colors.blue,
                          size: 16,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
