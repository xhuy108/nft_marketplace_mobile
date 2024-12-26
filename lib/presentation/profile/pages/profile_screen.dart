// lib/presentation/profile/pages/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:nft_marketplace_mobile/domain/entities/market_item.dart';
import 'package:nft_marketplace_mobile/domain/entities/nft_collection.dart';
import 'package:nft_marketplace_mobile/domain/entities/nft_item.dart';
import 'package:nft_marketplace_mobile/presentation/collection/pages/collection_detail_screen.dart';
import 'package:nft_marketplace_mobile/presentation/nft/pages/item_detail_screen.dart';
import 'package:nft_marketplace_mobile/presentation/profile/bloc/profile_bloc.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:web3dart/web3dart.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final _privateKeyController = TextEditingController();
  bool _isObscured = true;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<ProfileBloc>().add(LoadProfile());
  }

  void _showLoginDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          'Connect Wallet',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Form(
          key: _formKey,
          child: TextFormField(
            controller: _privateKeyController,
            obscureText: _isObscured,
            decoration: InputDecoration(
              hintText: 'Enter private key (0x...)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _isObscured ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () => setState(() => _isObscured = !_isObscured),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your private key';
              }
              if (!value.startsWith('0x')) {
                return 'Private key must start with 0x';
              }
              if (value.length != 66) {
                return 'Invalid private key length';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey[700]),
            ),
          ),
          BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              return ElevatedButton(
                onPressed: state is ProfileLoading
                    ? null
                    : () {
                        if (_formKey.currentState?.validate() ?? false) {
                          context.read<ProfileBloc>().add(
                                ConnectWallet(
                                  privateKey: _privateKeyController.text,
                                ),
                              );
                          Navigator.pop(context);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: state is ProfileLoading
                    ? SizedBox(
                        width: 20.w,
                        height: 20.h,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Connect',
                        style: TextStyle(color: Colors.white),
                      ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showProfileMenu(ProfileLoaded state) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              margin: EdgeInsets.only(bottom: 16.h),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Copy Address'),
              onTap: () {
                context
                    .read<ProfileBloc>()
                    .add(CopyWalletAddress(state.walletAddress));
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Disconnect Wallet'),
              onTap: () {
                context.read<ProfileBloc>().add(DisconnectWallet());
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Profile',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              if (state is ProfileLoaded)
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () => _showProfileMenu(state),
                ),
            ],
          ),
          body: RefreshIndicator(
            key: _refreshIndicatorKey,
            onRefresh: () async {
              context.read<ProfileBloc>().add(RefreshProfile());
              return Future<void>.delayed(const Duration(seconds: 1));
            },
            child: state is ProfileLoaded
                ? _buildProfileView(state)
                : state is ProfileLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildLoginView(),
          ),
        );
      },
    );
  }

  Widget _buildLoginView() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 64.sp,
            color: Colors.grey[400],
          ),
          Gap(24.h),
          Text(
            'Connect your wallet to view your\nNFTs and collections',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          Gap(24.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _showLoginDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                'Connect Wallet',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileView(ProfileLoaded state) {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        SliverToBoxAdapter(
          child: Column(
            children: [
              // Profile Header with Balance Card
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  children: [
                    // Balance Card
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(top: 16.h),
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.blue.shade600,
                            Colors.blue.shade800,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(24.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Wallet Address
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(8.w),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Icon(
                                  Icons.account_balance_wallet,
                                  color: Colors.white,
                                  size: 20.sp,
                                ),
                              ),
                              Gap(12.w),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Wallet Address',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        '${state.walletAddress.substring(0, 6)}...${state.walletAddress.substring(state.walletAddress.length - 4)}',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.copy,
                                          size: 16.sp,
                                          color: Colors.white.withOpacity(0.8),
                                        ),
                                        onPressed: () {
                                          context.read<ProfileBloc>().add(
                                              CopyWalletAddress(
                                                  state.walletAddress));
                                          ;
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Gap(20.h),
                          // Balance
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Balance',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 14.sp,
                                ),
                              ),
                              Gap(4.h),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    state.balance.toStringAsFixed(4),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 32.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Gap(8.w),
                                  Padding(
                                    padding: EdgeInsets.only(bottom: 4.h),
                                    child: Text(
                                      'ETH',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    Gap(24.h),

                    // Stats Cards Row
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Collected',
                            state.stats.collected.toString(),
                            'NFTs',
                            Icons.grid_view_rounded,
                          ),
                        ),
                        Gap(12.w),
                        Expanded(
                          child: _buildStatCard(
                            'Created',
                            state.stats.created.toString(),
                            'Collections',
                            Icons.collections,
                          ),
                        ),
                      ],
                    ),
                    Gap(12.h),
                    _buildValueStatCard(
                      'Portfolio Value',
                      state.stats.totalValue.toStringAsFixed(2),
                      'ETH',
                      Icons.pie_chart,
                    ),
                    Gap(24.h),
                  ],
                ),
              ),

              // Tab Bar with modern styling
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey.shade200,
                      width: 1,
                    ),
                  ),
                ),
                child: TabBar(
                  controller: _tabController,
                  labelStyle: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  labelColor: Colors.blue.shade600,
                  unselectedLabelColor: Colors.grey.shade600,
                  indicatorColor: Colors.blue.shade600,
                  indicatorWeight: 3,
                  tabs: [
                    Tab(text: 'Collected (${state.collectedNfts.length})'),
                    Tab(text: 'Created (${state.createdCollections.length})'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCollectedNFTsGrid(state.collectedNfts),
          _buildCreatedCollectionsGrid(state.createdCollections),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, String unit, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              icon,
              color: Colors.blue.shade600,
              size: 20.sp,
            ),
          ),
          Gap(12.h),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14.sp,
            ),
          ),
          Gap(4.h),
          Row(
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Gap(4.w),
              Text(
                unit,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildValueStatCard(
      String label, String value, String unit, IconData icon) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              icon,
              color: Colors.blue.shade600,
              size: 20.sp,
            ),
          ),
          Gap(16.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14.sp,
                ),
              ),
              Gap(4.h),
              Row(
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Gap(4.w),
                  Text(
                    unit,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCollectedNFTsGrid(List<MarketItem> nfts) {
    if (nfts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported,
              size: 48.sp,
              color: Colors.grey[400],
            ),
            Gap(8.h),
            Text(
              'No NFTs collected yet',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.all(16.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.w,
        mainAxisSpacing: 16.h,
        childAspectRatio: 0.8,
      ),
      itemCount: nfts.length,
      itemBuilder: (context, index) {
        final nft = nfts[index];

        return GestureDetector(
          onTap: () {
            if (nft.metadata != null) {
              final nftItem = NFTItem.fromMarketItem(nft,
                  "Collection Name"); // You might want to fetch collection name
              PersistentNavBarNavigator.pushNewScreen(
                context,
                screen: ItemDetailScreen(item: nftItem),
                withNavBar: true,
              );
            }
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(12.r),
                  ),
                  child: Image.network(
                    nft.metadata?.imageUrl ?? '',
                    height: 150.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 150.h,
                        color: Colors.grey[200],
                        child: Icon(
                          Icons.image,
                          color: Colors.grey[400],
                          size: 32.sp,
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nft.metadata?.name ?? '#${nft.tokenId}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Gap(4.h),
                      Text(
                        nft.formattedPrice,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCreatedCollectionsGrid(List<Collection> collections) {
    if (collections.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.collections_outlined,
              size: 48.sp,
              color: Colors.grey[400],
            ),
            Gap(8.h),
            Text(
              'No collections created yet',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.all(16.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.w,
        mainAxisSpacing: 16.h,
        childAspectRatio: 0.7,
      ),
      itemCount: collections.length,
      itemBuilder: (context, index) {
        final collection = collections[index];

        return GestureDetector(
          onTap: () {
            PersistentNavBarNavigator.pushNewScreen(
              context,
              screen: CollectionDetailScreen(collection: collection),
              withNavBar: true,
            );
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(12.r),
                  ),
                  child: collection.image != null
                      ? Image.network(
                          collection.image!,
                          height: 150.h,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 150.h,
                              color: Colors.grey[200],
                              child: Icon(
                                Icons.image,
                                color: Colors.grey[400],
                                size: 32.sp,
                              ),
                            );
                          },
                        )
                      : Container(
                          height: 150.h,
                          color: Colors.grey[200],
                          child: Icon(
                            Icons.image,
                            color: Colors.grey[400],
                            size: 32.sp,
                          ),
                        ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        collection.name,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
                            "${collection.totalSupply} items",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                      Gap(4.h),
                      Row(
                        children: [
                          Icon(
                            Icons.local_offer,
                            size: 14.sp,
                            color: Colors.grey[600],
                          ),
                          Gap(4.w),
                          Text(
                            "Floor: ${collection.floor} ETH",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _privateKeyController.dispose();
    super.dispose();
  }
}
