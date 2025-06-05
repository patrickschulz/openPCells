function parameters()
    pcell.add_parameters(
        { "channeltype", "nmos" },
        { "oxidetype", 1 },
        { "vthtype", 1 },
        { "flippedwell", false },
        { "gatelength", 0 },
        { "gatespace", 0 },
        { "gateextension", 0 },
        { "gatestrapwidth", 0 },
        { "gatestrapspace", 0 },
        { "sdwidth", 0 },
        { "sourcedrainmetal", 1 },
        { "sourcedrainstrapwidth", 0 },
        { "sourcedrainstrapspace", 0 },
        { "fingerwidth", 0 },
        { "numbits", 1 },
        { "bitlinemetal", 1 },
        { "bitlinewidth", 0 },
        { "bitlinespace", 0 },
        { "isdummy", false },
        { "extendalignmentbox", 0 },
        { "lsbtopbottomseparation", 0 },
        { "lsbleftrightseparation", 0 },
        { "topplateviawidth", 0 },
        { "markerextensions_topbottom", 0 },
        { "markerextensions_leftright", 0 }
    )
end

function layout(lsb, _P)
    local half = object.create(string.format("%s_%s", lsb:get_name(), "varbank_lsb_half"))

    local mosfet = pcell.create_layout("basic/mosfet", "core", {
        gatelength = _P.gatelength,
        gatespace = _P.gatespace,
        fingerwidth = _P.fingerwidth,
        sdwidth = _P.sdwidth,
        channeltype = _P.channeltype,
        oxidetype = _P.oxidetype,
        vthtype = _P.vthtype,
        flippedwell = _P.flippedwell,
        drawtopgate = true,
        drawtopgatestrap = true,
        topgatewidth = _P.gatestrapwidth,
        topgatespace = _P.gatestrapspace,
        topgateleftextension = 0,
        topgaterightextension = 0,
        topgatemetal = 1,
        gtopext = _P.gateextension,
        drawtopgatevia = true,
        botgatemetal = 7,
        gbotext = _P.gateextension,
        drawbotgatevia = true,
        drawsourcevia = true,
        drawdrainvia = true,
        drawleftstopgate = false,
        drawrightstopgate = false,
        extendalltop = math.max(_P.gatestrapspace + _P.gatestrapwidth + _P.markerextensions_topbottom, _P.lsbleftrightseparation / 2),
        extendallbottom = _P.sourcedrainstrapspace + _P.sourcedrainstrapspace + _P.markerextensions_topbottom + _P.lsbleftrightseparation / 2,
        extendallleft = math.max(_P.markerextensions_leftright, _P.lsbtopbottomseparation / 2),
        extendallright = math.max(_P.markerextensions_leftright, _P.lsbtopbottomseparation / 2),
        implantaligntopwithactive = true,
        implantalignbottomwithactive = true,
        vthtypealigntopwithactive = true,
        vthtypealignbottomwithactive = true,
        oxidetypealigntopwithactive = true,
        oxidetypealignbottomwithactive = true,
        lvsmarker = 2,
        fingers = 1,
        connectsource = false,
        --connectsourceinverse = true,
        connectsourceinline = false,
        splitsourcevias = false,
        connectsourcewidth = _P.sourcedrainstrapwidth,
        connectsourcespace = _P.sourcedrainstrapspace,
        connectsourcerightext = _P.gatelength + _P.gatespace,
        connectdrain = false,
        connectdraininline = false,
        splitdrainvias = false,
        connectdrainwidth = _P.sourcedrainstrapwidth,
        connectdrainspace = _P.sourcedrainstrapspace,
        sourcemetal = _P.isdummy and 1 or _P.sourcedrainmetal,
        drainmetal = _P.isdummy and 1 or _P.sourcedrainmetal,
        drawrotationmarker = true,
    })
    mosfet:rotate_90_left()
    half:merge_into(mosfet)

    -- alignment box
    half:set_alignment_box(
        point.create(
            mosfet:get_area_anchor("active").l - _P.lsbleftrightseparation / 2,
            mosfet:get_area_anchor("sourcedrain1").b - _P.sdwidth / 2 - _P.lsbtopbottomseparation / 2 - _P.extendalignmentbox / 2
        ),
        point.create(
            mosfet:get_area_anchor("active").r + _P.lsbleftrightseparation / 2,
            mosfet:get_area_anchor("sourcedrain-1").t + _P.sdwidth / 2 + _P.lsbtopbottomseparation / 2 + _P.extendalignmentbox / 2
        ),
        point.create(
            mosfet:get_area_anchor("active").l - _P.lsbleftrightseparation / 2,
            mosfet:get_area_anchor("sourcedrain1").t - _P.sdwidth / 2 - _P.lsbtopbottomseparation / 2 - _P.extendalignmentbox / 2
        ),
        point.create(
            mosfet:get_area_anchor("active").r + _P.lsbleftrightseparation / 2,
            mosfet:get_area_anchor("sourcedrain-1").b + _P.sdwidth / 2 + _P.lsbtopbottomseparation / 2 + _P.extendalignmentbox / 2
        )
    )

    half:inherit_area_anchor(mosfet, "sourcedrain1")
    half:inherit_area_anchor(mosfet, "sourcedrain2")
    half:inherit_area_anchor(mosfet, "sourcedrain-1")
    half:inherit_area_anchor(mosfet, "sourcedrain-2")

    -- add top plate via and gate anchors
    half:inherit_area_anchor_as(mosfet, "topgatestrap", "topgate")
    half:add_area_anchor_bltr("topplate",
        point.create(
            half:get_alignment_anchor("outerbl"):getx() - _P.topplateviawidth / 2,
            (mosfet:get_area_anchor("topgatestrap").t + mosfet:get_area_anchor("topgatestrap").b) / 2 - _P.topplateviawidth / 2
        ),
        point.create(
            half:get_alignment_anchor("outerbl"):getx() + _P.topplateviawidth / 2,
            (mosfet:get_area_anchor("topgatestrap").t + mosfet:get_area_anchor("topgatestrap").b) / 2 + _P.topplateviawidth / 2
        )
    )

    -- copy anchors
    half:inherit_area_anchor_as(mosfet, "sourcestrap", "outersourcedrain")

    -- short dummy lsb
    if _P.isdummy then
        geometry.polygon(half, generics.metal(1), {
            half:get_area_anchor("sourcedrain1").bl,
            point.create(
                half:get_area_anchor("topgate").l,
                half:get_area_anchor("sourcedrain1").b
            ),
            point.create(
                half:get_area_anchor("topgate").l,
                half:get_area_anchor("sourcedrain-1").t
            ),
            half:get_area_anchor("sourcedrain-1").tl,
            half:get_area_anchor("sourcedrain-1").bl,
            point.create(
                half:get_area_anchor("topgate").r,
                half:get_area_anchor("sourcedrain-1").b
            ),
            point.create(
                half:get_area_anchor("topgate").r,
                half:get_area_anchor("sourcedrain1").t
            ),
            half:get_area_anchor("sourcedrain1").tl
        })
    end

    -- place left/right mosfet
    local lefthalf = half:copy()
    local righthalf = half:copy()
    righthalf:mirror_at_yaxis()
    righthalf:abut_right(lefthalf)
    lsb:merge_into(righthalf)
    lsb:merge_into(lefthalf)

    lsb:inherit_alignment_box(lefthalf)
    lsb:inherit_alignment_box(righthalf)

    -- connect left/right source/drain
    geometry.rectanglebltr(lsb, generics.metal(_P.isdummy and 1 or _P.sourcedrainmetal),
        lefthalf:get_area_anchor("sourcedrain1").br,
        righthalf:get_area_anchor("sourcedrain1").tl
    )
    geometry.rectanglebltr(lsb, generics.metal(_P.isdummy and 1 or _P.sourcedrainmetal),
        lefthalf:get_area_anchor("sourcedrain2").br,
        righthalf:get_area_anchor("sourcedrain2").tl
    )

    -- add left/right center connection
    lsb:add_area_anchor_bltr("bottomplate",
        lefthalf:get_area_anchor("sourcedrain1").bl,
        righthalf:get_area_anchor("sourcedrain-1").tr
    )

    -- copy topgate anchors
    lsb:inherit_area_anchor_as(lefthalf, "topgate", "lefttopgate")
    lsb:inherit_area_anchor_as(righthalf, "topgate", "righttopgate")

    -- copy topplate anchors
    if not _P.isdummy then
        lsb:inherit_area_anchor_as(lefthalf, "topplate", "lefttopplate")
        lsb:inherit_area_anchor_as(righthalf, "topplate", "righttopplate")
    end

    -- place top-plate vias and connect to gates
    if not _P.isdummy then
        geometry.viabltr(lsb, 1, 7,
            lsb:get_area_anchor("lefttopgate").bl,
            lsb:get_area_anchor("lefttopgate").tr
        )
        geometry.viabltr(lsb, 1, 7,
            lsb:get_area_anchor("righttopgate").bl,
            lsb:get_area_anchor("righttopgate").tr
        )
        geometry.viabltr(lsb, 7, 8,
            lsb:get_area_anchor("lefttopplate").bl,
            lsb:get_area_anchor("lefttopplate").tr
        )
        geometry.viabltr(lsb, 7, 8,
            lsb:get_area_anchor("righttopplate").bl,
            lsb:get_area_anchor("righttopplate").tr
        )
        geometry.rectanglepoints(lsb, generics.metal(7),
            lsb:get_area_anchor("lefttopplate").br,
            point.create(
                lsb:get_area_anchor("lefttopgate").l,
                lsb:get_area_anchor("lefttopplate").t
            )
        )
        geometry.rectanglepoints(lsb, generics.metal(7),
            point.create(
                lsb:get_area_anchor("righttopgate").r,
                lsb:get_area_anchor("righttopplate").b
            ),
            lsb:get_area_anchor("righttopplate").tl
        )
    end

    -- add bit lines
    if not _P.isdummy then
        for bit = 1, _P.numbits do
            local width = lsb:get_area_anchor("bottomplate").l - lsb:get_area_anchor("bottomplate").r
            local shift = width / 2 + (bit - 1 - (_P.numbits - 1) / 2) * (_P.bitlinewidth + _P.bitlinespace)
            lsb:add_area_anchor_bltr(string.format("bitline_%d", bit),
                point.create(
                    lsb:get_area_anchor("bottomplate").r + shift - _P.bitlinewidth / 2,
                    lsb:get_alignment_anchor("outerbl"):gety()
                ),
                point.create(
                    lsb:get_area_anchor("bottomplate").r + shift + _P.bitlinewidth / 2,
                    lsb:get_alignment_anchor("outertr"):gety()
                )
            )
            geometry.rectanglebltr(lsb, generics.metal(_P.bitlinemetal),
                lsb:get_area_anchor(string.format("bitline_%d", bit)).bl,
                lsb:get_area_anchor(string.format("bitline_%d", bit)).tr
            )
        end
    end
end
-- vim: nowrap
