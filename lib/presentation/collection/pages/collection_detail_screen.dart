import 'package:flutter/material.dart';
import 'package:nft_marketplace_mobile/domain/entities/nft_collection.dart';
import 'package:nft_marketplace_mobile/presentation/nft_item/pages/item_detail_screen.dart';
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
                        child: Image.asset(
                          widget.collection.baseURI,
                          fit: BoxFit.cover,
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
              // Items tab
              GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.8,
                ),
                itemBuilder: (context, index) => _buildItemCard(),
                itemCount: 10,
              ),

              // Activity tab
              const Center(child: Text('Activity Content')),
            ],
          ),
        ),
      ),
    );
  }

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
                  text: 'Courtyard ',
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

  Widget _buildItemCard() {
    final item = NFTItem(
      name: 'Memories of Digital D...',
      image: 'assets/images/memories.jpg',
      price: '18 MATIC',
      collectionName: widget.collection.name,
    );

    return GestureDetector(
      onTap: () {
        PersistentNavBarNavigator.pushNewScreen(
          context,
          screen: ItemDetailScreen(item: item),
          withNavBar: true, // Keep bottom nav bar visible
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
              child: Image.asset(
                item.image,
                width: double.infinity,
                height: 160,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      overflow: TextOverflow.ellipsis,
                    ),
                    maxLines: 1,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.price,
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
}
