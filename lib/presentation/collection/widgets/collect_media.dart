import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CollectionMediaUpload extends StatelessWidget {
  const CollectionMediaUpload({Key? key}) : super(key: key);

  Future<void> _pickMedia(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    try {
      await picker.pickImage(source: ImageSource.gallery);
    } catch (e) {
      debugPrint('Error picking media: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _pickMedia(context),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey.shade300,
            style: BorderStyle.solid,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.upload_outlined,
              size: 32,
              color: Colors.grey.shade600,
            ),
            const SizedBox(height: 8),
            Text(
              'Drop and Drag media',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BlockchainOptionCard extends StatelessWidget {
  final Widget icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const BlockchainOptionCard({
    Key? key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            icon,
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
