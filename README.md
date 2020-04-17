# Arduino-semi-make
Simple wrapper for arduino-builder and avrdude since 'make' is excessive for it

# Usage:
```
make.sh path/to/enterpoint.ino -burn 		# make & burn sketch
```

# Other options:
```
make.sh -clean
make.sh path/to/enterpoint.ino -compile         # make only
make.sh path/to/enterpoint.ino			# the same as -compile
make.sh path/to/enterpoint.ino -burn-only
make.sh path/to/enterpoint.ino -dump-prefs
make.sh path/to/enterpoint.ino -asm		# generate .asm in the .ino folder
```
