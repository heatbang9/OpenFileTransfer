import 'package:flutter/material.dart';

void main() {
  runApp(const OpenFileTransferApp());
}

class OpenFileTransferApp extends StatelessWidget {
  const OpenFileTransferApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OpenFileTransfer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2563EB)),
        useMaterial3: true,
      ),
      home: const DeviceDiscoveryPage(),
    );
  }
}

class DeviceDiscoveryPage extends StatelessWidget {
  const DeviceDiscoveryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OpenFileTransfer'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _StatusPanel(),
          SizedBox(height: 16),
          _DeviceListPlaceholder(),
        ],
      ),
    );
  }
}

class _StatusPanel extends StatelessWidget {
  const _StatusPanel();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('디바이스 탐색', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            SizedBox(height: 8),
            Text('2단계에서 SSDP 탐색과 gRPC 파일 전송 화면이 연결됩니다.'),
          ],
        ),
      ),
    );
  }
}

class _DeviceListPlaceholder extends StatelessWidget {
  const _DeviceListPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: null,
          icon: const Icon(Icons.search),
          label: const Text('서버 찾기'),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: null,
          icon: const Icon(Icons.upload_file),
          label: const Text('파일 보내기'),
        ),
      ],
    );
  }
}

