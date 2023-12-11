# Check Unused Files

Checks unused `*.dart` files.

To execute the command, run:
```sh
$ linter check-unused-files lib # or linter uf lib
```
Full command description:
```sh
Usage: linter check-unused-files [arguments...] <directories>
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


    --no-analytics                               Disable sending anonymous usage statistics.


    --[no-]monorepo                              Treat all exported files as unused by default.


    --[no-]fatal-unused                          Treat find unused file as fatal.
                                                 (defaults to on)


-d, --[no-]delete-files                          Delete all unused files.

```
## Suppressing the command
In order to suppress the command add `ignore_for_file: unused-files` to the beginning of a file.

## Cyclic usage detection
If you have several files that reference each other, but are not referenced by other files and technically are unused, the command will only detect 1 level of cyclic usage.

## Monorepo support
:::caution
By default the command treats all files that are exported from the package as used. It uses `check-exports-completeness` results and won't report even transitive public entities that are not exported directly.
:::

To disable this behavior use `--monorepo` flag. This might be useful when all the packages in your repository are only used within the repository and are not published to the pub.

## Output example
### Console
Use `--reporter=console` to enable this format.


<!-- ![Analysis completed](/static/cli/analysis-completed-files.png) -->

JSON
The reporter prints a single JSON object containing meta information and the unused file paths. Use `--reporter=json` to enable this format.

The root object fields are
- `formatVersion` - an integer representing the format version (will be incremented each time the serialization format changes)
- `timestamp` - a creation time of the report in YYYY-MM-DD HH:MM:SS format
- `unusedFiles` - an array of [unused files](#the-unusedfiles-object-fields-are)
- `automaticallyDeleted` - an indication of unused files being automatically deleted

```json
{
  "formatVersion": 2,
  "timestamp": "2021-04-11 14:44:42",
  "unusedFiles": [
    {
      ...
    },
    {
      ...
    },
    {
      ...
    }
  ],
  "automaticallyDeleted": false
}
```
#### The unusedFiles object fields are
- `path` - a relative path of the unused file
```json
{
  "path": "lib/src/some/file.dart",
}
```
# GitLab
Reports unused file issues in merge requests based on Code Quality custom tool. Use `--reporter=gitlab` to enable this format.
