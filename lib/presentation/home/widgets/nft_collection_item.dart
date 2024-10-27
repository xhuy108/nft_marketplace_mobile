import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:nft_marketplace_mobile/domain/entities/nft_collection.dart';

class NFTCollectionItem extends StatelessWidget {
  final NFTCollection collection;
  final int rank;
  final VoidCallback? onTap;
  final VoidCallback? onWatchlistTap;

  const NFTCollectionItem({
    super.key,
    required this.collection,
    required this.rank,
    this.onTap,
    this.onWatchlistTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(bottom: 16.h),
        child: Row(
          children: [
            SizedBox(
              width: 24.w,
              child: Text(
                rank.toString(),
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Gap(8.w),
            CircleAvatar(
              radius: 20.r,
              backgroundImage: AssetImage(collection.imageUrl),
            ),
            Gap(8.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        collection.name,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (collection.isVerified) ...[
                        Gap(4.w),
                        Icon(Icons.verified, color: Colors.blue, size: 16.r),
                      ],
                    ],
                  ),
                  Text(
                    'Floor: ${collection.floor} ${collection.currency}',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${collection.volume} ${collection.currency}',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${collection.changePercentage.toStringAsFixed(2)}%',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: collection.changePercentage >= 0
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
              ],
            ),
            Gap(8.w),
            IconButton(
              onPressed: onWatchlistTap,
              icon: Icon(
                collection.isWatchlisted ? Icons.star : Icons.star_border,
                size: 24.r,
                color: collection.isWatchlisted ? Colors.amber : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
