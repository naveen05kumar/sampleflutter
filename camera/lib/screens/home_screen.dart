// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/camera_provider.dart';
import '../models/camera.dart';

class HomeScreen extends StatelessWidget {
  final TextEditingController _ipController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _ddnsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final cameraProvider = Provider.of<CameraProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Camera Management'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _ipController,
              decoration: InputDecoration(labelText: 'IP Address'),
            ),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: () async {
                await cameraProvider.addStaticCamera(
                  StaticCamera(
                    ipAddress: _ipController.text,
                    username: _usernameController.text,
                    password: _passwordController.text,
                  ),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Static Camera Connected')),
                );
              },
              child: Text('Connect Static Camera'),
            ),
            TextField(
              controller: _ddnsController,
              decoration: InputDecoration(labelText: 'DDNS Hostname'),
            ),
            ElevatedButton(
              onPressed: () async {
                await cameraProvider.addDDNSCamera(
                  DDNSCamera(
                    ddnsHostname: _ddnsController.text,
                    username: _usernameController.text,
                    password: _passwordController.text,
                  ),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('DDNS Camera Connected')),
                );
              },
              child: Text('Connect DDNS Camera'),
            ),
            ElevatedButton(
              onPressed: () async {
                final streamUrl = await cameraProvider.getStreamUrl('static');
                if (streamUrl != null) {
                  Navigator.pushNamed(
                    context,
                    '/stream',
                    arguments: streamUrl,
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to get Static Camera Stream URL')),
                  );
                }
              },
              child: Text('View Static Camera Stream'),
            ),
            ElevatedButton(
              onPressed: () async {
                final streamUrl = await cameraProvider.getStreamUrl('ddns');
                if (streamUrl != null) {
                  Navigator.pushNamed(
                    context,
                    '/stream',
                    arguments: streamUrl,
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to get DDNS Camera Stream URL')),
                  );
                }
              },
              child: Text('View DDNS Camera Stream'),
            ),
          ],
        ),
      ),
    );
  }
}
