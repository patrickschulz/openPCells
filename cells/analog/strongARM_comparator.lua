--[[

  VDD -------------*---------*-----*-----------------*-----*---------*-------
                   |         |     |                 |     |         |
                   |         |     |                 |     |         |
               |---|     |---|     |---|         |---|     |---|     |---| 
    vclk o----o|--------o|             |o--   --o|             |o--------|o----o vclk
               |---|     |---|     |---|   \ /   |---|     |---|     |---| 
                   |         |     |        x        |     |         |
                   |         |-----*-------* *-------*-----|         |
                   |               |        x        |               |
                   |               |---|   / \   |---|               |
                   |                   |---   ---|                   |
                   |               |---|         |---|               |
                   |               |                 |               |
                   |---------------*                 *---------------|
                                   |                 |
                               |---|                 |---|         
                    vinp o-----|                         |o----o vinn
                               |---|                 |---|         
                                   |--------*--------|
                                            |
                                            |
                                        |---|
                              vclk o----|    
                                        |---|
                                            |
                                            |
  VSS --------------------------------------*---------------------------------

--]]

function parameters()
    pcell.reference_cell("basic/mosfet")
    pcell.add_parameters(
        { "nmosclockfingers", 8 },
        { "nmosinputfingers", 4 }
    )
end

function layout(comparator, _P)
    local glength = 100
    local gspace = 110
    local fingerwidth = 500
    local fingerpitch = glength + gspace

    pcell.push_overwrites("basic/mosfet", {
        gatelength = glength, 
        gatespace = gspace, 
        fwidth = fingerwidth, 
        connectsource = true,
        connectdrain = true,
        conndrainmetal = 2,
        drawdrainvia = true,
        drawtopgate = true,
        sdconnspace = 200,
    })
    local nmosclockref = pcell.create_layout("basic/mosfet", { 
        fingers = _P.nmosclockfingers,
    })
    local nmosinputref = pcell.create_layout("basic/mosfet", { 
        fingers = _P.nmosinputfingers
    })
    pcell.pop_overwrites("basic/mosfet")

    local nmosclockname = pcell.add_cell_reference(nmosclockref, "nmosclock")
    local nmosinputname = pcell.add_cell_reference(nmosinputref, "nmosinput")

    local nmosclock = comparator:add_child(nmosclockname)
    local nmosinputleft = comparator:add_child(nmosinputname)
    local nmosinputright = comparator:add_child(nmosinputname)
    nmosinputleft:move_anchor("bottomright", nmosclock:get_anchor("top"))
    nmosinputright:move_anchor("bottomleft", nmosclock:get_anchor("top"))
end

