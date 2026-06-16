procedure(OPCPowergridWriteInitial(file)
    let(
        (lines)
        lines = list(
            "-- main power grid shapes cell"
            "local cell = object.create(\"opcpowergrid\")"
            ""
            "-- base cell"
            "local base = pcell.create_layout_from_script(\"openPCells_cellshapes.lua\")"
            ""
            "-- target metals (can also be nil/emtpy)"
            "local targetmetals = { 1 }"
            ""
            "-- power nets"
            "local powernets = { \"vdd\", \"vss\" }"
            ""
            "-- keep-out purposes (should at least include generics.metal)"
            "local keepout_purposes = { generics.metal, generics.metalexclude }"
            ""
            "-- size hint for labels"
            "local sizehint = 100"
            ""
            "-- annotate excludes"
            "local annotate_excludes = false"
            ""
            "-- offset/distance for via creation"
            "local viaoffset = 500"
            ""
            "-- place preliminary power connections (only labels for virtual connections during LVS runs)?"
            "local preliminary = false"
            ""
            "-- check if there are power shapes"
            "local has_power_shapes = false"
            "for _, net in ipairs(powernets) do"
            "    for _, metal in ipairs(targetmetals) do"
            "        local S = base:get_net_shapes(net, generics.metal(metal))"
            "        if #S > 0 then"
            "            has_power_shapes = true"
            "            break"
            "        end"
            "    end"
            "end"
            "if not has_power_shapes then"
            "    error(\"target cell does not contain any relevant net shapes\")"
            "end"
            ""
            "if preliminary then"
            "    for _, net in ipairs(powernets) do"
            "        for _, metal in ipairs(targetmetals) do"
            "            local S = base:get_net_shapes(net, generics.metal(metal))"
            "            for _, shape in ipairs(S) do"
            "                cell:add_port(net, generics.metalport(metal), shape.bl, sizehint)"
            "            end"
            "        end"
            "    end"
            "else"
            "    -- power grid metal definition"
            "    local powerdef = {"
            "        {"
            "            metal = 2,"
            "            width = 1000,"
            "            space = 1000,"
            "            offset = 200,"
            "        },"
            "        {"
            "            metal = 3,"
            "            width = 1000,"
            "            space = 1000,"
            "            offset = 300,"
            "        },"
            "    }"
            "    local first_is_vertical = true"
            ""
            "    -- target area"
            "    local pbl = point.create(0, 0)"
            "    local ptr = point.create(10000, 10000)"
            ""
            "    -- all-metal excludes"
            "    local global_excludes = {}"
            ""
            "    -- place only full-size vias"
            "    local only_full_vias = true"
            ""
            "    -- draw boundary"
            "    geometry.rectanglebltr(cell, generics.outline(), pbl, ptr)"
            ""
            "    -- place lines and store shapes lines"
            "    local powerlines"
            "    for i, def in ipairs(powerdef) do"
            "        local func = {}"
            "        if i % 2 == 1 and first_is_vertical then"
            "            func = layouthelpers.place_vlines"
            "        else"
            "            func = layouthelpers.place_hlines"
            "        end"
            "        local excludes = {}"
            "        util.insert_table(excludes, global_excludes)"
            "        for _, purpose in ipairs(keepout_purposes) do"
            "            local S = base:get_shape_outlines(purpose(def.metal), def.offset)"
            "            util.insert_table(excludes, S)"
            "        end"
            "        if annotate_excludes then"
            "            for _, shape in ipairs(excludes) do"
            "                geometry.polygon(cell, generics.metalexclude(def.metal), shape)"
            "            end"
            "        end"
            "        local lines = func"
            "            cell,"
            "            pbl, ptr,"
            "            generics.metal(def.metal),"
            "            def.width, def.space,"
            "            def.width, -- minwidth"
            "            powernets,"
            "            excludes"
            "        )"
            "        layouthelpers.annotate_netshapes(cell, lines, sizehint)"
            "        powerlines[i] = lines"
            "    end"
            ""
            "    -- connect target shapes to power grid on below/above power metals"
            "    for _, targetmetal in ipairs(targetmetals or {}) do"
            "        local netshapes = {}"
            "        for _, net in ipairs(powernets) do"
            "            util.insert_table(netshapes, base:get_net_shapes(net, generics.metal(targetmetal)))"
            "        end"
            "        -- find metal above target metal"
            "        local index"
            "        for i, def in ipairs(powerdef) do"
            "            if def.metal > targetmetal then"
            "                index = i"
            "                break"
            "            end"
            "        end"
            "        if index then"
            "            local powermetal = powerdef[index].metal"
            "            -- get intermediate shapes between targetmetal and lowest grid metal"
            "            local intermediate_shapes = {}"
            "            if lowerpmetal then"
            "                for metal = targetmetal + 1, powermetal - 1 do"
            "                    local shapes = base:get_shape_outlines(generics.metal(metal), viaoffset)"
            "                    util.insert_table(intermediate_shapes, shapes)"
            "                end"
            "            end"
            "            layouthelpers.place_vias("
            "                cell,"
            "                netshapes, powerlines[index],"
            "                intermediate_shapes, -- excludes"
            "                nil, -- net filter"
            "                only_full_vias"
            "            )"
            "        end"
            "    end"
            ""
            "    -- place vias between power lines"
            "    for i = 1, #powerdef - 1 do"
            "        layouthelpers.place_vias("
            "            cell,"
            "            powerlines[i], powerlines[i + 1],"
            "            nil, nil, -- no excludes, no filter"
            "            only_full_vias"
            "        )"
            "    end"
            ""
            "    -- add labels to grid-level netshapes for virtual-connect LVS (only for non-grid configurations)"
            "    if #powerdef == 1 then"
            "        local def = powerdef[1]"
            "        for _, net in ipairs(powernets) do"
            "            for _, shape in ipairs(powerlines[1]) do"
            "                cell:add_port(net, generics.metalport(def.metal), shape.bl, sizehint)"
            "                cell:add_port(net, generics.metalport(def.metal), shape.tr, sizehint)"
            "            end"
            "        end"
            "    end"
            "end"
            ""
            "-- return shapes"
            "return cell"
        )
        foreach(line lines
            fprintf(file "%s\n" line)
        )
    ) ; let
) ; OPCPowergridWriteInitial

