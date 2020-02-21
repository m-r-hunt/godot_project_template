REM Find and replace exe name: project_template itch path: proj-templ-itch-path

Godot_v3.2-stable_win64.exe .\project.godot --export "Windows Desktop" .\build\windows\project_template.exe
butler.exe push .\build\windows\ mrhthepie/proj-templ-itch-path:windows

Godot_v3.2-stable_win64.exe .\project.godot --export "HTML5" .\build\web\index.html
butler.exe push .\build\web\ mrhthepie/proj-templ-itch-path:web

Godot_v3.2-stable_win64.exe .\project.godot --export "Linux/X11" .\build\linux\project_template.x86_64
butler.exe push .\build\linux\ mrhthepie/proj-templ-itch-path:linux

Godot_v3.2-stable_win64.exe .\project.godot --export "Mac OSX" .\build\mac\project_template.zip
butler.exe push .\build\mac\project_template.zip mrhthepie/proj-templ-itch-path:mac
