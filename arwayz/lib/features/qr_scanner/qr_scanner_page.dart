import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/models/qr_payload.dart';

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

  String _prepareUrl(String code) {
    String urlString = code.trim().replaceAll('\n', '').replaceAll('\r', '');
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
      appBar: AppBar(
        title: const Text(
          'Scan QR Code',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18),
        ),
        backgroundColor: const Color(0xFF1A2D33),
        centerTitle: true,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
            onPressed: () => Navigator.maybePop(context),
            tooltip: 'Back',
          ),
        ),
      ),
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
                    borderRadius: BorderRadius.circular(16),
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
                              icon: const Icon(Icons.check_rounded),
                              label: const Text('USE THIS QR CODE'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1A2D33),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          )
                        else
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () => _openUrl(scannedCode),
                                icon: const Icon(Icons.open_in_browser_rounded),
                                label: const Text('Open'),
                              ),
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
                                icon: const Icon(Icons.copy_rounded),
                                label: const Text('Copy'),
                              ),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Share.share(
                                    scannedCode,
                                    subject: 'QR Code Link',
                                  );
                                },
                                icon: const Icon(Icons.share_rounded),
                                label: const Text('Share'),
                              ),
                            ],
                          ),
                        if (scannedPayload == null)
                          TextButton.icon(
                            onPressed: _scanAgain,
                            icon: const Icon(Icons.refresh_rounded),
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
