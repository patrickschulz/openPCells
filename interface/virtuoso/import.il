procedure(OPCImportWriteInitial(file)
    let(
        (lines)
        lines = list(
            "local filename = \"opctoplevel.cdl\""
            ""
            "local netlist = import.read_CDL_netlist(filename)"
            ""
            "--import.report_netlist(netlist)"
            ""
            "local devicemap = {"
            "   mosfet = {"
            "       nmos = import.maps.mosfet({"
            "           channeltype = \"nmos\","
            "           vthtype = 1,"
            "           oxidetype = 1,"
            "           flippedwell = true,"
            "       }),"
            "       pmos = import.maps.mosfet({"
            "           channeltype = \"pmos\","
            "           vthtype = 1,"
            "           oxidetype = 1,"
            "           flippedwell = true,"
            "       }),"
            "   },"
            "}"
            ""
            "-- placement"
            "local devices = import.map_netlist_devices(netlist, devicemap)"
            "local groups = {"
            "    -- specify devices that should be within one group:"
            "    { \"M0\", \"M1\" }, -- example syntax"
            "}"
            "local constraints = {"
            ""
            "}"
            "local ignored_nets = { \"vdd\", \"vss\", }"
            "local places, pinfo = placement.place_analog(devices, groups, constraints, ignored_nets)"
            ""
            "--import.report_devices(devices)"
            ""
            "--local routes = routing.route_analog(devices, places, ignored_nets)"
            ""
            "--import.check(devices, placeinstructions, { devices = \"warn\", placement = \"error\" })"
            ""
            "local filename = \"toplevel.lua\""
            "local file = io.open(filename, \"w\")"
            "generator.analog(file, settings, devices, places, routes)"
            "file:close()"
            "print(string.format(\"created file '%s'\", filename))"
        )
        foreach(line lines
            fprintf(file "%s\n" line)
        )
    ) ; let
) ; OPCImportWriteInitial

procedure(OPCImportEditScript()
    letseq(
        (
            (cv geGetEditCellView())
            (libPath cv->lib->readPath)
            (cellName cv->cellName)
            path file
        )
        path = lsprintf("%s/%s/layout/opcimport.lua" libPath cellName)
        unless(isFile(path)
            ; add some starting code to empty import scripts
            file = outfile(path "w")
            OPCImportWriteInitial(file)
            close(file)
        )
        OPCOpenEditor(path)
    )
) ; OPCImportEditScript

