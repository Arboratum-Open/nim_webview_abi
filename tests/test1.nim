# This is just an example to get you started. You may wish to put all of your
# tests into a single file, or separate them into multiple `test1`, `test2`
# etc. files (better names are recommended, just make sure the name starts with
# the letter 't').
#
# To run these tests, simply execute `nimble test`.

import unittest

import nim_webview_abi
import os

test "provide version information":
    let v = webview_version()
    echo v.version.repr
    check v.version.major == 0
    check v.version.minor >= 0
    check v.version.patch >= 0

test "create webview":
    var w = webview_create(1, nil);
    check w != nil
    
    check webview_set_title(w, "Basic Example") == 0
    check webview_set_size(w, 480, 320, WEBVIEW_HINT_NONE) == 0
    # check webview_navigate(w, "about:blank") == 0
    check webview_set_html(w, """
        <p>Thanks for using webview! Should stop in 3 second</p>
        <script>
            window.setTimeout(function() {
                window.terminate_test("hello", 4, 4.5);
            }, 3000);
            
        </script>
        """) == 0
#     check webview_navigate(w, "https://www.bing.com".cstring) == 0
#     check webview_eval(w, """
# document.body.innerHTML = '<h1>Hello, World!</h1>';
# """) == 0
    #check webview_set_html(w, "<p>Thanks for using webview!</p>".cstring) == 0
    echo "Running webview..."
    sleep(100)  # 100 milliseconds
    
    proc terminate_call(id: cstring; req: cstring; arg: pointer) {.cdecl, gcsafe, raises: [].} =
        echo "terminate_call args:", req
        discard webview_terminate(w)
    
    check webview_bind(w, "terminate_test", terminate_call, nil) == 0
    
    check webview_run(w) == 0
    
    echo "Webview closed."
    check webview_destroy(w) == 0