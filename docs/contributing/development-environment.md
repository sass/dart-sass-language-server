## Development environment

The Sass language server, like the Sass compiler, is written in [Dart](https://dart.dev/).
The language extension for Visual Studio Code is written in [TypeScript](https://www.typescriptlang.org/).
Tests for the extension are written in JavaScript.

If you have a background writing JavaScript or TypeScript, [Learning Dart as a JavaScript developer](https://dart.dev/resources/coming-from/js-to-dart) is a great place to start.

## Required software

To work on the language server:

- [The Dart SDK v3.5 or higher](https://dart.dev/get-dart)

To work on the language extension, or test your changes in Visual Studio Code:

- [Node.js v20 or higher](https://nodejs.org/en)
- [Visual Studio Code](https://code.visualstudio.com/) or [VSCodium](https://github.com/VSCodium/vscodium) (we'll refer to Visual Studio Code, VS Code for short, in the documentation)

### Recommended software

- [Dart extension for VS Code](https://github.com/Dart-Code/Dart-Code)

## Install dependencies

The repo is organised as a workspace. To install dependencies across packages, run this at the root level:

```sh
dart pub get
```

The language extension is not part of the Dart workspace. Install its dependencies separately.

```sh
cd extension
npm clean-install
```
