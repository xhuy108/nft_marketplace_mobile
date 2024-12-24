import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nft_marketplace_mobile/presentation/event/widgets/drop_grid_item.dart';
import 'package:nft_marketplace_mobile/presentation/event/widgets/featured_drop_card.dart';

class CreateNFTScreen extends StatelessWidget {
  const CreateNFTScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create NFTs',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: const CreateNFTForm(),
    );
  }
}

class CreateNFTForm extends StatefulWidget {
  const CreateNFTForm({Key? key}) : super(key: key);

  @override
  State<CreateNFTForm> createState() => _CreateNFTFormState();
}

class _CreateNFTFormState extends State<CreateNFTForm> {
  final _formKey = GlobalKey<FormState>();
  XFile? _selectedMedia;

  Future<void> _pickMedia() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? media = await picker.pickImage(source: ImageSource.gallery);
      if (media != null) {
        setState(() {
          _selectedMedia = media;
        });
      }
    } catch (e) {
      debugPrint('Error picking media: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MediaDropZone(
              onTap: _pickMedia,
              selectedMedia: _selectedMedia,
            ),
            const SizedBox(height: 24),
            const CollectionSection(),
            const SizedBox(height: 24),
            NFTNameField(),
            const SizedBox(height: 24),
            NFTSupplyField(),
            const SizedBox(height: 24),
            NFTDescriptionField(),
          ],
        ),
      ),
    );
  }
}

class MediaDropZone extends StatelessWidget {
  final VoidCallback onTap;
  final XFile? selectedMedia;

  const MediaDropZone({
    Key? key,
    required this.onTap,
    this.selectedMedia,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 200,
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
              size: 40,
              color: Colors.grey.shade600,
            ),
            const SizedBox(height: 8),
            const Text(
              'Drop and drag media',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Max size: 50MB\nJPG, PNG, GIF, SVG, MP4',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CollectionSection extends StatelessWidget {
  const CollectionSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Collection',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: const [
              Icon(Icons.add, size: 24),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Not all collections are eligible',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}

class NFTNameField extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  NFTNameField({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Name',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _controller,
          decoration: const InputDecoration(
            hintText: 'Name your NFT',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}

class NFTSupplyField extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  NFTSupplyField({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Supply',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}

class NFTDescriptionField extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  NFTDescriptionField({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _controller,
          maxLines: 4,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}
