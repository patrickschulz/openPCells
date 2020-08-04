# openPCells -- A framework for tool-independent layout cell generators 
This project intends to develop a set of parametric cells (PCells) for use in analog integrated circuit design.  Currently this is aimed at providing
a base set of cells for baseband and RF design (momcaps, inductors, transformers, transistors etc.), but ideally there would be also more complex
cells such as entire circuits (inverters, opamps etc.).

The key point of this framework is independency of any layout tool such as cadence virtuoso. In order to achieve this, the core generators are written
in lua and generate platform-independent files describing the cell. In the layout tool the files are read and the actual shapes are drawn. For this,
interfacing code is provided (currently only for virtuoso, but this is pretty simple to adapt). A second important point for this project is
technology independece. This is achieved by working in generic layers ('gate', 'metal1') and mapping that with (simple-to-write) layermaps.

# Installation for Cadence Virtuoso
The code has no dependencies except a working lua interpreter (>= 5.2), as we try to keep installation as easy as possible. Just clone this repository
and edit your `LUA_PATH` environment variable to include the path to the code (make sure to run this BEFORE you start virtuoso):

    # in your shell configuration file
    export LUA_PATH=";;/path/to/pcells/?.lua;/path/to/pcells/?/init.lua" # bash/zsh
    setenv LUA_PATH ";;/path/to/pcells/?.lua;/path/to/pcells/?/init.lua" # csh

Now you need to set up your virtuoso interface. The file `interface/virtuoso.il` shows how to do that, you can run that file from the SKILL IDE within
virtuoso. A better approach is to insert a menu to the layout editor, which is done in `interface/virtuoso_menu.il`. You need to include this file in
your `.cdsinit`:

    ; in your .cdsinit
    load("/path/to/pcells/interface/virtuoso_menu.il")

This will install a menu called `openPCells` at the last place before the `help` menu in the layout editor.

# The problem with SKILL-based PCells
In cadence virtuoso, pcells are built on top of SKILL-routines. SKILL is the closed-source proprietary language behind virtuoso. While this allows to
build very complex and highly sophisticated PCells, this has some disadvantages:
 * PCells are bound to cadence tools
 * SKILL sort of is lisp, which is nice for some people and tasks, but is rather hard to get started with for people who know C-like languages
 * SKILL code runs in virtuoso tools and must be developed and debugged from within these tools. May not be a problem for you, but it annoys me (I'm a
   vim guy)
 * PCells within virtuoso are actually too flexible

What? What's wrong with the last point? Let me elaborate: While trying out some designs it is nice to quickly change PCells. However, during tapeout
you usually share your design with other people who need to be able to use your stuff. If they are missing the respective libraries or worse the
supplementary code to execute the PCells, you have to tell them what to add etc. If you have ever worked in an academic group, you will know that you
won't be able to really accomplish this. And on top of that there's something even worse: PDK update. I personally had some problems with previous
LVS-clean designs, who now failed the check. Why? Because the PCell had changed. I know, you should freeze the design, that also helps with exchange.
But it is easy to miss something. Therefor, in my opinion it is better to use a cell that contains the PCell, but you have to regenerate it explicitly
if you want a change. This way, the design is frozen per default.

# How to use
Well, you're reading this in a very early state of development. There are some basic functions for drawing stuff as well as some interfacing. However,
the library is stil far from flexible and doesn't support many different cells. Still, this might be your best shot for some high-quality open-source
PCells, that allow to be used in different tools in different technologies (not because this library is so awesome -- it's not (yet) -- but because
the pcell code you find online is really terrible and not aimed at portability). If you want to use it, you need to have lua (probably >= 5.1, but
unsure) and then you need to adopt the paths. Look in cells/\*.lua for further information.

You can try it out by running `lua main.lua transistor` from the main directory. This will generate a file called `testpoints` in the current working
directory. This describes the polygons and can be read by tools such as virtuoso.

Set your `LUA_PATH` environment variable to the base path:

    export LUA_PATH=";;/path/to/pcells/?.lua"

The cell generator is used by passing the name of the cell, the to-be-used interface and the technology to the main program `opc`:

    ./opc skywater130 gds transistor

You can also pass some arguments to the cells:

    ./opc skywater130 gds transistor gatelength=0.2

# Status
## Available Cells
- Basic transistor
- metal-oxide-metal capacitor (momcap)
- octagonal inductor
- pads
- rounded inductor

## Interfaces
Currently there is an interface for cadence virtuoso and a direct GDS export.

<!---
vim: tw=150
-->
