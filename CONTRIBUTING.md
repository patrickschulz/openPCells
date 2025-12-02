# Contributing
Hello and thanks for considering contributing to openPCells.
This project is intended to be used and enhanced by many people, gathering different kinds of knowledge.
It's target users are designers/layout engineers of integrated circuits, mostly on the analog/mixed-signal side.

## How do I contribute?
All kinds of contributions are welcome, including (but not limited to) feature requests, bug fixes, cell defintions, documentation enhancements and technology definitions.
Furthermore, the provided cells are currently not being tested in many technologies, as this needs access to those.
If you are working with integrated circuits and have technology access, testing the generated layouts of various cells with different parameter values is very valuable for improving the code of the cells.

I try to add stuff that needs fixing or implementing to the todo file.
There is of course also the issue list on github, but that's probably out-of-sync.

# Development Overview
The main entry point (the main function) is in src/main.c.

## Dependencies
Avoid. This project is meant to be installable by users of ancient CAD servers, that might run on a not-supported-anymore version of centOS or something.
We can not assume that the user of this software has any install priviliges and there might also be no or not fast support from their IT team.
Hence everything here is built from scratch.
Additionally, the reason for the --all-load-paths-local configuration option also comes from the need for simple installation without priviliges.

## Goals for Version 1.0
Here is a list of goals that I want to implement before opc moves on to version 1.0.
All things in this list are not finished and perhaps the best entry points for development support.
Some of these things are also not particularly hard to do, they just require some work.
Especially with HTML-based stuff (cell display, searchable documentation) I could use some help, because my knowledge of how to properly do this is limited.
* browser-based cell display (essentially a gds viewer, although the internal format can be what we want)
* searchable HTML documentation
* functioning digital place&route
* up-to-date documentation
* hand-holding tutorial with mature examples so that anyone can start to use opc
* fix cell export in virtuoso
* GUI (browser-based) configuration tool for cells
* a collection of robust and mature cells with medium complexity:
    - ring oscillator
    - current mirror
    - OP-AMPs
    - LC oscillator
    - LDO
    - bandgap
    - digital cells (make stdcells.sh/stdcells.lua in wip work)
* skeleton generation from netlist + configuration file
* solid tech file assistant
* technology files for:
    x skywater130
    x IHP SG13G2
    x freePDK45
    x freePDK15
    x open GF180 or generic 180 nm
    x generic finfet technology (if freePDK15 does not include that)
* improve handling of error messages deep in a call stack
* proper and thorough testing
* pcell module implementation mostly in C, lua only as an interface
* properly support pcells written in C (requires pcell module C implementation)

## Important Types
There are a few types that are used throughout the project.
Some are data structures (such as struct vector), some are structures representing layout elements.

 * vector (src/vector.c)
    The most important data structure, represents dynamic arrays for pointers.
    As the individual elements are allocated again, there is another level of indirection.
    Continuous arrays (such as int* or char*) are not used much, because they are often not needed.
    Where they are, thin macro wrappers to realloc offer convenience to manipulate these arrays.
    For now, this works well and does not seem to be a problem performance-wise.
    This means that a struct vector* can not be used to directly store primitive types.
    The typical use case of a vector looks like this:

        struct vector* vector = vector_create(8, foo_destroy); // vector_create takes a number for the initial capacitance and a destructor
                                                               // the destructor must have the signature void (*destructor) (void*)
        vector_append(vector, foo_create());
        vector_append(vector, foo_create());
        vector_append(vector, foo_create());
        for(size_t i = 0; i < vector_size(vector); ++i)
        {
            struct foo* foo = vector_get(vector, i);
            foo_do_something(foo);
        }
        vector_destroy(vector);

    The type genericity of the vector comes from storing only void pointers.
    This means that there are no type checks through the compiler (it is C after all).

 * object (src/object.c):
    An object represents a collection of layout primitives (such as shapes or ports) and is the essential building block for integrated layouts.
    In standard terminology an object is a cell, part of a cell hierarchy.
    As such objects can store shapes, ports, placement boundaries and anchors, references to other cells (to build hierarchies) and know about nets.
    Objects come in two flavors: full and proxy objects, implemented as a union.
    Full objects actually contain and own (memory-wise) the stores layout primitives.
    Proxy objects are lightweight pointers to full objects, which can be stored in full objects as cell references.
    These references are called children.

    Through this dualality of objects, most functions check the type of the object first.
    Many functions make sense for both full and proxy objects, some only for one or the other.
    For instance, both full objects and proxy objects can be rotated, translated etc., but one can not inherit anchors from a proxy object.

## Lua Integration and Modules
The project includes a lua interpreter in source, which is almost identical to the official 5.4.4 source, with tiny changes.
The functionality of openPCells is mainly implemented in C, lua is mostly used as a scripting API access.
This is done for performance reasons, some less critical API functions are also implemented in lua.
These lua modules can be found in src/modules.
They are added to the binary by being compiled to bytecode which then is inserted into the main binary as char array.

## Style Guide
Follow the [mention guide] in general.
A few particularities are listed here:
 * curly braces for functions, conditionals etc. belong on their own line:

     if(condition)
     {

     }
     else
     {

     }

 * curly braces for initializers, structs, enums etc. belong on the same line as the preceeding code:

     struct foo {

     };
     enum bar {

     };
     int array[] = {
         1,
         2,
         3
     }; // this example could also be on one line

 * there is no hard limit on the line length, make it reasonable. Do not break at 80, that is too short.
 * prepend the namespace of a module:

    // in module foo.c
    int foo_create(void);

 * static functions don't prepend the module name and start with an underscore
 * Yes, I'm aware that identifiers starting with an underscore are reserved. I will change this in the future.
 * In geneneral (a few expections exist) structs and enums are *not* typedef'd. Use the full qualifier.
