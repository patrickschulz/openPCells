--[[
    VDD ----*-----------------------*
            |                       |
            |                       |
          |-|                     |-|
    A ---o|                ~A ---o|
          |-|                     |-|
            |                       |
          |-|                     |-|
   ~B ---o|                 B ---o|
          |-|                     |-|
            |                       |
            *-----------------------*-------o A XOR B
            |                       |
          |-|                     |-|
   ~B ----|                 B ----|
          |-|                     |-|
            |                       |
          |-|                     |-|
   ~A ----|                 A ----|
          |-|                     |-|
            |                       |
            |                       |
    VSS ----*-----------------------*
--]]

function parameters()
    pcell.reference_cell("stdcells/base")
    pcell.reference_cell("stdcells/harness")
    pcell.add_parameter("fingers", 1, { posvals = set(1) })
    pcell.add_parameter("shiftoutput", 0)
end

function layout(gate, _P)
    local bp = pcell.get_parameters("stdcells/base")
    local xpitch = bp.gspace + bp.glength

    local harness = pcell.create_layout("stdcells/harness", { 
        drawgatecontacts = true,
        gatecontactpos = { "lower", "dummy", "dummy", "upper", "lower", "center", "center", "dummy", "upper", "center", "lower" },
        pcontactpos = { "power", "inner", "power", "inner", "power", "outer", "outer", "outer", "full", nil,     "power", "power" },
        ncontactpos = { "power", "inner", "power", "inner", "power", "power", nil,     "outer", "full", "outer", "outer", "power" },
    })
    gate:merge_into_shallow(harness)
    gate:inherit_alignment_box(harness)

    -- short pmos
    geometry.rectanglebltr(gate, generics.metal(1), 
        harness:get_anchor("pSD6tr"):translate(0, -bp.sdwidth),
        harness:get_anchor("pSD7tl")
    )
    geometry.rectanglebltr(gate, generics.metal(1), 
        harness:get_anchor("pSD8tr"):translate(0, -bp.sdwidth),
        harness:get_anchor("pSD9tl")
    )

    -- short nmos
    geometry.rectanglebltr(gate, generics.metal(1), 
        harness:get_anchor("nSD10br"),
        harness:get_anchor("nSD11bl"):translate(0, bp.sdwidth)
    )
    geometry.rectanglebltr(gate, generics.metal(1), 
        harness:get_anchor("nSD8br"),
        harness:get_anchor("nSD9bl"):translate(0, bp.sdwidth)
    )

    -- output connection
    --geometry.path(gate, generics.metal(1), geometry.path_points_xy(
    --    harness:get_anchor("pSD9cc"), {
    --        point.combine_12(harness:get_anchor("pSD9cc"), harness:get_anchor("pSD4br")):translate(xpitch, bp.sdwidth / 2),
    --        harness:get_anchor("G11cc"):translate(xpitch, 0),
    --        0, -- toggle xy
    --        harness:get_anchor("nSD9tc"):translate(0, -bp.sdwidth / 2)
    --    }), bp.sdwidth)
    geometry.rectanglebltr(gate, generics.metal(1),
        harness:get_anchor("pSD9br"),
        (harness:get_anchor("G11tr") .. harness:get_anchor("pSD4br")):translate(xpitch, bp.sdwidth)
    )
    geometry.rectanglebltr(gate, generics.metal(1),
        harness:get_anchor("nSD9tr"):translate(0, -bp.sdwidth),
        (harness:get_anchor("G11tr") .. harness:get_anchor("nSD4tr")):translate(xpitch, 0)
    )
    geometry.rectanglebltr(gate, generics.metal(1),
        (harness:get_anchor("G11tl") .. harness:get_anchor("nSD9tr")):translate(xpitch, 0),
        (harness:get_anchor("G11tr") .. harness:get_anchor("pSD9br")):translate(xpitch, bp.sdwidth)
    )

    -- A
    geometry.rectanglebltr(gate, generics.metal(2),
        harness:get_anchor("G1br"),
        harness:get_anchor("G11tl")
    )
    geometry.viabltr(gate, 1, 2,
        harness:get_anchor("G1bl"),
        harness:get_anchor("G1tr")
    )
    geometry.viabltr(gate, 1, 2,
        harness:get_anchor("G5bl"),
        harness:get_anchor("G5tr")
    )
    geometry.viabltr(gate, 1, 2,
        harness:get_anchor("G11bl"),
        harness:get_anchor("G11tr")
    )

    -- B
    geometry.rectanglebltr(gate, generics.metal(2),
        point.combine_12(harness:get_anchor("G1tr"), harness:get_anchor("G9bl")),
        harness:get_anchor("G9tl")
    )
    geometry.viabltr(gate, 1, 2,
        point.combine_12(harness:get_anchor("G1bl"), harness:get_anchor("G4bl")),
        point.combine_12(harness:get_anchor("G1br"), harness:get_anchor("G4tl"))
    )
    geometry.viabltr(gate, 1, 2,
        harness:get_anchor("G4bl"),
        harness:get_anchor("G4tr")
    )
    geometry.viabltr(gate, 1, 2,
        harness:get_anchor("G9bl"),
        harness:get_anchor("G9tr")
    )

    -- not A
    geometry.path_cshape(gate, generics.metal(1),
        harness:get_anchor("pSD2br"):translate(0, bp.sdwidth / 2),
        harness:get_anchor("nSD2tr"):translate(0, -bp.sdwidth / 2),
        harness:get_anchor("G2cc"),
        bp.sdwidth
    )
    geometry.rectanglebltr(gate, generics.metal(1),
        point.combine_12(harness:get_anchor("G2tr"), harness:get_anchor("G6bl")),
        harness:get_anchor("G6tl")
    )
    geometry.rectanglebltr(gate, generics.metal(2),
        harness:get_anchor("G6br"),
        harness:get_anchor("G10tl")
    )
    geometry.viabltr(gate, 1, 2,
        harness:get_anchor("G6bl"),
        harness:get_anchor("G6tr")
    )
    geometry.viabltr(gate, 1, 2,
        harness:get_anchor("G10bl"),
        harness:get_anchor("G10tr")
    )

    -- not B
    geometry.rectanglebltr(gate, generics.metal(1),
        harness:get_anchor("pSD4br"),
        harness:get_anchor("G7tr") .. harness:get_anchor("pSD4br"):translate(0, bp.sdwidth)
    )
    geometry.rectanglebltr(gate, generics.metal(1),
        harness:get_anchor("nSD4tr"):translate(0, -bp.sdwidth),
        harness:get_anchor("G7tr") .. harness:get_anchor("nSD4tr")
    )
    geometry.rectanglebltr(gate, generics.metal(1),
        harness:get_anchor("G7tl") .. harness:get_anchor("nSD4tr"),
        harness:get_anchor("G7tr") .. harness:get_anchor("pSD4br"):translate(0, bp.sdwidth)
    )

    gate:add_port("A", generics.metal(1), harness:get_anchor("G1cc"))
    --gate:add_port("B", generics.metal(1), point.combine_12(inva:get_anchor("I"), invb:get_anchor("I")))
    --gate:add_port("O", generics.metal(1), point.create(3 * xpitch + _P.shiftoutput, 0))
    gate:add_port("VDD", generics.metal(1), harness:get_anchor("top"))
    gate:add_port("VSS", generics.metal(1), harness:get_anchor("bottom"))
end
