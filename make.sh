#!/bin/sh

# Simple wrapper for arduino-builder and avrdude since 'make' is excessive for it
# (c) Oleksandr Kubrak, BSD License

# Usage: 
# make.sh path/to/enterpoint.ino -burn 		# make & burn sketch 
#
# Other options:
# make.sh -clean
# make.sh path/to/enterpoint.ino -compile	# make only
# make.sh path/to/enterpoint.ino			# the same as -compile
# make.sh path/to/enterpoint.ino -burn-only
# make.sh path/to/enterpoint.ino -dump-prefs
# make.sh path/to/enterpoint.ino -asm		# generate .asm in the .ino folder

# vars to tune:
PORT='/dev/cu.usbmodem14101'
PORT_BR='115200'
BUILD_DIR="$HOME/Arduino/build" # !!! will be erased with '-clean' !!!
CACHE_DIR="$HOME/Arduino/cache" # !!! will be erased with '-clean' !!!
DEVICE='atmega2560'
DEVNAME='arduino:avr:mega'
VID='0X2341'
PID='0X0042'

# vars to tune once on install:
ARDU_BASE='/Applications/Arduino.app/Contents'
BUILDER="$ARDU_BASE/Java/arduino-builder"
DUDE="$ARDU_BASE/Java/hardware/tools/avr/bin/avrdude"
DUDE_CONF="$ARDU_BASE/Java/hardware/tools/avr/etc/avrdude.conf"
OBJDUMP="$ARDU_BASE/Java/hardware/tools/avr/bin/avr-objdump"


PROJ=$1
PROJ_BASENAME=`basename $1`

#  -p <partno>                Required. Specify AVR device.
DUDE_OPTS+=" -p$DEVICE"
#  -b <baudrate>              Override RS-232 baud rate.
DUDE_OPTS+=" -b$PORT_BR"
#  -B <bitclock>              Specify JTAG/STK500v2 bit clock period (us).
#  -C <config-file>           Specify location of configuration file.
DUDE_OPTS+=" -C$DUDE_CONF"
#  -c <programmer>            Specify programmer type.
DUDE_OPTS+=" -cwiring"
#  -D                         Disable auto erase for flash memory
DUDE_OPTS+=" -D"
#  -i <delay>                 ISP Clock Delay [in microseconds]
#  -P <port>                  Specify connection port.
DUDE_OPTS+=" -P$PORT"
#  -F                         Override invalid signature check.
#  -e                         Perform a chip erase.
#  -O                         Perform RC oscillator calibration (see AVR053).
#  -U <memtype>:r|w|v:<filename>[:format]
#                             Memory operation specification.
#                             Multiple -U options are allowed, each request
#                             is performed in the order specified.
DUDE_OPTS+=" -Uflash:w:$BUILD_DIR/$PROJ_BASENAME.hex:i"
#  -n                         Do not write anything to the device.
#  -V                         Do not verify.
DUDE_OPTS+=" -v"
#  -u                         Disable safemode, default when running from a script.
#  -s                         Silent safemode operation, will not ask you if
#                             fuses should be changed back.
#  -t                         Enter terminal mode.
#  -E <exitspec>[,<exitspec>] List programmer exit specifications.
#  -x <extended_param>        Pass <extended_param> to programmer.
#  -y                         Count# erase cycles in EEPROM.
#  -Y <number>                Initialize erase cycle# in EEPROM.
#  -v                         Verbose output. -v -v for more.
#  -q                         Quell progress output. -q -q for less.
#  -l logfile                 Use logfile rather than stderr for diagnostics.
#  -?                         Display this usage.


BUILDER_OPTS+=" -build-cache $CACHE_DIR"
# builds of 'core.a' are saved into this folder to be cached and reused

#  -build-options-file string
# Instead of specifying --hardware, --tools etc every time, you can load all such options from a file

BUILDER_OPTS+=" -build-path $BUILD_DIR"
# build path

BUILDER_OPTS+=" -built-in-libraries /Applications/Arduino.app/Contents/Java/libraries"
# Specify a built-in 'libraries' folder. These are low priority libraries. Can be added multiple times for specifying multiple built-in 'libraries' folders

#  -code-complete-at string
# output code completions for sketch at a specific location. Location format is "file:line:col"

#  -core-api-version=10812
# version of core APIs (used to populate ARDUINO #define) (default "10600")

#  -daemon
# daemonizes and serves its functions via rpc

#  -debug-level int
# Turns on debugging messages. The higher, the chattier (default 5)

#  -experimental
# enables experimental features

