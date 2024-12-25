import 'package:flutter/material.dart';
import 'package:nft_marketplace_mobile/config/themes/app_palette.dart';
import 'package:nft_marketplace_mobile/presentation/search/widgets/collection_card.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final List<CollectionItem> trendingCollections = [
    CollectionItem(
      name: "Apu Apustajas",
      image: "assets/images/memories.jpg",
      smallImage: "assets/images/memories.jpg",
      isVerified: false,
    ),
    CollectionItem(
      name: "Apu Apustajas",
      image: "assets/images/memories.jpg",
      smallImage: "assets/images/memories.jpg",
      isVerified: false,
    ),
    CollectionItem(
      name: "Apu Apustajas",
      image: "assets/images/memories.jpg",
      smallImage: "assets/images/memories.jpg",
      isVerified: false,
    ),
    CollectionItem(
      name: "Apu Apustajas",
      image: "assets/images/memories.jpg",
      smallImage: "assets/images/memories.jpg",
      isVerified: false,
    ),
    CollectionItem(
      name: "Apu Apustajas",
      image: "assets/images/memories.jpg",
      smallImage: "assets/images/memories.jpg",
      isVerified: false,
    ),
    CollectionItem(
      name: "Apu Apustajas",
      image: "assets/images/memories.jpg",
      smallImage: "assets/images/memories.jpg",
      isVerified: false,
    ),
    CollectionItem(
      name: "Apu Apustajas",
      image: "assets/images/memories.jpg",
      smallImage: "assets/images/memories.jpg",
      isVerified: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Search Bar
              Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    hintText: "Search OpenSea",
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Trending Collections Title
              const Text(
                "Trending Collections",
                style: TextStyle(
                  color: AppPalette.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 16),
              // Collection Grid
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1,
                  ),
                  itemCount: trendingCollections.length,
                  itemBuilder: (context, index) {
                    return CollectionCard(
                        collection: trendingCollections[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
