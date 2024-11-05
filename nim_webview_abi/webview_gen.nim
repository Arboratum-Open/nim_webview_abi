# Command line:
#   ~/.nimble/pkgs/nimterop-#head/nimterop/toast --preprocess -m:c --recurse -H --includeDirs+=nim_webview_abi/webview/core/include --pnim --nim:nim nim_webview_abi/webview/core/include/webview.h -o nim_webview_abi/webview_gen.nim

# const 'WEBVIEW_API' has unsupported value 'extern'
# const 'WEBVIEW_VERSION_NUMBER' has unsupported value 'WEBVIEW_EXPAND_AND_STRINGIFY(WEBVIEW_VERSION_MAJOR) "." WEBVIEW_EXPAND_AND_STRINGIFY( WEBVIEW_VERSION_MINOR) "." WEBVIEW_EXPAND_AND_STRINGIFY(WEBVIEW_VERSION_PATCH)'
{.push hint[ConvFromXtoItselfNotNeeded]: off.}
import macros

macro defineEnum(typ: untyped): untyped =
  result = newNimNode(nnkStmtList)

  # Enum mapped to distinct cint
  result.add quote do:
    type `typ`* = distinct cint

  for i in ["+", "-", "*", "div", "mod", "shl", "shr", "or", "and", "xor", "<", "<=", "==", ">", ">="]:
    let
      ni = newIdentNode(i)
      typout = if i[0] in "<=>": newIdentNode("bool") else: typ # comparisons return bool
    if i[0] == '>': # cannot borrow `>` and `>=` from templates
      let
        nopp = if i.len == 2: newIdentNode("<=") else: newIdentNode("<")
      result.add quote do:
        proc `ni`*(x: `typ`, y: cint): `typout` = `nopp`(y, x)
        proc `ni`*(x: cint, y: `typ`): `typout` = `nopp`(y, x)
        proc `ni`*(x, y: `typ`): `typout` = `nopp`(y, x)
    else:
      result.add quote do:
        proc `ni`*(x: `typ`, y: cint): `typout` {.borrow.}
        proc `ni`*(x: cint, y: `typ`): `typout` {.borrow.}
        proc `ni`*(x, y: `typ`): `typout` {.borrow.}
    result.add quote do:
      proc `ni`*(x: `typ`, y: int): `typout` = `ni`(x, y.cint)
      proc `ni`*(x: int, y: `typ`): `typout` = `ni`(x.cint, y)

  let
    divop = newIdentNode("/")   # `/`()
    dlrop = newIdentNode("$")   # `$`()
    notop = newIdentNode("not") # `not`()
  result.add quote do:
    proc `divop`*(x, y: `typ`): `typ` = `typ`((x.float / y.float).cint)
    proc `divop`*(x: `typ`, y: cint): `typ` = `divop`(x, `typ`(y))
    proc `divop`*(x: cint, y: `typ`): `typ` = `divop`(`typ`(x), y)
    proc `divop`*(x: `typ`, y: int): `typ` = `divop`(x, y.cint)
    proc `divop`*(x: int, y: `typ`): `typ` = `divop`(x.cint, y)

    proc `dlrop`*(x: `typ`): string {.borrow.}
    proc `notop`*(x: `typ`): `typ` {.borrow.}


{.experimental: "codeReordering".}
when (NimMajor, NimMinor) < (1, 4):
  {.pragma: wvdecl, cdecl, gcsafe, raises: [Defect].}
else:
  {.pragma: wvdecl, cdecl, gcsafe, raises: [].}
defineEnum(webview_native_handle_kind_t) ## ```
                                         ##   / Native handle kind. The actual type depends on the backend.
                                         ## ```
defineEnum(webview_hint_t)   ## ```
                             ##   / Window size hints
                             ## ```
defineEnum(webview_error_t) ## ```
                            ##   / @name Errors
                            ##     / @{
                            ##     
                            ##    @brief Error codes returned to callers of the API.
                            ##   
                            ##    The following codes are commonly used in the library:
                            ##    - @c WEBVIEW_ERROR_OK
                            ##    - @c WEBVIEW_ERROR_UNSPECIFIED
                            ##    - @c WEBVIEW_ERROR_INVALID_ARGUMENT
                            ##    - @c WEBVIEW_ERROR_INVALID_STATE
                            ##   
                            ##    With the exception of @c WEBVIEW_ERROR_OK which is normally expected,
                            ##    the other common codes do not normally need to be handled specifically.
                            ##    Refer to specific functions regarding handling of other codes.
                            ## ```
