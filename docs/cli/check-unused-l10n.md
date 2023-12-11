# Check Unused L10n
Checks unused Dart class members, that encapsulates the app's localized values.

An example of such class:
```dart
class ClassWithLocalization {
  String get title {
    return Intl.message(
      'Hello World',
      name: 'title',
      desc: 'Title for the Demo application',
      locale: localeName,
    );
  }
}
```
Read more about this localization approach [in the Flutter docs](https://flutter.dev/docs/development/accessibility-and-localization/internationalization#defining-a-class-for-the-apps-localized-resources).

:::info
By default the command searches for classes that end with `I18n`, but you can override this behavior with `--class-pattern` argument.
:::

To execute the command, run:
```sh
$ linter check-unused-l10n lib # or linter ul lib
```
Full command description:
```sh
Usage: dcl check-unused-l10n [arguments] <directories>
-h, --help                                       Print this usage information.


-p, --class-pattern=<I18n$>                      The pattern to detect classes providing localization
                                                 (defaults to "I18n$")


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


    --[no-]fatal-unused                          Treat find unused l10n as fatal.
                                                 (defaults to on)
```

## Output example
### Console
Use `--reporter=console` to enable this format.

<!-- ![Analysis completed](/static/img/cli/analysis-completed.png)
 -->
### JSON
The reporter prints a single JSON object containing meta information and the unused file paths. Use `--reporter=json` to enable this format.

#### The root object fields are

- `formatVersion` - an integer representing the format version (will be incremented each time the serialization format changes)
- `timestamp` - a creation time of the report in YYYY-MM-DD HH:MM:SS format
- `unusedLocalizations` - an array of [unused files](#the-unusedlocalizations-object-fields-are)
```dart
{
  "formatVersion": 2,
  "timestamp": "2021-04-11 14:44:42",
  "unusedLocalizations": [
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
#### The unusedLocalizations object fields are
- `path` - a relative path of the unused file
- `className` - a name of the class that has unused members
- `issues` - an array of [issues](#the-issue-object-fields-are) detected in the target class
```dart
{
  "path": "lib/src/some/class.dart",
  "className": "class",
  "issues": [
    ...
  ],
}
```
#### The issue object fields are
- `memberName` - unused class member name
- `offset` - a zero-based offset of the class member location in the source
- `line` - a zero-based line of the class member location in the source
- `column` - a zero-based column of class member the location in the source
```dart
{
  "memberName": "someGetter",
  "offset": 156,
  "line": 7,
  "column": 1
}
```
## GitLab
Reports unused l10n issues in merge requests based on Code Quality custom tool. Use `--reporter=gitlab` to enable this format.
