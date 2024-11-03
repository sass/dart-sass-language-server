import { AddressInfo, createServer } from 'node:net';
import vscode from 'vscode';
import {
  Executable,
  ServerOptions,
  TransportKind,
} from 'vscode-languageclient/node';
import { Utils } from 'vscode-uri';

export async function createServerOptions(
  context: vscode.ExtensionContext
): Promise<ServerOptions> {
  return new Promise((resolve, reject) => {
    // The client is the one listening to socket connections on the specified port.
    // In other words the language client is a _server_ for the socket transport.
    // The client sets up a socket server on an arbitrary available port and
    // makes sure to pass that port number as --socket=<port> when starting
    // the language server.

    const socketServer = createServer();
    socketServer.on('error', (e) => {
      reject(e);
    });
    socketServer.listen(0, () => {
      const debug: Executable = {
        command: 'dart',
        args: [
          'run',
          // '--pause-isolates-on-start', // Uncomment this to debug issues during startup and initial scan
          '--observe',
          'sass_language_server',
          '--loglevel=debug',
        ],
        transport: {
          kind: TransportKind.socket,
          port: (socketServer.address() as AddressInfo).port,
        },
        options: {
          cwd: Utils.joinPath(
            context.extensionUri,
            '..',
            'pkgs',
            'sass_language_server'
          ).fsPath,
        },
      };

      // @ts-expect-error Set in test/electron/mocha.js so we
      // don't have to build and add the server to PATH to test.
      if (vscode.env.isTest) {
        resolve(debug);
      } else {
        const serverOptions: ServerOptions = {
          command: 'sass-language-server',
          transport: {
            kind: TransportKind.socket,
            port: (socketServer.address() as AddressInfo).port,
          },
          debug,
        };
        resolve(serverOptions);
      }
    });
  });
}
