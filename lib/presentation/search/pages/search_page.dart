import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get_it/get_it.dart';
import 'package:nft_marketplace_mobile/core/constants/app_constants.dart';
import 'package:nft_marketplace_mobile/domain/entities/nft_collection.dart';
import 'package:nft_marketplace_mobile/domain/repositories/collection_repository.dart';
import 'package:nft_marketplace_mobile/presentation/collection/pages/collection_detail_screen.dart';
import 'package:nft_marketplace_mobile/presentation/search/bloc/search_collection_bloc.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;
  String _selectedCategory = 'All categories';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      final searchTerm = _searchController.text.trim();
      if (searchTerm.isNotEmpty) {
        context.read<SearchCollectionBloc>().add(
              SearchCollections(
                searchTerm: searchTerm,
                category: _selectedCategory == 'All categories'
                    ? null
                    : _selectedCategory,
              ),
            );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Bar
                  Container(
                    height: 48.h,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: TextStyle(color: Colors.black, fontSize: 16.sp),
                      decoration: InputDecoration(
                        hintText: "Search collections",
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon:
                                    Icon(Icons.clear, color: Colors.grey[500]),
                                onPressed: () {
                                  _searchController.clear();
                                  context
                                      .read<SearchCollectionBloc>()
                                      .add(ClearSearch());
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 12.h,
                        ),
                      ),
                    ),
                  ),
                  Gap(16.h),

                  // Category Filter
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: AppConstants.nftCategories.map((category) {
                        final isSelected = _selectedCategory == category;
                        return Padding(
                          padding: EdgeInsets.only(right: 8.w),
                          child: FilterChip(
                            label: Text(category),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                _selectedCategory = category;
                              });
                              if (_searchController.text.isNotEmpty) {
                                _onSearchChanged();
                              }
                            },
                            backgroundColor: Colors.grey[100],
                            selectedColor: Colors.blue.shade100,
                            checkmarkColor: Colors.blue,
                            labelStyle: TextStyle(
                              color:
                                  isSelected ? Colors.blue : Colors.grey[800],
                              fontSize: 14.sp,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

            // Search Results
            Expanded(
              child: BlocBuilder<SearchCollectionBloc, SearchCollectionState>(
                builder: (context, state) {
                  if (state is SearchCollectionLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is SearchCollectionError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline,
                              size: 48.sp, color: Colors.red),
                          Gap(8.h),
                          Text(
                            state.message,
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 16.sp,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is SearchCollectionSuccess) {
                    if (state.collections.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 48.sp,
                              color: Colors.grey[400],
                            ),
                            Gap(8.h),
                            Text(
                              'No collections found',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16.sp,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: EdgeInsets.all(16.w),
                      itemCount: state.collections.length,
                      itemBuilder: (context, index) {
                        final collection = state.collections[index];
                        return CollectionListItem(
                          collection: collection,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CollectionDetailScreen(
                                  collection: collection,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  }

                  // Initial state or when search is cleared
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search,
                          size: 48.sp,
                          color: Colors.grey[400],
                        ),
                        Gap(8.h),
                        Text(
                          'Search for collections',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16.sp,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Collection List Item Widget
class CollectionListItem extends StatelessWidget {
  final Collection collection;
  final VoidCallback onTap;

  const CollectionListItem({
    super.key,
    required this.collection,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[200]!),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            // Collection Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: collection.image != null
                  ? Image.network(
                      collection.image!,
                      width: 64.w,
                      height: 64.w,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 64.w,
                        height: 64.w,
                        color: Colors.grey[200],
                        child: Icon(Icons.image, color: Colors.grey[400]),
                      ),
                    )
                  : Container(
                      width: 64.w,
                      height: 64.w,
                      color: Colors.grey[200],
                      child: Icon(Icons.image, color: Colors.grey[400]),
                    ),
            ),
            Gap(12.w),

            // Collection Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    collection.name,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Gap(4.h),
                  Text(
                    'Floor: ${collection.floor} ETH',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                  Gap(4.h),
                  Row(
                    children: [
                      Icon(
                        Icons.grid_view,
                        size: 14.sp,
                        color: Colors.grey[600],
                      ),
                      Gap(4.w),
                      Text(
                        '${collection.totalSupply} items',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                      Gap(12.w),
                      Icon(
                        Icons.category,
                        size: 14.sp,
                        color: Colors.grey[600],
                      ),
                      Gap(4.w),
                      Text(
                        collection.category,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Arrow icon
            Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
              size: 24.sp,
            ),
          ],
        ),
      ),
    );
  }
}
