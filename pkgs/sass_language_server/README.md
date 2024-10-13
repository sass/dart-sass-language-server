# sass_language_server

A Dart implementation of a language server for Sass. The language server uses the Language Server Protocol (LSP).

## Installing the Sass language server

### From Pub

<!-- Assuming this is how it will be -->

If you're a [Dart](https://dart.dev/get-dart) user, you can install the Sass language server globally using `pub global activate sass_language_server`, which will provide a `sass-language-server` executable.

## Using the Sass language server

To use `sass-language-server` your editor needs a language client.

We provide a language client extension for [Visual Studio Code](https://github.com/wkillerud/dart-sass-language-server/tree/main/extension). For other editors we lean on the community.

There may a client already available for your editor. If not, check your editor's documentation for how to configure a language client.

Here is an example for the Helix editor. With the configuration below, `sass-language-server` will start once you open an SCSS file in Helix.

```toml
[language-server.sass-language-server]
command = "sass-language-server"
config = { sass = { workspace = { loadPaths = [] } } }

[[language]]
name = "scss"
language-servers = [
    { name = "sass-language-server" }
]
```
