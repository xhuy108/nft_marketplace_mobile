import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:nft_marketplace_mobile/domain/entities/market_item.dart';
import 'package:nft_marketplace_mobile/domain/entities/nft_collection.dart';
import 'package:nft_marketplace_mobile/domain/entities/nft_item.dart';
import 'package:nft_marketplace_mobile/presentation/collection/bloc/collection_items_bloc/collection_items_bloc.dart';
import 'package:nft_marketplace_mobile/presentation/nft/pages/item_detail_screen.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

class CollectionDetailScreen extends StatefulWidget {
  final Collection collection;
  static const routeName = '/collection-detail';

  const CollectionDetailScreen({
    super.key,
    required this.collection,
  });

  @override
  State<CollectionDetailScreen> createState() => _CollectionDetailScreenState();
}

class _CollectionDetailScreenState extends State<CollectionDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['Items', 'Activity'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    // Load NFT items when screen initializes
    context.read<CollectionItemsBloc>().add(
          LoadCollectionItems(collectionAddress: widget.collection.address),
        );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: DefaultTabController(
        length: 2,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverToBoxAdapter(
              child: Stack(
                children: [
                  Column(
                    children: [
                      // Blue background section
                      Container(
                        color: Colors.blue,
                        height: 120,
                      ),

                      // White section content
                      Column(
                        children: [
                          const SizedBox(
                              height: 40), // Space for overlapped image
                          _buildCollectionHeader(),
                          _buildCollectionDetails(),
                          _buildCollectionStats(),
                          _buildTabBar(),
                        ],
                      ),
                    ],
                  ),
                  // Positioned image between blue and white sections
                  Positioned(
                    left: 16,
                    top: 40,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 0,
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: widget.collection.image != null
                            ? Image.network(
                                widget.collection.image!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.image),
                                  );
                                },
                              )
                            : Container(
                                color: Colors.grey[300],
                                child: const Icon(Icons.image),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          body: TabBarView(
            controller: _tabController,
            children: [
              // Items tab with BLoC integration
              BlocBuilder<CollectionItemsBloc, CollectionItemsState>(
                builder: (context, state) {
                  if (state is CollectionItemsLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is CollectionItemsError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(state.message),
                          ElevatedButton(
                            onPressed: () {
                              context.read<CollectionItemsBloc>().add(
                                    LoadCollectionItems(
                                      collectionAddress:
                                          widget.collection.address,
                                    ),
                                  );
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is CollectionItemsLoaded) {
                    if (state.items.isEmpty) {
                      return const Center(child: Text('No items found'));
                    }

                    return GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.8,
                      ),
                      itemBuilder: (context, index) =>
                          _buildItemCard(state.items[index]),
                      itemCount: state.items.length,
                    );
                  }

                  return const Center(child: Text('No items available'));
                },
              ),

              // Activity tab remains the same
              const Center(child: Text('Activity Content')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemCard(MarketItem item) {
    return GestureDetector(
      onTap: () {
        final nftItem = NFTItem.fromMarketItem(item, widget.collection.name);

        PersistentNavBarNavigator.pushNewScreen(
          context,
          screen: ItemDetailScreen(item: nftItem),
          withNavBar: true,
          pageTransitionAnimation: PageTransitionAnimation.cupertino,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: item.metadata?.imageUrl != null
                  ? Image.network(
                      item.metadata!.imageUrl,
                      width: double.infinity,
                      height: 160,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: double.infinity,
                          height: 160,
                          color: Colors.grey[300],
                          child: Icon(
                            Icons.image,
                            color: Colors.grey[400],
                            size: 50,
                          ),
                        );
                      },
                    )
                  : Container(
                      width: double.infinity,
                      height: 160,
                      color: Colors.grey[300],
                      child: Icon(
                        Icons.image,
                        color: Colors.grey[400],
                        size: 50,
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.metadata?.name ?? '#${item.tokenId}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      overflow: TextOverflow.ellipsis,
                    ),
                    maxLines: 1,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.isOnSale
                        ? '${item.formattedPrice} ETH'
                        : 'Not for sale',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
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

  // Keep your existing UI building methods
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.blue,
      elevation: 0,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.share, color: Colors.black),
          ),
          onPressed: () {},
        ),
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.more_horiz, color: Colors.black),
          ),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildCollectionHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                widget.collection.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // if (widget.collection.isVerified)
              if (true)
                const Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: Icon(Icons.verified, color: Colors.blue, size: 20),
                ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.star_border),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.black),
              children: [
                const TextSpan(text: 'By '),
                TextSpan(
                  text: widget.collection.owner,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const WidgetSpan(
                  child: Icon(Icons.verified, color: Colors.blue, size: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollectionDetails() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 4,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text.rich(
                TextSpan(
                  text: 'Items ',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                  children: [
                    TextSpan(
                      text: '40K',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const Text(' • ', style: TextStyle(color: Colors.black)),
              Text.rich(
                TextSpan(
                  text: 'Create ',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                  children: [
                    TextSpan(
                      text: 'Aug 2024',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const Text(' • ', style: TextStyle(color: Colors.black)),
              Text.rich(
                TextSpan(
                  text: 'Create Earnings ',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                  children: [
                    TextSpan(
                      text: '6%',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text.rich(
                TextSpan(
                  text: 'Chain ',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                  children: [
                    TextSpan(
                      text: 'Polygon',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
              children: [
                const TextSpan(text: 'A '),
                TextSpan(
                  text: 'courtyard',
                  style: const TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
                const TextSpan(
                  text:
                      ' is a common architectural feature found in many cultures, typically serving as a central open space surrounded by buildings or walls.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollectionStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      child: Column(
        children: [
          // First row with three evenly spaced columns
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 1,
                child: _buildStatItemColumn('1,59K ETH', 'total volume'),
              ),
              Expanded(
                flex: 1,
                child: _buildStatItemColumn('18 MATIC', 'floor price'),
              ),
              Expanded(
                flex: 1,
                child: _buildStatItemColumn('0,0023 ETH', 'best offer'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Second row with three evenly spaced columns
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 1,
                child: _buildStatItemColumn('1.93%', 'listed'),
              ),
              Expanded(
                flex: 1,
                child: _buildStatItemColumn('6,12', 'owners'),
              ),
              Expanded(
                flex: 1,
                child: _buildStatItemColumn('0,08%', 'unique owners'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItemColumn(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Material(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: Colors.blue,
        unselectedLabelColor: Colors.grey,
        indicatorColor: Colors.blue,
        indicatorSize: TabBarIndicatorSize.label,
        tabs: _tabs
            .map((tab) => Tab(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(tab),
                  ),
                ))
            .toList(),
      ),
    );
  }
}
