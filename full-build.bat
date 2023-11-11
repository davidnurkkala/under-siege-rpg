wally install
rojo sourcemap -o sourcemap.json
wally-package-types --sourcemap sourcemap.json Packages
wally-package-types --sourcemap sourcemap.json ServerPackages
rojo sourcemap -o sourcemap.json
lune LuneScripts/UnanchorAllWeapons.lua
rojo build -o game.rbxl
set /p key=<"api-key.txt"
set /p place-id=<"place-id.txt"
rbxcloud experience publish --filename game.rbxl --version-type saved --place-id %place-id% --universe-id 5095740172 --api-key %key%
explorer roblox-studio://launchmode/:edit+task:EditPlace+placeId:%place-id%+universeId:5095740172