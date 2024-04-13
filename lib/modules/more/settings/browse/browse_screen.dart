import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mangayomi/providers/l10n_providers.dart';
import 'package:mangayomi/utils/extensions/build_context_extensions.dart';
import 'package:mangayomi/modules/more/settings/browse/providers/browse_state_provider.dart';

class BrowseSScreen extends ConsumerWidget {
  const BrowseSScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showNSFWS = ref.watch(showNSFWStateProvider);
    final onlyIncludePinnedSource =
        ref.watch(onlyIncludePinnedSourceStateProvider);
    final checkForExtensionUpdates =
        ref.watch(checkForExtensionsUpdateStateProvider);
    final autoUpdateExtensions = ref.watch(autoUpdateExtensionsStateProvider);
    final l10n = l10nLocalizations(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n!.browse),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 30, top: 20),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      children: [
                        Text(l10n.extensions,
                            style: TextStyle(
                                fontSize: 13, color: context.primaryColor)),
                      ],
                    ),
                  ),
                  SwitchListTile(
                      value: checkForExtensionUpdates,
                      title: Text(l10n.check_for_extension_updates),
                      onChanged: (value) {
                        ref
                            .read(checkForExtensionsUpdateStateProvider.notifier)
                            .set(value);
                      }),
                  if (checkForExtensionUpdates)
                    SwitchListTile(
                        value: autoUpdateExtensions,
                        title: Text(l10n.auto_extensions_updates),
                        subtitle: Text(
                            l10n.auto_extensions_updates_subtitle,
                            style: TextStyle(
                                fontSize: 11, color: context.secondaryColor)),
                        onChanged: (value) {
                          ref
                              .read(autoUpdateExtensionsStateProvider.notifier)
                              .set(value);
                        }),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      children: [
                        Text(l10n.global_search,
                            style: TextStyle(
                                fontSize: 13, color: context.primaryColor)),
                      ],
                    ),
                  ),
                  SwitchListTile(
                      value: onlyIncludePinnedSource,
                      title: Text(l10n.only_include_pinned_sources),
                      onChanged: (value) {
                        ref
                            .read(onlyIncludePinnedSourceStateProvider.notifier)
                            .set(value);
                      }),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      children: [
                        Text(l10n.nsfw_sources,
                            style: TextStyle(
                                fontSize: 13, color: context.primaryColor)),
                      ],
                    ),
                  ),
                  SwitchListTile(
                      value: showNSFWS,
                      title: Text(l10n.nsfw_sources_show),
                      onChanged: (value) {
                        ref.read(showNSFWStateProvider.notifier).set(value);
                      }),
                  ListTile(
                    title: Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            color: context.secondaryColor,
                          ),
                        ],
                      ),
                    ),
                    subtitle: Text(l10n.nsfw_sources_info,
                        style: TextStyle(
                            fontSize: 11, color: context.secondaryColor)),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