const
  WEBVIEW_VERSION_MAJOR* = 0
  WEBVIEW_VERSION_MINOR* = 12
  WEBVIEW_VERSION_PATCH* = 0
  WEBVIEW_VERSION_PRE_RELEASE* = ""
  WEBVIEW_VERSION_BUILD_METADATA* = ""
  WEBVIEW_NATIVE_HANDLE_KIND_UI_WINDOW* = (0).webview_native_handle_kind_t ## ```
                                                                           ##   / Top-level window. @c GtkWindow pointer (GTK), @c NSWindow pointer (Cocoa)
                                                                           ##     / or @c HWND (Win32).
                                                                           ## ```
  WEBVIEW_NATIVE_HANDLE_KIND_UI_WIDGET* = (
      WEBVIEW_NATIVE_HANDLE_KIND_UI_WINDOW + 1).webview_native_handle_kind_t ## ```
                                                                             ##   / Browser widget. @c GtkWidget pointer (GTK), @c NSView pointer (Cocoa) or
                                                                             ##     / @c HWND (Win32).
                                                                             ## ```
  WEBVIEW_NATIVE_HANDLE_KIND_BROWSER_CONTROLLER* = (
      WEBVIEW_NATIVE_HANDLE_KIND_UI_WIDGET + 1).webview_native_handle_kind_t ## ```
                                                                             ##   / Browser controller. @c WebKitWebView pointer (WebKitGTK), @c WKWebView
                                                                             ##     / pointer (Cocoa/WebKit) or @c ICoreWebView2Controller pointer
                                                                             ##     / (Win32/WebView2).
                                                                             ## ```
  WEBVIEW_HINT_NONE* = (0).webview_hint_t ## ```
                                          ##   / Width and height are default size.
                                          ## ```
  WEBVIEW_HINT_MIN* = (WEBVIEW_HINT_NONE + 1).webview_hint_t ## ```
                                                             ##   / Width and height are minimum bounds.
                                                             ## ```
  WEBVIEW_HINT_MAX* = (WEBVIEW_HINT_MIN + 1).webview_hint_t ## ```
                                                            ##   / Width and height are maximum bounds.
                                                            ## ```
  WEBVIEW_HINT_FIXED* = (WEBVIEW_HINT_MAX + 1).webview_hint_t ## ```
                                                              ##   / Window size can not be changed by a user.
                                                              ## ```
  WEBVIEW_ERROR_MISSING_DEPENDENCY* = (-5).webview_error_t ## ```
                                                           ##   / Missing dependency.
                                                           ## ```
  WEBVIEW_ERROR_CANCELED* = (-4).webview_error_t ## ```
                                                 ##   / Operation canceled.
                                                 ## ```
  WEBVIEW_ERROR_INVALID_STATE* = (-3).webview_error_t ## ```
                                                      ##   / Invalid state detected.
                                                      ## ```
  WEBVIEW_ERROR_INVALID_ARGUMENT* = (-2).webview_error_t ## ```
                                                         ##   / One or more invalid arguments have been specified e.g. in a function call.
                                                         ## ```
  WEBVIEW_ERROR_UNSPECIFIED* = (-1).webview_error_t ## ```
                                                    ##   / An unspecified error occurred. A more specific error code may be needed.
                                                    ## ```
  WEBVIEW_ERROR_OK* = (0).webview_error_t ## ```
                                          ##   / OK/Success. Functions that return error codes will typically return this
                                          ##     / to signify successful operations.
                                          ## ```
  WEBVIEW_ERROR_DUPLICATE* = (1).webview_error_t ## ```
                                                 ##   / Signifies that something already exists.
                                                 ## ```
  WEBVIEW_ERROR_NOT_FOUND* = (2).webview_error_t ## ```
                                                 ##   / Signifies that something does not exist.
                                                 ## ```
type
  webview_version_t* {.bycopy.} = object ## ```
                                          ##   / @}
                                          ##     / Holds the elements of a MAJOR.MINOR.PATCH version number.
                                          ## ```
    major*: cuint            ## ```
                             ##   / Major version.
                             ## ```
    minor*: cuint            ## ```
                             ##   / Minor version.
                             ## ```
    patch*: cuint            ## ```
                             ##   / Patch version.
                             ## ```
  
  webview_version_info_t* {.bycopy.} = object ## ```
                                               ##   / Holds the library's version information.
                                               ## ```
    version*: webview_version_t ## ```
                                ##   / The elements of the version number.
                                ## ```
    version_number*: array[32, cchar] ## ```
                                      ##   / SemVer 2.0.0 version number in MAJOR.MINOR.PATCH format.
                                      ## ```
    pre_release*: array[48, cchar] ## ```
                                   ##   / SemVer 2.0.0 pre-release labels prefixed with "-" if specified, otherwise
                                   ##     / an empty string.
                                   ## ```
    build_metadata*: array[48, cchar] ## ```
                                      ##   / SemVer 2.0.0 build metadata prefixed with "+", otherwise an empty string.
                                      ## ```
  
  webview_t* = pointer       ## ```
                             ##   / Pointer to a webview instance.
                             ## ```
