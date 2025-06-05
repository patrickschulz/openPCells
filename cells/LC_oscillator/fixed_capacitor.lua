function parameters()
    pcell.add_parameters(
        { "firstmetal", 1 },
        { "lastmetal", 2 },
        { "fingers", 8 },
        { "fingerwidth", 0 },
        { "fingerspace", 0 },
        { "fingerheight", 0 },
        { "fingeroffset", 0 },
        { "railwidth", 0 },
        { "rext", 0 },
        { "viaxsize", 0 },
        { "viaysize", 0 },
        { "resonator_separation", 0 },
        { "boundaryextensions", {} }
    )
end

function layout(capacitor, _P)
    local lmcapacitor = pcell.create_layout("passive/capacitor/mom", "capacitor", {
        firstmetal = _P.firstmetal,
        lastmetal = _P.lastmetal,
        fingers = _P.fingers,
        fingerwidth = _P.fingerwidth,
        fingerspace = _P.fingerspace,
        fingerheight = _P.fingerheight,
        fingeroffset = _P.fingeroffset,
        railwidth = _P.railwidth,
        rext = _P.rext,
    })
    lmcapacitor:rotate_90_left()
    lmcapacitor:move_point(lmcapacitor:get_area_anchor("upperrail").br, point.create(-_P.resonator_separation / 2, 0))
    lmcapacitor:translate_y(1000)
    lmcapacitor:translate_x((_P.resonator_separation - _P.fingerheight - 2 * _P.fingeroffset) / 2)
    capacitor:merge_into(lmcapacitor)
    capacitor:inherit_alignment_box(lmcapacitor)
    local railheight = point.ydistance_abs(
        lmcapacitor:get_area_anchor("upperrail").bl,
        lmcapacitor:get_area_anchor("upperrail").tr
    )
    for metal = 1, technology.resolve_metal(-1) do
        if metal < technology.resolve_metal(_P.firstmetal) or
           metal > technology.resolve_metal(_P.lastmetal) then
            capacitor:set_empty_layer_boundary(generics.metal(metal))
        elseif metal == _P.lastmetal then
            if railheight < _P.viaysize then
                capacitor:add_layer_boundary(generics.metal(metal),
                    util.rectangle_to_polygon(
                        point.combine_12(
                            point.create(-_P.resonator_separation / 2, 0),
                            lmcapacitor:get_area_anchor("upperrail").bl
                        ):translate(-_P.viaxsize, -_P.viaysize / 2 + railheight / 2),
                        point.combine_12(
                            point.create(_P.resonator_separation / 2, 0),
                            lmcapacitor:get_area_anchor("lowerrail").tr
                        ):translate(_P.viaxsize, _P.viaysize / 2 - railheight / 2),
                        _P.boundaryextensions[metal].x, _P.boundaryextensions[metal].x, _P.boundaryextensions[metal].y, _P.boundaryextensions[metal].y
                    )
                )
            else
                capacitor:add_layer_boundary(generics.metal(metal),
                    util.rectangle_to_polygon(
                        point.combine_12(
                            point.create(-_P.resonator_separation / 2, 0),
                            lmcapacitor:get_area_anchor("upperrail").bl
                        ):translate_x(-_P.viaxsize),
                        point.combine_12(
                            point.create(_P.resonator_separation / 2, 0),
                            lmcapacitor:get_area_anchor("lowerrail").tr
                        ):translate_x(_P.viaxsize),
                        _P.boundaryextensions[metal].x, _P.boundaryextensions[metal].x, _P.boundaryextensions[metal].y, _P.boundaryextensions[metal].y
                    )
                )
            end
        else
            capacitor:add_layer_boundary(generics.metal(metal),
                util.rectangle_to_polygon(
                    lmcapacitor:get_area_anchor("upperrail").bl,
                    lmcapacitor:get_area_anchor("lowerrail").tr,
                    _P.boundaryextensions[metal].x, _P.boundaryextensions[metal].x, _P.boundaryextensions[metal].y, _P.boundaryextensions[metal].y
                )
            )
        end
    end

    -- connect to main traces
    geometry.viabltr(capacitor, _P.lastmetal, -2,
        point.combine_12(
            point.create(-_P.resonator_separation / 2, 0),
            lmcapacitor:get_area_anchor("upperrail").bl
        ):translate(-_P.viaxsize, -_P.viaysize / 2 + railheight / 2),
        point.combine_12(
            point.create(-_P.resonator_separation / 2, 0),
            lmcapacitor:get_area_anchor("upperrail").tl
        ):translate(0, _P.viaysize / 2 - railheight / 2)
    )
    geometry.viabltr(capacitor, _P.lastmetal, -2,
        point.combine_12(
            point.create(_P.resonator_separation / 2, 0),
            lmcapacitor:get_area_anchor("lowerrail").br
        ):translate(0, -_P.viaysize / 2 + railheight / 2),
        point.combine_12(
            point.create(_P.resonator_separation / 2, 0),
            lmcapacitor:get_area_anchor("lowerrail").tr
        ):translate(_P.viaxsize, _P.viaysize / 2 - railheight / 2)
    )

    -- if the capacitor is smaller than the separation explicitly connect it to the vias
    if _P.fingerheight + 2 * _P.fingeroffset < _P.resonator_separation then
        if railheight < _P.viaysize then
            geometry.rectanglehlines(capacitor, generics.metal(_P.lastmetal),
                point.combine_12(
                    point.create(-_P.resonator_separation / 2, 0),
                    lmcapacitor:get_area_anchor("upperrail").bl
                ),
                lmcapacitor:get_area_anchor("upperrail").tl,
                8, 1
            )
            geometry.rectanglehlines(capacitor, generics.metal(_P.lastmetal),
                lmcapacitor:get_area_anchor("lowerrail").bl,
                point.combine_12(
                    point.create(_P.resonator_separation / 2, 0),
                    lmcapacitor:get_area_anchor("lowerrail").tr
                ),
                8, 1
            )
        else
            geometry.rectanglehlines(capacitor, generics.metal(_P.lastmetal),
                point.combine_12(
                    point.create(-_P.resonator_separation / 2, 0),
                    lmcapacitor:get_area_anchor("upperrail").bl
                ):translate_y(-_p.viaysize / 2 + railheight / 2),
                lmcapacitor:get_area_anchor("upperrail").tl:translate_y(_P.viaysize / 2 - railheight / 2),
                8, 1
            )
            geometry.rectanglehlines(capacitor, generics.metal(_P.lastmetal),
                lmcapacitor:get_area_anchor("lowerrail").br:translate_y(-_P.viaysize / 2 + railheight / 2),
                point.combine_12(
                    point.create(_P.resonator_separation / 2, 0),
                    lmcapacitor:get_area_anchor("lowerrail").tr
                ):translate_y(_P.viaysize / 2 - railheight / 2),
                8, 1
            )
        end
    end
end
