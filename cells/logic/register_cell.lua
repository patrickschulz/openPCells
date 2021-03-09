--[[
          INV   OAI_221     FF_OUT  
   OAI_21 INV   OAI_221     FF_BUF
                OAI_221     FF_IN
]] --
function parameters() pcell.reference_cell("logic/base") end

function layout(gate, _P)
    local bp = pcell.get_parameters("logic/base")

    local xpitch = bp.gspace + bp.glength

    -- general settings
    pcell.push_overwrites("logic/base", {leftdummies = 0, rightdummies = 0})

    -- or_and_inv_221 gate & ff_in 
    local orandinv221_in =
        pcell.create_layout("logic/or_and_inv_221"):move_anchor("right")
    gate:merge_into(orandinv221_in)

    local ff_in = pcell.create_layout("logic/dff"):move_anchor("left",
                                                               orandinv221_in:get_anchor(
                                                                   "right"))

    gate:merge_into(ff_in)

    -- or_and_inv_221 gate & ff_buf, location is above ff_in, needs to be flipped in y axis
    local orandinv221_buf = pcell.create_layout("logic/or_and_inv_221")
    orandinv221_buf:flipy()
    orandinv221_buf:move_anchor("VDD", orandinv221_in:get_anchor("VDD"))
    gate:merge_into(orandinv221_buf)

    local ff_buf = pcell.create_layout("logic/dff"):move_anchor("left",
                                                                orandinv221_buf:get_anchor(
                                                                    "right"))
    ff_buf:flipy()
    gate:merge_into(ff_buf)
    local inv_buf = pcell.create_layout("logic/not_gate"):move_anchor("right",
                                                                      orandinv221_buf:get_anchor(
                                                                          "left"))
    inv_buf:flipy()
    gate:merge_into(inv_buf)

    local orandinv21 = pcell.create_layout("logic/or_and_inv_21"):move_anchor(
                           "right", orandinv221_buf:get_anchor("left"))
    orandinv21:flipy()
    gate:merge_into(orandinv21)

    -- or_and_inv_221 gate & ff_out, location is above ff_buf
    local orandinv221_out =
        pcell.create_layout("logic/or_and_inv_221"):move_anchor("VSS",
                                                                orandinv221_buf:get_anchor(
                                                                    "VSS"))
    gate:merge_into(orandinv221_out)

    local ff_out = pcell.create_layout("logic/dff"):move_anchor("left",
                                                                orandinv221_out:get_anchor(
                                                                    "right"))
    gate:merge_into(ff_out)

    local inv_out = pcell.create_layout("logic/not_gate"):move_anchor("right",
                                                                      orandinv221_out:get_anchor(
                                                                          "left"))
    gate:merge_into(inv_out)

end
