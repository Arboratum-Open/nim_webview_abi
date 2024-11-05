# Copyright 2024 Geoffrey Picron.
# SPDX-License-Identifier: (MIT or Apache-2.0)

import nimterop/cimport

static:
  cIncludeDir(@["webview/core/include"])
  cAddSearchDir("webview/core/include")

cImport("webview/core/include/webview.h", recurse=true, flags="-H", nimfile="webview_gen.nim")


#{.passL: "-lpthread".}
