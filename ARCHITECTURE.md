# Architecture
This document describes the high-level architecture of openPCells. This serves as an introduction to the code base, which module does what, how do the modules
interact and so on. This is NOT a technical description of HOW things work, this is covered in-depth (well, at least will be) in doc/techdoc.pdf.

## Overview
OpenPCells is based on lua with additions written in C. It reads cell definitions and creates layouts corresponding to these definitions and user-supplied
parameters. The main tasks are therefore to provide a user interface for cell definitions (geometrical functions), a translation from technology-independent
cells to technology-dependent layouts (the so-called 'technology translation') and an appropriate export matching the requested interface (GDS, OASIS, virtuoso,
magic, etc.). These three main tasks should also provide easy mechanisms for the user to add her own cell/technology/interface definitions.

## Modules
### `main.lua` and `main.c`
The main program and entry point from a lua perspective resides in `main.lua`. The actual interpreter is adapted from the standard lua interpreter in `main.c`
and loads the API.

### `geometry.lua`
Geometry functions for cell definitions. Functions such as `path`, `rectangle` but also more specialized routines for IC layouts like `crossing`. Every function
takes a layer argument (see `generics.lua`).

### `graphics.lua`
This provides graphical routine for the geometry system. These are similar to classical computer graphics functions (e.g. calculating which pixels lie on a
curve). Currently provides functions for lines, ellipses and circles. Extensions like bezier curves enable full SVG support for drawing pictures in layouts.

### `generics.lua`

### `pcell.lua`

### `object.lua`, `shape.lua` and the point module

### `technology.lua`

### `interface.lua`

### Utility Modules
`aux.lua`, `stack.lua`, `stringfile.lua`/`stringbuffer.c`, `support.lua`, `util.lua`, `

lbinary.c
lbinary.h

lbind.c
lbind.h

ldir.c
ldir.h

### Configuration Modules
`config.lua`, `envlib.lua`

### `profiler.lua`

### `load.lua`

### `argparse.lua` and `cmdoptions.lua`
