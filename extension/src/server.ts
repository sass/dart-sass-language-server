import net from 'node:net';
import vscode from 'vscode';
import {
  Executable,
  ServerOptions,
  TransportKind,
} from 'vscode-languageclient/node';
import { Utils } from 'vscode-uri';

async function getRandomAvailablePort() {
  return new Promise<number>((resolve, reject) => {
    const server = net.createServer();
    server.on('error', (e) => {
      reject(e);
    });
    server.listen(
      {
        // assign a random available port
        port: 0,
      },
      () => {
        const availablePort = (server.address() as net.AddressInfo).port;
        server.close(() => {
          resolve(availablePort);
        });
      }
    );
  });
}

export async function createServerOptions(
  context: vscode.ExtensionContext
): Promise<ServerOptions> {
  // The client is the one listening to socket connections on the specified port.
  // In other words the language client is a _server_ for the socket transport.
  // The client sets up a socket server on an arbitrary available port and
  // makes sure to pass that port number as --socket=<port> when starting
  // the language server.

  // vscode-languageclient sets up a socket server for us,
  // but doesn't support passing in 0 to be assigned a random port
  const port = await getRandomAvailablePort();

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
      port,
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
    return debug;
  } else {
    const serverOptions: ServerOptions = {
      command: 'sass-language-server',
      transport: {
        kind: TransportKind.socket,
        port,
      },
      debug,
    };
    return serverOptions;
  }
}
