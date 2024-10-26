# Building

This document describes how to:

- Build the Dart Sass language server.
- Build the Sass language extension for Visual Studio Code.

Here we assume you have set up a [development environment](./development-environment.md).

## Building the language server

In `pkgs/sass_language_server`:

```sh
dart compile exe bin/sass_language_server.dart -o bin/sass-language-server
```

This builds an executable for your current operating system named `sass-language-server`.

## Building the language extension

In `extension`:

```sh
npm run package
```

This creates a `vsix` file, which is the Visual Studio Code extension format. You can install it via the overflow-menu (tripple dots) in the Extensions pane. This can be useful to test the production build of the extension, but is not needed for [development and debugging](./debugging.md).
