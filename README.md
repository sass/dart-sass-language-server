# Overview

This repository contains the Dart implementation of the Sass language server. It's divided in two packages:

- [sass_language_server](./pkgs/sass_language_server/)
- [sass_language_services](./pkgs/sass_language_services/)

We have this split so the language server features are in a reusable library format [for embedded languages](https://code.visualstudio.com/api/language-extensions/embedded-languages) where the embedder language server is also written in Dart.

## Development environment

1. [Install the Dart SDK](https://dart.dev/get-dart)
2. Open [pkgs/sass_language_server](./pkgs/sass_language_server/) in a terminal.
3. Run `dart run`.

There are [Dart plugins for several editors](https://dart.dev/tools#editors) to improve the editor experience.
