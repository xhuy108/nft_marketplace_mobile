import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:nft_marketplace_mobile/config/themes/app_palette.dart';
import 'package:nft_marketplace_mobile/domain/entities/mock_data_service.dart';
import 'package:nft_marketplace_mobile/domain/entities/nft_collection.dart';
import 'package:nft_marketplace_mobile/presentation/home/widgets/featured_nft_card.dart';
import 'package:nft_marketplace_mobile/presentation/home/widgets/filter_chip.dart';
import 'package:nft_marketplace_mobile/presentation/home/widgets/nft_collection_item.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final tabs = ['Trending', 'Top', 'Owned', 'Watchlist'];
  int selectedTab = 0;
  final scrollController = ScrollController();

  // Updated state variables to store selected options
  FilterOption? selectedTimeFrameOption;
  FilterOption? selectedChainOption;
  FilterOption? selectedCategoryOption;

  List<FeaturedNFT> featuredNFTs = [];
  List<NFTCollection> collections = [];

  // Filter options
  // Updated filter options definitions
  final List<FilterOption> timeFrameOptions = [
    FilterOption(label: '1h', value: '1h'),
    FilterOption(label: '6h', value: '6h'),
    FilterOption(label: '24h', value: '24h'),
    FilterOption(label: '7d', value: '7d'),
  ];

  final List<FilterOption> chainOptions = [
    FilterOption(label: 'All chains', value: 'all'),
    FilterOption(label: 'Ethereum', value: 'eth', icon: Icons.currency_bitcoin),
    FilterOption(label: 'Polygon', value: 'poly', icon: Icons.hexagon),
    FilterOption(label: 'Solana', value: 'sol', icon: Icons.abc),
  ];

  final List<FilterOption> categoryOptions = [
    FilterOption(label: 'All categories', value: 'all'),
    FilterOption(label: 'Art', value: 'art'),
    FilterOption(label: 'Gaming', value: 'gaming'),
    FilterOption(label: 'Music', value: 'music'),
    FilterOption(label: 'Photography', value: 'photo'),
  ];

  @override
  void initState() {
    super.initState();
    selectedTimeFrameOption = timeFrameOptions.first;
    selectedChainOption = chainOptions.first;
    selectedCategoryOption = categoryOptions.first;

    _loadData();
  }

  void _loadData() {
    setState(() {
      featuredNFTs = MockDataService.getFeaturedNFTs();
      collections = MockDataService.getTrendingCollections();
    });
  }

  void _onTabSelected(int index) {
    setState(() {
      selectedTab = index;
    });
    // Here you would typically load different data based on selected tab
  }

  void _onWatchlistTap(NFTCollection collection) {
    setState(() {
      final index = collections.indexOf(collection);
      collections[index] = NFTCollection(
        id: collection.id,
        name: collection.name,
        imageUrl: collection.imageUrl,
        floor: collection.floor,
        volume: collection.volume,
        changePercentage: collection.changePercentage,
        isVerified: collection.isVerified,
        isWatchlisted: !collection.isWatchlisted,
        currency: collection.currency,
      );
    });
  }

  void _showFilterBottomSheet(
    BuildContext context,
    List<FilterOption> options,
    FilterOption? selectedOption,
    Function(FilterOption) onOptionSelected,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: true,
      builder: (context) => FilterBottomSheet(
        options: options,
        selectedValue: selectedOption?.value ?? '',
        onOptionSelected: onOptionSelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            // App Header
            SliverToBoxAdapter(
              child: _buildHeader(),
            ),

            // Featured NFTs
            SliverToBoxAdapter(
              child: _buildFeaturedNFTs(),
            ),

            // Sticky Header
            SliverOverlapAbsorber(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              sliver: SliverSafeArea(
                top: false,
                sliver: SliverPersistentHeader(
                  delegate: _StickyHeaderDelegate(
                    child: _buildStickyHeader(context),
                  ),
                  pinned: true,
                ),
              ),
            ),
          ],
          body: Builder(
            builder: (context) {
              return CustomScrollView(
                slivers: [
                  SliverOverlapInjector(
                    handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                        context),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final collection = collections[index];
                          return NFTCollectionItem(
                            collection: collection,
                            rank: index + 1,
                            onTap: () =>
                                print('Tapped on collection: ${collection.id}'),
                            onWatchlistTap: () => _onWatchlistTap(collection),
                          );
                        },
                        childCount: collections.length,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedNFTs() {
    return SizedBox(
      height: 180.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: featuredNFTs.length,
        separatorBuilder: (context, index) => Gap(12.w),
        itemBuilder: (context, index) {
          return FeaturedNFTCard(
            nft: featuredNFTs[index],
            onTap: () {
              // Navigate to NFT details
              print('Tapped on featured NFT: ${featuredNFTs[index].id}');
            },
          );
        },
      ),
    );
  }

  Widget _buildStickyHeader(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTabBar(),
          _buildFilters(),
          _buildListHeader(),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      height: 50.h,
      padding: EdgeInsets.only(left: 16.w),
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          final isSelected = entry.key == selectedTab;
          return GestureDetector(
            onTap: () => _onTabSelected(entry.key),
            child: Padding(
              padding: EdgeInsets.only(right: 24.w),
              child: Text(
                entry.value,
                style: TextStyle(
                  fontSize: 19.sp,
                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
                  color: isSelected ? AppPalette.textPrimary : Colors.grey,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      height: 40.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          CustomFilterChip(
            label: selectedTimeFrameOption?.label ?? '24h',
            isSelected: true,
            onTap: () {
              _showFilterBottomSheet(
                context,
                timeFrameOptions,
                selectedTimeFrameOption,
                (option) {
                  setState(() {
                    selectedTimeFrameOption = option;
                  });
                },
              );
            },
          ),
          Gap(8.w),
          CustomFilterChip(
            label: selectedChainOption?.label ?? 'All chains',
            icon: selectedChainOption?.icon,
            onTap: () {
              _showFilterBottomSheet(
                context,
                chainOptions,
                selectedChainOption,
                (option) {
                  setState(() {
                    selectedChainOption = option;
                  });
                },
              );
            },
          ),
          Gap(8.w),
          CustomFilterChip(
            label: selectedCategoryOption?.label ?? 'All categories',
            onTap: () {
              _showFilterBottomSheet(
                context,
                categoryOptions,
                selectedCategoryOption,
                (option) {
                  setState(() {
                    selectedCategoryOption = option;
                  });
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildListHeader() {
    return Container(
      height: 40.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          Text(
            '#',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14.sp,
            ),
          ),
          Gap(16.w),
          Text(
            'Collection',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14.sp,
            ),
          ),
          const Spacer(),
          Text(
            'Volume',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: AppPalette.primary,
            radius: 15.r,
            child: Icon(Icons.beach_access, color: Colors.white, size: 20.r),
          ),
          Gap(8.w),
          Text(
            'OpenBeach',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w900,
              color: AppPalette.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNFTList() {
    return ListView.builder(
      itemCount: collections.length,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      itemBuilder: (context, index) {
        final collection = collections[index];
        return NFTCollectionItem(
          collection: collection,
          rank: index + 1,
          onTap: () {
            // Navigate to collection details
            print('Tapped on collection: ${collection.id}');
          },
          onWatchlistTap: () => _onWatchlistTap(collection),
        );
      },
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavBarItem(Icons.home, 0),
          _buildNavBarItem(Icons.search, 1),
          _buildNavBarItem(Icons.calendar_today, 2),
          _buildNavBarItem(Icons.person_outline, 3),
        ],
      ),
    );
  }

  Widget _buildNavBarItem(IconData icon, int index) {
    final isSelected = index == 0; // Assuming we're on home page
    return IconButton(
      onPressed: () {
        // Handle navigation
        print('Navigate to index: $index');
      },
      icon: Icon(
        icon,
        size: 24.r,
        color: isSelected ? Colors.blue : Colors.grey,
      ),
    );
  }
}

class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _StickyHeaderDelegate({
    required this.child,
  });

  @override
  double get minExtent => 130.h; // Adjust this value based on your needs

  @override
  double get maxExtent =>
      130.h; // Should be the same as minExtent for a fixed height

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(_StickyHeaderDelegate oldDelegate) {
    return child != oldDelegate.child;
  }
}
