import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nft_marketplace_mobile/config/themes/app_palette.dart';
import 'package:nft_marketplace_mobile/domain/entities/nft_collection.dart';
import 'package:nft_marketplace_mobile/presentation/collection/pages/collection_detail_screen.dart';

import '../../collection/bloc/collection_bloc/collection_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum FilterType { time, chain, category }

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});
  static const routeName = '/';

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  final List<String> _tabs = ['Trending', 'Top', 'Owned', 'Watchlist'];
  int _selectedTabIndex = 0;
  String selectedTimeFilter = '24h';
  String selectedChainFilter = 'All chains';
  String selectedCategoryFilter = 'All categories';

  @override
  void initState() {
    super.initState();
    context.read<CollectionBloc>().add(LoadCollections());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              title: Row(
                mainAxisSize: MainAxisSize.min, // Make Row take minimum space
                children: [
                  CircleAvatar(
                    backgroundColor: AppPalette.primary,
                    radius: 15.r,
                    child: Icon(Icons.beach_access,
                        color: Colors.white, size: 20.r),
                  ),
                  const SizedBox(width: 8),
                  const Text('OpenBeach'),
                ],
              ),
              floating: true,
              centerTitle: true,
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
            ),

            // Featured Collections Cards
            SliverToBoxAdapter(
              child: SizedBox(
                height: 200,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildFeaturedCard(
                      'Memories of Digital',
                      '0.24 ETH',
                      'assets/images/memories.jpg',
                    ),
                    _buildFeaturedCard(
                      'Pixel - Farm Land',
                      '1 ETH',
                      'assets/images/memories.jpg',
                    ),
                  ],
                ),
              ),
            ),

            // Custom Tab Bar

            // Create a combined sticky header for all three elements
            // Sticky Section (Tab Bar + Filter Buttons)

            SliverPersistentHeader(
              pinned: true,
              delegate: _StickySectionDelegate(
                child: Container(
                  color: Colors.white,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tab Bar
                      Container(
                        padding: const EdgeInsets.only(
                            left: 16, top: 8), // Added top padding
                        height: 45,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: List.generate(
                              _tabs.length,
                              (index) => GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedTabIndex = index;
                                  });
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(right: 32),
                                  child: Text(
                                    _tabs[index],
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: _selectedTabIndex == index
                                          ? Colors.black
                                          : Colors.grey[600],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Filter Buttons
                      Container(
                        height: 52, // Adjusted height to match design
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              // Update your filter buttons calls
                              _buildFilterButton('24h', FilterType.time),
                              const SizedBox(width: 12),

                              _buildFilterButton(
                                  'All chains', FilterType.chain),
                              const SizedBox(width: 12),

                              _buildFilterButton(
                                  'All categories', FilterType.category),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
                child: Row(
                  children: [
                    const Text('#',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        )),
                    const SizedBox(width: 32),
                    const Text('Collection',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        )),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(right: 65),
                      child: Text(
                        'Volume',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Collection List
            BlocBuilder<CollectionBloc, CollectionState>(
              builder: (context, state) {
                if (state is CollectionLoading) {
                  return const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (state is CollectionError) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(state.message),
                          ElevatedButton(
                            onPressed: () {
                              context
                                  .read<CollectionBloc>()
                                  .add(LoadCollections());
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (state is CollectionLoaded) {
                  if (state.collections.isEmpty) {
                    return const SliverFillRemaining(
                      child: Center(child: Text('No collections found')),
                    );
                  }

                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildCollectionListItem(
                        state.collections[index],
                        index + 1,
                      ),
                      childCount: state.collections.length,
                    ),
                  );
                }

                return const SliverFillRemaining(
                  child: Center(child: Text('No collections available')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

// Add this class for the sticky header

  Widget _buildFeaturedCard(String title, String floor, String image) {
    return Container(
      width: 240,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(
          image: AssetImage(image),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            bottom: 16,
            left: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Floor: $floor',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String text, FilterType type) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              builder: (context) => _buildFilterBottomSheet(text, type),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  text,
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.keyboard_arrow_down,
                    size: 18, color: Colors.grey[700]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterBottomSheet(String title, FilterType type) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Only drag indicator
          Column(
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),

          // Sheet content
          Flexible(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: _buildFilterContent(type),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterContent(FilterType type) {
    switch (type) {
      case FilterType.time:
        final timeOptions = ['1h', '6h', '24h', '7d'];
        return Column(
          children: timeOptions
              .map((time) => _buildFilterOption(
                    text: time,
                    isSelected: selectedTimeFilter == time,
                    onTap: () {
                      setState(() {
                        selectedTimeFilter = time;
                      });
                      Navigator.pop(context);
                    },
                  ))
              .toList(),
        );

      case FilterType.chain:
        final chains = [
          {'name': 'All chains', 'icon': Icons.link},
          {'name': 'Arbitrum', 'icon': Icons.circle_outlined},
          {'name': 'Arbitrum Nova', 'icon': Icons.circle_outlined},
          {'name': 'Avalanche', 'icon': Icons.abc},
          {'name': 'B3', 'icon': Icons.link},
          {'name': 'Base', 'icon': Icons.circle_outlined},
          {'name': 'Blast', 'icon': Icons.link},
          {'name': 'Ethereum', 'icon': Icons.currency_bitcoin},
          {'name': 'Klaytn', 'icon': Icons.hexagon_outlined},
          {'name': 'Optimism', 'icon': Icons.circle_outlined},
          {'name': 'Polygon', 'icon': Icons.hexagon_outlined},
          {'name': 'Sei', 'icon': Icons.link},
          {'name': 'Solana', 'icon': Icons.compare_arrows},
          {'name': 'Zora', 'icon': Icons.circle},
        ];
        return Column(
          children: chains
              .map((chain) => _buildFilterOption(
                    text: chain['name']! as String,
                    icon: chain['icon'] as IconData,
                    isSelected: selectedChainFilter == chain['name'],
                    onTap: () {
                      setState(() {
                        selectedChainFilter = chain['name']! as String;
                      });
                      Navigator.pop(context);
                    },
                  ))
              .toList(),
        );

      case FilterType.category:
        final categories = [
          'All categories',
          'Art',
          'Gaming',
          'Memberships',
          'Music',
          'PFPs',
          'Photography'
        ];
        return Column(
          children: categories
              .map((category) => _buildFilterOption(
                    text: category,
                    isSelected: selectedCategoryFilter == category,
                    onTap: () {
                      setState(() {
                        selectedCategoryFilter = category;
                      });
                      Navigator.pop(context);
                    },
                  ))
              .toList(),
        );
    }
  }

  Widget _buildFilterOption({
    required String text,
    IconData? icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20, color: Colors.grey[700]),
              const SizedBox(width: 12),
            ],
            Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                color: isSelected ? Colors.black : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCollectionListItem(Collection collection, int rank) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                CollectionDetailScreen(collection: collection),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Rank number
            SizedBox(
              width: 32,
              child: Text(
                rank.toString(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            // Collection info
            Expanded(
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: collection.image != null
                        ? Image.network(
                            collection.image!,
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 48,
                                height: 48,
                                color: Colors.grey[300],
                                child: const Icon(Icons.image),
                              );
                            },
                          )
                        : Container(
                            width: 48,
                            height: 48,
                            color: Colors.grey[300],
                            child: const Icon(Icons.image),
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          collection.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Floor: ${collection.floor} ETH',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Volume and percentage (with fixed width)
            SizedBox(
              width: 100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${collection.volume} ETH',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${collection.changePercentage}%',
                    style: TextStyle(
                      color: collection.changePercentage >= 0
                          ? Colors.green
                          : Colors.red,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StickySectionDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _StickySectionDelegate({
    required this.child,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: child,
    );
  }

  @override
  double get maxExtent => 97.0; // Adjusted for new total height (45 + 52)

  @override
  double get minExtent => 97.0; // Same as maxExtent

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
