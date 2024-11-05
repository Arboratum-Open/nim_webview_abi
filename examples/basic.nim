# Copyright 2024 Geoffrey Picron.
# SPDX-License-Identifier: (MIT or Apache-2.0)
import nim_webview_abi

func check(x: bool) =
  if not x:
    debugEcho "Error"

var w = webview_create(1, nil);
check w != nil

check webview_init(w, "window.alert('go');") == 0
check webview_set_title(w, "Basic Example") == 0
check webview_set_size(w, 800, 600, WEBVIEW_HINT_NONE) == 0
check webview_set_html(w, """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login Screen</title>
    <meta name="author" content="David Grzyb">
    <meta name="description" content="">
    <!-- Tailwind -->
    <link rel="preconnect" href="https://rsms.me/">
    <link rel="stylesheet" href="https://rsms.me/inter/inter.css">

    /* CSS */
    :root {
      font-family: Inter, sans-serif;
      font-feature-settings: 'liga' 1, 'calt' 1; /* fix for Chrome */
    }
    @supports (font-variation-settings: normal) {
      :root { font-family: InterVariable, sans-serif; }
    }
    <script src="https://cdn.tailwindcss.com"> </script>    
    <script>
    tailwind.config = {
      theme: {
        extend: {
          fontFamily: {
            sans: ['InterVariable', ...defaultTheme.fontFamily.sans],
          },
        }
      }
    }
    </script>
</head>

<body class=" font-family-karla bg-[#061b28]">
    <div class="flex justify-center items-center rounded-lg h-full lg:p-64 sm:p-16 md:p-16">
        <div class=" flex flex-wrap border-width: 1px bg-slate-200 shadow-xl rounded px-8 mb-4">

            <!-- Login Section -->
              <div class="flex flex-col justify-center md:justify-start my-auto px-9 py-9 ">
                <p class="text-center text-3xl text-[#3d87b4]">Welcome Back!</p>
                <form class="flex flex-col pt-3 "  action="" method="POST">
                    
                    <div class="justify-center flex flex-col pt-4">
                        <label for="email" class="text-lg">Email</label>
                        <input type="text" name="username" class="text-white mt-1 px-3 py-2 bg-[#061b28] border shadow-sm border-slate-300 placeholder-slate-400 focus:outline-none focus:border-[#3d87b4] focus:ring-[#3d87b4] block w-full rounded-md sm:text-sm focus:ring-1" placeholder="you@example.com" />                        
                    </div>
    
                    <div class="flex flex-col pt-4">
                        <label for="password" class="text-lg">Password</label>
                        <input type="password" name="password" class="text-white mt-1 px-3 py-2 bg-[#061b28] border shadow-sm border-slate-300 placeholder-slate-400 focus:outline-none focus:border-[#3d87b4] focus:ring-[#3d87b4] block w-full rounded-md sm:text-sm focus:ring-1" placeholder="Your password" />                        
                    </div>
    
                    <input type="submit" name="submit" value="Log In" class="bg-[#3d87b4] text-white font-bold text-lg hover:bg-blue-600 p-2 mt-8 rounded-lg">
                
                </form>
               
            </div>
        </div>
    </div>
</body>

</html>
""".cstring) == 0
echo "Running webview..."

check webview_run(w) == 0

echo "Webview closed."
check webview_destroy(w) == 0