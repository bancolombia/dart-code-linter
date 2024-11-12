# Fix

added in: 1.2.0 <span style={{color: 'green'}}>style</span>

Fixes violations for lint rules that have a replacement.

To execute the command, run:

```sh
$ dart run dart_code_linter:metrics fix lib
```
info

You need to configure rules entry in the analysis_options.yaml to have a rules report included into the result.

Full command description:

```sh
Usage: dcl fix [arguments] <directories>
-h, --help                                       Print this usage information.


-r, --reporter=<console>                         The format of the output of the analysis.
                                                 [console (default), checkstyle, codeclimate, github, gitlab, json]
    --json-path=<path/to/file.json>              Path to the JSON file with the output of the analysis.


-c, --print-config                               Print resolved config.


    --root-folder=<./>                           Root folder.
                                                 (defaults to current directory)
    --sdk-path=<directory-path>                  Dart SDK directory path.
                                                 If the project has a `.fvm/flutter_sdk` symlink, it will be used if the SDK is not found. 
    --exclude=<{**/*.g.dart,**/*.freezed.dart}>  File paths in Glob syntax to be exclude.
                                                 (defaults to "{**/*.g.dart,**/*.freezed.dart}")


    --no-congratulate                            Don't show output even when there are no issues.


    --[no-]verbose                               Show verbose logs.


    --set-exit-on-violation-level=<warning> Set exit code 2 if code violations same or higher level than selected are detected.
                                                 [noted, warning, alarm]
                                                 
    --[no-]fatal-style                           Treat style level issues as fatal.
    --[no-]fatal-performance                     Treat performance level issues as fatal.
    --[no-]fatal-warnings                        Treat warning level issues as fatal.
                                                 (defaults to on)
```