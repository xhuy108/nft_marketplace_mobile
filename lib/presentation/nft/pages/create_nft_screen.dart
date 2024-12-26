import 'dart:math' show pow;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nft_marketplace_mobile/core/services/wallet_service.dart';
import 'package:nft_marketplace_mobile/core/services/wallet_storage_service.dart';
import 'package:nft_marketplace_mobile/domain/entities/nft_collection.dart';
import 'package:nft_marketplace_mobile/presentation/collection/bloc/collection_bloc/collection_bloc.dart';
import 'package:nft_marketplace_mobile/presentation/collection/bloc/user_collection_bloc/user_collection_bloc.dart';
import 'package:nft_marketplace_mobile/presentation/collection/pages/create_collection_page.dart';
import 'package:nft_marketplace_mobile/presentation/login/pages/wallet_login_form.dart';
import 'package:nft_marketplace_mobile/presentation/nft/bloc/create_market_item_bloc.dart';
import 'package:nft_marketplace_mobile/presentation/profile/bloc/profile_bloc.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:web3dart/web3dart.dart';
import 'dart:io';

class CreateNFTScreen extends StatefulWidget {
  const CreateNFTScreen({super.key});

  static const routeName = '/create-nft';

  @override
  State<CreateNFTScreen> createState() => _CreateNFTScreenState();
}

class _CreateNFTScreenState extends State<CreateNFTScreen> {
  File? _imageFile;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  Collection? _selectedCollection;
  bool _isCollectionExpanded = false;
  bool _isWalletConnected = false;
  final _walletStorageService = GetIt.I<WalletStorageService>();
  final _walletService = GetIt.I<WalletService>();

  // bool get _isWalletConnected => GetIt.I<WalletService>().isConnected;

