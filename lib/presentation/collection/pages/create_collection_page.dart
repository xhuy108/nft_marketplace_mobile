import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nft_marketplace_mobile/core/services/wallet_service.dart';
import 'dart:io';

import 'package:nft_marketplace_mobile/domain/entities/category.dart';
import 'package:nft_marketplace_mobile/presentation/collection/bloc/collection_bloc/collection_bloc.dart';
import 'package:nft_marketplace_mobile/presentation/collection/bloc/create_collection_bloc/create_collection_bloc.dart';
import 'package:nft_marketplace_mobile/presentation/nft/pages/create_nft_screen.dart';
import 'package:nft_marketplace_mobile/presentation/profile/bloc/profile_bloc.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

class CreateCollectionPage extends StatefulWidget {
  const CreateCollectionPage({super.key});

  static const routeName = '/create-collection';

  @override
  State<CreateCollectionPage> createState() => _CreateCollectionPageState();
}

class _CreateCollectionPageState extends State<CreateCollectionPage> {
  File? _imageFile;
  String? _selectedCategory;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _symbolController = TextEditingController();

  final List<Category> _categories = [
    Category(name: 'Art', icon: Icons.palette),
    Category(name: 'Gaming', icon: Icons.sports_esports),
    Category(name: 'Memberships', icon: Icons.card_membership),
    Category(name: 'Music', icon: Icons.music_note),
    Category(name: 'PFPs', icon: Icons.face),
    Category(name: 'Photography', icon: Icons.camera_alt),
  ];

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

  void _handleSubmit() {
    if (_formKey.currentState!.validate() && _selectedCategory != null) {
      if (_imageFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a collection image'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      try {
        final walletService = GetIt.I<WalletService>();

        context.read<CreateCollectionBloc>().add(
              CreateCollectionSubmitted(
                name: _nameController.text,
                symbol: _symbolController.text,
                category: _selectedCategory!,
                imageFile: _imageFile!,
                credentials: walletService.credentials,
              ),
            );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please connect your wallet first'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a category'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _navigateBack() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      // If can't pop, navigate to CreateNFTScreen
      PersistentNavBarNavigator.pushNewScreen(
        context,
        screen: const CreateNFTScreen(),
        withNavBar: true,
        pageTransitionAnimation: PageTransitionAnimation.cupertino,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Create collection',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<CreateCollectionBloc, CreateCollectionState>(
        listener: (context, state) {
          if (state is CreateCollectionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'Collection created successfully at ${state.collection.address}'),
                backgroundColor: Colors.green,
              ),
            );

            context.read<CollectionBloc>().add(LoadCollections());
            context.read<ProfileBloc>().add(LoadProfile());

            _navigateBack();
          } else if (state is CreateCollectionFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is CreateCollectionLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  Gap(16.h),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(20.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "First, you'll need to create a for your NFT",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Gap(8.h),
                  Text(
                    "You'll need to deploy an ERC-1155 contract on the blockchain to creates a collection for your NFT.",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16.sp,
                    ),
                  ),
                  Gap(32.h),
                  Text(
                    'Collection',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Gap(16.h),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: double.infinity,
                      height: 120.h,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey.shade300,
                          style: BorderStyle.solid,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: _imageFile != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12.r),
                              child: Image.file(
                                _imageFile!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.upload_file,
                                  size: 32.sp,
                                  color: Colors.grey,
                                ),
                                Gap(8.h),
                                Text(
                                  'Drop and Drag media',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16.sp,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  Gap(32.h),
                  Text(
                    'Contract name',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Gap(16.h),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: 'retro goth',
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 16.h,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: Colors.grey.shade200,
                          width: 1,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: Colors.grey.shade200,
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: const BorderSide(
                          color: Colors.blue,
                          width: 2,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a contract name';
                      }
                      return null;
                    },
                  ),
                  Gap(32.h),
                  Text(
                    'Token symbol',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Gap(16.h),
                  TextFormField(
                    controller: _symbolController,
                    decoration: InputDecoration(
                      hintText: 'RG',
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 16.h,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: Colors.grey.shade200,
                          width: 1,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: Colors.grey.shade200,
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: const BorderSide(
                          color: Colors.blue,
                          width: 2,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a token symbol';
                      }
                      return null;
                    },
                  ),
                  Gap(32.h),
                  Text(
                    'Category',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Gap(16.h),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16.w,
                      mainAxisSpacing: 16.h,
                      childAspectRatio: 1.8,
                    ),
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final isSelected = _selectedCategory == category.name;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCategory = category.name;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color:
                                isSelected ? Colors.blue.shade50 : Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.blue
                                  : Colors.grey.shade200,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          padding: EdgeInsets.all(16.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                category.icon,
                                color: isSelected
                                    ? Colors.blue
                                    : Colors.grey.shade700,
                                size: 24.sp,
                              ),
                              Gap(8.h),
                              Text(
                                category.name,
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      isSelected ? Colors.blue : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar:
          BlocBuilder<CreateCollectionBloc, CreateCollectionState>(
        builder: (context, state) {
          return SafeArea(
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: ElevatedButton(
                onPressed:
                    state is CreateCollectionLoading ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  state is CreateCollectionLoading
                      ? 'Creating Collection...'
                      : 'Create Collection',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
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
    _symbolController.dispose();
    super.dispose();
  }
}
