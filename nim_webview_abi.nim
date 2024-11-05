# Copyright 2024 Geoffrey Picron.
# SPDX-License-Identifier: (MIT or Apache-2.0)

import nim_webview_abi/webview_gen

export webview_gen

{.passC: "-DWEBVIEW_STATIC -DWEBVIEW_IMPLEMENTATION".}
{.compile: "nim_webview_abi/webview/core/src/webview.cc".}