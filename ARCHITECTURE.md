# Architecture
This document describes the high-level architecture of openPCells. This serves as an introduction to the code base, which module does what, how do the modules
interact and so on. This is NOT a technical description of HOW things work, this is covered in-depth (well, at least will be) in doc/techdoc.pdf.

## Overview
OpenPCells is based on lua with additions written in C. It reads cell definitions and creates layouts corresponding to these definitions and user-supplied
parameters. The main tasks are therefore to provide a user interface for cell definitions (geometrical functions), a translation from technology-independent
cells to technology-dependent layouts (the so-called 'technology translation') and an appropriate export matching the requested format (GDS, OASIS, virtuoso,
magic, etc.). These three main tasks should also provide easy mechanisms for the user to add her own cell/technology/export definitions.

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
This module provides functions for generating generic layer objects. These are used in cell definitions and are technology-independent (e.g. a generic metal is
used instead of M1). Besides that, the `technology` module makes heavy use of this module.

### `pcell.lua`
Main module for handling cell definitions.

### `object.lua`, `shape.lua` and the point module
Modules for handling of layout objects. Objects are collections of shapes, which use points (for description of polygons and rectangles).

### `technology.lua`
Module for technology translation. Here all generic layers are mapped to technology-specific layers. Read technology definitions in `tech/`.

### `export.lua` and `export/*.lua`
Module for generating output. In `export.lua` the generic logic is implemented, the actual generator depending on the file format is in `export`.

### Utility Modules
`aux.lua`, `stack.lua`, `stringfile.lua`/`stringbuffer.c`, `support.lua`, `util.lua`, `
Various stuff needed by other modules. `util.lua` provides geometry-related helper functions, `aux.lua` general ones. `stack.lua` implements a stack,
`stringfile.lua` together with `stringbuffer.c` provides an object that behaves like a file but does not write to the filesystem until explicitly called for. 
`support.lua` is like `aux.lua` and should probably be merged.

### `lbinary.c`
Provides helper functions for writing binary files and computing the required data. Written in C for performance reasons.

### `lbind.c`
Provides `bind` to bind function arguments. Written in C because this is more easily done in C (stack manipulations, registry).

### `ldir.c`
Module for simple filesystem queries (like lua-filesystem, but without the dependency).

### Configuration Modules
`config.lua`, `envlib.lua`
Provides configuration for the user and other modules.

### `profiler.lua`
Rudimentary profiler, which is off by default (option `--profile`). Cell generation can take a while for big (-ish unfortunately) cells. The profiler helps
finding bottlenecks.

### `load.lua`
Provides `_load_module`, a fancy `require`. Used to load the API and submodules within modules.

### `argparse.lua` and `cmdoptions.lua`
Simple argument parser for command line options as well as the definition of these options.

## Implementation Notes
This project aims for zero dependencies and easy installation for users without admin privileges. Because of this, some modules implement
functionality, that can be easily found in other libraries (lua-penlight for argument parsing, for instance). The only dependency needed is a C compiler and
`make` for building.

