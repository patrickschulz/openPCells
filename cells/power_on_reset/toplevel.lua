function parameters()
    pcell.reference_cell("basic/mosfet")
    pcell.add_parameters(
        { "gatelength", 200 },
        { "gatespace", 140 },
        { "factor", 10, posvals = even() },
        { "numdiodes", 2 }
    )
end

function layout(cell, _P)
    local powergriddensity = 0.5
    local options = {
        fingers = 4,
        nmos = {
            vthtype = 3,
            channeltype = "nmos",
        },
        pmos = {
            vthtype = 3,
            channeltype = "pmos",
        },
        gatelength = _P.gatelength,
        gatespace = _P.gatespace,
        gatewidth = 500,
        powerbarwidth = 200,
        powerbarspace = 400,
        guardringwidth = 200,
        guardringspace = 200,
        guardringsep = 500,
        factor = _P.factor,
        pg = {
            mhwidth = 400, 
            mhspace = 350, 
        },
        capsep = 2000,
    }
    -- derived parameters
    options.ypitch = options.gatewidth + 2 * options.powerbarspace + options.powerbarwidth
    options.pg.mhwidth = math.roundeven(powergriddensity * 750)
    options.pg.mhspace = 750 - options.pg.mhwidth
    options.pg.mvwidth = math.roundeven(powergriddensity * options.fingers * (_P.gatelength + _P.gatespace))
    options.pg.mvspace = options.fingers * (_P.gatelength + _P.gatespace) - options.pg.mvwidth

    -- helper functions
    local viaref = geometry.rectangle(generics.via(1, 3), options.pg.mvwidth, options.guardringwidth)
    local vianame = pcell.add_cell_reference(viaref, "pgvia")
    options.place_power_vias = function(what, cell, ypos)
        if what == "vdd" then
            cell:add_child_array(vianame, 6, 1, 2 * (options.pg.mvwidth + options.pg.mvspace), 0):translate(-9 * (options.pg.mvwidth + options.pg.mvspace) / 2, ypos)
        elseif what == "vss" then
            cell:add_child_array(vianame, 6, 1, 2 * (options.pg.mvwidth + options.pg.mvspace), 0):translate(-11 * (options.pg.mvwidth + options.pg.mvspace) / 2, ypos)
        end
    end

    pcell.push_overwrites("basic/mosfet", {
        gatelength = _P.gatelength,
        gatespace = _P.gatespace,
        fwidth = options.gatewidth,
        sdwidth = 60,
        gtopext = 65,
        gbotext = 65,
        specifyactext = true,
        actext = 75,
        topgatestrwidth = 120,
        topgatestrspace = 65,
        botgatestrwidth = 120,
        botgatestrspace = 65,
    })

    -- current mirror slices
    local nslicedioderef = pcell.create_layout("power_on_reset/delay_cell_nslicediode_cell", { numstack = _P.numdiodes }, options)
    local nslicediodename = pcell.add_cell_reference(nslicedioderef, "ndiode")
    local nslicediode = cell:add_child(nslicediodename)

    local psliceref = pcell.create_layout("power_on_reset/delay_cell_pslice_cell", nil, options)
    local pslicename = pcell.add_cell_reference(psliceref, "delay_cell_pslice_cell")
    local pslice = cell:add_child(pslicename):move_anchor("top", nslicediode:get_anchor("bottom"))
    pslice:translate(0, -options.guardringsep - options.guardringwidth)

    local nsliceref = pcell.create_layout("power_on_reset/delay_cell_nslice_cell", nil, options)
    local nslicename = pcell.add_cell_reference(nsliceref, "delay_cell_nslice_cell")
    local nslice = cell:add_child(nslicename):move_anchor("top", pslice:get_anchor("bottom"))
    nslice:translate(0, -options.guardringsep - options.guardringwidth)

    local pslice1to1ref = pcell.create_layout("power_on_reset/delay_cell_pslice1to1_cell", nil, options)
    local pslice1to1name = pcell.add_cell_reference(pslice1to1ref, "delay_cell_pslice1to1_cell")
    local pslice1to1 = cell:add_child(pslice1to1name)
    pslice1to1:flipy()
    pslice1to1:move_anchor("top", nslice:get_anchor("bottom"))
    pslice1to1:translate(0, -options.guardringsep - options.guardringwidth)

    local schmitttriggerref = pcell.create_layout("power_on_reset/schmitt_trigger", nil, options)
    local schmitttriggername = pcell.add_cell_reference(schmitttriggerref, "schmitt_trigger")
    local schmitttrigger = cell:add_child(schmitttriggername)
    schmitttrigger:move_anchor("top", pslice1to1:get_anchor("bottom"))

    -- guardring
    local ext = 4000
    local height = point.ydistance(nslicediode:get_anchor("top"), schmitttrigger:get_anchor("bottom")) + ext
    local guardringref = pcell.create_layout("auxiliary/guardring", { 
        contype = "n", 
        ringwidth = 400, 
        width = (options.factor + 1) * options.fingers * (options.gatelength + options.gatespace) + 4120, 
        height = height,
        drawdeepwell = true, 
        fillwell = false,
        extension = 500,
        deepwelloffset = 150
    })
    local guardringviaref = geometry.rectangle(generics.via(1, 3), options.pg.mvwidth, 400)
    local guardringvianame = pcell.add_cell_reference(guardringviaref, "guardringpgvia")
    guardringref:add_child_array(guardringvianame, 6, 1, 2 * (options.pg.mvwidth + options.pg.mvspace), 0):translate(-9 * (options.pg.mvwidth + options.pg.mvspace) / 2, height / 2)
    guardringref:add_child_array(guardringvianame, 6, 1, 2 * (options.pg.mvwidth + options.pg.mvspace), 0):translate(-9 * (options.pg.mvwidth + options.pg.mvspace) / 2, -height / 2)

    local guardringname = pcell.add_cell_reference(guardringref, "guardring")
    local guardring = cell:add_child(guardringname)
    guardring:move_anchor("top", nslicediode:get_anchor("top"))
    guardring:translate(0, ext / 2)

    -- power grid
    local width = point.xdistance(guardring:get_anchor("right"), guardring:get_anchor("left"))
    local height = point.ydistance(guardring:get_anchor("top"), guardring:get_anchor("bottom"))
    local mhlines = math.ceil(height / (options.pg.mhwidth + options.pg.mhspace))
    local mvlines = math.floor(width / (options.pg.mvwidth + options.pg.mvspace))
    if mvlines % 2 == 1 then
        mvlines = mvlines + 1
    end
    local powergridref = pcell.create_layout("auxiliary/metalgrid", {
        metalh = 4, 
        metalv = 3, 
        mhwidth = options.pg.mhwidth,
        mhspace = options.pg.mhspace,
        mvwidth = options.pg.mvwidth,
        mvspace = options.pg.mvspace,
        mhlines = mhlines,
        mvlines = mvlines,
        flatvias = false
    })
    local powergridname = pcell.add_cell_reference(powergridref, "toplevel_powergrid")
    local powergrid = cell:add_child(powergridname)
    powergrid:move_anchor("top", guardring:get_anchor("top"))
    powergrid:translate(0, -(height - mhlines * options.pg.mhwidth - (mhlines + 1) * options.pg.mhspace + options.pg.mhspace) / 2)

    -- capacitor
    local capref = pcell.create_layout("passive/capacitor/mom", {
        fingers = 100,
        fwidth = 44,
        fspace = 46,
        fheight = height / 2,
        foffset = 100,
        rwidth = 200,
        firstmetal = 1,
        lastmetal = 7,
    })
    local capname = pcell.add_cell_reference(capref, "capacitor")
    local capacitors = {}
    local uppercap = cell:add_child(capname)
    uppercap:move_anchor("bottomright", guardring:get_anchor("left"))
    uppercap:translate(-options.capsep, 0)
    local lowercap = cell:add_child(capname)
    lowercap:flipy()
    lowercap:move_anchor("topright", guardring:get_anchor("left"))
    lowercap:translate(-options.capsep, 0)

    -- connections
    cell:merge_into_shallow(geometry.path(generics.metal(2), 
        geometry.path_points_yx(pslice1to1:get_anchor("out"), {
            schmitttrigger:get_anchor("in"), 
    }), 100))
    cell:merge_into_shallow(geometry.path(generics.metal(2), 
        geometry.path_points_xy(pslice1to1:get_anchor("out"), {
            -options.capsep / 2,
            uppercap:get_anchor("bottomright"),
    }), 200))

    cell:add_port("vreset", generics.metal(2), schmitttrigger:get_anchor("out"))
    cell:add_port("vss", generics.metal(4), powergrid:get_anchor("top"):translate(0, -options.pg.mhspace / 2 - options.pg.mhwidth / 2))
    cell:add_port("vdd", generics.metal(4), powergrid:get_anchor("top"):translate(0, -3 * options.pg.mhspace / 2 - 3 * options.pg.mhwidth / 2))

    pcell.pop_overwrites("basic/mosfet")
end
