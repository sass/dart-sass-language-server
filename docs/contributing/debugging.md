# Debugging

Here we assume you have set up a [development environment](./development-environment.md).

## Run the language extension and server

The quickest way to test the language server is to debug the language extension in Visual Studio Code. A debugging launch configuration is included in the repository. To use it:

1. Open this repository in VS Code.
2. Go to the Run and Debug view.
3. Pick Debug extension and language server from the menu.
4. Click Start debugging.

This will open another window of Visual Studio Code, this one running as an `[Extension Development Host]`.

### Open the Dart DevTools

In this configuration, the client has run `dart run --observe` in the local `sass_language_server` package. You can now use [Dart DevTools](https://dart.dev/tools/dart-devtools) to debug the language server.

To find the link to open Dart DevTools, use the `[Extension Development Host]`.

1. Open a CSS, SCSS or Sass file to activate the language server.
2. Open the Output pane (View -> Output in the menu).
3. In the dropdown in the top right, choose Sass from the list.

You should see output similar to this.

```
The Dart VM service is listening on http://127.0.0.1:8181/SMIxtkPzlAY=/
The Dart DevTools debugger and profiler is available at: http://127.0.0.1:8181/SMIxtkPzlAY=/devtools/?uri=ws://127.0.0.1:8181/SMIxtkPzlAY=/ws
```

![screenshot showing the output pane and the dropdown with sass selected](https://github.com/user-attachments/assets/85839d2f-4305-4fb9-aeb0-d78f435e8b7d)

Click the second link to open Dart DevTools.

The Debugger tab has a File explorer in which you can find `package:sass_language_server`. Go to `src/language_server.dart` to find the request handlers for messages coming in from the client.

## Debug unit tests

Assuming you installed [Dart for Visual Studio Code](https://marketplace.visualstudio.com/items?itemName=Dart-Code.dart-code) you can debug individual unit tests by right-clicking the Run button in the editor gutter.

Writing a test is often faster when debugging an issue with a specific language feature, and helps improve test coverage.

## Debug VS Code tests

To debug, add this launch configuration to `.vscode/launch.json`
and change the path to match the test suite you're debugging.
Place breakpoints in the test code and choose the Debug extensions
test profile in the Run and Debug view in VS Code.

```json
{
  "name": "Debug extension tests",
  "type": "extensionHost",
  "request": "launch",
  "runtimeExecutable": "${execPath}",
  "args": [
    "--extensionDevelopmentPath=${workspaceFolder}/extension",
    "--extensionTestsPath=${workspaceFolder}/extension/test/electron/document-links/index"
  ]
}
```

## Testing in isolation

VS Code ships with some built-in support for SCSS and CSS. To test this language server in isolation you can disable the built-in extension.

1. Go to the Extensions tab and search for `@builtin css language features`.
2. Click the settings icon and pick Disable from the list.
3. Click Restart extension to turn it off.

You should also turn off extensions like SCSS IntelliSense or Some Sass.
