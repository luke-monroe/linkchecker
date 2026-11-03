AI made this based on the original documentation

# LinkChecker: Complete Options Reference (CLI + `linkcheckerrc`)

> **Purpose:** Agent-oriented reference for every option that can be used with `linkchecker`, on the command line and in the `linkcheckerrc` configuration file.
> **Sources:** LinkChecker man pages `linkchecker(1)` and `linkcheckerrc(5)` (docs version 10.6.0.post53):
> - https://linkchecker.github.io/linkchecker/man/linkchecker.html
> - https://linkchecker.github.io/linkchecker/man/linkcheckerrc.html
>
> Sections marked **[Agent note]** or **[Recipe]** are practical guidance added to help build commands. They are derived from the documented behavior, not quoted from it. Where the docs are silent or ambiguous, this is flagged.

---

## Table of Contents

1. [Quick facts](#1-quick-facts)
2. [Synopsis and basic usage](#2-synopsis-and-basic-usage)
3. [Complete CLI option reference](#3-complete-cli-option-reference)
4. [CLI to `linkcheckerrc` mapping table](#4-cli-to-linkcheckerrc-mapping-table)
5. [`linkcheckerrc` file: format and location](#5-linkcheckerrc-file-format-and-location)
6. [`linkcheckerrc` settings by section](#6-linkcheckerrc-settings-by-section)
7. [Output types and per-type options](#7-output-types-and-per-type-options)
8. [Logger parts](#8-logger-parts)
9. [Regular expressions](#9-regular-expressions)
10. [Cookie files](#10-cookie-files)
11. [Proxy support and environment variables](#11-proxy-support-and-environment-variables)
12. [Plugins and their options](#12-plugins-and-their-options)
13. [Warnings catalog](#13-warnings-catalog)
14. [What gets checked (URL types, recursion, sitemaps)](#14-what-gets-checked)
15. [Exit codes](#15-exit-codes)
16. [Recipes](#16-recipes)
17. [Gotchas, precedence rules, and doc inconsistencies](#17-gotchas-precedence-rules-and-doc-inconsistencies)
18. [Agent decision guide](#18-agent-decision-guide)

---

## 1. Quick facts

| Item | Value |
|---|---|
| Command | `linkchecker` |
| Default config file (Unix) | `$XDG_CONFIG_HOME/linkchecker/linkcheckerrc`, else `~/.config/linkchecker/linkcheckerrc` |
| Default config file (Windows) | `%HOMEPATH%\.config\linkchecker\linkcheckerrc` |
| Config format | INI-style |
| Default recursion depth | Infinite |
| Default threads | 10 |
| Default connection timeout | 60 seconds |
| Default console output | `text`, errors and warnings only |
| Default file output | None |
| `failures` output file | `$XDG_DATA_HOME/linkchecker/failures` |
| Default file output name | `linkchecker-out.TYPE` |
| Regex flavor | Python regular expressions (leading `!` negates) |
| Exit codes | `0` OK, `1` invalid links (or warnings, if enabled), `2` program error |
| Checks external URLs by default? | **No.** Only internal links, unless `--check-extern` / `checkextern=1` |
| Respects `robots.txt` by default? | **Yes** (disable with `--no-robots`) |

**Features:** recursive and multithreaded checking; output as colored/plain text, HTML, SQL, CSV, XML, or sitemap graphs; HTTP/1.1, HTTPS, FTP, `mailto:`, and local file links; URL filters; proxy support; username/password auth for HTTP and FTP; `robots.txt`; cookies; HTML5; antivirus check; command-line and web interface.

---

## 2. Synopsis and basic usage

```
linkchecker [options] [file-or-url]...
```

### Input forms for `FILE-OR-URL`

- A URL (`https://example.com/`).
- A local file or directory path.
- A **URL list file**: a plain list of URLs, one per line, **if the first line is exactly `# LinkChecker URL list`**.
- A **sitemap** (detected if the `urlset`/`sitemapindex` tag is within the first 70 characters; compressed sitemaps are *not* supported).
- With `--stdin`: whitespace-separated URLs read from standard input.

### Shorthand rules for command-line URLs

- Starts with `www.` is treated as `http://www.…`
- Starts with `ftp.` is treated as `ftp://ftp.…`

### Basic examples (from the man page)

```bash
# Check a whole site recursively (can be thousands of URLs; consider -r)
linkchecker http://www.example.com/

# Skip URLs containing /secret (they are syntax-checked only)
linkchecker --ignore-url=/secret mysite.example.com

# Local HTML file (Unix)
linkchecker ../bla.html

# Skip the http:// part if the domain starts with www.
linkchecker www.example.com

# Skip the ftp:// part if the domain starts with ftp.  (-r0 = no recursion)
linkchecker -r0 ftp.example.com

# Generate a sitemap graph and render it with Graphviz
linkchecker -odot -v www.example.com | dot -Tps > sitemap.ps
```

---

## 3. Complete CLI option reference

### 3.1 General options

| Option | Argument | Default | Description |
|---|---|---|---|
| `-f FILENAME`, `--config=FILENAME` | file path | `$XDG_CONFIG_HOME/linkchecker/linkcheckerrc` | Use FILENAME as the configuration file. |
| `-h`, `--help` | none | n/a | Print usage information and exit. |
| `-t NUMBER`, `--threads=NUMBER` | integer | `10` | Maximum number of threads. A **non-positive number disables threading**. |
| `-V`, `--version` | none | n/a | Print version and exit. |
| `--list-plugins` | none | n/a | Print available check plugins (with their documentation) and exit. |

### 3.2 Output options

#### URL checking results

| Option | Argument | Default | Description |
|---|---|---|---|
| `-F TYPE[/ENCODING][/FILENAME]`, `--file-output=TYPE[/ENCODING][/FILENAME]` | see below | no file output | Write results to a file. **Can be given multiple times.** |
| `-o TYPE[/ENCODING]`, `--output=TYPE[/ENCODING]` | see below | `text` | Console output type. |
| `-v`, `--verbose` | none | off (errors + warnings only) | Log **all** checked URLs. Overrides `--no-warnings`. |
| `--no-warnings` | none | warnings are logged | Do not log warnings. |

**`-F` details**

- Default filename: `linkchecker-out.TYPE`; for the `failures` type: `$XDG_DATA_HOME/linkchecker/failures`; otherwise FILENAME if given.
- `ENCODING` sets the output encoding (default: your locale). Valid encodings: https://docs.python.org/library/codecs.html#standard-encodings
- For the `none` type, FILENAME and ENCODING are ignored.
- **If the file already exists it is overwritten.**
- Valid TYPEs: `text`, `html`, `sql`, `csv`, `gml`, `dot`, `xml`, `sitemap`, `none`, `failures`.
- Example: `-Fhtml/utf-8/report.html -Fcsv//results.csv` *(the empty ENCODING slot in the second example follows the documented `TYPE[/ENCODING][/FILENAME]` pattern; verify on your version if it matters)*.

**`-o` details**

- Valid TYPEs: `text`, `html`, `sql`, `csv`, `gml`, `dot`, `xml`, `sitemap`, `none`, `failures`.
- `-o none` suppresses **all** console output (useful with `-F`, or when only the exit code matters).
- By default only errors and warnings are logged; add `-v` for the full URL list, **especially when emitting sitemap/graph formats**.

#### Progress updates

| Option | Description |
|---|---|
| `--no-status` | Do not print URL check status (progress) messages. |

#### Application

| Option | Argument | Description |
|---|---|---|
| `-D STRING`, `--debug=STRING` | logger name | Print debug output for the given logger. Available loggers: `cmdline`, `checking`, `cache`, `plugin`, `all` (alias for every logger). **May be given multiple times.** |

#### Quiet

| Option | Description |
|---|---|
| `-q`, `--quiet` | Quiet operation. Alias for `-o none` that **also hides application information messages**. Only useful together with `-F`, otherwise no results are output at all. |

### 3.3 Checking options

| Option | Argument | Default | Description |
|---|---|---|---|
| `--cookiefile=FILENAME` | file path | none | Use initial cookie data from a file. Format: see [Cookie files](#10-cookie-files). |
| `--check-extern` | none | off (internal only) | Also check **external** URLs. |
| `--ignore-url=REGEX` | Python regex | none | URLs matching are **only syntax-checked** (not fetched). Repeatable. |
| `--no-follow-url=REGEX` | Python regex | none | URLs matching are **checked but not recursed into**. Repeatable. |
| `--no-robots` | none | robots.txt honored | Check URLs regardless of any `robots.txt`. |
| `-p`, `--password` | none (prompts) | none | Read a password from the console and use it for HTTP and FTP authorization. FTP default password is `anonymous@`; HTTP has no default. Pair with `-u`. |
| `-r NUMBER`, `--recursion-level=NUMBER` | integer | infinite | Max recursion depth. **Negative = infinite.** `-r0` = check only the given URL(s), no recursion. |
| `--timeout=NUMBER` | seconds | `60` | Connection-attempt timeout. |
| `-u STRING`, `--user=STRING` | username | none | Username for HTTP and FTP authorization. FTP default user is `anonymous`; HTTP has no default. Pair with `-p`. |
| `--user-agent=STRING` | string | `LinkChecker/X.Y` | `User-Agent` header sent to HTTP servers (e.g. `Mozilla/4.0`). |

### 3.4 Input options

| Option / Argument | Description |
|---|---|
| `--stdin` | Read whitespace-separated URLs to check from standard input. |
| `FILE-OR-URL` | Starting location(s). May be a URL, a file, or a URL-list file (first line `# LinkChecker URL list`). |

### 3.5 Complete flag index (alphabetical)

```
-D, --debug=STRING            -p, --password
-F, --file-output=TYPE[/ENC][/FILE]   -q, --quiet
-V, --version                 -r, --recursion-level=NUMBER
-f, --config=FILENAME         -t, --threads=NUMBER
-h, --help                    -u, --user=STRING
-o, --output=TYPE[/ENC]       -v, --verbose
--check-extern                --no-follow-url=REGEX
--cookiefile=FILENAME         --no-robots
--ignore-url=REGEX            --no-status
--list-plugins                --no-warnings
--stdin                       --timeout=NUMBER
                              --user-agent=STRING
```

---

## 4. CLI to `linkcheckerrc` mapping table

Many options exist in both places. **Some settings exist only in the config file** (marked "none" under CLI).

| CLI option | `linkcheckerrc` section | `linkcheckerrc` key |
|---|---|---|
| `--cookiefile` | `[checking]` | `cookiefile` |
| `-r`, `--recursion-level` | `[checking]` | `recursionlevel` |
| `-t`, `--threads` | `[checking]` | `threads` |
| `--timeout` | `[checking]` | `timeout` |
| `--user-agent` | `[checking]` | `useragent` |
| `--no-robots` | `[checking]` | `robotstxt` (set to `0`) |
| `--ignore-url` | `[filtering]` | `ignore` |
| `--no-follow-url` | `[filtering]` | `nofollow` |
| `--check-extern` | `[filtering]` | `checkextern` |
| `-u`, `-p` | `[authentication]` | `entry` |
| `-F`, `--file-output` | `[output]` | `fileoutput` |
| `-o`, `--output` | `[output]` | `log` |
| `-v`, `--verbose` | `[output]` | `verbose` |
| `--no-warnings` | `[output]` | `warnings` (set to `0`) |
| `--no-status` | `[output]` | `status` (set to `0`) |
| `-D`, `--debug` | `[output]` | `debug` |
| `-q`, `--quiet` | `[output]` | `quiet` |
| `-f`, `--config` | n/a | selects the file itself |
| `-h`, `-V`, `--list-plugins`, `--stdin` | n/a | CLI only |

### Config-file-only settings (no CLI equivalent)

`debugmemory`, `localwebroot`, `aborttimeout`, `sslverify`, `maxrunseconds`, `maxfilesizedownload`, `maxfilesizeparse`, `maxnumurls`, `maxrequestspersecond`, `allowedschemes`, `resultcachesize`, `ignorewarnings`, `ignorewarningsforurls`, `internlinks`, `loginurl`, `loginuserfield`, `loginpasswordfield`, `loginextrafields`, `ignoreerrors`, all per-output-type options (colors, separators, etc.), and **all plugin enablement and plugin options**.

---

## 5. `linkcheckerrc` file: format and location

- INI-style, with `[section]` headers and `key=value` lines.
- Default location: see [Quick facts](#1-quick-facts). Override with `-f FILENAME`.
- Booleans are written `0` or `1`.
- **Plugins** are enabled by the **mere presence** of their section (e.g. `[AnchorCheck]`).

### Multiline values

Some values (marked *MULTILINE* below) can span several lines. **Every continuation line must be indented.** Lines starting with `#` are comments and are ignored, but must also be indented.

```ini
[filtering]
ignore=
  lconline
  bookmark
  # a comment
  ^mailto:
```

### Minimal example (from the docs)

```ini
[output]
log=html

[checking]
threads=5

[filtering]
ignorewarnings=http-moved-permanent

[AnchorCheck]
```

> **[Agent note]** In this example the `AnchorCheck` plugin is enabled simply because its section appears. Also, `http-moved-permanent` is the warning name used in the official example; the warnings catalog in §13 lists the names documented on the current page (which does not include that name), so prefer names from §13 and confirm with your installed version.

---

## 6. `linkcheckerrc` settings by section

### 6.1 `[checking]`

| Key | Value | Default | Description | CLI equivalent |
|---|---|---|---|---|
| `cookiefile` | filename | none | File with initial cookie data. | `--cookiefile` |
| `debugmemory` | `0`/`1` | `0` (no file) | Write memory allocation stats to a file on exit. Requires [meliae](https://pypi.org/project/meliae/). | none |
| `localwebroot` | STRING | none | Root directory used as base URL when checking **absolute URLs inside local files**. Must be written in **URL syntax** (forward slashes) and **must end with a slash**. | none |
| `recursionlevel` | NUMBER | infinite | Max depth; negative = infinite. | `-r` |
| `threads` | NUMBER | `10` | Max threads; non-positive disables threading. | `-t` |
| `timeout` | NUMBER (s) | `60` | Connection timeout. | `--timeout` |
| `aborttimeout` | NUMBER (s) | `300` | Time to wait for checks to finish after the **first** user abort (Ctrl-C / abort button). | none |
| `useragent` | STRING | `LinkChecker/X.Y` | `User-Agent` header. | `--user-agent` |
| `sslverify` | `0` / `1` / filename | `1` | `0` disables SSL certificate verification; `1` enables it using the provided CA bundle; a filename uses that file as the CA certificate file. | none |
| `maxrunseconds` | NUMBER (s) | unlimited | Stop checking **new** URLs after this many seconds (equivalent to the user hitting Ctrl-C at that moment). | none |
| `maxfilesizedownload` | NUMBER (bytes) | `5242880` (5 MB) | Files larger than this are ignored; for HTTP, nothing is downloaded if an accurate `Content-Length` is returned. No more than this amount is ever downloaded. | none |
| `maxfilesizeparse` | NUMBER (bytes) | `1048576` (1 MB) | Files larger than this are **not parsed for links**. | none |
| `maxnumurls` | NUMBER | unlimited | Max number of URLs to check; no new URLs queued after the limit. | none |
| `maxrequestspersecond` | NUMBER | `10` | Max HTTP requests per second **per host**. Average rate is about one third of the max. Values `< 1` and `≥ 0.001` are allowed. **To use values > 10, the HTTP server must return a `LinkChecker` response header.** | none |
| `robotstxt` | `0`/`1` | `1` | Fetch `robots.txt` over HTTP and confirm each URL may be accessed before checking. | `--no-robots` |
| `allowedschemes` | `NAME[,NAME...]` | not documented | Allowed URL schemes, comma-separated. | none |
| `resultcachesize` | NUMBER | `100000` | Result cache size (number of URLs). | none |

### 6.2 `[filtering]`

| Key | Value | Description | CLI equivalent |
|---|---|---|---|
| `ignore` | REGEX (*MULTILINE*) | Only **syntax-check** URLs matching these regexes. | `--ignore-url` |
| `ignorewarnings` | `NAME[,NAME...]` | Ignore the listed warnings (see [§13](#13-warnings-catalog)). Messages are logged as **information**. | none |
| `ignorewarningsforurls` | `URL_REGEX [NAME_REGEX]` (*MULTILINE*) | One rule per line: ignore warnings for URLs matching `URL_REGEX`. If a second regex is given, only warnings whose **name** matches it are ignored; if omitted, **all** warnings for that URL are ignored. Default: ignore nothing. Messages logged as information. | none |
| `internlinks` | REGEX | Additional URLs to treat as **internal** links. By default, URLs given on the command line are internal. | none |
| `nofollow` | REGEX (*MULTILINE*) | Check but do **not recurse** into matching URLs. | `--no-follow-url` |
| `checkextern` | `0`/`1` | Check external links. Default: internal only. | `--check-extern` |

Example (`ignorewarningsforurls`):

```ini
[filtering]
ignorewarningsforurls=
  ^https://redirected\.example\.com ^http-redirected
```

### 6.3 `[authentication]`

| Key | Value | Default | Description |
|---|---|---|---|
| `entry` | `REGEX USER [PASS]` (*MULTILINE*) | none | Per-URL credentials. Whitespace-separated triple (URL regex, username, password) or pair (URL regex, username). If the password is omitted it must be entered on the command line. Supports multiple FTP and HTTP **Basic Auth** links. **First match wins.** CLI `-u`/`-p` match **every** link and therefore **override** these entries. |
| `loginurl` | URL | none | A login page to visit **before** checking. It must contain an HTML form that collects credentials and POSTs them to the form's `action`. The input `name` attributes and the values to submit must be known (see `entry` for username/password values). |
| `loginuserfield` | STRING | `login` | `name` attribute of the username input. |
| `loginpasswordfield` | STRING | `password` | `name` attribute of the password input. |
| `loginextrafields` | `NAME:VALUE` (*MULTILINE*) | none | Extra form fields and values to submit. Submitted **without checking** that matching inputs exist in the form. |

Examples:

```ini
[authentication]
entry=
  ^https://intranet\.example\.com/ alice s3cret
  ^ftp://files\.example\.com/      bob            # password prompted

# Form-based login
loginurl=https://example.com/login
loginuserfield=username
loginpasswordfield=passwd
loginextrafields=
  csrf_mode:off
  remember:1
```

> **[Agent note]** Avoid hard-coding real passwords in shared config files. The docs allow omitting the password so it can be entered interactively.

### 6.4 `[output]`

#### URL checking results

| Key | Value | Default | Description | CLI equivalent |
|---|---|---|---|---|
| `fileoutput` | `TYPE[,TYPE...]` | none | Write to `linkchecker-out.TYPE` (or the `failures` path for `failures`). Documented valid types here: `text`, `html`, `sql`, `csv`, `gml`, `dot`, `xml`, `none`, `failures`. | `-F` |
| `log` | `TYPE[/ENCODING]` | `text` | Console output type. Documented valid types here: `text`, `html`, `sql`, `csv`, `gml`, `dot`, `xml`, `none`, `failures`. | `-o` |
| `verbose` | `0`/`1` | `0` | Log **all** checked URLs once; overrides `warnings`. | `-v` |
| `warnings` | `0`/`1` | `1` | Log warnings. | `--no-warnings` |
| `ignoreerrors` | `URL_REGEX [MESSAGE_REGEX]` (*MULTILINE*) | none | Ignore **errors** for matching URLs. Optional second regex restricts to matching error messages. Unlike `[filtering]`, this happens **after** checking, so URLs are still checked despite expected/tolerable errors. | none |

Example (`ignoreerrors`):

```ini
[output]
ignoreerrors=
  ^https://deprecated\.example\.com ^410 Gone
  # ignore all errors (no second expression), also for syntax check:
  ^mailto:.*@example\.com$
```

#### Progress updates

| Key | Value | Default | Description | CLI equivalent |
|---|---|---|---|---|
| `status` | `0`/`1` | `1` | Print URL checker status messages. | `--no-status` |

#### Application

| Key | Value | Description | CLI equivalent |
|---|---|---|---|
| `debug` | `STRING[,STRING...]` | Debug loggers: `cmdline`, `checking`, `cache`, `plugin`, `all`. | `-D` |

#### Quiet

| Key | Value | Description | CLI equivalent |
|---|---|---|---|
| `quiet` | `0`/`1` | Alias for `log=none` that also hides application information messages. Only useful with `fileoutput`. | `-q` |

---

## 7. Output types and per-type options

Each output type has its own config section named after the type (e.g. `[text]`, `[html]`, `[csv]`). These per-type options are **config-file only**.

### 7.1 Overview of output types

| Type | Purpose |
|---|---|
| `text` | Standard logger; URLs in `keyword: argument` form. |
| `html` | Same keyword/argument layout as HTML, with links to referenced pages. Invalid URLs get HTML and CSS syntax-check links appended. |
| `csv` | One URL per line, CSV format. |
| `gml` | Parent-child relations between linked URLs as a **GML** sitemap graph. |
| `dot` | Parent-child relations as a **DOT** sitemap graph (pipe to Graphviz). |
| `gxml` | Check result as a **GraphXML** sitemap graph. |
| `xml` | Machine-readable XML. |
| `sitemap` | XML sitemap per https://www.sitemaps.org/protocol.html. |
| `sql` | SQL script with `INSERT` commands; an example table-creation script `create.sql` is included with LinkChecker. |
| `failures` | For **cron jobs**. Writes `$XDG_DATA_HOME/linkchecker/failures` containing only invalid URLs and **how many times they have failed**. |
| `none` | Logs nothing. For debugging or checking only the exit code. |

### 7.2 Options common to most types

Available in `[text]`, `[gml]`, `[dot]`, `[csv]`, `[sql]`, `[html]`, `[xml]`, `[gxml]`, `[sitemap]` (and `filename`/`encoding` only for `[failures]`):

| Key | Description |
|---|---|
| `filename=STRING` | Output filename. Default for `text` is `linkchecker-out.txt`. |
| `parts=STRING` | Comma-separated list of [logger parts](#8-logger-parts) to log. *(Not available for `failures`.)* |
| `encoding=STRING` | Output encoding (default: system locale). See Python's [standard encodings](https://docs.python.org/library/codecs.html#standard-encodings). |

### 7.3 `[text]` extras

| Key | Default | Description |
|---|---|---|
| `wraplength` | `65` | Characters at which each message line is wrapped. |
| `colorparent` | `white` | Parent color. |
| `colorurl` | `default` | URL color. |
| `colorname` | `default` | Name color. |
| `colorreal` | `cyan` | Real URL color. |
| `colorbase` | `purple` | Base URL color. |
| `colorvalid` | `bold;green` | Valid color. |
| `colorinvalid` | `bold;red` | Invalid color. |
| `colorinfo` | `default` | Info color. |
| `colorwarning` | `bold;yellow` | Warning color. |
| `colordltime` | `default` | Download time color. |
| `colorreset` | `default` | Reset color. |

**Color syntax:** `color` or `type;color`.
- **type:** `bold`, `light`, `blink`, `invert`
- **color:** `default`, `black`, `red`, `green`, `yellow`, `blue`, `purple`, `cyan`, `white`, and capitalized variants `Black`, `Red`, `Green`, `Yellow`, `Blue`, `Purple`, `Cyan`, `White`

### 7.4 `[csv]` extras

| Key | Default | Description |
|---|---|---|
| `separator` | `;` (semicolon) | CSV separator character. |
| `quotechar` | `"` (double quote) | CSV quote character. |
| `dialect` | `excel` | Output formatting; see https://docs.python.org/3/library/csv.html#csv.Dialect |

### 7.5 `[sql]` extras

| Key | Default | Description |
|---|---|---|
| `dbname` | `linksdb` | Database name to store into. |
| `separator` | `;` | SQL command separator character. |

### 7.6 `[html]` extras

| Key | Default | Description |
|---|---|---|
| `colorbackground` | `#fff7e5` | Background color. |
| `colorurl` | `#dcd5cf` | URL color. |
| `colorborder` | `#000000` | Border color. |
| `colorlink` | `#191c83` | Link color. |
| `colorwarning` | `#e0954e` | Warning color. |
| `colorerror` | `#db4930` | Error color. |
| `colorok` | `#3ba557` | Valid color. |

### 7.7 `[sitemap]` extras

| Key | Default | Description |
|---|---|---|
| `priority` | `1.0` for the first URL, `0.5` for all child URLs | Float between `0.0` and `1.0`. |
| `frequency` | `daily` | One of `always`, `hourly`, `daily`, `weekly`, `monthly`, `yearly`, `never`. |

### 7.8 `[failures]`

Only `filename` and `encoding` apply.

### 7.9 `[gml]`, `[dot]`, `[xml]`, `[gxml]`

Only `filename`, `parts`, `encoding` apply.

---

## 8. Logger parts

Used with the `parts=` key in output-type sections. Comma-separated.

| Part | Meaning |
|---|---|
| `all` | All parts |
| `id` | Unique ID for each log entry |
| `realurl` | The full URL link |
| `result` | Valid or invalid, with messages |
| `extern` | `1` or `0`; only reported in some logger types |
| `base` | `base href=...` |
| `name` | `<a href=...>name</a>` and `<img alt="name">` |
| `parenturl` | Parent URL, if any |
| `info` | Extra info, e.g. FTP welcome messages |
| `warning` | Warnings |
| `dltime` | Download time |
| `checktime` | Check time |
| `url` | The original URL name (may be relative) |
| `intro` | The blurb at the start ("starting at ...") |
| `outro` | The blurb at the end ("found x errors ...") |

Example:

```ini
[csv]
filename=results.csv
parts=url,realurl,result,parenturl,warning
separator=,
```

---

## 9. Regular expressions

- LinkChecker uses **Python regular expressions** (intro: https://docs.python.org/howto/regex.html).
- **Addition:** a **leading exclamation mark negates** the expression.
- Applies to: `--ignore-url`, `--no-follow-url`, config keys `ignore`, `nofollow`, `internlinks`, `ignorewarningsforurls`, `ignoreerrors`, `entry`, and the `RegexCheck` plugin's `warningregex`.

Examples:

```bash
# Ignore anything under /secret
linkchecker --ignore-url=/secret https://example.com/

# Ignore everything EXCEPT the docs section (negation with a leading !)
linkchecker --ignore-url='!^https://example\.com/docs/' https://example.com/
```

> **[Agent note]** The negation example is an application of the documented "leading `!` negates" rule. Quote regexes in the shell to protect `^`, `$`, `!`, `|`, `(`, `)`.

---

## 10. Cookie files

Used with `--cookiefile=FILENAME` or `cookiefile=` in `[checking]`.

A cookie file contains standard HTTP header (RFC 2616) style data:

| Name | Required | Meaning |
|---|---|---|
| `Host` | **Yes** | Domain the cookies are valid for. |
| `Path` | No | Path the cookies are valid for. Default `/`. |
| `Set-cookie` | **Yes** | Cookie name/value. May be repeated. |

**Entries are separated by a blank line.**

```
Host: example.com
Path: /hello
Set-cookie: ID="smee"
Set-cookie: spam="egg"

Host: example.org
Set-cookie: baggage="elitist"; comment="hologram"
```

The first entry sends two cookies to all URLs starting with `http://example.com/hello/`. The second sends one cookie to all URLs starting with `https://example.org/`.

---

## 11. Proxy support and environment variables

### Proxy

Set `http_proxy` / `https_proxy` to a URL of the form `http://[user:pass@]host[:port]`. LinkChecker also detects manual proxy settings of Internet Explorer on Windows; on a Mac, use Internet Config. Set `no_proxy` to a comma-separated list of domains to bypass the proxy.

```bash
export http_proxy="http://proxy.example.com:8080"
export http_proxy="http://user1:mypass@proxy.example.org:8081"   # with auth
```

```bat
C:\> set http_proxy=http://proxy.example.com:8080
```

### Environment variables

| Variable | Purpose |
|---|---|
| `http_proxy` | Default HTTP proxy server |
| `https_proxy` | Default HTTPS proxy server |
| `curl_ca_bundle` | Alternative certificate bundle for use with an **HTTPS proxy** |
| `no_proxy` | Comma-separated list of domains **not** contacted via a proxy |
| `LC_MESSAGES`, `LANG`, `LANGUAGE` | Output language |
| `XDG_CONFIG_HOME` | Base dir for the default `linkcheckerrc` |
| `XDG_DATA_HOME` | Base dir for the `failures` output file |

### Related files

| Path | Purpose |
|---|---|
| `$XDG_CONFIG_HOME/linkchecker/linkcheckerrc` | Default configuration file |
| `$XDG_DATA_HOME/linkchecker/failures` | Default `failures` logger output |
| `linkchecker-out.TYPE` | Default file-output name |

---

## 12. Plugins and their options

There are two plugin types:

- **Connection plugins:** run after a successful connection to the URL host.
- **Content plugins:** run if the URL type has content (e.g. `mailto:` has none) **and** the check is not forbidden (e.g. by `robots.txt`).

**All plugins are enabled via `linkcheckerrc`**, by adding a section with the plugin's name. There is no CLI switch to enable a plugin. List available plugins and their docs with `linkchecker --list-plugins`.

| Plugin | Section | Options | What it does / requirements |
|---|---|---|---|
| **AnchorCheck** | `[AnchorCheck]` | none | Validates HTML anchors (`#fragment`). For local files, URLs with anchors that point to directories (e.g. `example/#anchor`) are not supported; no such limit over http(s). |
| **LocationInfo** | `[LocationInfo]` | none | Adds country (and city if possible) of the URL host as info. Needs GeoIP or pygeoip plus a local country/city lookup DB. |
| **RegexCheck** | `[RegexCheck]` | `warningregex=REGEX` | Prints a warning if the regex matches any content of a **valid** page. Use for error-message pages, e.g. `(This page has moved\|Oracle Application error)`. Regex is **unquoted**. |
| **SslCertificateCheck** | `[SslCertificateCheck]` | `sslcertwarndays=NUMBER` | Checks SSL certificate expiry. Only **internal https:** links; each domain once to avoid duplicate warnings. `sslcertwarndays` sets the warning window in days. |
| **HtmlSyntaxCheck** | `[HtmlSyntaxCheck]` | none | Submits page URLs to the online W3C HTML validator (https://validator.w3.org/docs/api.html). **Currently broken and disabled.** |
| **HttpHeaderInfo** | `[HttpHeaderInfo]` | `prefixes=prefix1[,prefix2]...` | Prints HTTP headers in URL info. `prefixes` filters by header-name prefix, e.g. `X-`. |
| **CssSyntaxCheck** | `[CssSyntaxCheck]` | none | Submits stylesheet URLs to the online W3C CSS validator (https://jigsaw.w3.org/css-validator/manual.html#expert). If the validator can't reach the URL, no check and no warning. |
| **VirusCheck** | `[VirusCheck]` | `clamavconf=filename` | Scans page content with ClamAV (local `clamd` daemon required). `clamavconf` = path to `clamd.conf`. **Does not support ClamAV >= 1.0 and is disabled.** |
| **PdfParser** | `[PdfParser]` | none | Parses PDF files for URLs to check. Needs the `pdfminer.six` Python package. |
| **WordParser** | `[WordParser]` | none | Parses Word files for URLs to check. Needs the `pywin32` Python extension. |
| **MarkdownCheck** | `[MarkdownCheck]` | `filename_re=REGEX` | Parses Markdown files for URLs to check. `filename_re` matches names of Markdown files. |

Example:

```ini
[AnchorCheck]

[SslCertificateCheck]
sslcertwarndays=30

[HttpHeaderInfo]
prefixes=X-,Server

[RegexCheck]
warningregex=(This page has moved|Oracle Application error)

[MarkdownCheck]
filename_re=.*\.md$
```

> **[Agent note]** The `sslcertwarndays=30`, `prefixes=X-,Server`, and `filename_re=.*\.md$` values above are illustrative; the docs define the keys but give no defaults for them.

---

## 13. Warnings catalog

Names recognized by `ignorewarnings` and `ignorewarningsforurls`:

| Warning name | Meaning |
|---|---|
| `file-anchorcheck-directory` | A local directory with an anchor, not supported by AnchorCheck. |
| `file-missing-slash` | The `file:` URL is missing a trailing slash. |
| `file-system-path` | The `file:` path differs from the system-specific path. |
| `ftp-missing-slash` | The `ftp:` URL is missing a trailing slash. |
| `http-cookie-store-error` | Error while storing a cookie. |
| `http-empty-content` | The URL had no content. |
| `http-rate-limited` | Too many HTTP requests. |
| `http-redirected` | Redirected to a different URL. |
| `mail-no-mx-host` | The mail MX host could not be found. |
| `url-content-size-zero` | The URL content size is zero. |
| `url-content-too-large` | The URL content size is too large. |
| `url-content-type-unparseable` | The URL content type is not parseable. |
| `url-effective-url` | The effective URL differs from the original. |
| `url-error-getting-content` | Could not get the content of the URL. |
| `url-obfuscated-ip` | The IP is obfuscated. |
| `url-whitespace` | The URL has leading or trailing whitespace. |

Ignored warnings are **logged as information**, not discarded silently.

---

## 14. What gets checked

### 14.1 URL types and what "valid" means

All URLs first pass a **syntax test**. Minor quoting mistakes produce a *warning*; other invalid syntax is an *error*. Then the URL is queued for a connection check.

| Type | Behavior |
|---|---|
| **HTTP/HTTPS** (`http:`, `https:`) | Connects, requests path/query. **All redirects are followed.** Credentials are used if provided and needed. **Any final status other than 2xx is an error.** HTML content is checked for recursion. |
| **Local files** (`file:`) | A regular, readable, openable file is valid; a readable directory is valid. Device files, unreadable or missing files are errors. HTML and other parseable content is checked for recursion. |
| **Mail** (`mailto:`) | Resolves to a list of addresses; **if one fails, the whole list fails.** Per address: (1) syntax check both sides of `@`; (2) MX DNS lookup (error if none); (3) try SMTP connection to MX hosts, higher priority first (warning if none accept); (4) try `VRFY`; if answered, the verified address is printed as info. |
| **FTP** (`ftp:`) | (1) connect; (2) log in (default `anonymous` / `anonymous@`); (3) change to the directory; (4) list the file with `NLST`. |
| **Unsupported** (`javascript:` etc.) | Only a **warning**; no further checking. Full list in `linkcheck/checker/unknownurl.py`. JavaScript links are not supported. |

### 14.2 Recursion conditions (checked in this order)

1. URL must be valid.
2. URL must be **parseable**: currently HTML files, Opera bookmark files, and directories. If the type can't be determined (no common HTML extension and content doesn't look like HTML), it is assumed non-parseable.
3. Content must be retrievable (not `mailto:` or unknown types).
4. Max recursion level must not be exceeded (`-r` / `recursionlevel`).
5. URL must not match the ignore list (`--ignore-url` / `ignore`).
6. The Robots Exclusion Protocol must allow following links (a `nofollow` directive in HTML header data blocks it).

Directory recursion reads **all** files in the directory, not only `index.htm`.

### 14.3 Sitemaps

- Sitemaps are parsed for links to check.
- Detected from a `Sitemap:` entry in `robots.txt`, **or** when passed as `FILE-OR-URL` (then the `urlset`/`sitemapindex` tag must be within the first **70 characters**).
- **Compressed sitemap files are not supported.**

### 14.4 Limitations

- Memory is consumed **per queued URL**; thousands of queued URLs can use a lot of memory and slow the system. Use `-r`, `maxnumurls`, or `--ignore-url` to bound it.
- If the platform lacks threading support, threading is disabled automatically.
- If your system auto-dials the internet (e.g. diald), checking non-local links will trigger a connection; use `--ignore-url` to prevent this.

---

## 15. Exit codes

| Code | Meaning |
|---|---|
| `0` | No problems found. |
| `1` | Invalid links were found, **or** link warnings were found **and warnings are enabled**. |
| `2` | A program error occurred. |

> **[Agent note]** In CI, `--no-warnings` changes whether warnings alone produce exit code `1`. Combine `-o none` with the exit code for pass/fail-only checks.

---

## 16. Recipes

> **[Recipe]** All recipes below are composed from the documented options. Test on a small target first.

### 16.1 Shallow check of a single page

```bash
linkchecker -r1 https://example.com/page.html
```

### 16.2 Check only the given URL (no recursion)

```bash
linkchecker -r0 https://example.com/
```

### 16.3 Full site check including external links, saved to HTML and CSV

```bash
linkchecker --check-extern -Fhtml/utf-8/report.html -Fcsv//report.csv https://example.com/
```

### 16.4 Silent CI check (exit code only)

```bash
linkchecker -q -r2 https://example.com/ ; echo "exit=$?"
# or, equivalently for the console:
linkchecker -o none -r2 https://example.com/
```

### 16.5 CI check that writes a report but prints nothing

```bash
linkchecker -q -Ftext/utf-8/linkreport.txt https://example.com/
```

### 16.6 Be polite to a server (fewer threads, short timeout, custom UA)

```bash
linkchecker -t 2 --timeout 20 --user-agent "MySiteChecker/1.0" https://example.com/
```
Rate limiting per host is config-only:
```ini
[checking]
maxrequestspersecond=2
```

### 16.7 Ignore parts of the site / skip noisy URLs

```bash
linkchecker --ignore-url='^mailto:' --ignore-url='/private/' --no-follow-url='/archive/' https://example.com/
```

### 16.8 Check only a docs subtree (negated ignore)

```bash
linkchecker --ignore-url='!^https://example\.com/docs/' https://example.com/docs/
```

### 16.9 Check a list of URLs from stdin

```bash
printf '%s\n' https://example.com/a https://example.com/b | linkchecker --stdin -r0
```

### 16.10 Check a URL-list file

File `urls.txt` (**first line must be exactly this**):
```
# LinkChecker URL list
https://example.com/a
https://example.com/b
```
```bash
linkchecker -r0 urls.txt
```

### 16.11 Authenticated (Basic Auth / FTP) check

```bash
linkchecker -u alice -p https://intranet.example.com/    # prompts for password
```
Config alternative (per-URL):
```ini
[authentication]
entry=
  ^https://intranet\.example\.com/ alice
```

### 16.12 Form-login before checking

```ini
[authentication]
loginurl=https://example.com/login
loginuserfield=username
loginpasswordfield=password
loginextrafields=
  next:/dashboard
entry=
  ^https://example\.com/ alice
```
*(How `entry` credentials combine with `loginurl` is described in the docs only as "see **entry** for an explanation of username and password values"; confirm behavior on your version.)*

### 16.13 Sitemap graph via Graphviz

```bash
linkchecker -odot -v www.example.com | dot -Tps > sitemap.ps
```

### 16.14 Generate an XML sitemap file

```bash
linkchecker -v -Fsitemap/utf-8/sitemap.xml https://example.com/
```
Tune in config:
```ini
[sitemap]
priority=0.8
frequency=weekly
```

### 16.15 Cron job: track persistent failures

```bash
linkchecker -q -Ffailures https://example.com/
```
Writes `$XDG_DATA_HOME/linkchecker/failures` with invalid URLs and failure counts.

### 16.16 Limit runtime and scope for big sites

```ini
[checking]
maxrunseconds=600
maxnumurls=5000
recursionlevel=3
maxfilesizedownload=2097152
maxfilesizeparse=524288
```

### 16.17 Ignore expected errors and noisy warnings

```ini
[filtering]
ignorewarnings=url-effective-url
ignorewarningsforurls=
  ^https://redirected\.example\.com ^http-redirected

[output]
ignoreerrors=
  ^https://deprecated\.example\.com ^410 Gone
```

### 16.18 Behind a proxy

```bash
export http_proxy="http://proxy.example.com:8080"
export https_proxy="http://proxy.example.com:8080"
export no_proxy="localhost,intranet.example.com"
linkchecker https://example.com/
```

### 16.19 Self-signed or private-CA HTTPS

```ini
[checking]
sslverify=/path/to/ca-bundle.pem
# sslverify=0   # disables certificate checking entirely (insecure)
```

### 16.20 Check local files with absolute URLs rooted somewhere

```ini
[checking]
localwebroot=/var/www/html/
```
*(Must use forward slashes and end with `/`.)*

### 16.21 Check Markdown files for links

```ini
[MarkdownCheck]
filename_re=.*\.md$
```
```bash
linkchecker -f ./linkcheckerrc README.md
```

### 16.22 Use a project-local config file

```bash
linkchecker -f ./ci/linkcheckerrc https://example.com/
```

### 16.23 Debugging

```bash
linkchecker -D checking -D cache https://example.com/ 2> debug.log
linkchecker -D all https://example.com/
```
*(Debug output destination is not specified in the docs; redirecting stderr is a common precaution.)*

---

## 17. Gotchas, precedence rules, and doc inconsistencies

### Precedence and interaction rules

1. **`-v` overrides `--no-warnings`** (and `verbose=1` overrides `warnings`).
2. **`-u` / `-p` override every `entry=` rule** because they match all links. For `entry`, the **first match wins**.
3. **`-q` = `-o none` + hides application info messages.** With no `-F`, you get no results at all.
4. **`--ignore-url` / `ignore`** means *syntax-check only* (no fetch), not "skip entirely".
5. **`--no-follow-url` / `nofollow`** means *check the URL, but do not recurse into it*.
6. **`ignoreerrors`** (output) happens **after** checking; **`ignore`** (filtering) happens **before**.
7. **`-F` overwrites** existing files without asking.
8. **`-F` is repeatable;** `-o` selects one console type.
9. Without `--check-extern`, only **internal** links are checked (URLs on the command line define "internal"; extend with `internlinks`).
10. `-t` with a non-positive value **disables threading**; `-r` negative means **unlimited**.
11. Config keys use **inverted booleans** relative to some flags: `--no-robots` is `robotstxt=0`; `--no-warnings` is `warnings=0`; `--no-status` is `status=0`.
12. Plugin enablement is **config-only** and by **section presence**.

### Inconsistencies / things to verify on your installed version

- **Output type lists differ.** The CLI page lists `text, html, sql, csv, gml, dot, xml, sitemap, none, failures` for `-o`/`-F`. The `linkcheckerrc` page lists `text, html, sql, csv, gml, dot, xml, none, failures` for `log=`/`fileoutput=` (no `sitemap`) yet documents `[sitemap]` and `[gxml]` sections. `gxml` is described under "Output types" but is not in either option list. Run `linkchecker --help` to confirm what your build accepts.
- **`allowedschemes`**: the docs give no default and no further detail.
- **`HtmlSyntaxCheck`** and **`VirusCheck`** are documented as **broken/disabled** in this version.
- **`WordParser`** requires `pywin32` (Windows-oriented).
- **`maxrequestspersecond` > 10** requires the target server to send a `LinkChecker` response header, which is rarely true for third-party sites.
- The example warning name `http-moved-permanent` in the official example config does not appear in the documented warnings list; use names from [§13](#13-warnings-catalog).
- **Windows paths:** the rendered man page's Windows example appears garbled by escape processing; use a normal Windows path (e.g. `C:\path\to\file.html`).

---

## 18. Agent decision guide

Use this to translate user intent into options.

| User intent | Use |
|---|---|
| "Only check this one page" | `-r0` |
| "Check N levels deep" | `-r N` |
| "Also check outbound links" | `--check-extern` |
| "Skip these URLs" | `--ignore-url=REGEX` (repeat as needed) |
| "Check those URLs but don't crawl them" | `--no-follow-url=REGEX` |
| "Ignore robots.txt" | `--no-robots` (mind site owner's wishes) |
| "Be gentler on the server" | lower `-t`, set `maxrequestspersecond` in rc, raise/lower `--timeout` |
| "Pretend to be a browser" | `--user-agent="..."` |
| "Needs login (HTTP Basic/FTP)" | `-u` / `-p`, or `[authentication] entry=` |
| "Needs login (HTML form)" | `[authentication] loginurl` + field keys |
| "Needs cookies" | `--cookiefile=FILE` |
| "Need a report file" | `-F TYPE/ENC/FILE` (`html`, `csv`, `xml`, `text`, `sql`) |
| "Silent, just pass/fail" | `-o none` or `-q`, read exit code |
| "Quiet but keep a report" | `-q -F...` |
| "Show every URL, not only problems" | `-v` |
| "Hide warnings" | `--no-warnings` |
| "No progress noise" | `--no-status` |
| "Draw a site graph" | `-odot -v` (Graphviz) or `gml` / `gxml` |
| "Generate sitemap.xml" | `-v -Fsitemap/.../sitemap.xml` |
| "Track recurring broken links (cron)" | `-q -Ffailures` |
| "Check URLs from a pipeline" | `--stdin` |
| "Check URLs from a file" | URL-list file with `# LinkChecker URL list` header |
| "Validate #anchors" | `[AnchorCheck]` in rc |
| "Warn on expiring TLS certs" | `[SslCertificateCheck] sslcertwarndays=N` |
| "Flag pages containing error text" | `[RegexCheck] warningregex=...` |
| "Show certain HTTP headers" | `[HttpHeaderInfo] prefixes=...` |
| "Check links inside PDFs / Markdown / Word" | `[PdfParser]` / `[MarkdownCheck]` / `[WordParser]` |
| "Stop after X seconds / X URLs" | `maxrunseconds`, `maxnumurls` (rc only) |
| "Don't download huge files" | `maxfilesizedownload`, `maxfilesizeparse` (rc only) |
| "Ignore certificate problems" | `sslverify=0` (rc only; insecure) |
| "Expected 404/410 shouldn't fail the run" | `[output] ignoreerrors=` |
| "Silence a specific warning type" | `[filtering] ignorewarnings=` or `ignorewarningsforurls=` |
| "Debug what's happening" | `-D checking` / `-D all` |

### Safe default command template

```bash
linkchecker \
  -r 3 \
  -t 5 \
  --timeout 30 \
  --no-status \
  -F html/utf-8/linkcheck-report.html \
  https://example.com/
```

### Before running on a real site (agent checklist)

1. Confirm the **target** and that the user is entitled to crawl it.
2. Bound the crawl: set `-r`, and consider `maxnumurls` / `maxrunseconds` in rc.
3. Decide **internal-only vs `--check-extern`**.
4. Choose **output**: console type, `-F` files, and whether to use `-q`.
5. Handle **auth/cookies** without exposing secrets in shell history or shared files.
6. Interpret the **exit code** (`0` / `1` / `2`) correctly.
7. If a flag behaves unexpectedly, check [§17](#17-gotchas-precedence-rules-and-doc-inconsistencies) and `linkchecker --help`.

---

*End of reference.*