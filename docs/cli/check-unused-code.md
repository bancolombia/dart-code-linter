# Check Unused Code

Checks unused classes, fields, properties, methods, functions, variables, extensions, enums, mixins and type aliases.

To execute the command, run:
```sh
$ dcm check-unused-code lib # or dcm uc lib
```
Full command description:
```sh
Usage: dcm check-unused-code [arguments] <directories>
-h, --help                                       Print this usage information.


-r, --reporter=<console>                         The format of the output of the analysis.
                                                 [console (default), codeclimate, json, gitlab]


-c, --print-config                               Print resolved config.


    --root-folder=<./>                           Root folder.
                                                 (defaults to current directory)
    --sdk-path=<directory-path>                  Dart SDK directory path.
                                                 If the project has a `.fvm/flutter_sdk` symlink, it will be used if the SDK is not found.
    --exclude=<{**/*.g.dart,**/*.freezed.dart}>  File paths in Glob syntax to be exclude.
                                                 (defaults to "{**/*.g.dart,**/*.freezed.dart}")


    --no-congratulate                            Don't show output even when there are no issues.


    --[no-]verbose                               Show verbose logs.


    --ci-key                                     The license key to run on CI server. Can be provided via DCM_CI_KEY env variable.
    --email                                      The email used to purchase the license. Can be provided via DCM_EMAIL env variable.


    --no-analytics                               Disable sending anonymous usage statistics.


    --[no-]monorepo                              Treat all exported code as unused by default.


    --[no-]fatal-unused                          Treat find unused code as fatal.
                                                 (defaults to on)
```

## Suppressing the command

In order to suppress the command add the `ignore: unused-code` comment. To suppress for an entire file add `ignore_for_file: unused-code` to the beginning of a file.

## Monorepo support

:::caution
By default this command treats all code that is exported from the package as used. It uses `check-exports-completeness` results and won't report even transitive public entities that are not exported directly.

This command also follows this [convention](https://dart.dev/tools/pub/package-layout#implementation-files) of locating implementation files in the `lib/src/` folder. If you don't follow this convention, you will need to pass the `--monorepo` flag for this command to work.
:::

To disable this behavior use `--monorepo` flag. This might be useful when all the packages in your repository are only used within the repository and are not published to the pub.

## Output example
### Console

Use `--reporter=console` to enable this format.

![console](/console2.png)

### JSON

The reporter prints a single JSON object containing meta information and the unused code file paths. Use `--reporter=json` to enable this format.

#### The root object fields are

- `formatVersion` - an integer representing the format version (will be incremented each time the serialization format changes)
- `timestamp` - a creation time of the report in YYYY-MM-DD HH:MM:SS format
- `unusedCode` - an array of unused code issues

```json
{
  "formatVersion": 2,
  "timestamp": "2021-04-11 14:44:42",
  "unusedCode": [
    {
      ...
    },
    {
      ...
    },
    {
      ...
    }
  ]
}
```

#### The unusedCode object fields are

- `path` - a relative path of the unused file
- `issues` - an array of issues detected in the target file

```json
{
  "path": "lib/src/some/file.dart",
  "issues": [
    ...
  ],
}
```

#### The issue object fields are

- `declarationType` - unused declaration type
- `declarationName` - unused declaration name
- `offset` - a zero-based offset of the class member location in the source
- `line` - a zero-based line of the class member location in the source
- `column` - a zero-based column of class member the location in the source

```json
{
  "declarationType": "extension",
  "declarationName": "StringX",
  "offset": 156,
  "line": 7,
  "column": 1
}
```

### GitLab
Reports unused code issues in merge requests based on Code Quality custom tool. Use `--reporter=gitlab` to enable this format.
