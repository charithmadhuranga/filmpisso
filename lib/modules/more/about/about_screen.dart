import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:filmpisso/modules/more/about/providers/check_for_update.dart';
import 'package:filmpisso/providers/l10n_providers.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutScreen extends ConsumerStatefulWidget {
  const AboutScreen({super.key});

  @override
  ConsumerState<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends ConsumerState<AboutScreen> {
  Future<void> _launchInBrowser(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw 'Could not launch $url';
    }
  }

  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
    buildSignature: 'Unknown',
    installerStore: 'Unknown',
  );

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _packageInfo = info;
      });
    }
  }

  @override
  void initState() {
    _initPackageInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = l10nLocalizations(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n!.about),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Image.asset(
                "assets/app_icons/icon.png",
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.black
                    : Colors.white,
                fit: BoxFit.cover,
                height: 100,
              ),
            ),
            Column(
              children: [
                const Divider(
                  color: Colors.grey,
                ),
                ListTile(
                  onTap: () {},
                  title: const Text('Version'),
                  subtitle: Text(
                    'Beta (${_packageInfo.version})',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                ListTile(
                  onTap: () {
                    ref.read(checkForUpdateProvider(
                        context: context, manualUpdate: true));
                  },
                  title: Text(l10n.check_for_update),
                ),
                // ListTile(
                //   onTap: () {},
                //   title: const Text("What's news"),
                // ),
                // ListTile(
                //   onTap: () {},
                //   title: const Text('Help translation'),
                // ),
                // ListTile(
                //   onTap: () {},
                //   title: const Text('Privacy policy'),
                // ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                        onPressed: () {
                          _launchInBrowser(Uri.parse(
                              'https://github.com/charithmadhuranga/filmpisso'));
                        },
                        icon: const Icon(FontAwesomeIcons.github)),
                    IconButton(
                        onPressed: () {
                          _launchInBrowser(Uri.parse(
                              'https://discord.com/invite/EjfBuYahsP'));
                        },
                        icon: const Icon(FontAwesomeIcons.discord))
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
