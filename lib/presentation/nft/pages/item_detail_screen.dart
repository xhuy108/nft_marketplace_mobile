import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get_it/get_it.dart';
import 'package:nft_marketplace_mobile/core/services/wallet_service.dart';
import 'package:nft_marketplace_mobile/domain/entities/market_item.dart';
import 'package:nft_marketplace_mobile/domain/entities/nft_item.dart';
import 'package:nft_marketplace_mobile/presentation/collection/bloc/collection_bloc/collection_bloc.dart';
import 'package:nft_marketplace_mobile/presentation/nft/bloc/create_market_item_bloc.dart';
import 'package:nft_marketplace_mobile/presentation/profile/bloc/profile_bloc.dart';
import 'package:web3dart/web3dart.dart';

class ItemDetailScreen extends StatefulWidget {
  final NFTItem item;
  static const routeName = '/item-detail';

  const ItemDetailScreen({
    super.key,
    required this.item,
  });

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['Details', 'Offers', 'Listings', 'Item Activity'];
  late NFTItem _currentItem;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _currentItem = widget.item;
  }

  void _updateNFTStatus(String newOwner) {
    final walletService = GetIt.I<WalletService>();
    setState(() {
      _currentItem = _currentItem.copyWith(
        owner: newOwner,
        isOnSale: false,
      );
    });

    // Update Profile Screen data
    context.read<ProfileBloc>().add(RefreshProfile());

    // Update Collection Screen data if needed
    context.read<CollectionBloc>().add(LoadCollections());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildItemInfo(),
                _buildStats(),
                _buildPriceSection(),
                _buildCreatorSection(),
                _buildTabBar(),
                const SizedBox(height: 100), // Space for bottom button
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildPurchaseButton(),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 360.h,
      pinned: true,
      backgroundColor: Colors.white,
      leading:
          _buildCircularButton(Icons.arrow_back, () => Navigator.pop(context)),
      actions: [
        _buildCircularButton(Icons.share, () {}),
        _buildCircularButton(Icons.more_horiz, () {}),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Image.network(
          widget.item.image,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: Colors.grey[200],
            child: Icon(Icons.image, size: 50.sp, color: Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget _buildCircularButton(IconData icon, VoidCallback onPressed) {
    return IconButton(
      icon: Container(
        padding: EdgeInsets.all(8.w),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.black, size: 20.sp),
      ),
      onPressed: onPressed,
    );
  }

  Widget _buildItemInfo() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                _currentItem.name,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Gap(4.w),
              const Icon(Icons.verified, color: Colors.blue, size: 20),
            ],
          ),
          Gap(8.h),
          Text(
            widget.item.collectionName,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          Gap(16.h),
          if (widget.item.description != null)
            Text(
              widget.item.description!,
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey[700],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem(Icons.favorite_border, '0', 'favorites'),
          _buildStatItem(Icons.people_outline, '0', 'owners'),
          _buildStatItem(Icons.grid_4x4, '0', 'editions'),
          _buildStatItem(Icons.visibility_outlined, '0', 'views'),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 20.sp, color: Colors.grey[800]),
        Gap(8.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 13.sp,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      padding: EdgeInsets.all(16.w),
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.item.isOnSale ? 'Current Price' : 'Not for Sale',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14.sp,
            ),
          ),
          Gap(8.h),
          if (widget.item.isOnSale) ...[
            Text(
              widget.item.formattedPrice,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            // Add estimated USD price here if available
          ],
        ],
      ),
    );
  }

  Widget _buildCreatorSection() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: Container(
                  width: 40.w,
                  height: 40.w,
                  color: Colors.grey[200],
                  child: Icon(Icons.person, size: 24.sp),
                ),
              ),
              Gap(12.w),
              Text(
                'Seller: ',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14.sp,
                ),
              ),
              Expanded(
                child: Text(
                  widget.item.seller,
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        Gap(16.h),
        Divider(height: 1, color: Colors.grey[200]),
      ],
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      labelColor: Colors.blue,
      unselectedLabelColor: Colors.grey,
      indicatorColor: Colors.blue,
      isScrollable: true,
      tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
    );
  }

  Widget _buildPurchaseButton() {
    final walletService = GetIt.I<WalletService>();
    final walletAddress = walletService.addressHex.toLowerCase();
    final isOwner = walletService.isConnected &&
        (_currentItem.seller.toLowerCase() == walletAddress ||
            _currentItem.owner.toLowerCase() == walletAddress);

    if (isOwner) {
      return SafeArea(
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _currentItem.owner.toLowerCase() == walletAddress
                      ? Icons.account_balance_wallet
                      : Icons.store,
                  size: 20.sp,
                  color: Colors.grey[600],
                ),
                Gap(8.w),
                Text(
                  _currentItem.owner.toLowerCase() == walletAddress
                      ? 'You own this NFT'
                      : 'You are selling this NFT',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return BlocConsumer<CreateMarketItemBloc, CreateMarketItemState>(
      listener: (context, state) {
        if (state is PurchaseMarketItemSuccess) {
          // Update local state immediately
          _updateNFTStatus(walletService.addressHex);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('NFT purchased successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is PurchaseMarketItemFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Purchase failed: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        return SafeArea(
          child: Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed:
                  state is PurchaseMarketItemLoading || !_currentItem.isOnSale
                      ? null
                      : () => _handlePurchase(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 0,
                disabledBackgroundColor: Colors.grey[300],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (state is PurchaseMarketItemLoading)
                    SizedBox(
                      width: 20.sp,
                      height: 20.sp,
                      child: const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 2,
                      ),
                    )
                  else
                    Icon(Icons.shopping_cart, size: 20.sp),
                  Gap(8.w),
                  Text(
                    state is PurchaseMarketItemLoading
                        ? 'Processing...'
                        : _currentItem.isOnSale
                            ? 'Purchase Now'
                            : 'Not for Sale',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _handlePurchase(BuildContext context) {
    if (!GetIt.I<WalletService>().isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please connect your wallet first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Purchase'),
        content: Text(
            'Do you want to purchase this NFT for ${widget.item.formattedPrice}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              final walletService = GetIt.I<WalletService>();

              context.read<CreateMarketItemBloc>().add(
                    PurchaseMarketItem(
                      collectionAddress: widget.item.collectionAddress,
                      tokenId: BigInt.parse(widget.item.tokenId),
                      price: widget.item.price,
                      credentials: walletService.credentials,
                    ),
                  );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
