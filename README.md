<p align="center">
 <img width=200px height=200px src="assets/app_icons/icon-red.png"/>
</p>
<p align="center">

[![latest release](https://img.shields.io/github/release/charithmadhuranga/filmpisso.svg?maxAge=3600&label=download)](https://github.com/charithmadhuranga/filmpisso/releases)
[![Github All Releases](https://img.shields.io/github/downloads/charithmadhuranga/filmpisso/total.svg)]()

</p>

Filmpisso is free an open source manga reader and anime/Film/TVSeries streaming cross-platform app. It allows users to read manga and watch,Download anime/Film/TVSeries from variety of sources.



## How to use the application


[![how to use filmpisso](https://i9.ytimg.com/vi_webp/nAUttqh-J9I/mq2.webp?sqp=COTe5rkG-oaymwEmCMACELQB8quKqQMa8AEB-AH-CYAC0AWKAgwIABABGEYgTChlMA8=&rs=AOn4CLBw5H_LjMro5DSS5x1s6HM5pYRlnQ)](https://youtu.be/nAUttqh-J9I)


## Features

Features include:

- [Supports external sources](https://github.com/charithmadhuranga/filmpisso-extensions), utilizing the capabilities of the [dart_eval](https://pub.dev/packages/dart_eval) package & [flutter_qjs package A small Javascript engine supports ES2020](https://github.com/charithmadhuranga/flutter_qjs)
- Online reading from a variety of sources
- Watching anime from a variety of sources
- Local reading of downloaded content
- A configurable reader with multiple viewers, reading directions and other settings..
- Tracker support for anime and manga: [MyAnimeList](https://myanimelist.net/), [AniList](https://anilist.co/) and [Kitsu](https://kitsu.io/) support
- Categories to organize your library
- Light and dark themes
- Create backups locally to read offline or to your desired cloud service
- Download and stream Film/anime/TvSeries

## ToDo List

1. Catergorizing Content Seperatly Manga,anime,film,Tvseries
2. add torrent streaming and downloading capabilites
3. Improve the Searching Capabilities and filtering
4. Improve source Mangement
5. add a dashboard with Collections of shortcuts creation to navigate easy to favourite/recent film/anime/tvseries
6. Notifications when favourite anime/tvseries/manga get new episodes

## Download

Get the app from our [releases page](https://github.com/charithmadhuranga/filmpisso/releases).

## Using Rust Inside Flutter

This project use Rust for the [auto-image-cropper](https://github.com/ritiek/auto-image-cropper) crate utilizing the capabilities of the [Rinf](https://pub.dev/packages/rinf) framework.

To run and build this app, you need to have
[Flutter SDK](https://docs.flutter.dev/get-started/install)
and [Rust toolchain](https://www.rust-lang.org/tools/install)
installed on your system.
You can check that your system is ready with the commands below.
Note that all the Flutter subcomponents should be installed.

```bash
rustc --version
flutter doctor
```

You also need to have the CLI tool for Rinf ready.

```bash
cargo install rinf
```

Messages sent between Dart and Rust are implemented using Protobuf.
If you have newly cloned the project repository
or made changes to the `.proto` files in the `./messages` directory,
run the following command:

```bash
rinf message
```

Now you can run and build this app just like any other Flutter projects.

```bash
flutter run
```

For detailed instructions on writing Rust and Flutter together,
please refer to Rinf's [documentation](https://rinf-docs.cunarist.com).

# Contributing

Contributions are welcome!

To get started with extension development, see [CONTRIBUTING.md](https://github.com/charithmadhuranga/filmpisso-extensions/blob/main/CONTRIBUTING.md) for create sources in Dart or [CONTRIBUTING-JS.md](https://github.com/charithmadhuranga/filmpisso-extensions/blob/main/CONTRIBUTING-JS.md) for create sources in JavaScript.

## License

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

## Disclaimer

The developer of this application does not have any affiliation with the content providers available.
