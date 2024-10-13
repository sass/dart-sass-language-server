# Debugging

Here we assume you have set up a [development environment](./development-environment.md).

## Run the language extension and server

The quickest way to test the language server is to debug the language extension in Visual Studio Code. A debugging launch configuration is included in the repository. To use it:

1. open this repository in VS Code
2. go to the Run and Debug view
3. Pick Debug extension and language server from the menu
4. Click Start debugging

This will open another window of Visual Studio Code, this one running as an `[Extension Development Host]`.

### Open the Dart DevTools

In this configuration, the client has run `dart run --observe` in the local `sass_language_server` package. You can now use [Dart DevTools](https://dart.dev/tools/dart-devtools) to debug the language server.

To find the link to open Dart DevTools, use the `[Extension Development Host]`.

1. open the Output pane (View -> Output in the menu)
2. in the dropdown, choose Sass from the list

You should see output similar to this.

```
The Dart VM service is listening on http://127.0.0.1:8181/SMIxtkPzlAY=/
The Dart DevTools debugger and profiler is available at: http://127.0.0.1:8181/SMIxtkPzlAY=/devtools/?uri=ws://127.0.0.1:8181/SMIxtkPzlAY=/ws
```

Click the second link to open Dart DevTools.

The Debugger tab has a File explorer in which you can find `package:sass_language_server`. Go to `src/sass_language_server_base.dart` to find the request handlers for messages coming in from the client.

## Debug unit tests

Assuming you installed [Dart for Visual Studio Code](https://marketplace.visualstudio.com/items?itemName=Dart-Code.dart-code) you can debug individual unit tests by right-clicking the Run button in the editor gutter.

Writing a test is often faster when debugging an issue with a specific language feature, and helps improve test coverage.
