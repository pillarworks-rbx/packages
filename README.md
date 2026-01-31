# packages
## this repository includes:
- the framework package, which is a simple module loader
- the group package, which is a memory management module
- the region package, which is a zoneplus alternative
- the stack package, which is a simple stack implementation in luau

please check the `README.md` of the packages (which are located in `pkgs`) for more information about each package, including how to use them.

i aim to keep all packages up to date and maintainable, aswell as simple and easy to use. however, feel free to contribute to the packages if you think you can improve them!

most of the packages are kept in one file, so they're easy to vendor into your own projects.

most packages are coded in pure luau, with the exception of:
- region, which relies on roblox apis such as the player