BUILDER_OPTS+=" -fqbn=$DEVNAME:cpu=$DEVICE"
# fully qualified board name

BUILDER_OPTS+=" -hardware /Applications/Arduino.app/Contents/Java/hardware"
BUILDER_OPTS+=" -hardware $HOME/Library/Arduino15/packages"
# Specify a 'hardware' folder. Can be added multiple times for specifying multiple 'hardware' folders

#  -ide-version string
# [deprecated] use 'core-api-version' instead (default "10600")

#  -jobs int
# specify how many concurrent gcc processes should run at the same time. Defaults to the number of available cores on the running machine

BUILDER_OPTS+=" -libraries $HOME/Arduino/libraries"
# Specify a 'libraries' folder. Can be added multiple times for specifying multiple 'libraries' folders

BUILDER_OPTS+=" -logger=humantags"
# BUILDER_OPTS+=" -logger=machine"
# Sets type of logger. Available values are 'human', 'humantags', 'machine' (default "human")

BUILDER_OPTS+=" -prefs=build.warn_data_percentage=75"
BUILDER_OPTS+=" -prefs=runtime.tools.arduinoOTA.path=/Applications/Arduino.app/Contents/Java/hardware/tools/avr"
BUILDER_OPTS+=" -prefs=runtime.tools.arduinoOTA-1.3.0.path=/Applications/Arduino.app/Contents/Java/hardware/tools/avr"
BUILDER_OPTS+=" -prefs=runtime.tools.avrdude.path=/Applications/Arduino.app/Contents/Java/hardware/tools/avr"
BUILDER_OPTS+=" -prefs=runtime.tools.avrdude-6.3.0-arduino17.path=/Applications/Arduino.app/Contents/Java/hardware/tools/avr"
BUILDER_OPTS+=" -prefs=runtime.tools.avr-gcc.path=/Applications/Arduino.app/Contents/Java/hardware/tools/avr"
BUILDER_OPTS+=" -prefs=runtime.tools.avr-gcc-7.3.0-atmel3.6.1-arduino5.path=/Applications/Arduino.app/Contents/Java/hardware/tools/avr"
# Specify a custom preference. Can be added multiple times for specifying multiple custom preferences
# See /Applications/Arduino.app/Contents/Java/hardware/arduino/avr/platform.txt
#BUILDER_OPTS+=" -prefs=compiler.cpp.extra_flags=-fverbose-asm"
#BUILDER_OPTS+=" -prefs=compiler.cpp.extra_flags=-save-temps"

#  -preprocess
# preprocess the given sketch

# -quiet
# if 'true' doesn't print any warnings or progress or whatever

BUILDER_OPTS+=" -tools $HOME/Library/Arduino15/packages"
BUILDER_OPTS+=" -tools /Applications/Arduino.app/Contents/Java/hardware/tools/avr"
BUILDER_OPTS+=" -tools /Applications/Arduino.app/Contents/Java/tools-builder"
# Specify a 'tools' folder. Can be added multiple times for specifying multiple 'tools' folders

# -trace
# traces the whole process lifecycle

BUILDER_OPTS+=" -verbose"
# if 'true' prints lots of stuff

#  -version
# prints version and exits

BUILDER_OPTS+=" -vid-pid=${VID}_$PID"
# specify to use vid/pid specific build properties, as defined in boards.txt

BUILDER_OPTS+=" -warnings=default"
# Sets warnings level. Available values are 'none', 'default', 'more' and 'all'


