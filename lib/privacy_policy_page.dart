import 'package:flutter/material.dart';
import 'app_info.dart';

/// The Notion-ready document is also bundled, so the complete policy works offline.
class PrivacyPolicyPage extends StatefulWidget {
  const PrivacyPolicyPage({super.key});
  @override
  State<PrivacyPolicyPage> createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage> {
  Future<String>? _policy;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _policy ??= DefaultAssetBundle.of(
      context,
    ).loadString('docs/PRIVACY_POLICY.md');
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Privacy policy')),
    body: SafeArea(
      child: FutureBuilder<String>(
        future: _policy,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: SelectableText(
                  'Contact $supportEmail for a copy of the privacy policy.',
                ),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return SelectionArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 680),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: snapshot.data!
                        .split(RegExp(r'\r?\n\s*\r?\n'))
                        .map((block) {
                          final heading = block.startsWith('#');
                          var text = block
                              .replaceFirst(RegExp(r'^#+\s*'), '')
                              .replaceAll('**', '');
                          text = text.replaceAllMapped(
                            RegExp(r'\[([^\]]+)\]\(([^)]+)\)'),
                            (match) {
                              return match[2] == 'mailto:${match[1]}'
                                  ? match[1]!
                                  : '${match[1]} (${match[2]})';
                            },
                          );
                          if (!block.startsWith('- ') &&
                              !block.startsWith('**')) {
                            text = text.replaceAll(RegExp(r'\r?\n'), ' ');
                          }
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 18),
                            child: Text(
                              text,
                              style: TextStyle(
                                fontSize: heading ? 21 : 16,
                                height: 1.5,
                                fontWeight: heading
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          );
                        })
                        .toList(),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    ),
  );
}
