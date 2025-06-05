function parameters()
    pcell.add_parameters(
        { "psub_guardring_ringwidth", 0 },
        { "psub_guardring_xspace", 0 },
        { "psub_guardring_yspace", 0 },
        { "boundaryextensions", {} },
        { "base_fingerwidth", 300 },
        { "base_gatelength", 1000 },
        { "base_dummygatelength", 150 },
        { "base_sourcedrainspacetogate", 50 },
        { "base_topplateviawidth", 600 },
        { "base_topplatewidth", 450 },
        { "base_connectsourcedraininline", false },
        { "base_sourcedrainmetal", 2 },
        { "base_channeltype", "pmos" },
        { "base_oxidetype", 2 },
        { "base_vthtype", 5 },
        { "base_flippedwell", true },
        { "base_bitlinemetal", 3 },
        { "base_gatestrapwidth", 90 },
        { "base_gatestrapspace", 20 },
        { "base_lsbleftrightseparation", 520 },
        { "base_lsbtopbottomseparation", 100 },
        { "base_sdwidth", 60 },
        { "base_sourcedrainstrapwidth", 60 },
        { "base_sourcedrainstrapspace", 120 },
        { "numh", 1 },
        { "numv", 2 },
        { "additionalctrlmetals", { 1, 2 } },
        { "additionalctrllines", 3 },
        { "innerctrllinewidth", 200 },
        { "ctrlmetal", 5 },
        { "ctrlwidth", 1000 },
        { "ctrlxshift", 400 }
    )
end

