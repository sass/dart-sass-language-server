import { AddressInfo, createServer } from 'node:net';
import { ExtensionContext } from 'vscode';
import { ServerOptions, TransportKind } from 'vscode-languageclient/node';
import { Utils } from 'vscode-uri';

export async function createServerOptions(
  context: ExtensionContext
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
      const serverOptions: ServerOptions = {
        command: 'sass-language-server',
        transport: {
          kind: TransportKind.socket,
          port: (socketServer.address() as AddressInfo).port,
        },
        debug: {
          command: 'dart',
          args: [
            'run',
            // TODO: figure out how we can use the debugger while also not breaking on startup. Maybe we can't use --sdtio? Some Sass uses .ipc
            // '--pause-isolates-on-start', // TODO: see if we can use this
            '--observe',
            'sass_language_server',
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
        },
      };
      resolve(serverOptions);
    });
  });
}
