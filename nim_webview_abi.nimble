# Package
packageName   = "nim_webview_abi"
version       = "0.12.0.2"
author        = "Geoffrey Picron"
description   = "Nim low level binding to https://github.com/webview/webview.git"
license       = "Apache License 2.0 or MIT"
skipDirs     = @["examples", "tests", "build"]
skipFiles    = @["nim_webview_abi/wrap.nim", "update.sh"]


# Dependencies

requires "nim >= 1.4.0"
requires "nimterop >= 0.6.3"
