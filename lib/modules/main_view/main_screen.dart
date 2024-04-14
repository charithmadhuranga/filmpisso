import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:isar/isar.dart';
import 'package:filmpisso/main.dart';
import 'package:filmpisso/models/source.dart';
import 'package:filmpisso/services/fetch_anime_sources.dart';
import 'package:filmpisso/services/fetch_manga_sources.dart';
import 'package:filmpisso/modules/main_view/providers/migration.dart';
import 'package:filmpisso/modules/more/about/providers/check_for_update.dart';
import 'package:filmpisso/modules/more/backup_and_restore/providers/auto_backup.dart';
import 'package:filmpisso/modules/more/settings/browse/providers/browse_state_provider.dart';
import 'package:filmpisso/providers/l10n_providers.dart';
import 'package:filmpisso/router/router.dart';
import 'package:filmpisso/utils/extensions/build_context_extensions.dart';
import 'package:filmpisso/modules/library/providers/library_state_provider.dart';
import 'package:filmpisso/modules/more/providers/incognito_mode_state_provider.dart';

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = l10nLocalizations(context)!;
    final route = GoRouter.of(context);
    ref.read(checkAndBackupProvider);
    ref.watch(checkForUpdateProvider(context: context));
    ref.watch(fetchMangaSourcesListProvider(id: null, reFresh: false));
    ref.watch(fetchAnimeSourcesListProvider(id: null, reFresh: false));
    return ref.watch(migrationProvider).when(data: (_) {
      return Consumer(builder: (context, ref, chuld) {
        final location = ref.watch(
          routerCurrentLocationStateProvider(context),
        );
        bool isReadingScreen =
            location == '/mangareaderview' || location == '/animePlayerView';
        int currentIndex = switch (location) {
          null => 0,
          '/MangaLibrary' => 0,
          '/AnimeLibrary' => 1,
          '/history' => 2,
          '/browse' => 3,
          _ => 4,
        };

        final incognitoMode = ref.watch(incognitoModeStateProvider);
        final isLongPressed = ref.watch(isLongPressedMangaStateProvider);
        return Column(
          children: [
            if (!isReadingScreen)
              Material(
                child: AnimatedContainer(
                  height: incognitoMode
                      ? Platform.isAndroid || Platform.isIOS
                          ? MediaQuery.of(context).padding.top * 2
                          : 50
                      : 0,
                  curve: Curves.easeIn,
                  duration: const Duration(milliseconds: 150),
                  color: context.primaryColor,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          l10n.incognito_mode,
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: GoogleFonts.aBeeZee().fontFamily,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            Flexible(
              child: Scaffold(
                body: context.isTablet
                    ? Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 0),
                            width: switch (isLongPressed) {
                              true => 0,
                              _ => switch (location) {
                                  null => 100,
                                  != '/MangaLibrary' &&
                                        != '/AnimeLibrary' &&
                                        != '/history' &&
                                        != '/browse' &&
                                        != '/more' =>
                                    0,
                                  _ => 100,
                                },
                            },
                            child: Stack(
                              children: [
                                NavigationRailTheme(
                                  data: NavigationRailThemeData(
                                    indicatorShape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(30)),
                                  ),
                                  child: NavigationRail(
                                    labelType: NavigationRailLabelType.all,
                                    useIndicator: true,
                                    destinations: [
                                      NavigationRailDestination(
                                          selectedIcon: const Icon(
                                              Icons.collections_bookmark),
                                          icon: const Icon(Icons
                                              .collections_bookmark_outlined),
                                          label: Padding(
                                              padding:
                                                  const EdgeInsets.only(top: 5),
                                              child: Text(l10n.manga))),
                                      NavigationRailDestination(
                                          selectedIcon: const Icon(
                                              Icons.video_collection),
                                          icon: const Icon(
                                              Icons.video_collection_outlined),
                                          label: Padding(
                                              padding:
                                                  const EdgeInsets.only(top: 5),
                                              child: Text(l10n.anime))),
                                      NavigationRailDestination(
                                          selectedIcon:
                                              const Icon(Icons.history),
                                          icon: const Icon(
                                              Icons.history_outlined),
                                          label: Padding(
                                              padding:
                                                  const EdgeInsets.only(top: 5),
                                              child: Text(l10n.history))),
                                      NavigationRailDestination(
                                          selectedIcon:
                                              const Icon(Icons.explore),
                                          icon: const Icon(
                                              Icons.explore_outlined),
                                          label: Padding(
                                              padding:
                                                  const EdgeInsets.only(top: 5),
                                              child: Text(l10n.browse))),
                                      NavigationRailDestination(
                                          selectedIcon:
                                              const Icon(Icons.more_horiz),
                                          icon: const Icon(
                                              Icons.more_horiz_outlined),
                                          label: Padding(
                                              padding:
                                                  const EdgeInsets.only(top: 5),
                                              child: Text(l10n.more))),
                                    ],
                                    selectedIndex: currentIndex,
                                    onDestinationSelected: (newIndex) {
                                      if (newIndex == 0) {
                                        route.go('/MangaLibrary');
                                      } else if (newIndex == 1) {
                                        route.go('/AnimeLibrary');
                                      } else if (newIndex == 2) {
                                        route.go('/history');
                                      } else if (newIndex == 3) {
                                        route.go('/browse');
                                      } else if (newIndex == 4) {
                                        route.go('/more');
                                      }
                                    },
                                  ),
                                ),
                                Positioned(
                                    right: 18,
                                    top: 210,
                                    child: _extensionUpdateTotalNumbers(ref)),
                              ],
                            ),
                          ),
                          Expanded(child: child)
                        ],
                      )
                    : child,
                bottomNavigationBar: context.isTablet
                    ? null
                    : AnimatedContainer(
                        duration: const Duration(milliseconds: 0),
                        width: context.mediaWidth(1),
                        height: switch (isLongPressed) {
                          true => 0,
                          _ => switch (location) {
                              null => null,
                              != '/MangaLibrary' &&
                                    != '/AnimeLibrary' &&
                                    != '/history' &&
                                    != '/browse' &&
                                    != '/more' =>
                                0,
                              _ => null,
                            },
                        },
                        child: NavigationBarTheme(
                          data: NavigationBarThemeData(
                            indicatorShape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                          ),
                          child: NavigationBar(
                            animationDuration:
                                const Duration(milliseconds: 500),
                            selectedIndex: currentIndex,
                            destinations: [
                              NavigationDestination(
                                  selectedIcon:
                                      const Icon(Icons.collections_bookmark),
                                  icon: const Icon(
                                      Icons.collections_bookmark_outlined),
                                  label: l10n.manga),
                              NavigationDestination(
                                  selectedIcon:
                                      const Icon(Icons.video_collection),
                                  icon: const Icon(
                                      Icons.video_collection_outlined),
                                  label: l10n.anime),
                              NavigationDestination(
                                  selectedIcon: const Icon(Icons.history),
                                  icon: const Icon(Icons.history_outlined),
                                  label: l10n.history),
                              Stack(
                                children: [
                                  NavigationDestination(
                                      selectedIcon: const Icon(Icons.explore),
                                      icon: const Icon(Icons.explore_outlined),
                                      label: l10n.browse),
                                  Positioned(
                                      right: 14,
                                      top: 3,
                                      child: _extensionUpdateTotalNumbers(ref)),
                                ],
                              ),
                              NavigationDestination(
                                  selectedIcon: const Icon(Icons.more_horiz),
                                  icon: const Icon(Icons.more_horiz_outlined),
                                  label: l10n.more),
                            ],
                            onDestinationSelected: (newIndex) {
                              if (newIndex == 0) {
                                route.go('/MangaLibrary');
                              } else if (newIndex == 1) {
                                route.go('/AnimeLibrary');
                              } else if (newIndex == 2) {
                                route.go('/history');
                              } else if (newIndex == 3) {
                                route.go('/browse');
                              } else if (newIndex == 4) {
                                route.go('/more');
                              }
                            },
                          ),
                        ),
                      ),
              ),
            ),
          ],
        );
      });
    }, error: (error, _) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Image.asset(
            "assets/app_icons/icon.png",
            color: Colors.black,
            fit: BoxFit.cover,
            height: 100,
          ),
        ),
      );
    }, loading: () {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Image.asset(
            "assets/app_icons/icon.png",
            color: Colors.black,
            fit: BoxFit.cover,
            height: 100,
          ),
        ),
      );
    });
  }
}

Widget _extensionUpdateTotalNumbers(WidgetRef ref) {
  return StreamBuilder(
      stream: isar.sources
          .filter()
          .idIsNotNull()
          .and()
          .isActiveEqualTo(true)
          .watch(fireImmediately: true),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          final entries = snapshot.data!
              .where((element) => ref.watch(showNSFWStateProvider)
                  ? true
                  : element.isNsfw == false)
              .where((element) =>
                  compareVersions(element.version!, element.versionLast!) < 0)
              .toList();
          return entries.isEmpty
              ? Container()
              : Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: const Color.fromARGB(255, 176, 46, 37)),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                    child: Text(
                      entries.length.toString(),
                      style: TextStyle(
                          fontSize: 10,
                          color: Theme.of(context).textTheme.bodySmall!.color),
                    ),
                  ),
                );
        }
        return Container();
      });
}
