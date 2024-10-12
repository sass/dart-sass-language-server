# sass_language_server

A Dart implementation of a language server for Sass. The language server uses the Language Server Protocol (LSP).

## Building

```sh
dart compile exe bin/sass_language_server.dart -o bin/sass-language-server
```

### Testing the build executable

Add the built executable to your path.

Assuming:

1. `/usr/local/bin` is already on your path
2. your terminal is in the same directory as this README

Run:

```sh
sudo ln -s "$(pwd)/bin/sass-language-server" /usr/local/bin/sass-language-server
```

Then configure your editor to use `sass-language-server` over `stdio`.

Here is an example using the [Helix editor](https://docs.helix-editor.com/guides/adding_languages.html) (though [not all LSP features are supported in that editor](https://docs.helix-editor.com/languages.html), including links).

Open `.config/helix/languages.toml` and add this configuration.

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

The language server will start once you open an SCSS file.

## Server capabilities

<table>
	<caption style="visibility:hidden">Comparison of <code>vscode-css-languageservice</code> and <code>some-sass-language-service</code></caption>
	<thead>
		<tr>
			<th>Request</th>
			<th>Capability</th>
			<th>sass-language-server</th>
		</tr>
	</thead>
	<tbody>
		<tr>
			<th rowspan="2">
				<a href="https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#textDocument_codeAction">
					<code>textDocument/codeAction</code>
				</a>
			</th>
			<td>CSS code actions</td>
			<td></td>
		</tr>
		<tr>
			<td>Sass code actions</td>
			<td></td>
		</tr>
		<tr>
			<th rowspan="1">
				<a href="https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#textDocument_colorPresentation">
					<code>textDocument/colorPresentation</code>
				</a>
			</th>
			<td>Color picker for CSS colors</td>
			<td></td>
		</tr>
		<tr>
			<th rowspan="4">
				<a href="https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#textDocument_completion">
					<code>textDocument/completion</code>
				</a>
			</th>
			<td>CSS completions</td>
			<td></td>
		</tr>
		<tr>
			<td>Sass same-document completions</td>
			<td></td>
		</tr>
		<tr>
			<td>Sass workspace completions</td>
			<td></td>
		</tr>
		<tr>
			<td>SassDoc completions</td>
			<td></td>
		</tr>
		<tr>
			<th rowspan="2">
				<a href="https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#textDocument_definition">
					<code>textDocument/definition</code>
				</a>
			</th>
			<td>Same-document definition</td>
			<td></td>
		</tr>
		<tr>
			<td>Workspace definition</td>
			<td></td>
		</tr>
		<tr>
			<th rowspan="2">
				<a href="https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#textDocument_documentColor">
					<code>textDocument/documentColor</code>
				</a>
			</th>
			<td>CSS colors</td>
			<td></td>
		</tr>
		<tr>
			<td>Sass variable colors</td>
			<td></td>
		</tr>
		<tr>
			<th rowspan="1">
				<a href="https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#textDocument_documentHighlight">
					<code>textDocument/documentHighlight</code>
				</a>
			</th>
			<td>Highlight references in document</td>
			<td></td>
		</tr>
		<tr>
			<th rowspan="1">
				<a href="https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#textDocument_documentLink">
					<code>textDocument/documentLink</code>
				</a>
			</th>
			<td>Navigate to linked document</td>
			<td>✅</td>
		</tr>
		<tr>
			<th rowspan="1">
				<a href="https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#textDocument_documentSymbol">
					<code>textDocument/documentSymbol</code>
				</a>
			</th>
			<td>Go to symbol in document</td>
			<td></td>
		</tr>
		<tr>
			<th rowspan="1">
				<a href="https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#textDocument_foldingRange">
					<code>textDocument/foldingRange</code>
				</a>
			</th>
			<td>Code block folding</td>
			<td></td>
		</tr>
		<tr>
			<th rowspan="3">
				<a href="https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#textDocument_hover">
					<code>textDocument/hover</code>
				</a>
			</th>
			<td>CSS hover info</td>
			<td></td>
		</tr>
		<tr>
			<td>Sass hover info</td>
			<td></td>
		</tr>
		<tr>
			<td>SassDoc hover info</td>
			<td></td>
		</tr>
		<tr>
			<th rowspan="2">
				<a href="https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#textDocument_references">
					<code>textDocument/references</code>
				</a>
			</th>
			<td>CSS references</td>
			<td></td>
		</tr>
		<tr>
			<td>Sass references</td>
			<td></td>
		</tr>
		<tr>
			<th rowspan="2">
				<a href="https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#textDocument_rename">
					<code>textDocument/rename</code>
				</a>
			</th>
			<td>Same-document rename</td>
			<td></td>
		</tr>
		<tr>
			<td>Workspace rename</td>
			<td></td>
		</tr>
		<tr>
			<th rowspan="1">
				<a href="https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#textDocument_selectionRange">
					<code>textDocument/selectionRange</code>
				</a>
			</th>
			<td>Ranges for expand/shrink selection</td>
			<td></td>
		</tr>
		<tr>
			<th rowspan="1">
				<a href="https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#textDocument_signatureHelp">
					<code>textDocument/signatureHelp</code>
				</a>
			</th>
			<td>Sass function/mixin signature help</td>
			<td></td>
		</tr>
		<tr>
			<th rowspan="1">
				<a href="https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#workspace_symbol">
					<code>workspace/symbol</code>
				</a>
			</th>
			<td>Go to symbol in workspace</td>
			<td></td>
			<td></td>
		</tr>
	</tbody>
</table>
