# Testing and debugging

Here we assume you have set up a [development environment](./development-environment.md).

## Run the language extension and server

The quickest way to test the language server is to debug the language extension in Visual Studio Code. A debugging launch configuration is included in the repository. To use it:

1. Open this repository in VS Code.
2. Go to the Run and Debug view.
3. Pick Debug extension and language server from the menu.
4. Click Start debugging.

This will open another window of Visual Studio Code, this one running as an `[Extension Development Host]`.

### Find the link to Dart DevTools or VM service

When debugging, the client runs [`dart run --enable-vm-service`](https://github.com/sass/dart-sass-language-server/blob/main/extension/src/server.ts#L49)
in the local `sass_language_server` package.

Use the `[Extension Development Host]` window to find the link to open Dart DevTools or to [attach the debugger](#attach-to-language-server).

1. Open a CSS, SCSS or Sass file to activate the language server.
2. Open the Output pane (View -> Output in the menu).
3. Choose Sass in the dropdown to the top right of the Output pane.
4. Scroll to the top of the output.

You should see something similar to this.

```
The Dart VM service is listening on http://127.0.0.1:8181/SMIxtkPzlAY=/
The Dart DevTools debugger and profiler is available at: http://127.0.0.1:8181/SMIxtkPzlAY=/devtools/?uri=ws://127.0.0.1:8181/SMIxtkPzlAY=/ws
```

Click the second link to open Dart DevTools, or copy the first link to [attach a debugger](#attach-to-language-server).

![screenshot showing the output pane and the dropdown with sass selected](https://github.com/user-attachments/assets/85839d2f-4305-4fb9-aeb0-d78f435e8b7d)

### Attach to language server

The debugger in Dart DevTools is deprecated in favor the debugger that ships with [Dart for Visual Studio Code][vscodedart].

To start debugging in VS Code (provided you have the Dart extension):

1. [Run the language server and extension](#run-the-language-extension-and-server) in debug mode.
2. [Find the link to the Dart VM](#find-the-link-to-dart-devtools-or-vm-service).

You should see output similar to this in the `[Extension Development Host]`.

```
The Dart VM service is listening on http://127.0.0.1:8181/SMIxtkPzlAY=/
The Dart DevTools debugger and profiler is available at: http://127.0.0.1:8181/SMIxtkPzlAY=/devtools/?uri=ws://127.0.0.1:8181/SMIxtkPzlAY=/ws
```

Copy the first link, then go back to the Run and debug window where you started the language server and extension.

1. Click the Run and debug drop-down and run `Attach to language server`.
2. Paste the link you copied and hit Enter.

Your debugger should be attached, allowing you to place breakpoints and step through code.

### Test in VS Code without built-in SCSS features

VS Code ships with some built-in support for SCSS and CSS. To test this language server in isolation you can disable the built-in extension.

1. Go to the Extensions tab and search for `@builtin css language features`.
2. Click the settings icon and pick Disable from the list.
3. Click Restart extension to turn it off.

You should also turn off extensions like SCSS IntelliSense or Some Sass.

## Debug unit tests

Assuming you installed [Dart for Visual Studio Code][vscodedart] you can debug individual unit tests by right-clicking the Run button in the editor gutter.

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

[vscodedart]: https://marketplace.visualstudio.com/items?itemName=Dart-Code.dart-code
