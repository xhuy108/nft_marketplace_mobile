class NFTCollection {
  final String id;
  final String name;
  final String imageUrl;
  final double floor;
  final double volume;
  final double changePercentage;
  final bool isVerified;
  final bool isWatchlisted;
  final String currency;

  NFTCollection({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.floor,
    required this.volume,
    required this.changePercentage,
    this.isVerified = false,
    this.isWatchlisted = false,
    this.currency = 'ETH',
  });
}

// lib/models/featured_nft.dart
class FeaturedNFT {
  final String id;
  final String title;
  final String imageUrl;
  final double floor;
  final bool isVerified;
  final String currency;
  final String backgroundColor;

  FeaturedNFT({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.floor,
    required this.isVerified,
    this.currency = 'ETH',
    required this.backgroundColor,
  });
}