procedure(OPCPowergridEditScript()
    letseq(
        (
            (cv geGetEditCellView())
            (libPath cv->lib->readPath)
            (cellName cv->cellName)
            path file
        )
        path = lsprintf("%s/%s/layout/opcpowergrid.lua" libPath cellName)
        unless(isFile(path)
            ; add some starting code to empty powergrid scripts
            file = outfile(path "w")
            OPCPowergridWriteInitial(file)
            close(file)
        )
        OPCOpenEditor(path)
    )
) ; OPCPowergridEditScript

procedure(OPCUpdatePowergridCallback(@key (deleteAll t) (callopc t) (hierarchical nil) (origin list(0 0)) (useOrigin nil))
    letseq(
        (
            (cv geGetEditCellView())
            (libPath cv->lib->readPath)
            (libname cv->libName) ; read by generated .il script, don't remove
            (cellName cv->cellName)
            path groupname OPCArgs OPCCmd success
        )
        groupname = "opcpowergrid"
        let(((group dbGetFigGroupByName(cv groupname)))
            when(group
                foreach(obj group->figs dbDeleteObject(obj))
                dbDeleteObject(group)
            )
        )
        ; write out current cell (for exclude shapes)
        OPCExportCell("openPCells_cellshapes.lua")
        ; call powergrid script
        path = lsprintf("%s/%s/layout/opcpowergrid.lua" libPath cellName)
        OPCArgs = OPCPrepareArgsForCellCreation(
            lsprintf("--cellscript %s -f %s" path OPCSettingsForm->OPCCellFilename->value)
            origin
            ?groupname groupname
        )
        ; FIXME: should powergrid always be flat? Currently it is, as the callback is called without parameters and hierarchical is nil
        unless(hierarchical
            OPCArgs = lsprintf("%s --flat" OPCArgs)
        )
        OPCCmd = OPCBuildCallCommand(OPCArgs)
        success = if(callopc
            then
                OPCCall(OPCCmd ?redirect OPCSettingsForm->OPCStdoutFileName->value)
            else
                t
        )
        when(success
            let(((group dbGetFigGroupByName(cv groupname)))
                foreach(obj group->figs dbDeleteObject(obj))
            )
            load(lsprintf("%s.il" OPCSettingsForm->OPCCellFilename->value))
            OPCCleanUp(lsprintf("%s.il" OPCSettingsForm->OPCCellFilename->value))
        )
    )
) ; OPCUpdateCellscriptCallback

procedure(OPCDeletePowergridGroup()
    let(
        (cv groupname)
        cv = geGetEditCellView()
        groupname = "opcpowergrid"
        let(((group dbGetFigGroupByName(cv groupname)))
            when(group
                foreach(obj group->figs dbDeleteObject(obj))
                dbDeleteObject(group)
            )
        )
    )
) ; OPCDeletePowergridGroup

procedure(OPCDeletePowergridScript()
    letseq(
        (
            (cv geGetEditCellView())
            (libPath cv->lib->readPath)
            (cellName cv->cellName)
            (path lsprintf("%s/%s/layout/opcpowergrid.lua" libPath cellName))
        )
        when(isFile(path)
            deleteFile(path)
        )
    )
) ; OPCDeletePowergridScript

/*
procedure(OPCCollectNetShapes()
    let(
        (cv group)
        cv = geGetEditCellView()
        group = dbCreateFigGroup(cv "opcnetshapes")
        foreach(instance cv->instances
            foreach(shape instance->master->shapes
                dbCopyFig(cv shape)
                dbAddFig
            ) ; foreach shapes
        ) ; foreach instances
    ) ; let
) ;

mapcar(lambda( (instTerm)
    list(nil 
        'name instTerm->name 
        'shapes setof(shape master->shapes shape->net->name == instTerm->term->net->name)
    )
))
*/