proc webview_create*(debug: cint; window: pointer): webview_t {.importc, wvdecl.}
  ## ```
                                                                                ##   / @}
                                                                                ##     
                                                                                ##    Creates a new webview instance.
                                                                                ##   
                                                                                ##    @param debug Enable developer tools if supported by the backend.
                                                                                ##    @param window Optional native window handle, i.e. @c GtkWindow pointer
                                                                                ##           @c NSWindow pointer (Cocoa) or @c HWND (Win32). If non-null,
                                                                                ##           the webview widget is embedded into the given window, and the
                                                                                ##           caller is expected to assume responsibility for the window as
                                                                                ##           well as application lifecycle. If the window handle is null,
                                                                                ##           a new window is created and both the window and application
                                                                                ##           lifecycle are managed by the webview instance.
                                                                                ##    @remark Win32: The function also accepts a pointer to @c HWND (Win32) in the
                                                                                ##            window parameter for backward compatibility.
                                                                                ##    @remark Win32/WebView2: @c CoInitializeEx should be called with
                                                                                ##            @c COINIT_APARTMENTTHREADED before attempting to call this function
                                                                                ##            with an existing window. Omitting this step may cause WebView2
                                                                                ##            initialization to fail.
                                                                                ##    @return @c NULL on failure. Creation can fail for various reasons such
                                                                                ##            as when required runtime dependencies are missing or when window
                                                                                ##            creation fails.
                                                                                ##    @retval WEBVIEW_ERROR_MISSING_DEPENDENCY
                                                                                ##            May be returned if WebView2 is unavailable on Windows.
                                                                                ## ```
proc webview_destroy*(w: webview_t): webview_error_t {.importc, wvdecl.}
  ## ```
                                                                       ##   Destroys a webview instance and closes the native window.
                                                                       ##   
                                                                       ##    @param w The webview instance.
                                                                       ## ```
proc webview_run*(w: webview_t): webview_error_t {.importc, wvdecl.}
  ## ```
                                                                   ##   Runs the main loop until it's terminated.
                                                                   ##   
                                                                   ##    @param w The webview instance.
                                                                   ## ```
proc webview_terminate*(w: webview_t): webview_error_t {.importc, wvdecl.}
  ## ```
                                                                         ##   Stops the main loop. It is safe to call this function from another other
                                                                         ##    background thread.
                                                                         ##   
                                                                         ##    @param w The webview instance.
                                                                         ## ```
proc webview_dispatch*(w: webview_t;
                       fn: proc (w: webview_t; arg: pointer) {.wvdecl.};
                       arg: pointer): webview_error_t {.importc, wvdecl.}
  ## ```
                                                                        ##   Schedules a function to be invoked on the thread with the run/event loop.
                                                                        ##    Use this function e.g. to interact with the library or native handles.
                                                                        ##   
                                                                        ##    @param w The webview instance.
                                                                        ##    @param fn The function to be invoked.
                                                                        ##    @param arg An optional argument passed along to the callback function.
                                                                        ## ```
proc webview_get_window*(w: webview_t): pointer {.importc, wvdecl.}
  ## ```
                                                                  ##   Returns the native handle of the window associated with the webview instance.
                                                                  ##    The handle can be a @c GtkWindow pointer (GTK), @c NSWindow pointer (Cocoa)
                                                                  ##    or @c HWND (Win32).
                                                                  ##   
                                                                  ##    @param w The webview instance.
                                                                  ##    @return The handle of the native window.
                                                                  ## ```
proc webview_get_native_handle*(w: webview_t; kind: webview_native_handle_kind_t): pointer {.
    importc, wvdecl.}
  ## ```
                    ##   Get a native handle of choice.
                    ##   
                    ##    @param w The webview instance.
                    ##    @param kind The kind of handle to retrieve.
                    ##    @return The native handle or @c NULL.
                    ##    @since 0.11
                    ## ```
proc webview_set_title*(w: webview_t; title: cstring): webview_error_t {.
    importc, wvdecl.}
  ## ```
                    ##   Updates the title of the native window.
                    ##   
                    ##    @param w The webview instance.
                    ##    @param title The new title.
                    ## ```
