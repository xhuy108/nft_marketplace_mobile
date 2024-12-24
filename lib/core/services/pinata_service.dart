import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PinataService {
  static const String _apiUrl = 'https://api.pinata.cloud';
  final String _apiKey;
  final String _apiSecret;

  PinataService({
    String? apiKey,
    String? apiSecret,
  })  : _apiKey = apiKey ?? dotenv.env['PINATA_API_KEY'] ?? '',
        _apiSecret = apiSecret ?? dotenv.env['PINATA_API_SECRET'] ?? '';

  Future<String> uploadImage(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final uri = Uri.parse('$_apiUrl/pinning/pinFileToIPFS');

      var request = http.MultipartRequest('POST', uri);

      // Add headers
      request.headers.addAll({
        'pinata_api_key': _apiKey,
        'pinata_secret_api_key': _apiSecret,
      });

      // Add file
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: 'collection_image.png',
        ),
      );

      // Add metadata
      request.fields['pinataMetadata'] = json.encode({
        'name': 'NFTCollection_${DateTime.now().millisecondsSinceEpoch}',
      });

      request.fields['pinataOptions'] = json.encode({
        'cidVersion': 1,
      });

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final jsonResponse = json.decode(responseData);

      if (response.statusCode == 200) {
        return 'ipfs://${jsonResponse['IpfsHash']}';
      } else {
        throw Exception('Failed to upload to IPFS: ${jsonResponse['error']}');
      }
    } catch (e) {
      throw Exception('Failed to upload to IPFS: $e');
    }
  }

  Future<String> uploadJson(Map<String, dynamic> jsonData) async {
    try {
      final uri = Uri.parse('$_apiUrl/pinning/pinJSONToIPFS');

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'pinata_api_key': _apiKey,
          'pinata_secret_api_key': _apiSecret,
        },
        body: json.encode({
          'pinataContent': jsonData,
          'pinataMetadata': {
            'name':
                'NFTCollection_Metadata_${DateTime.now().millisecondsSinceEpoch}',
          },
          'pinataOptions': {
            'cidVersion': 1,
          },
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return 'ipfs://${jsonResponse['IpfsHash']}';
      } else {
        throw Exception('Failed to upload JSON to IPFS: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to upload JSON to IPFS: $e');
    }
  }
}
