import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart'; // Clipboard
import 'package:share_plus/share_plus.dart'; // Share
import 'qr_payload.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  final MobileScannerController _scannerController = MobileScannerController();
  String scannedCode = "";
  bool hasScanned = false;
  QrPayload? scannedPayload;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  /// Helper: Clean and prepare QR code for opening
  String _prepareUrl(String code) {
    String urlString = code.trim().replaceAll('\n', '').replaceAll('\r', '');

    // Check if it looks like a URL, if not prepend https://
    if (!urlString.startsWith(RegExp(r'https?://'))) {
      urlString = 'https://$urlString';
    }
    return urlString;
  }

  Future<void> _openUrl(String code) async {
    final urlString = _prepareUrl(code);

    try {
      final Uri url = Uri.parse(urlString);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        // Show dialog for invalid URL
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Cannot open link'),
            content: Text('Scanned QR code is not a valid URL:\n$urlString'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error opening link: $e')));
    }
  }

  void _useScannedPayload() {
    final payload = scannedPayload;
    if (payload == null) return;
    Navigator.pop(context, payload);
  }

  void _scanAgain() {
    setState(() {
      scannedCode = "";
      scannedPayload = null;
      hasScanned = false;
    });
    _scannerController.start();
  }

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
              controller: _scannerController,
              onDetect: (capture) {
                final barcode = capture.barcodes.first;
                final code = barcode.rawValue ?? "";
                if (code.isNotEmpty && scannedCode != code) {
                  final payload = QrPayload.parse(code);
                  if (payload != null) {
                    _scannerController.stop();
                    setState(() {
                      scannedCode = code;
                      scannedPayload = payload;
                      hasScanned = true;
                    });
                    return;
                  }
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
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          scannedCode,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        if (scannedPayload != null)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _useScannedPayload,
                              icon: const Icon(Icons.check),
                              label: const Text('USE THIS QR CODE'),
                            ),
                          )
                        else
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // Open in browser
                              ElevatedButton.icon(
                                onPressed: () => _openUrl(scannedCode),
                                icon: const Icon(Icons.open_in_browser),
                                label: const Text('Open'),
                              ),

                              // Copy to clipboard
                              ElevatedButton.icon(
                                onPressed: () {
                                  Clipboard.setData(
                                    ClipboardData(text: scannedCode),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Copied to clipboard'),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.copy),
                                label: const Text('Copy'),
                              ),

                              // Share
                              ElevatedButton.icon(
                                onPressed: () {
                                  Share.share(
                                    scannedCode,
                                    subject: 'QR Code Link',
                                  );
                                },
                                icon: const Icon(Icons.share),
                                label: const Text('Share'),
                              ),
                            ],
                          ),
                        if (scannedPayload == null)
                          TextButton.icon(
                            onPressed: _scanAgain,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Scan again'),
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
