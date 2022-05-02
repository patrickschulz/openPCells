function parameters()
    pcell.add_parameters(
        { "flavour", "ground" },
        { "cellsize", 10000 },
        { "topmetal", 8 },
        { "captopmetal", 7 },
        { "gridstartmetal", 9 },
        { "gridtopmetal", 10 },
        { "metalwidth", { 600, 600, 1200, 1200, 1200, 1200, 1200, 1000 } }
    )
end

function layout(mesh, _P)
    local rwidth = 600
    for i = 1, _P.captopmetal do
        geometry.ring(mesh, generics.metal(i), _P.cellsize - _P.metalwidth[i], _P.cellsize - _P.metalwidth[i], _P.metalwidth[i])
        local foffset = 100
        local fwidth = 50
        local fspace = 50
        local nfingers = math.floor((_P.cellsize - 2 * _P.metalwidth[i]) / (2 * (fwidth + fspace))) - 5
        local topcap = pcell.create_layout("passive/capacitor/mom", { 
            firstmetal = i, lastmetal = i, 
            fingers = nfingers,
            fwidth = fwidth, fspace = fspace,
            foffset = foffset,
            rwidth = rwidth, 
            fheight = _P.cellsize / 2 - rwidth / 2 - _P.metalwidth[i] - foffset
        })
        local botcap = topcap:copy()
        topcap:move_anchor("minus")
        botcap:move_anchor("plus")
        botcap:flipy()
        mesh:merge_into_shallow(topcap)
        mesh:merge_into_shallow(botcap)
        -- inner rail via
        if i > 1 then
            geometry.via(mesh, i - 1, i, (2 * nfingers + 1) * (fwidth + fspace), rwidth)
        end
        -- outer rail via
        if i > 1 then
            local mwidth = math.min(_P.metalwidth[i - 1], _P.metalwidth[i])
            geometry.via(mesh, i - 1, i, mwidth, _P.cellsize - 2 * mwidth, -_P.cellsize / 2 + mwidth / 2, 0)
            geometry.via(mesh, i - 1, i, mwidth, _P.cellsize - 2 * mwidth, _P.cellsize / 2 - mwidth / 2, 0)
            geometry.via(mesh, i - 1, i, _P.cellsize - 2 * mwidth, mwidth, 0, -_P.cellsize / 2 + mwidth / 2, 0)
            geometry.via(mesh, i - 1, i, _P.cellsize - 2 * mwidth, mwidth, 0, _P.cellsize / 2 - mwidth / 2, 0)
        end
    end
    -- connection between top lower metal and intermediate metal
    local mwidth = math.min(_P.metalwidth[_P.gridstartmetal - 2], _P.metalwidth[_P.gridstartmetal - 1])
    geometry.via(mesh, _P.gridstartmetal - 2, _P.gridstartmetal - 1, mwidth, _P.cellsize - 2 * mwidth, -_P.cellsize / 2 + mwidth / 2, 0)
    geometry.via(mesh, _P.gridstartmetal - 2, _P.gridstartmetal - 1, mwidth, _P.cellsize - 2 * mwidth, _P.cellsize / 2 - mwidth / 2, 0)
    geometry.via(mesh, _P.gridstartmetal - 2, _P.gridstartmetal - 1, _P.cellsize - 2 * mwidth, mwidth, 0, -_P.cellsize / 2 + mwidth / 2, 0)
    geometry.via(mesh, _P.gridstartmetal - 2, _P.gridstartmetal - 1, _P.cellsize - 2 * mwidth, mwidth, 0, _P.cellsize / 2 - mwidth / 2, 0)
    geometry.via(mesh, _P.gridstartmetal - 2, _P.gridstartmetal - 1, _P.cellsize / 2, rwidth)
    -- top metal grid
    geometry.ring(mesh, generics.metal(_P.gridstartmetal - 1), 
        _P.cellsize - _P.metalwidth[_P.gridstartmetal - 1], _P.cellsize - _P.metalwidth[_P.gridstartmetal - 1], _P.metalwidth[_P.gridstartmetal - 1])
    geometry.rectangle(mesh, generics.metal(_P.gridstartmetal - 1), _P.cellsize / 2, _P.cellsize / 2)
    geometry.via(mesh, _P.gridstartmetal - 1, _P.gridtopmetal, _P.cellsize / 2, _P.cellsize / 2)
    local rotate = false
    for i = _P.gridstartmetal, _P.gridtopmetal do
        if rotate then
            geometry.rectangle(mesh, generics.metal(i), _P.cellsize / 2, _P.cellsize)
        else
            geometry.rectangle(mesh, generics.metal(i), _P.cellsize, _P.cellsize / 2)
        end
        rotate = not rotate
    end
    -- guard ring
    mesh:merge_into_shallow(pcell.create_layout("auxiliary/guardring", { 
        contype = "p", 
        width = _P.cellsize - _P.metalwidth[1], height = _P.cellsize - _P.metalwidth[1], 
        ringwidth = _P.metalwidth[1] 
    }))
end