function layout(varbank, _P)
    local env = {
        oscillator = {
            buswidth = 200,
            busspace = 100,
            varbank = {
                placeouterdummies = true,
                topbottomdummies = 1,
                interweavedummies = false,
                numh = 4,
                numv = 4,
                numbits = 4,
                topplatespace = 1635,
                bitlineoffset = 200,
                innerbitlinewidth = 60,
                innerbitlinespace = 50,
                bitlineviafactor = 6,
            },
        },
    }
    local _E = env.oscillator.varbank
    -- create lsb and lsbdummy cells
    local baseoptions = {
        gatelength = _P.base_gatelength,
        gatespace = 2 * _P.base_sourcedrainspacetogate + _P.base_sourcedrainstrapwidth,
        fingerwidth = _P.base_fingerwidth,
        channeltype = _P.base_channeltype,
        oxidetype = _P.base_oxidetype,
        vthtype = _P.base_vthtype,
        flippedwell = _P.base_flippedwell,
        gatestrapwidth = _P.base_gatestrapwidth,
        gatestrapspace = _P.base_gatestrapspace,
        sdwidth = _P.base_sdwidth,
        sourcedrainmetal = _P.base_sourcedrainmetal,
        sourcedrainstrapwidth = _P.base_sourcedrainstrapwidth,
        sourcedrainstrapspace = _P.base_sourcedrainstrapspace,
        bitlinemetal = _P.base_bitlinemetal,
        --extendalignmentbox,
        lsbtopbottomseparation = _P.base_lsbtopbottomseparation,
        lsbleftrightseparation = _P.base_lsbleftrightseparation,
        topplateviawidth = _P.base_topplateviawidth,
        --markerextensions_topbottom,
        --markerextensions_leftright,
    }
    local varactorref = pcell.create_layout(
        "./varactorbase",
        "varactor",
        util.add_options(baseoptions, {
            numbits = 1,
            bitlinewidth = _P.innerctrllinewidth,
            isdummy = false,
        })
    )
    local lsbref = pcell.create_layout(
        "./varactorbase",
        "varbank_lsb",
        util.add_options(baseoptions, {
            numbits = _E.numbits + 1,
            bitlinewidth = _E.innerbitlinewidth,
            bitlinespace = _E.innerbitlinespace,
            isdummy = false,
        })
    )
    local lsbtopbotdummyref = pcell.create_layout(
        "./varactorbase",
        "varbank_lsbtopbotdummy",
        util.add_options(baseoptions, {
            gatelength = _P.base_dummygatelength,
            numbits = _E.numbits + 1,
            bitlinewidth = _E.innerbitlinewidth,
            bitlinespace = _E.innerbitlinespace,
            isdummy = true,
        })
    )
    local lsbleftrightdummyref = pcell.create_layout(
        "./varactorbase",
        "varbank_lsbleftrightdummy",
        util.add_options(baseoptions, {
            numbits = _E.numbits + 1,
            bitlinewidth = _E.innerbitlinewidth,
            bitlinespace = _E.innerbitlinespace,
            isdummy = true,
        })
    )

    -- place bits
    local numcolumns = _E.interweavedummies and (2 * _E.numh + 1) or (_E.numh + 3)
    local bitdef = {}
    for rownum = 1, _E.topbottomdummies do
        local row = {}
        for columnnum = 1, numcolumns do
            table.insert(row, { reference = lsbtopbotdummyref, instance = string.format("bottomdummy_%d_%d", rownum, columnnum) })
        end
        table.insert(bitdef, row)
    end
    for rownum = 1, _E.numv do
        local row = {}
        if _E.placeouterdummies then
            table.insert(row, { reference = lsbleftrightdummyref, instance = string.format("leftdummy_%d", rownum) })
        end
        if _E.interweavedummies then
            for columnnum = 1, 2 * _E.numh - 1 do
                if columnnum % 2 == 1 then
                    local flip = columnnum % 4 == 3
                    table.insert(row, { reference = lsbref, instance = string.format("bit_%d_%d", rownum, columnnum // 2 + 1), flipx = flip })
                elseif
                    (rownum > (_E.numv - _P.numv) / 2) and
                    (rownum <= _E.numv - (_E.numv - _P.numv) / 2) and
                    (columnnum == _E.numh) then
                    table.insert(row, { reference = varactorref, instance = string.format("varactor_%d", rownum - (_E.numv - _P.numv) / 2) })
                else
                    table.insert(row, { reference = lsbleftrightdummyref, instance = string.format("innerdummy_%d_%d", rownum, columnnum) })
                end
            end
        else
            for columnnum = 1, _E.numh / 2 do
                local flip = columnnum % 2 == 0
                table.insert(row, { reference = lsbref, instance = string.format("bit_%d_%d", rownum, columnnum), flipx = flip })
            end
            if
                (rownum > (_E.numv - _P.numv) / 2) and
                (rownum <= _E.numv - (_E.numv - _P.numv) / 2) then
                table.insert(row, { reference = varactorref, instance = string.format("varactor_%d", rownum - (_E.numv - _P.numv) / 2) })
            else
                table.insert(row, { reference = lsbleftrightdummyref, instance = string.format("innerdummy_%d", rownum) })
            end
            for columnnum = _E.numh / 2 + 1, _E.numh do
                local flip = columnnum % 2 == 0
                table.insert(row, { reference = lsbref, instance = string.format("bit_%d_%d", rownum, columnnum), flipx = flip })
            end
        end
        if _E.placeouterdummies then
            table.insert(row, { reference = lsbleftrightdummyref, instance = string.format("rightdummy_%d", rownum) })
        end
        table.insert(bitdef, row)
    end
    for rownum = 1, _E.topbottomdummies do
        local row = {}
        for columnnum = 1, numcolumns do
            table.insert(row, { reference = lsbtopbotdummyref, instance = string.format("topdummy_%d_%d", rownum, columnnum) })
        end
        table.insert(bitdef, row)
    end
    local bits = placement.rowwise(varbank, bitdef)

    -- connect left/right top-plates
    for column = 1, _E.numh / 2 do
        varbank:add_area_anchor_bltr(string.format("lefttopplate_%d", column),
            point.create(
                (
                    bits[string.format("bit_%d_%d", 1, column)]:get_area_anchor("lefttopplate").l
                    + bits[string.format("bit_%d_%d", 1, column)]:get_area_anchor("lefttopplate").r
                ) / 2 - _P.base_topplatewidth / 2,
                bits[string.format("bit_%d_%d", 1, column)]:get_area_anchor("lefttopplate").b
            ),
            point.create(
                (
                    bits[string.format("bit_%d_%d", 1, column)]:get_area_anchor("lefttopplate").l
                    + bits[string.format("bit_%d_%d", 1, column)]:get_area_anchor("lefttopplate").r
                ) / 2 + _P.base_topplatewidth / 2,
                bits[string.format("bit_%d_%d", _E.numv, column)]:get_area_anchor("lefttopplate").t
            )
        )
        varbank:add_area_anchor_bltr(string.format("righttopplate_%d", column),
            point.create(
                (
                    bits[string.format("bit_%d_%d", 1, column)]:get_area_anchor("righttopplate").l
                    + bits[string.format("bit_%d_%d", 1, column)]:get_area_anchor("righttopplate").r
                ) / 2 - _P.base_topplatewidth / 2,
                bits[string.format("bit_%d_%d", 1, column)]:get_area_anchor("righttopplate").b
            ),
            point.create(
                (
                    bits[string.format("bit_%d_%d", 1, column)]:get_area_anchor("righttopplate").l
                    + bits[string.format("bit_%d_%d", 1, column)]:get_area_anchor("righttopplate").r
                ) / 2 + _P.base_topplatewidth / 2,
                bits[string.format("bit_%d_%d", _E.numv, column)]:get_area_anchor("righttopplate").t
            )
        )
    end
    for column = _E.numh / 2 + 1, _E.numh do
        varbank:add_area_anchor_bltr(string.format("righttopplate_%d", column),
            point.create(
                (
                    bits[string.format("bit_%d_%d", 1, column)]:get_area_anchor("lefttopplate").l
                    + bits[string.format("bit_%d_%d", 1, column)]:get_area_anchor("lefttopplate").r
                ) / 2 - _P.base_topplatewidth / 2,
                bits[string.format("bit_%d_%d", 1, column)]:get_area_anchor("lefttopplate").b
            ),
            point.create(
                (
                    bits[string.format("bit_%d_%d", 1, column)]:get_area_anchor("lefttopplate").l
                    + bits[string.format("bit_%d_%d", 1, column)]:get_area_anchor("lefttopplate").r
                ) / 2 + _P.base_topplatewidth / 2,
                bits[string.format("bit_%d_%d", _E.numv, column)]:get_area_anchor("lefttopplate").t
            )
        )
        varbank:add_area_anchor_bltr(string.format("lefttopplate_%d", column),
            point.create(
                (
                    bits[string.format("bit_%d_%d", 1, column)]:get_area_anchor("righttopplate").l
                    + bits[string.format("bit_%d_%d", 1, column)]:get_area_anchor("righttopplate").r
                ) / 2 - _P.base_topplatewidth / 2,
                bits[string.format("bit_%d_%d", 1, column)]:get_area_anchor("righttopplate").b
            ),
            point.create(
                (
                    bits[string.format("bit_%d_%d", 1, column)]:get_area_anchor("righttopplate").l
                    + bits[string.format("bit_%d_%d", 1, column)]:get_area_anchor("righttopplate").r
                ) / 2 + _P.base_topplatewidth / 2,
                bits[string.format("bit_%d_%d", _E.numv, column)]:get_area_anchor("righttopplate").t
            )
        )
    end

    for column = 1, _E.numh do
        for _, side in ipairs({ "left", "right" }) do
            geometry.rectanglebltr(varbank, generics.metal(8),
                varbank:get_area_anchor(string.format("%stopplate_%d", side, column)).bl,
                varbank:get_area_anchor(string.format("%stopplate_%d", side, column)).tr
            )
        end
    end

    -- copy local bit line anchors
    for column = 1, _E.numh do
        for bit = 1, _E.numbits + 1 do
            varbank:add_area_anchor_bltr(string.format("localbitline_%d_%d", column, bit),
                bits[string.format("bit_%d_%d", 1, column)]:get_area_anchor(string.format("bitline_%d", bit)).bl,
                bits[string.format("bit_%d_%d", _E.numv, column)]:get_area_anchor(string.format("bitline_%d", bit)).tr
            )
        end
    end

    -- via targets for top-level bit line connections
    for row = 1, _E.numv do
        for column = 1, _E.numh do
            for bit = 1, _E.numbits + 1 do
                varbank:add_area_anchor_bltr(string.format("viatarget_%d_%d_%d", row, column, bit),
                    point.create(
                        varbank:get_area_anchor(string.format("localbitline_%d_%d", column, bit)).l,
                        bits[string.format("bit_%d_%d", row, column)]:get_area_anchor("bottomplate").b
                    ),
                    point.create(
                        varbank:get_area_anchor(string.format("localbitline_%d_%d", column, bit)).r,
                        bits[string.format("bit_%d_%d", row, column)]:get_area_anchor("bottomplate").t
                    )
                )
            end
        end
    end

    -- add bit vias
    for row = 1, _E.numv do
        for column = 1, _E.numh do
            if row == _E.numv and column == _E.numh then -- last bit is not symmetrical
                geometry.viabltr(varbank, 2, 3,
                    varbank:get_area_anchor(string.format("viatarget_%d_%d_%d", row, column, 1)).bl,
                    varbank:get_area_anchor(string.format("viatarget_%d_%d_%d", row, column, 1)).tr
                )
            else
                local index = _E.numh - column + (_E.numv - row) * _E.numh
                local bit = math.floor(math.log(index, 2)) + 2
                geometry.viabltr(varbank, 2, 3,
                    varbank:get_area_anchor(string.format("viatarget_%d_%d_%d", row, column, bit)).bl,
                    varbank:get_area_anchor(string.format("viatarget_%d_%d_%d", row, column, bit)).tr
                )
            end
        end
    end

    -- anchors for global bit lines
    for bit = 1, _E.numbits + 1 do
        varbank:add_area_anchor_bltr(string.format("bitline_%d", bit),
            varbank:get_area_anchor(string.format("localbitline_%d_%d", 1, 1)).bl
                :translate(-_E.bitlineviafactor * _E.innerbitlinewidth, -_E.bitlineoffset - (bit - 1) * (env.oscillator.buswidth + env.oscillator.busspace) - env.oscillator.buswidth),
            varbank:get_area_anchor(string.format("localbitline_%d_%d", _E.numh, 1)).br
                :translate(_E.bitlineviafactor * _E.innerbitlinewidth, -_E.bitlineoffset - (bit - 1) * (env.oscillator.buswidth + env.oscillator.busspace))
        )
        geometry.rectanglebltr(varbank, generics.metal(_P.base_bitlinemetal + 1),
            varbank:get_area_anchor(string.format("bitline_%d", bit)).bl,
            varbank:get_area_anchor(string.format("bitline_%d", bit)).tr
        )
    end

    -- anchor for vctrl line
    varbank:add_area_anchor_bltr("vctrl_inner",
        bits[string.format("varactor_%d", 1)]:get_area_anchor("bitline_1").bl,
        bits[string.format("varactor_%d", _P.numv)]:get_area_anchor("bitline_1").tr
    )
    geometry.viabltr(varbank, _P.base_bitlinemetal, _P.ctrlmetal,
        varbank:get_area_anchor("vctrl_inner").bl,
        varbank:get_area_anchor("vctrl_inner").tr
    )

    -- connect varactor cells with vctrl line
    for row = 1, _P.numv do
        geometry.viabltr(varbank, 2, _P.base_bitlinemetal,
            point.create(
                varbank:get_area_anchor("vctrl_inner").l,
                bits[string.format("varactor_%d", row)]:get_area_anchor("bottomplate").b
            ),
            point.create(
                varbank:get_area_anchor("vctrl_inner").r,
                bits[string.format("varactor_%d", row)]:get_area_anchor("bottomplate").t
            )
        )
    end

    -- connect local to global bit lines
    for column = 1, _E.numh do
        for bit = 1, _E.numbits + 1 do
            local offsetfactor1 = column % 2 == 1 and -1 or 0
            local offsetfactor2 = column % 2 == 1 and 0 or 1
            geometry.rectanglebltr(varbank, generics.metal(_P.base_bitlinemetal),
                point.create(
                    varbank:get_area_anchor(string.format("localbitline_%d_%d", column, bit)).l,
                    (varbank:get_area_anchor(string.format("bitline_%d", bit)).b + varbank:get_area_anchor(string.format("bitline_%d", bit)).t) / 2 - _E.innerbitlinewidth / 2
                ),
                point.create(
                    varbank:get_area_anchor(string.format("localbitline_%d_%d", column, bit)).r,
                    varbank:get_area_anchor(string.format("localbitline_%d_%d", column, bit)).b
                )
            )
            geometry.viabltr(varbank, _P.base_bitlinemetal, _P.base_bitlinemetal + 1,
                point.create(
                    varbank:get_area_anchor(string.format("localbitline_%d_%d", column, bit)).l + offsetfactor1 * _E.bitlineviafactor * _E.innerbitlinewidth,
                    (varbank:get_area_anchor(string.format("bitline_%d", bit)).b + varbank:get_area_anchor(string.format("bitline_%d", bit)).t) / 2 - _E.innerbitlinewidth / 2
                ),
                point.create(
                    varbank:get_area_anchor(string.format("localbitline_%d_%d", column, bit)).l + offsetfactor2 * _E.bitlineviafactor * _E.innerbitlinewidth,
                    (varbank:get_area_anchor(string.format("bitline_%d", bit)).b + varbank:get_area_anchor(string.format("bitline_%d", bit)).t) / 2 + _E.innerbitlinewidth / 2
                )
            )
        end
    end

    -- connect local to global vctrl line
    varbank:add_anchor("vctrl",
        point.create(
            (varbank:get_area_anchor("vctrl_inner").l + varbank:get_area_anchor("vctrl_inner").r) / 2,
            (varbank:get_area_anchor(string.format("bitline_%d", _E.numbits + 1)).b + varbank:get_area_anchor(string.format("bitline_%d", 1)).t) / 2 - _E.innerbitlinewidth / 2
        )
    )
    geometry.rectanglebltr(varbank, generics.metal(_P.ctrlmetal),
        point.create(
            varbank:get_area_anchor("vctrl_inner").l,
            varbank:get_anchor("vctrl"):gety()
        ),
        point.create(
            varbank:get_area_anchor("vctrl_inner").r,
            varbank:get_area_anchor("vctrl_inner").b
        )
    )

    -- connect split topplates
    -- the topplates are inverted (left becomes right and vice versa),
    -- due to how the circuit is laid out.
    -- This leads to shorter connections in the oscillator core
    varbank:add_area_anchor_bltr("lefttopplate",
        point.create(
            varbank:get_area_anchor(string.format("lefttopplate_%d", 1)).l,
            varbank:get_area_anchor(string.format("lefttopplate_%d", 1)).b - _E.topplatespace - _P.base_topplatewidth
        ),
        point.create(
            varbank:get_area_anchor(string.format("lefttopplate_%d", _E.numh)).r,
            varbank:get_area_anchor(string.format("lefttopplate_%d", 1)).b - _E.topplatespace
        )
    )
    geometry.rectanglebltr(varbank, generics.metal(8),
        varbank:get_area_anchor("lefttopplate").bl,
        varbank:get_area_anchor("lefttopplate").tr
    )
    for column = 1, _E.numh do
        geometry.rectanglebltr(varbank, generics.metal(8),
            point.create(
                varbank:get_area_anchor(string.format("lefttopplate_%d", column)).l,
                varbank:get_area_anchor("lefttopplate").t
            ),
            point.create(
                varbank:get_area_anchor(string.format("lefttopplate_%d", column)).r,
                varbank:get_area_anchor(string.format("lefttopplate_%d", column)).b
            )
        )
    end
    varbank:add_area_anchor_bltr("righttopplate",
        point.create(
            varbank:get_area_anchor(string.format("righttopplate_%d", 1)).l,
            varbank:get_area_anchor(string.format("righttopplate_%d", 1)).t + _E.topplatespace
        ),
        point.create(
            varbank:get_area_anchor(string.format("righttopplate_%d", _E.numh)).r,
            varbank:get_area_anchor(string.format("righttopplate_%d", 1)).t + _E.topplatespace + _P.base_topplatewidth
        )
    )
    geometry.rectanglebltr(varbank, generics.metal(8),
        varbank:get_area_anchor("righttopplate").bl,
        varbank:get_area_anchor("righttopplate").tr
    )
    for column = 1, _E.numh do
        geometry.rectanglebltr(varbank, generics.metal(8),
            point.create(
                varbank:get_area_anchor(string.format("righttopplate_%d", column)).l,
                varbank:get_area_anchor(string.format("righttopplate_%d", column)).t
            ),
            point.create(
                varbank:get_area_anchor(string.format("righttopplate_%d", column)).r,
                varbank:get_area_anchor("righttopplate").b
            )
        )
    end

    -- psub guard ring
    layouthelpers.place_guardring_quantized(
        varbank,
        varbank:get_alignment_anchor("outerbl"),
        varbank:get_alignment_anchor("outertr"),
        _P.psub_guardring_xspace, _P.psub_guardring_yspace,
        2 * _P.psub_guardring_ringwidth,
        2 * _P.psub_guardring_ringwidth,
        "psubguardring_",
        {
            fit = true,
            ringwidth = _P.psub_guardring_ringwidth,
            --wellextension = env.genericguardring.wellextension,
            --soiopenextension = env.psubguardring.soiopenextension,
            --implantextension = env.psubguardring.implantextension,
            fillinnerimplant = true,
            contype = "p",
        }
    )

    -- add anchor for bus placement
    varbank:add_anchor("rightbusin",
        point.create(
            varbank:get_area_anchor(string.format("bitline_%d", 1)).r,
            (varbank:get_area_anchor(string.format("bitline_%d", _E.numbits + 1)).t + varbank:get_area_anchor(string.format("bitline_%d", 1)).b) / 2
        )
    )
    varbank:add_anchor("leftbusin",
        point.create(
            varbank:get_area_anchor(string.format("bitline_%d", 1)).l,
            (varbank:get_area_anchor(string.format("bitline_%d", _E.numbits + 1)).t + varbank:get_area_anchor(string.format("bitline_%d", 1)).b) / 2
        )
    )

    -- excludes
    for metal = 1, 2 do
        varbank:add_layer_boundary_rectangular(generics.metal(metal),
            varbank:get_area_anchor("psubguardring_outerboundary").bl,
            varbank:get_area_anchor("psubguardring_outerboundary").tr
        )
    end
    for metal = _P.base_bitlinemetal, _P.base_bitlinemetal + 1 do
        varbank:add_layer_boundary_rectangular(generics.metal(metal),
            point.create(
                varbank:get_area_anchor("psubguardring_outerboundary").l,
                varbank:get_area_anchor(string.format("bitline_%d", _E.numbits + 1)).b - _P.boundaryextensions[metal].y
            ),
            varbank:get_area_anchor("psubguardring_outerboundary").tr
        )
    end
    for metal = 5, 7 do
        varbank:add_layer_boundary_rectangular(generics.metal(metal),
            varbank:get_area_anchor("psubguardring_outerboundary").bl,
            varbank:get_area_anchor("psubguardring_outerboundary").tr
        )
    end

    -- add ports
    varbank:add_bus_port(
        "enable",
        generics.metalport(_P.base_bitlinemetal + 1),
        point.create(
            (varbank:get_area_anchor(string.format("bitline_%d", _E.numbits + 1)).l + varbank:get_area_anchor(string.format("bitline_%d", _E.numbits + 1)).r) / 2,
            varbank:get_area_anchor(string.format("bitline_%d", _E.numbits + 1)).b
        ),
        _E.numbits - 1, 0,
        0,
        env.oscillator.buswidth + env.oscillator.busspace
    )
    for column = 1, _E.numh do
        for _, powerlabel in ipairs({ "vdd", "vss" }) do
            for _, half in ipairs({ lefthalf, righthalf }) do
                for _, side in ipairs({ "left", "right" }) do
                    varbank:add_port(
                        powerlabel,
                        generics.metalport(_E.powerlineendmetal),
                        varbank:get_area_anchor(string.format("%s%sline_%d", side, powerlabel, column)).bl,
                        400
                    )
                end
            end
        end
    end
    varbank:add_port(
        "vss",
        generics.metalport(_P.base_bitlinemetal + 1),
        point.create(
            (varbank:get_area_anchor(string.format("bitline_%d", 1)).l + varbank:get_area_anchor(string.format("bitline_%d", 1)).r) / 2,
            varbank:get_area_anchor(string.format("bitline_%d", 1)).b
        )
    )
    for _, position in ipairs({ "bl", "br", "tl", "tr" }) do
        varbank:add_port(
            "vss",
            generics.metalport(1),
            varbank:get_area_anchor("psubguardring_outerboundary")[position]
        )
    end
    for _, side in ipairs({ "left", "right" }) do
        varbank:add_port(
            string.format("v%s", side),
            generics.metalport(8),
            point.create(
                (varbank:get_area_anchor(string.format("%stopplate", side)).l + varbank:get_area_anchor(string.format("%stopplate", side)).r) / 2,
                (varbank:get_area_anchor(string.format("%stopplate", side)).b + varbank:get_area_anchor(string.format("%stopplate", side)).t) / 2
            )
        )
    end
    if _E.placesubstractlabel then
        varbank:add_port(
            "sx",
            generics.otherport("pwell"),
            point.create(
                (varbank:get_area_anchor("psubguardring_outerboundary").l + varbank:get_area_anchor("psubguardring_outerboundary").r) / 2,
                varbank:get_area_anchor("psubguardring_outerboundary").b - 1000
            )
        )
    end
    -- analog tuning
    varbank:add_port(
        "vctrl",
        generics.metalport(_P.ctrlmetal),
        point.create(
            (varbank:get_area_anchor("vctrl_inner").l + varbank:get_area_anchor("vctrl_inner").r) / 2,
            varbank:get_area_anchor("vctrl_inner").b
        )
    )
    --[[
    --]]

    -- center varbank
    local diff = point.xaverage(
        varbank:get_alignment_anchor("outerbl"),
        varbank:get_alignment_anchor("outertr")
    )
    varbank:translate_x(-diff)
end
-- vim: nowrap
