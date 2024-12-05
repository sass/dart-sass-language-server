import {
  window,
  workspace,
  ExtensionContext,
  WorkspaceFolder,
  ProgressLocation,
  Uri,
  TextDocument,
} from 'vscode';
import { BaseLanguageClient, LanguageClient } from 'vscode-languageclient/node';
import { createLanguageClientOptions } from './client';
import { createServerOptions } from './server';

let defaultClient: LanguageClient;
const clients: Map<string, BaseLanguageClient> = new Map<
  string,
  BaseLanguageClient
>();

let _sortedWorkspaceFolders: string[] | undefined;
function sortedWorkspaceFolders(): string[] {
  if (_sortedWorkspaceFolders === void 0) {
    _sortedWorkspaceFolders = workspace.workspaceFolders
      ? workspace.workspaceFolders
          .map((folder) => {
            let result = folder.uri.toString();
            if (result.charAt(result.length - 1) !== '/') {
              result = result + '/';
            }
            return result;
          })
          .sort((a, b) => {
            return a.length - b.length;
          })
      : [];
  }
  return _sortedWorkspaceFolders;
}
workspace.onDidChangeWorkspaceFolders(
  () => (_sortedWorkspaceFolders = undefined)
);

function getOuterMostWorkspaceFolder(folder: WorkspaceFolder): WorkspaceFolder {
  const sorted = sortedWorkspaceFolders();
  for (const element of sorted) {
    let uri = folder.uri.toString();
    if (uri.charAt(uri.length - 1) !== '/') {
      uri = uri + '/';
    }
    if (uri.startsWith(element)) {
      const folder = workspace.getWorkspaceFolder(Uri.parse(element));
      if (folder) {
        return folder;
      }
    }
  }
  return folder;
}

export async function activate(context: ExtensionContext): Promise<void> {
  async function didOpenTextDocument(document: TextDocument): Promise<void> {
    if (
      document.uri.scheme !== 'file' &&
      document.uri.scheme !== 'untitled' &&
      document.uri.scheme !== 'vscode-vfs' &&
      document.languageId !== 'css' &&
      document.languageId !== 'scss' &&
      document.languageId !== 'sass'
    ) {
      return;
    }

    const uri = document.uri;
    // Untitled files go to a default client.
    if (uri.scheme === 'untitled' && !defaultClient) {
      defaultClient = new LanguageClient(
        'sass',
        'Sass',
        await createServerOptions(context),
        createLanguageClientOptions()
      );
      defaultClient.start();
      return;
    }

    let folder = workspace.getWorkspaceFolder(uri);
    // Require a workspace folder
    if (!folder) {
      return;
    }
    // If we have nested workspace folders we only start a server on the outer most workspace folder.
    folder = getOuterMostWorkspaceFolder(folder);
    if (!clients.has(folder.uri.toString())) {
      const client = new LanguageClient(
        'sass',
        'Sass',
        await createServerOptions(context),
        createLanguageClientOptions(folder)
      );

      clients.set(folder.uri.toString(), client);

      return await window.withProgress(
        {
          title: `[${folder.name}] Starting Sass language server`,
          location: ProgressLocation.Window,
        },
        async () => {
          try {
            client.registerProposedFeatures();
            await client.start();
          } catch (error: unknown) {
            await window.showErrorMessage(
              `Client initialization failed. ${
                (error as Error).stack ?? '<empty_stack>'
              }`
            );
          }
        }
      );
    }
  }

  workspace.onDidOpenTextDocument(didOpenTextDocument);
  workspace.textDocuments.forEach(didOpenTextDocument);
  workspace.onDidChangeWorkspaceFolders((event) => {
    for (const folder of event.removed) {
      const client = clients.get(folder.uri.toString());
      if (client) {
        clients.delete(folder.uri.toString());
        client.stop();
      }
    }
  });
}

export function deactivate(): Promise<void> {
  const promises: Thenable<void>[] = [];
  if (defaultClient) {
    promises.push(defaultClient.stop());
  }
  for (const client of clients.values()) {
    promises.push(client.stop());
  }
  return Promise.all(promises).then(() => undefined);
}
