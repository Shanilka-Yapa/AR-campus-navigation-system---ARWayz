import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart'; // Clipboard
import 'package:share_plus/share_plus.dart'; // Share

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  String scannedCode = "";
  bool hasScanned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR Code')),
      body: Column(
        children: [
          // Camera view
          Expanded(
            flex: 4,
            child: MobileScanner(
              onDetect: (capture) {
                final barcode = capture.barcodes.first;
                final code = barcode.rawValue;
                if (code != null && scannedCode != code) {
                  setState(() {
                    scannedCode = code;
                    hasScanned = true;
                  });
                }
              },
            ),
          ),

          // QR result block
          if (hasScanned)
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Card(
                  color: Colors.white,
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          scannedCode,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Open in browser
                            ElevatedButton.icon(
                              onPressed: () async {
                                String urlString = scannedCode;
                                if (!urlString.startsWith('http://') &&
                                    !urlString.startsWith('https://')) {
                                  urlString = 'https://$urlString';
                                }
                                final Uri url = Uri.parse(urlString);
                                if (await canLaunchUrl(url)) {
                                  await launchUrl(url,
                                      mode: LaunchMode.externalApplication);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'Cannot open URL: $scannedCode')),
                                  );
                                }
                              },
                              icon: const Icon(Icons.open_in_browser),
                              label: const Text('Open'),
                            ),

                            // Copy to clipboard
                            ElevatedButton.icon(
                              onPressed: () {
                                Clipboard.setData(
                                    ClipboardData(text: scannedCode));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Copied to clipboard')),
                                );
                              },
                              icon: const Icon(Icons.copy),
                              label: const Text('Copy'),
                            ),

                            // Share
                            ElevatedButton.icon(
                              onPressed: () {
                                Share.share(scannedCode,
                                    subject: 'QR Code Link');
                              },
                              icon: const Icon(Icons.share),
                              label: const Text('Share'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
