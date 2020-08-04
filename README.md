# openPCells -- A framework for tool-independent layout cell generators 
This project intends to develop a set of parametric cells (PCells) for use in analog integrated circuit design.  Currently this is aimed at providing
a base set of cells for baseband and RF design (momcaps, inductors, transformers, transistors etc.), but ideally there would be also more complex
cells such as entire circuits (inverters, opamps etc.).

The key point of this framework is independency of any layout tool such as cadence virtuoso. In order to achieve this, the core generators are written
in lua and generate platform-independent files describing the cell. In the layout tool the files are read and the actual shapes are drawn. For this,
interfacing code is provided (currently only for virtuoso, but this is pretty simple to adapt). A second important point for this project is
technology independece. This is achieved by working in generic layers ('gate', 'metal1') and mapping that with (simple-to-write) layermaps.

# How to use
Well, you're reading this in a very early state of development. There are some basic functions for drawing stuff as well as some interfacing. However,
the library is stil far from flexible and doesn't support many different cells. Still, this might be your best shot for some high-quality open-source
PCells, that allow to be used in different tools in different technologies (not because this library is so awesome -- it's not (yet) -- but because
the pcell code you find online is really terrible and not aimed at portability). If you want to use it, you need to have lua (probably >= 5.3, but
unsure) and then you need to adopt the paths. Look in cells/\*.lua for further information.

You can try it out by running `opc skywater130 gds transistor` from the main directory. This will generate a file called `openPCells.gds` in the
current working directory. You can import it to virtuoso or look at it with any GDSII tool (e.g. klayout).

Set your `LUA_PATH` environment variable to the base path:

    # in your shell configuration file
    export LUA_PATH=";;/path/to/pcells/?.lua;/path/to/pcells/?/init.lua" # bash/zsh
    setenv LUA_PATH ";;/path/to/pcells/?.lua;/path/to/pcells/?/init.lua" # csh

The cell generator is used by passing the name of the cell, the to-be-used interface and the technology to the main program `opc`:

    ./opc skywater130 gds transistor

You can also pass some arguments to the cells:

    ./opc skywater130 gds transistor gatelength=0.2

# Installation for Cadence Virtuoso
The code has no dependencies except a working lua interpreter (>= 5.3), as we try to keep installation as easy as possible. Just clone this repository
and edit your `LUA_PATH` environment variable (described above) to include the path to the code (make sure to run this BEFORE you start virtuoso).
Then you need to set up your virtuoso interface. The file `interface/virtuoso/init.il` shows how to do that, you can run that file from the SKILL IDE
within virtuoso (note: the file is old and does not work any more due to changes in the interface). A better approach is to insert a menu to the
layout editor, which is done in `interface/virtuoso/menu.il`. You need to include this file in your `.cdsinit`:

    ; in your .cdsinit
    load("/path/to/pcells/interface/virtuoso/menu.il")

This will install a menu called `openPCells` at the last place before the `help` menu in the layout editor. This interface currently only includes
three cells: transistor, momcap and circular_inductor and is anyways pretty limited, as it does not allow any parametrization. This is easy to add,
but I need to find the time to do it. Most of the work is building GUIs for the parameters for every cell, which is boring, hence there is no work on
that. If you want to add this, look in the menu.il, there is some old code of mine that can be adapted to do something like that.

# Technology translation and mapping
## Introduction
The pcells are defined in general layers (such as "gate" or "M1" or "lastmetal"), which have to be translated into a specific technology for
cell generation. This works in two runs: first vias have to be translated, as they are only defined as rectangular areas since we can't put any
spacing or sizing of the individual vias into the pcell. After this, all generic layers need to become technology-specific layers.
## How to add technologies
Every technology needs three files (currently, this might change in the future): a general configuration, a layer map and a via rules file.
Have a look in tech/template or tech/skywater130 on how to write these files.

The config is pretty simple:

    return {
    }

With this you're good to go as any data inside the table is not used any ways. But it should at least contain the grid, as I plan to include this in
the next time.

The layermap includes information on the human-readable layer data as well as the stream numbers (virtuoso could also work just with the stream
numbers, but often the layers have internal numbers that are NOT the stream numbers. Oh well). Therefore every entry is a table containing a table for
the layer and a table for the purpose:

    -- example
    lastmetal = { 
        layer = { name = "M8", number = 13 }, 
        purpose = { name = "drawing", number = 0 }
    }

The needed layers depends on the cells that are being used, but the program will also tell you when you are missing something. Therefore, you can also
keep running it until it works. The template layer map should contain most of the used layers, but I didn't consider all obscure technology features.

The via rules file is a bit more complex, as the via geometries and the needed layers need to be described (e.g. gate contacts in skywater130 need to
have a poly nitride cut). A typical entry looks like this (taken from tech/skywater130/viarules.lua):

    gatecont = {
        layers = {
            {
                lpp = {
                    layer   = { name = "poly",    number = 66 },
                    purpose = { name = "drawing", number = 20 },
                },
                enlarge = 0.1
            },
            {
                lpp = {
                    layer   = { name = "npc",     number = 95 },
                    purpose = { name = "drawing", number = 20 },
                },
                enlarge = 0.1
            },
            {
                lpp = {
                    layer   = { name = "licon1",  number = 66 },
                    purpose = { name = "drawing", number = 44 },
                },
            },
        },
        width = 0.17,
        height = 0.17, 
        xspace = 0.25, 
        yspace = 0.17, 
        xencl = 0.04, 
        yencl = 0.08
    }

The entry describes the geometry of the actual cuts and the needed layers. This works ok currently, but assumes that metal/poly strips with SEVERAL
cuts are drawn explicitly. I am working on this to improve that, but it works right now with this method.

# Roadmap
This project started as a way of designing pcells independently of SKILL/virtuoso and technologies, but I have shifted a bit my goals and am thinking
of building some kind of pcell-text-based layout description/generator. There is still a lot of work to do and right now the best use of this project
is as a pcell generator. Once I've really figured out how to do technology-independent pcells (which is already working a little bit), I will start
thinking of connecting several cells and creating entire layouts. 

# Contributions
Contributions of any kind are welcome and even wished for. I'm trying to add issues to github, but there's of course a lot more that needs to be
worked on. The most helpful currently would be people working in different technologies figuring out how the pcells need to be built and how the
technology translation has to work. I only have access to two technologies right now (three if you count skywater130, maybe four if you count
freepdk45), so any information on that would be greatly appreciated. Furthermore I'm happy about pcell contributions as well as general code
contributions. I'm also happy to know just what you are missing, if I find time I would be glad to implement that functionality.

# Status
## Available Cells
- Basic transistor
- metal-oxide-metal capacitor (momcap)
- pads
- circular inductor
- octagonal inductor
## Interfaces
Currently there is an interface for cadence virtuoso and a direct GDS export.


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

<!---
vim: tw=150
-->
