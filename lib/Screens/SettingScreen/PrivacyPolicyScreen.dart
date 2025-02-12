import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;

class PrivacyPolicyScreen extends StatefulWidget {
  @override
  _PrivacyPolicyScreenState createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  String _privacyPolicy = "";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPrivacyPolicy();
  }

  Future<void> _fetchPrivacyPolicy() async {
    try {
      final response = await http.get(
          Uri.parse('https://gaming.sunztech.com/api/v1/api.php?get_settings'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _privacyPolicy = data['settings']['privacy_policy'] ??
              'Privacy policy not available.';
          _isLoading = false;
        });
      } else {
        setState(() {
          _privacyPolicy = 'Failed to load privacy policy.';
          _isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        _privacyPolicy = 'An error occurred: $error';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Html(
                data: _privacyPolicy, // Render HTML content
                style: {
                  "body": Style(
                    fontSize: FontSize(14.0),
                    color: Colors.black87,
                  ),
                },
              ),
            ),
    );
  }
}
