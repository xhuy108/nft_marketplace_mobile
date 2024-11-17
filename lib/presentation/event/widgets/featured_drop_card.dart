import 'package:flutter/material.dart';

class FeaturedDropCard extends StatelessWidget {
  const FeaturedDropCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFeaturedImage(),
            const SizedBox(height: 16),
            _buildDropInfo(),
            const SizedBox(height: 16),
            _buildMintingButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedImage() {
    return Stack(
      children: [
        Container(
          height: 300,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(12),
            ),
          ),
          child: Center(
            child: Image.asset(
              'assets/images/memories.jpg',
              width: 200,
              height: 200,
            ),
          ),
        ),
        Positioned(
          left: 16,
          top: 16,
          child: CircleAvatar(
            radius: 20,
            backgroundColor: Colors.white,
            child: Image.asset(
              'assets/icon.png',
              width: 24,
              height: 24,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Tigerbob: Elysian Garden',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.verified, color: Colors.blue[600], size: 20),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Text(
                'By tigerbobft',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.verified, color: Colors.blue[600], size: 16),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '216 items',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '0.08 ETH',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMintingButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[300],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          minimumSize: const Size(double.infinity, 44),
        ),
        child: const Text(
          'Minting Now',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
