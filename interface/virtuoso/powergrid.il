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
            "-- size hint for labels"
            "local sizehint = 100"
            ""
            "-- annotate excludes"
            "local annotate_excludes = false"
            ""
            "-- offset/distance around shapes as exclusion zones"
            "local offset = 500"
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
            "    -- power metals (can be nil)"
            "    local vmetal = 2"
            "    local hmetal = 3"
            "    if not (vmetal or hmetal) then"
            "        error(\"at least one set of metal lines must be placed ('vmetal' and 'hmetal' can not be nil at the same time)\")"
            "    end"
            ""
            "    -- power grid size"
            "    local pwidth = 1000"
            "    local pspace = 1000"
            "    local pgrid = #powernets * (pwidth + pspace)"
            ""
            "    -- target area"
            "    local pbl = point.create(-10000, -10000)"
            "    local ptr = point.create( 10000,  10000)"
            ""
            "    -- place only full-size vias"
            "    local only_full_vias = true"
            ""
            "    -- draw boundary"
            "    geometry.rectanglebltr(cell, generics.outline(), pbl, ptr)"
            ""
            "    -- place vertical lines"
            "    local vlines"
            "    if vmetal then"
            "        local vshapes = base:get_shape_outlines(generics.metal(vmetal), offset)"
            "        if annotate_excludes then"
            "            for _, shape in ipairs(vshapes) do"
            "                geometry.polygon(cell, generics.metalexclude(vmetal), shape)"
            "            end"
            "        end"
            "        vlines = layouthelpers.place_vlines("
            "            cell,"
            "            pbl, ptr,"
            "            generics.metal(vmetal),"
            "            pwidth, pspace,"
            "            pwidth, -- minwidth"
            "            powernets,"
            "            vshapes -- excludes"
            "        )"
            "    end"
            ""
            "    -- place horizontal lines"
            "    local hlines"
            "    if hmetal then"
            "        local hshapes = base:get_shape_outlines(generics.metal(hmetal), offset)"
            "        if annotate_excludes then"
            "            for _, shape in ipairs(hshapes) do"
            "                geometry.polygon(cell, generics.metalexclude(hmetal), shape)"
            "            end"
            "        end"
            "        hlines = layouthelpers.place_hlines("
            "            cell,"
            "            pbl, ptr,"
            "            generics.metal(hmetal),"
            "            pwidth, pspace,"
            "            pwidth, -- minwidth"
            "            powernets,"
            "            hshapes -- excludes"
            "        )"
            "     end"
            ""
            "    -- draw labels to identify shapes"
            "    if vmetal then"
            "        layouthelpers.annotate_netshapes(cell, vlines, sizehint)"
            "    end"
            "    if hmetal then"
            "        layouthelpers.annotate_netshapes(cell, hlines, sizehint)"
            "    end"
            ""
            "    -- lower power metal"
            "    local lowerpmetal = nil"
            "    if vmetal and hmetal then"
            "        lowerpmetal = math.min(vmetal, hmetal)"
            "    elseif vmetal then"
            "        lowerpmetal = vmetal"
            "    else -- hmetal must be non-nil"
            "        lowerpmetal = hmetal"
            "    end"
            ""
            "    -- connect target shapes to power grid"
            "    for _, targetmetal in ipairs(targetmetals or {}) do"
            "        local netshapes = {}"
            "        for _, net in ipairs(powernets) do"
            "            util.insert_table(netshapes, base:get_net_shapes(net, generics.metal(targetmetal)))"
            "        end"
            "        -- lines to connect to"
            "        local powermetal"
            "        local powerlines"
            "        if vmetal and hmetal then"
            "            if targetmetal < math.min(vmetal, hmetal) then -- target metal below power grid"
            "                if vmetal < hmetal then"
            "                    powermetal = vmetal"
            "                    powerlines = vlines"
            "                else"
            "                    powermetal = hmetal"
            "                    powerlines = hlines"
            "                end"
            "            elseif targetmetal > math.max(vmetal, hmetal) then -- target metal above power grid"
            "                if vmetal > hmetal then"
            "                    powermetal = vmetal"
            "                    powerlines = vlines"
            "                else"
            "                    powermetal = hmetal"
            "                    powerlines = hlines"
            "                end"
            "            else -- target metal on power grid"
            "                if targetmetal == hmetal then"
            "                    powermetal = vmetal"
            "                    powerlines = vlines"
            "                else"
            "                    powermetal = hmetal"
            "                    powerlines = hlines"
            "                end"
            "            end"
            "        elseif vmetal then"
            "            powermetal = vmetal"
            "            powerlines = vlines"
            "        else -- hmetal must be non-nil"
            "            powermetal = hmetal"
            "            powerlines = hlines"
            "        end"
            "        -- get intermediate shapes between targetmetal and lowest grid metal"
            "        local intermediate_shapes = {}"
            "        if lowerpmetal then"
            "            for metal = targetmetal + 1, lowerpmetal - 1 do"
            "                local shapes = base:get_shape_outlines(generics.metal(metal), viaoffset)"
            "                util.insert_table(intermediate_shapes, shapes)"
            "            end"
            "        end"
            "        layouthelpers.place_vias("
            "            cell,"
            "            netshapes, powerlines,"
            "            intermediate_shapes, -- excludes"
            "            nil, -- net filter"
            "            only_full_vias"
            "        )"
            "    end"
            ""
            "    -- place vias between power lines"
            "    if hmetal and vmetal then"
            "        layouthelpers.place_vias("
            "            cell,"
            "            vlines, hlines"
            "            nil, nil, -- no excludes, no filter"
            "            only_full_vias
            "        )"
            "    elseif vmetal then"
            "        for _, shape in ipairs(vlines) do"
            "            cell:add_port(shape.net, generics.metalport(vmetal), shape.bl, sizehint)"
            "            cell:add_net_shape(shape.net, shape.bl, shape.tr, shape.layer)"
            "        end"
            "    elseif hmetal then"
            "        for _, shape in ipairs(hlines) do"
            "            cell:add_port(shape.net, generics.metalport(hmetal), shape.bl, sizehint)"
            "            cell:add_net_shape(shape.net, shape.bl, shape.tr, shape.layer)"
            "        end"
            "    end"
            "    -- add labels to grid-level netshapes for virtual-connect LVS"
            "    if (not (vmetal and hmetal)) then"
            "        for _, net in ipairs(powernets) do"
            "            for _, metal in ipairs(targetmetals) do"
            "                if metal >= lowerpmetal then"
            "                    local S = base:get_net_shapes(net, generics.metal(metal))"
            "                    for _, shape in ipairs(S) do"
            "                        cell:add_port(net, generics.metalport(metal), shape.bl, sizehint)"
            "                    end"
            "                end"
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
