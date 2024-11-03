import { window, workspace, WorkspaceFolder } from 'vscode';
import {
  DocumentSelector,
  LanguageClientOptions,
  RevealOutputChannelOn,
} from 'vscode-languageclient';

const output = window.createOutputChannel('sass');

export function log(message: string): void {
  output.appendLine(message);
}

export function createLanguageClientOptions(
  currentWorkspace?: WorkspaceFolder
): LanguageClientOptions {
  let documentSelector: DocumentSelector = [
    { scheme: 'untitled', language: 'css' },
    { scheme: 'untitled', language: 'scss' },
    { scheme: 'untitled', language: 'sass' },
  ];

  if (currentWorkspace) {
    /**
     * The workspace path is used to separate clients in multi-workspace environment.
     * Otherwise, each client will participate in each workspace.
     */
    const pattern = `${currentWorkspace.uri.fsPath.replace(/\\/g, '/')}}/**`;
    documentSelector = [
      { scheme: 'file', language: 'css', pattern },
      { scheme: 'file', language: 'scss', pattern },
      { scheme: 'file', language: 'sass', pattern },
      { scheme: 'vscode-vfs', language: 'css', pattern },
      { scheme: 'vscode-vfs', language: 'scss', pattern },
      { scheme: 'vscode-vfs', language: 'sass', pattern },
    ];
  }

  const clientOptions: LanguageClientOptions = {
    documentSelector,
    synchronize: {
      configurationSection: ['sass', 'editor'],
      fileEvents: currentWorkspace
        ? workspace.createFileSystemWatcher({
            baseUri: currentWorkspace.uri,
            base: currentWorkspace.uri.fsPath,
            pattern: '**/*.{css,scss,sass}',
          })
        : undefined,
    },
    diagnosticCollectionName: 'sass',
    outputChannel: output,
    revealOutputChannelOn: RevealOutputChannelOn.Never,
  };

  return clientOptions;
}
