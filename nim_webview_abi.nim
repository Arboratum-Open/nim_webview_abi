# Copyright 2024 Geoffrey Picron.
# SPDX-License-Identifier: (MIT or Apache-2.0)

import nim_webview_abi/webview_gen
import std/paths
export webview_gen

when defined(macosx):
    {.passL: "-framework AppKit".}
    {.passL: "-framework WebKit".}
    {.passL: "-framework Cocoa".}
    {.passL: "-framework Foundation".}

const includePath = currentSourcePath().Path.parentDir() / "nim_webview_abi/webview/core/include".Path
{.passC: "-I" & includePath.string .}
{.passC: "-DWEBVIEW_STATIC -DWEBVIEW_IMPLEMENTATION".}
{.compile: "nim_webview_abi/webview/core/src/webview.cc".}