proc webview_set_size*(w: webview_t; width: cint; height: cint;
                       hints: webview_hint_t): webview_error_t {.importc, wvdecl.}
  ## ```
                                                                                 ##   Updates the size of the native window.
                                                                                 ##   
                                                                                 ##    Remarks:
                                                                                 ##    - Using WEBVIEW_HINT_MAX for setting the maximum window size is not
                                                                                 ##      supported with GTK 4 because X11-specific functions such as
                                                                                 ##      gtk_window_set_geometry_hints were removed. This option has no effect
                                                                                 ##      when using GTK 4.
                                                                                 ##   
                                                                                 ##    @param w The webview instance.
                                                                                 ##    @param width New width.
                                                                                 ##    @param height New height.
                                                                                 ##    @param hints Size hints.
                                                                                 ## ```
proc webview_navigate*(w: webview_t; url: cstring): webview_error_t {.importc,
    wvdecl.}
  ## ```
           ##   Navigates webview to the given URL. URL may be a properly encoded data URI.
           ##   
           ##    Example:
           ##    @code{.c}
           ##    webview_navigate(w, "https:github.com/webview/webview");
           ##    webview_navigate(w, "data:text/html,%3Ch1%3EHello%3C%2Fh1%3E");
           ##    webview_navigate(w, "data:text/html;base64,PGgxPkhlbGxvPC9oMT4=");
           ##    @endcode
           ##   
           ##    @param w The webview instance.
           ##    @param url URL.
           ## ```
proc webview_set_html*(w: webview_t; html: cstring): webview_error_t {.importc,
    wvdecl.}
  ## ```
           ##   Load HTML content into the webview.
           ##   
           ##    Example:
           ##    @code{.c}
           ##    webview_set_html(w, "<h1>Hello</h1>");
           ##    @endcode
           ##   
           ##    @param w The webview instance.
           ##    @param html HTML content.
           ## ```
proc webview_init*(w: webview_t; js: cstring): webview_error_t {.importc, wvdecl.}
  ## ```
                                                                                 ##   Injects JavaScript code to be executed immediately upon loading a page.
                                                                                 ##    The code will be executed before @c window.onload.
                                                                                 ##   
                                                                                 ##    @param w The webview instance.
                                                                                 ##    @param js JS content.
                                                                                 ## ```
proc webview_eval*(w: webview_t; js: cstring): webview_error_t {.importc, wvdecl.}
  ## ```
                                                                                 ##   Evaluates arbitrary JavaScript code.
                                                                                 ##   
                                                                                 ##    Use bindings if you need to communicate the result of the evaluation.
                                                                                 ##   
                                                                                 ##    @param w The webview instance.
                                                                                 ##    @param js JS content.
                                                                                 ## ```
proc webview_bind*(w: webview_t; name: cstring;
                   fn: proc (id: cstring; req: cstring; arg: pointer) {.wvdecl.};
                   arg: pointer): webview_error_t {.importc, wvdecl.}
  ## ```
                                                                    ##   Binds a function pointer to a new global JavaScript function.
                                                                    ##   
                                                                    ##    Internally, JS glue code is injected to create the JS function by the
                                                                    ##    given name. The callback function is passed a request identifier,
                                                                    ##    a request string and a user-provided argument. The request string is
                                                                    ##    a JSON array of the arguments passed to the JS function.
                                                                    ##   
                                                                    ##    @param w The webview instance.
                                                                    ##    @param name Name of the JS function.
                                                                    ##    @param fn Callback function.
                                                                    ##    @param arg User argument.
                                                                    ##    @retval WEBVIEW_ERROR_DUPLICATE
                                                                    ##            A binding already exists with the specified name.
                                                                    ## ```
proc webview_unbind*(w: webview_t; name: cstring): webview_error_t {.importc,
    wvdecl.}
  ## ```
           ##   Removes a binding created with webview_bind().
           ##   
           ##    @param w The webview instance.
           ##    @param name Name of the binding.
           ##    @retval WEBVIEW_ERROR_NOT_FOUND No binding exists with the specified name.
           ## ```
proc webview_return*(w: webview_t; id: cstring; status: cint; result: cstring): webview_error_t {.
    importc, wvdecl.}
  ## ```
                    ##   Responds to a binding call from the JS side.
                    ##   
                    ##    @param w The webview instance.
                    ##    @param id The identifier of the binding call. Pass along the value received
                    ##              in the binding handler (see webview_bind()).
                    ##    @param status A status of zero tells the JS side that the binding call was
                    ##                  succesful; any other value indicates an error.
                    ##    @param result The result of the binding call to be returned to the JS side.
                    ##                  This must either be a valid JSON value or an empty string for
                    ##                  the primitive JS value @c undefined.
                    ## ```
proc webview_version*(): ptr webview_version_info_t {.importc, wvdecl.}
  ## ```
                                                                      ##   Get the library's version information.
                                                                      ##   
                                                                      ##    @since 0.10
                                                                      ## ```
{.pop.}
