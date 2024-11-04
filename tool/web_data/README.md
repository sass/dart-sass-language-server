# Web data

Generates Dart code with CSS and HTML data used by the Sass language services.
The data source is [`@vscode/custom-web-data`](https://www.npmjs.com/package/@vscode/web-custom-data)
which gathers and transforms data from MDN and Chrome for attribute relevance.

To generate updated Dart code:

- Update the version in `package.json`.
- Run `npm install`.
- Run `npm start`.

Commit the updated `package.json` and Dart files.