  @override
  void initState() {
    super.initState();
    _isWalletConnected = GetIt.I<WalletService>().isConnected;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileState = context.read<ProfileBloc>().state;
      if (profileState is ProfileLoaded) {
        setState(() {
          _isWalletConnected = true;
        });
        _checkWalletAndLoadData();
      }
      _initializeWallet();
    });
    // _loadUserCollections();
  }

  Future<void> _initializeWallet() async {
    try {
      final storedKey = _walletStorageService.getPrivateKey();
      if (storedKey != null) {
        await _walletService.connectWithPrivateKey(storedKey);
        setState(() {
          _isWalletConnected = true;
        });
        _checkWalletAndLoadData();
      }
    } catch (e) {
      debugPrint('Error initializing wallet: $e');
      setState(() {
        _isWalletConnected = false;
      });
    }
  }

  void _checkWalletAndLoadData() {
    if (_isWalletConnected) {
      context.read<UserCollectionBloc>().add(LoadUserCollections());
    }
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
        content: BlocProvider.value(
          value: context.read<ProfileBloc>(),
          child: BlocListener<ProfileBloc, ProfileState>(
            listener: (context, state) {
              if (state is ProfileLoaded) {
                setState(() {
                  _isWalletConnected = true;
                });
                Navigator.pop(context);
                _checkWalletAndLoadData();
              } else if (state is ProfileError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
            },
            child: WalletLoginForm(),
          ),
        ),
      ),
    );
  }

  // void _loadUserCollections() {
  //   final walletService = GetIt.I<WalletService>();
  //   if (walletService.isConnected) {
  //     context.read<CollectionBloc>().add(LoadUserCollections());
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text('Please connect your wallet first'),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //   }
  // }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        setState(() {
          _imageFile = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to pick image'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _clearForm() {
    setState(() {
      _imageFile = null;
      _nameController.clear();
      _descriptionController.clear();
      _priceController.clear();
      _selectedCollection = null;
      _isCollectionExpanded = false;
    });
  }

  void _navigateToCreateCollection() {
    PersistentNavBarNavigator.pushNewScreen(
      context,
      screen: const CreateCollectionPage(),
      withNavBar: true,
      pageTransitionAnimation: PageTransitionAnimation.cupertino,
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      if (_imageFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select an image'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (_selectedCollection == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a collection'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      try {
        final walletService = GetIt.I<WalletService>();
        // Convert price to Wei using proper conversion
        final priceInEther = double.parse(_priceController.text);
        final priceInWei = BigInt.from(priceInEther * pow(10, 18));

        context.read<CreateMarketItemBloc>().add(
              CreateMarketItemSubmitted(
                name: _nameController.text,
                description: _descriptionController.text,
                collection: _selectedCollection!,
                imageFile: _imageFile!,
                price: priceInWei,
                credentials: walletService.credentials,
              ),
            );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
            'Connect your wallet to create NFTs',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Create NFTs',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: !_isWalletConnected
          ? _buildLoginView()
          : MultiBlocListener(
              listeners: [
                BlocListener<CreateMarketItemBloc, CreateMarketItemState>(
                  listener: (context, state) {
                    if (state is CreateMarketItemSuccess) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('NFT created successfully!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      // Navigator.pop(context);
                      _clearForm();
                    } else if (state is CreateMarketItemFailure) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.message),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                ),
                BlocListener<ProfileBloc, ProfileState>(
                  listener: (context, state) {
                    if (state is ProfileLoaded) {
                      setState(() {
                        _isWalletConnected = true;
                      });
                      _checkWalletAndLoadData();
                    } else if (state is ProfileDisconnected) {
                      setState(() {
                        _isWalletConnected = false;
                      });
                    }
                  },
                ),
              ],
              child: BlocBuilder<CreateMarketItemBloc, CreateMarketItemState>(
                builder: (context, marketItemState) {
                  if (marketItemState is CreateMarketItemLoading) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(),
                          Gap(16.h),
                          Text(
                            marketItemState.message,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Image Upload Section
                            GestureDetector(
                              onTap: _pickImage,
                              child: Container(
                                width: double.infinity,
                                height: 200.h,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: _imageFile != null
                                    ? ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(12.r),
                                        child: Image.file(
                                          _imageFile!,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.upload_file,
                                            size: 32.sp,
                                            color: Colors.grey,
                                          ),
                                          Gap(8.h),
                                          Text(
                                            'Drop and drag media',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 16.sp,
                                            ),
                                          ),
                                          Gap(4.h),
                                          Text(
                                            'Max size: 50MB',
                                            style: TextStyle(
                                              color: Colors.grey[400],
                                              fontSize: 14.sp,
                                            ),
                                          ),
                                          Gap(4.h),
                                          Text(
                                            'JPG, PNG, GIF, SVG, MP4',
                                            style: TextStyle(
                                              color: Colors.grey[400],
                                              fontSize: 14.sp,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),

                            Gap(24.h),

                            // Collection Section
                            Text(
                              'Collection',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Gap(8.h),

                            BlocBuilder<UserCollectionBloc, CollectionState>(
                              builder: (context, state) {
                                if (state is CollectionLoading) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }

                                if (state is CollectionError) {
                                  return Center(
                                    child: Text(state.message),
                                  );
                                }

                                if (state is UserCollectionsLoaded) {
                                  if (state.collections.isEmpty) {
                                    return InkWell(
                                      onTap: _navigateToCreateCollection,
                                      child: Container(
                                        width: double.infinity,
                                        padding: EdgeInsets.all(16.w),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          borderRadius:
                                              BorderRadius.circular(12.r),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(Icons.add, size: 24.sp),
                                            Gap(8.w),
                                            Text(
                                              'Create new collection',
                                              style: TextStyle(
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }

                                  return Column(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            _isCollectionExpanded =
                                                !_isCollectionExpanded;
                                          });
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(16.w),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.grey[300]!),
                                            borderRadius:
                                                BorderRadius.circular(12.r),
                                          ),
                                          child: Row(
                                            children: [
                                              if (_selectedCollection?.image !=
                                                  null)
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(25),
                                                  child: Image.network(
                                                    _selectedCollection!.image!,
                                                    width: 32.w,
                                                    height: 32.w,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              Gap(8.w),
                                              Text(
                                                _selectedCollection?.name ??
                                                    'Choose a collection',
                                                style: TextStyle(
                                                  fontSize: 16.sp,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const Spacer(),
                                              Icon(
                                                _isCollectionExpanded
                                                    ? Icons.expand_less
                                                    : Icons.expand_more,
                                                color: Colors.grey[600],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      if (_isCollectionExpanded)
                                        Container(
                                          margin: EdgeInsets.only(top: 4.h),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.grey[300]!),
                                            borderRadius:
                                                BorderRadius.circular(12.r),
                                          ),
                                          child: Column(
                                            children: [
                                              ...state.collections
                                                  .map((collection) {
                                                return ListTile(
                                                  leading: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            25),
                                                    child: collection.image !=
                                                            null
                                                        ? Image.network(
                                                            collection.image!,
                                                            width: 40.w,
                                                            height: 40.w,
                                                            fit: BoxFit.cover,
                                                          )
                                                        : Container(
                                                            width: 40.w,
                                                            height: 40.w,
                                                            color: Colors
                                                                .grey[200],
                                                            child: Icon(
                                                              Icons.image,
                                                              color: Colors
                                                                  .grey[400],
                                                            ),
                                                          ),
                                                  ),
                                                  title: Text(collection.name),
                                                  subtitle:
                                                      Text(collection.symbol),
                                                  trailing: _selectedCollection
                                                              ?.address ==
                                                          collection.address
                                                      ? Icon(Icons.check_circle,
                                                          color: Colors.blue,
                                                          size: 20.sp)
                                                      : null,
                                                  onTap: () {
                                                    setState(() {
                                                      _selectedCollection =
                                                          collection;
                                                      _isCollectionExpanded =
                                                          false;
                                                    });
                                                  },
                                                );
                                              }),
                                              const Divider(height: 1),
                                              ListTile(
                                                leading: CircleAvatar(
                                                  backgroundColor:
                                                      Colors.grey[200],
                                                  child: Icon(Icons.add,
                                                      color: Colors.grey[600]),
                                                ),
                                                title: const Text(
                                                    'Create a new collection'),
                                                onTap:
                                                    _navigateToCreateCollection,
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  );
                                }

                                return const SizedBox.shrink();
                              },
                            ),
                            // _buildCollectionSection(),

                            Gap(24.h),

                            // Name Field
                            Text(
                              'Name',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Gap(8.h),
                            TextFormField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                hintText: 'Name your NFT',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                  borderSide:
                                      BorderSide(color: Colors.grey[300]!),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                  borderSide:
                                      BorderSide(color: Colors.grey[300]!),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a name';
                                }
                                return null;
                              },
                            ),

                            Gap(24.h),

                            // Price Field
                            Text(
                              'Price (ETH)',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Gap(8.h),
                            TextFormField(
                              controller: _priceController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              decoration: InputDecoration(
                                hintText: '0.01',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                  borderSide:
                                      BorderSide(color: Colors.grey[300]!),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                  borderSide:
                                      BorderSide(color: Colors.grey[300]!),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a price';
                                }
                                try {
                                  final price = double.parse(value);
                                  if (price <= 0) {
                                    return 'Price must be greater than 0';
                                  }
                                } catch (e) {
                                  return 'Please enter a valid number';
                                }
                                return null;
                              },
                            ),

                            Gap(24.h),

                            // Description Field
                            Text(
                              'Description',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Gap(8.h),
                            TextFormField(
                              controller: _descriptionController,
                              maxLines: 4,
                              decoration: InputDecoration(
                                hintText:
                                    'Provide a detailed description of your NFT',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                  borderSide:
                                      BorderSide(color: Colors.grey[300]!),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                  borderSide:
                                      BorderSide(color: Colors.grey[300]!),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a description';
                                }
                                return null;
                              },
                            ),

                            Gap(32.h),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
      bottomNavigationBar: !_isWalletConnected
          ? null
          : BlocBuilder<CreateMarketItemBloc, CreateMarketItemState>(
              builder: (context, state) {
                return SafeArea(
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: ElevatedButton(
                      onPressed: state is CreateMarketItemLoading
                          ? null
                          : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        state is CreateMarketItemLoading
                            ? 'Creating NFT...'
                            : 'Create NFT',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}