OBJDUMP_OPTS=' -S'
# Usage: /Applications/Arduino.app/Contents//Java/hardware/tools/avr/bin/avr-objdump <option(s)> <file(s)>
#  Display information from object <file(s)>.
#  At least one of the following switches must be given:
#   -a, --archive-headers    Display archive header information
#   -f, --file-headers       Display the contents of the overall file header
#   -p, --private-headers    Display object format specific file header contents
#   -P, --private=OPT,OPT... Display object format specific contents
#   -h, --[section-]headers  Display the contents of the section headers
#   -x, --all-headers        Display the contents of all headers
#   -d, --disassemble        Display assembler contents of executable sections
#   -D, --disassemble-all    Display assembler contents of all sections
#   -S, --source             Intermix source code with disassembly
#   -s, --full-contents      Display the full contents of all sections requested
#   -g, --debugging          Display debug information in object file
#   -e, --debugging-tags     Display debug information using ctags style
#   -G, --stabs              Display (in raw form) any STABS info in the file
#   -W[lLiaprmfFsoRt] or
#   --dwarf[=rawline,=decodedline,=info,=abbrev,=pubnames,=aranges,=macro,=frames,
#           =frames-interp,=str,=loc,=Ranges,=pubtypes,
#           =gdb_index,=trace_info,=trace_abbrev,=trace_aranges,
#           =addr,=cu_index]
#                            Display DWARF info in the file
#   -t, --syms               Display the contents of the symbol table(s)
#   -T, --dynamic-syms       Display the contents of the dynamic symbol table
#   -r, --reloc              Display the relocation entries in the file
#   -R, --dynamic-reloc      Display the dynamic relocation entries in the file
#   @<file>                  Read options from <file>
#   -v, --version            Display this program's version number
#   -i, --info               List object formats and architectures supported
#   -H, --help               Display this information
# 
#  The following switches are optional:
#   -b, --target=BFDNAME           Specify the target object format as BFDNAME
#   -m, --architecture=MACHINE     Specify the target architecture as MACHINE
#   -j, --section=NAME             Only display information for section NAME
#   -M, --disassembler-options=OPT Pass text OPT on to the disassembler
#   -EB --endian=big               Assume big endian format when disassembling
#   -EL --endian=little            Assume little endian format when disassembling
#       --file-start-context       Include context from start of file (with -S)
#   -I, --include=DIR              Add DIR to search list for source files
#   -l, --line-numbers             Include line numbers and filenames in output
#   -F, --file-offsets             Include file offsets when displaying information
#   -C, --demangle[=STYLE]         Decode mangled/processed symbol names
#                                   The STYLE, if specified, can be `auto', `gnu',
#                                   `lucid', `arm', `hp', `edg', `gnu-v3', `java'
#                                   or `gnat'
#   -w, --wide                     Format output for more than 80 columns
#   -z, --disassemble-zeroes       Do not skip blocks of zeroes when disassembling
#       --start-address=ADDR       Only process data whose address is >= ADDR
#       --stop-address=ADDR        Only process data whose address is <= ADDR
#       --prefix-addresses         Print complete address alongside disassembly
#       --[no-]show-raw-insn       Display hex alongside symbolic disassembly
#       --insn-width=WIDTH         Display WIDTH bytes on a single line for -d
#       --adjust-vma=OFFSET        Add OFFSET to all displayed section addresses
#       --special-syms             Include special symbols in symbol dumps
#       --prefix=PREFIX            Add PREFIX to absolute paths for -S
#       --prefix-strip=LEVEL       Strip initial directory names for -S
#       --dwarf-depth=N        Do not display DIEs at depth N or greater
#       --dwarf-start=N        Display DIEs starting with N, at the same depth
#                              or deeper
#       --dwarf-check          Make additional dwarf internal consistency checks.
# 
# /Applications/Arduino.app/Contents//Java/hardware/tools/avr/bin/avr-objdump: supported targets: elf32-avr elf32-little elf32-big plugin srec symbolsrec verilog tekhex binary ihex
# /Applications/Arduino.app/Contents//Java/hardware/tools/avr/bin/avr-objdump: supported architectures: avr avr:1 avr:2 avr:25 avr:3 avr:31 avr:35 avr:4 avr:5 avr:51 avr:6 avr:100 avr:101 avr:102 avr:103 avr:104 avr:105 avr:106 avr:107 plugin
# 
# Options supported for -P/--private switch:
# For AVR ELF files:
#   mem-usage   Display memory usage
#   avr-prop    Display contents of .avr.prop section



run() {
  echo "==== $1"
  echo
  eval "$1"
  exit $?
}

BUILDER_CMD=$2
#  -compile
# compiles the given sketch
#  -dump-prefs
# dumps build properties used when compiling

[ "$BUILDER_CMD" = '-clean' -a -n "$BUILD_DIR" -a -n "$CACHE_DIR" ] && { rm -vfR $BUILD_DIR/* $CACHE_DIR/* ; exit 0; }
[ "$BUILDER_CMD" = '-asm' ] && run "$OBJDUMP $OBJDUMP_OPTS $BUILD_DIR/$PROJ_BASENAME.elf > $PROJ.asm"
[ "$BUILDER_CMD" = '-burn' ] && run "$BUILDER $BUILDER_OPTS -compile $PROJ && $DUDE $DUDE_OPTS"
[ "$BUILDER_CMD" = '-burn-only' ] && run "$DUDE $DUDE_OPTS"
[ -z $BUILDER_CMD ] && run "$BUILDER $BUILDER_OPTS -compile $PROJ"
run "$BUILDER $BUILDER_OPTS $BUILDER_CMD $PROJ"

