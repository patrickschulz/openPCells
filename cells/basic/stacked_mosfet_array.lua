function parameters()
    pcell.add_parameters(
        { "rows", {} },
        { "centermosfets", false },
        { "sharediffusion", true },
        { "splitgates", true },
        { "splitimplant", true, follow = "splitgates" },
        { "splitoxidetype", true, follow = "splitgates" },
        { "splitvthtype", true, follow = "splitgates" },
        { "splitwell", true, follow = "splitgates" },
        { "splitlvsmarker", true, follow = "splitgates" },
        { "splitrotationmarker", true, follow = "splitgates" },
        { "splitanalogmarker", true, follow = "splitgates" },
        { "xalignmosfetsatactive", false },
        { "yalignmosfetsatactive", false },
        { "drawimplant", true },
        { "drawoxidetype", true },
        { "drawwell", true },
        { "sdwidth", technology.get_dimension("Minimum M1 Width") },
        { "xseparation", 0 },
        { "yseparation", 0 },
        { "autoskip", false },
        { "unequalgatelengths", false },
        { "drawguardring", false },
        { "guardringwidth", technology.get_dimension("Minimum Active Contact Region Size") },
        { "guardringsep", technology.get_dimension("Minimum Active Space") },
        { "guardringleftsep", technology.get_dimension("Minimum Active Space"), follow = "guardringsep" },
        { "guardringrightsep", technology.get_dimension("Minimum Active Space"), follow = "guardringsep" },
        { "guardringtopsep", technology.get_dimension("Minimum Active Space"), follow = "guardringsep" },
        { "guardringbottomsep", technology.get_dimension("Minimum Active Space"), follow = "guardringsep" },
        { "guardringrespectactivedummies", false },
        { "guardringrespectgatestraps", true },
        { "guardringrespectgateextensions", true },
        { "guardringrespectsourcestraps", true },
        { "guardringrespectdrainstraps", true },
        { "guardringfillimplant", false },
        { "guardringfillwell", false },
        { "guardringdrawoxidetype", true },
        { "guardringfilloxidetype", false },
        { "guardringoxidetype", 1 },
        { "guardringwellinnerextension", technology.get_dimension("Minimum Well Extension") },
        { "guardringwellouterextension", technology.get_dimension("Minimum Well Extension") },
        { "guardringimplantinnerextension", technology.get_dimension("Minimum Implant Extension") },
        { "guardringimplantouterextension", technology.get_dimension("Minimum Implant Extension") },
        { "guardringsoiopeninnerextension", technology.get_optional_dimension("Minimum Soiopen Extension", 0) },
        { "guardringsoiopenouterextension", technology.get_optional_dimension("Minimum Soiopen Extension", 0) },
        { "guardringoxidetypeinnerextension", technology.get_dimension("Minimum Oxide Extension") },
        { "guardringoxidetypeouterextension", technology.get_dimension("Minimum Oxide Extension") },
        { "checkshorts", true }
    )
end

function check(_P)
    local rowfingers = {}
    -- check that rows are present
    if #_P.rows == 0 then
        return false, "the row definition does not define any rows"
    end
    -- check that every row defines devices
    for rownum, row in ipairs(_P.rows) do
        if not row.devices or #row.devices == 0 then
            return false, string.format("row %d does not define any devices", rownum)
        end
    end
    -- check that every device specifies the number of fingers
    for rownum, row in ipairs(_P.rows) do
        for devicenum, device in ipairs(row.devices) do
            if not device.fingers then
                return false, string.format("device %d in row %d (\"%s\") has no finger specification", devicenum, rownum, device.name)
            end
        end
    end
    -- check that no device has zero or negative number of fingers (zero is allowed with autoskip set to true)
    for rownum, row in ipairs(_P.rows) do
        for devicenum, device in ipairs(row.devices) do
            if not _P.autoskip and (device.fingers <= 0 and not device.skip) then
                return false, string.format("device %d in row %d (\"%s\") has zero or negative amount of fingers (%d). If this is intensional, set 'autoskip' to true", devicenum, rownum, device.name, device.fingers)
            end
        end
    end
    -- check that all devices have an integer number of fingers
    -- (typically happens when the number of fingers is a result of an expression in a calling layout cell)
    for rownum, row in ipairs(_P.rows) do
        for devicenum, device in ipairs(row.devices) do
            if not math.tointeger(device.fingers) then
                return false, string.format("device %d in row %d (\"%s\") has a non-integer number of fingers (%f)", devicenum, rownum, device.name, device.fingers)
            end
        end
    end
    -- collect number of fingers per row
    for rownum, row in ipairs(_P.rows) do
        local f = 0
        for devicenum, device in ipairs(row.devices) do
            f = f + device.fingers
        end
        rowfingers[rownum] = f
    end
    -- check that all rows have the same number of fingers
    -- with unequalgatelengths this check is not performed
    if not _P.unequalgatelengths then
        local fingersperrow = rowfingers[1]
        for i = 2, #rowfingers do
            if fingersperrow ~= rowfingers[i] then
                return false, string.format("rows don't have the same number of fingers (first row has %d fingers, %d. row has %d fingers). If this is intentional, set 'unequalgatelengths' to true", fingersperrow, i, rowfingers[i])
            end
        end
    end
    -- check that every device explicitely defines the channeltype
    for rownum, row in ipairs(_P.rows) do
        if not row.channeltype then
            return false, string.format("row %d does not have a channeltype", rownum)
        end
    end
    -- check that every device has a name and that it is unique (the names are used for creating anchors)
    local names = {}
    for rownum, row in ipairs(_P.rows) do
        for devicenum, device in ipairs(row.devices) do
            if not device.name then
                return false, string.format("device %d in row %d does not have a name", devicenum, rownum)
            else
                if names[device.name] then
                    return false, string.format("device %d in row %d does not have a unique name ('%s')", devicenum, rownum, device.name)
                end
                names[device.name] = true
            end
        end
    end
    return true
end

-- this function returns nil when the respective parameters are not specified
-- the explicit nil checks (as opposed to 'if not devparam[name]') are important
-- for follower-parameters, where false is handled different than nil
-- this was a source for subtle bugs
-- therefore, this function MUST be used to pass parameters to the underlying mosfet pcell
local function _select_parameter(name, devparam, rowparam, cellparam)
    if devparam[name] == nil then
        if rowparam[name] == nil then
            return cellparam and cellparam[name]
        else
            return rowparam[name]
        end
    else
        return devparam[name]
    end
end

-- convenience function that implements x = switch and a or b
local function _select_switch(switch, a, b)
    if switch then
        return a
    else
        return b
    end
end

function layout(cell, _P)
    -- create mosfets (but don't place them)
    local mosfetrows = {}
    for rownum, row in ipairs(_P.rows) do
        local mosfetrow = {}
        for devnum, device in ipairs(row.devices) do
            -- create mosfet
            if not (device.skip or (device.fingers <= 0)) then
                local status, mosfet = xpcall(pcell.create_layout, fulltraceback, "basic/mosfet", device.name, {
                    channeltype = row.channeltype,
                    implantalignwithactive = not _P.splitimplant or row.implantalignwithactive,
                    flippedwell = row.flippedwell,
                    gatelength = row.gatelength,
                    gatespace = row.gatespace,
                    fingerwidth = row.width,
                    fingers = device.fingers,
                    drawoxidetype = _select_parameter("drawoxidetype", device, row, _P),
                    oxidetype = row.oxidetype,
                    oxidetypealignwithactive = not _P.splitoxidetype or row.oxidetypealignwithactive,
                    vthtype = row.vthtype,
                    vthtypealignwithactive = not _P.splitvthtype or row.vthtypealignwithactive,
                    drawimplant = _select_parameter("drawimplant", device, row, _P),
                    gatemarker = row.gatemarker,
                    mosfetmarker = row.mosfetmarker,
                    mosfetmarkeralignatsourcedrain = row.mosfetmarkeralignatsourcedrain,
                    actext = _select_parameter("actext", device, row),
                    sdwidth = _select_parameter("sdwidth", device, row, _P),
                    sdviawidth = _select_parameter("sdviawidth", device, row),
                    sdmetalwidth = _select_parameter("sdmetalwidth", device, row),
                    sdm1botext = _select_parameter("sdm1botext", device, row),
                    sdm1topext = _select_parameter("sdm1topext", device, row),
                    interweavevias = _select_parameter("interweavevias", device, row),
                    alternateinterweaving = _select_parameter("alternateinterweaving", device, row),
                    minviaxspace = _select_parameter("minviaxspace", device, row),
                    minviayspace = _select_parameter("minviayspace", device, row),
                    gtopext = _select_switch(((rownum == #_P.rows) or _P.splitgates), _select_parameter("gtopext", device, row), _P.yseparation / 2),
                    gbotext = _select_switch(((rownum == 1) or _P.splitgates), _select_parameter("gbotext", device, row), _P.yseparation / 2), 
                    gtopextadd = _select_parameter("gtopextadd", device, row),
                    gbotextadd = _select_parameter("gbotextadd", device, row),
                    gatetopabsoluteheight = _select_parameter("gatetopabsoluteheight", device, row),
                    gatebotabsoluteheight = _select_parameter("gatebotabsoluteheight", device, row),
                    cliptop = _select_parameter("cliptop", device, row),
                    clipbot = _select_parameter("clipbot", device, row),
                    drawleftstopgate = _select_parameter("drawleftstopgate", device, row),
                    drawrightstopgate = _select_parameter("drawrightstopgate", device, row),
                    endleftwithgate = _select_parameter("endleftwithgate", device, row),
                    endrightwithgate = _select_parameter("endrightwithgate", device, row),
                    leftendgatelength = _select_parameter("leftendgatelength", device, row),
                    leftendgatespace = _select_parameter("leftendgatespace", device, row),
                    rightendgatelength = _select_parameter("rightendgatelength", device, row),
                    rightendgatespace = _select_parameter("rightendgatespace", device, row),
                    drawtopgate = _select_parameter("drawtopgate", device, row),
                    drawtopgatestrap = _select_parameter("drawtopgatestrap", device, row),
                    topgatewidth = _select_parameter("topgatewidth", device, row),
                    topgateleftextension = _select_parameter("topgateleftextension", device, row),
                    topgaterightextension = _select_parameter("topgaterightextension", device, row),
                    topgatespace = _select_parameter("topgatespace", device, row),
                    topgatemetal = _select_parameter("topgatemetal", device, row),
                    drawtopgatevia = _select_parameter("drawtopgatevia", device, row),
                    topgatecontinuousvia = _select_parameter("topgatecontinuousvia", device, row),
                    drawbotgate = _select_parameter("drawbotgate", device, row),
                    drawbotgatestrap = _select_parameter("drawbotgatestrap", device, row),
                    botgatewidth = _select_parameter("botgatewidth", device, row),
                    botgatespace = _select_parameter("botgatespace", device, row),
                    botgateleftextension = _select_parameter("botgateleftextension", device, row),
                    botgaterightextension = _select_parameter("botgaterightextension", device, row),
                    botgatemetal = _select_parameter("botgatemetal", device, row),
                    drawbotgatevia = _select_parameter("drawbotgatevia", device, row),
                    botgatecontinuousvia = _select_parameter("botgatecontinuousvia", device, row),
                    botgateviatarget = _select_parameter("botgateviatarget", device, row),
                    drawtopgatecut = _select_parameter("drawtopgatecut", device, row),
                    topgatecutheight = _select_parameter("topgatecutheight", device, row),
                    topgatecutspace = _select_parameter("topgatecutspace", device, row),
                    topgatecutleftext = _select_parameter("topgatecutleftext", device, row),
                    topgatecutrightext = _select_parameter("topgatecutrightext", device, row),
                    drawbotgatecut = _select_parameter("drawbotgatecut", device, row),
                    botgatecutheight = _select_parameter("botgatecutheight", device, row),
                    botgatecutspace = _select_parameter("botgatecutspace", device, row),
                    botgatecutleftext = _select_parameter("botgatecutleftext", device, row),
                    botgatecutrightext = _select_parameter("botgatecutrightext", device, row),
                    simulatemissinggatecut = _select_parameter("simulatemissinggatecut", device, row),
                    drawsourcedrain = _select_parameter("drawsourcedrain", device, row),
                    excludesourcedraincontacts = _select_parameter("excludesourcedraincontacts", device, row),
                    sourcesize = _select_parameter("sourcesize", device, row),
                    sourceviasize = _select_parameter("sourceviasize", device, row),
                    drainsize = _select_parameter("drainsize", device, row),
                    drainviasize = _select_parameter("drainviasize", device, row),
                    sourcealign = _select_parameter("sourcealign", device, row),
                    sourceviaalign = _select_parameter("sourceviaalign", device, row),
                    drainalign = _select_parameter("drainalign", device, row),
                    drainviaalign = _select_parameter("drainviaalign", device, row),
                    drawsourcevia = _select_parameter("drawsourcevia", device, row),
                    drawfirstsourcevia = _select_parameter("drawfirstsourcevia", device, row),
                    drawlastsourcevia = _select_parameter("drawlastsourcevia", device, row),
                    connectsource = _select_parameter("connectsource", device, row),
                    drawsourcestrap = _select_parameter("drawsourcestrap", device, row),
                    drawsourceconnections = _select_parameter("drawsourceconnections", device, row),
                    connectsourceboth = _select_parameter("connectsourceboth", device, row),
                    connectsourcewidth = _select_parameter("connectsourcewidth", device, row),
                    connectsourcespace = _select_parameter("connectsourcespace", device, row),
                    connectsourceleftext = _select_parameter("connectsourceleftext", device, row),
                    connectsourcerightext = _select_parameter("connectsourcerightext", device, row),
                    connectsourceotherwidth = _select_parameter("connectsourceotherwidth", device, row),
                    connectsourceotherspace = _select_parameter("connectsourceotherspace", device, row),
                    connectsourceotherleftext = _select_parameter("connectsourceotherleftext", device, row),
                    connectsourceotherrightext = _select_parameter("connectsourceotherrightext", device, row),
                    sourcemetal = _select_parameter("sourcemetal", device, row),
                    sourcestartmetal = _select_parameter("sourcestartmetal", device, row),
                    sourceendmetal = _select_parameter("sourceendmetal", device, row),
                    sourceviametal = _select_parameter("sourceviametal", device, row),
                    connectsourceinline = _select_parameter("connectsourceinline", device, row),
                    connectsourceinlineoffset = _select_parameter("connectsourceinlineoffset", device, row),
                    connectsourceinverse = _select_parameter("connectsourceinverse", device, row),
                    connectdrain = _select_parameter("connectdrain", device, row),
                    drawdrainstrap = _select_parameter("drawdrainstrap", device, row),
                    drawdrainconnections = _select_parameter("drawdrainconnections", device, row),
                    connectdrainboth = _select_parameter("connectdrainboth", device, row),
                    connectdrainwidth = _select_parameter("connectdrainwidth", device, row),
                    connectdrainspace = _select_parameter("connectdrainspace", device, row),
                    connectdrainleftext = _select_parameter("connectdrainleftext", device, row),
                    connectdrainrightext = _select_parameter("connectdrainrightext", device, row),
                    connectdraininverse = _select_parameter("connectdraininverse", device, row),
                    connectdrainotherwidth = _select_parameter("connectdrainotherwidth", device, row),
                    connectdrainotherspace = _select_parameter("connectdrainotherspace", device, row),
                    connectdrainotherleftext = _select_parameter("connectdrainotherleftext", device, row),
                    connectdrainotherrightext = _select_parameter("connectdrainotherrightext", device, row),
                    drawdrainvia = _select_parameter("drawdrainvia", device, row),
                    drawfirstdrainvia = _select_parameter("drawfirstdrainvia", device, row),
                    drawlastdrainvia = _select_parameter("drawlastdrainvia", device, row),
                    drainmetal = _select_parameter("drainmetal", device, row),
                    drainstartmetal = _select_parameter("drainstartmetal", device, row),
                    drainendmetal = _select_parameter("drainendmetal", device, row),
                    drainviametal = _select_parameter("drainviametal", device, row),
                    connectdraininline = _select_parameter("connectdraininline", device, row),
                    connectdraininlineoffset = _select_parameter("connectdraininlineoffset", device, row),
                    diodeconnected = _select_parameter("diodeconnected", device, row),
                    drawextrabotstrap = _select_parameter("drawextrabotstrap", device, row),
                    extrabotstrapwidth = _select_parameter("extrabotstrapwidth", device, row),
                    extrabotstrapspace = _select_parameter("extrabotstrapspace", device, row),
                    extrabotstrapmetal = _select_parameter("extrabotstrapmetal", device, row),
                    extrabotstrapleftalign = _select_parameter("extrabotstrapleftalign", device, row),
                    extrabotstraprightalign = _select_parameter("extrabotstraprightalign", device, row),
                    drawextratopstrap = _select_parameter("drawextratopstrap", device, row),
                    extratopstrapwidth = _select_parameter("extratopstrapwidth", device, row),
                    extratopstrapspace = _select_parameter("extratopstrapspace", device, row),
                    extratopstrapmetal = _select_parameter("extratopstrapmetal", device, row),
                    extratopstrapleftalign = _select_parameter("extratopstrapleftalign", device, row),
                    extratopstraprightalign = _select_parameter("extratopstraprightalign", device, row),
                    shortdevice = _select_parameter("shortdevice", device, row),
                    shortdeviceleftoffset = _select_parameter("shortdeviceleftoffset", device, row),
                    shortdevicerightoffset = _select_parameter("shortdevicerightoffset", device, row),
                    shortlocation = _select_parameter("shortlocation", device, row),
                    shortwidth = _select_parameter("shortwidth", device, row),
                    shortspace = _select_parameter("shortspace", device, row),
                    shortsourcegate = _select_parameter("shortsourcegate", device, row),
                    shortdraingate = _select_parameter("shortdraingate", device, row),
                    drawtopactivedummy = _select_parameter("drawtopactivedummy", device, row),
                    topactivedummywidth = _select_parameter("topactivedummywidth", device, row),
                    topactivedummysep = _select_parameter("topactivedummysep", device, row),
                    drawbotactivedummy = _select_parameter("drawbotactivedummy", device, row),
                    botactivedummywidth = _select_parameter("botactivedummywidth", device, row),
                    botactivedummysep = _select_parameter("botactivedummysep", device, row),
                    leftfloatingdummies = _select_parameter("leftfloatingdummies", device, row),
                    rightfloatingdummies = _select_parameter("rightfloatingdummies", device, row),
                    drawactive = _select_parameter("drawactive", device, row),
                    lvsmarker = _select_parameter("lvsmarker", device, row),
                    lvsmarkeralignwithactive = not _P.splitlvsmarker or _select_parameter("lvsmarkeralignwithactive", device, row),
                    extendalltop = _select_switch(((rownum == #_P.rows) or _P.splitgates), _select_parameter("extendalltop", device, row), _P.yseparation / 2),
                    extendallbottom = _select_switch(((rownum == 1) or _P.splitgates), _select_parameter("extendallbottom", device, row), _P.yseparation / 2),
                    extendallleft = _select_parameter("extendallleft", device, row),
                    extendallright = _select_parameter("extendallright", device, row),
                    extendoxidetypetop = _select_switch(((rownum == #_P.rows) or _P.splitoxidetype), _select_parameter("extendoxidetypetop", device, row), _P.yseparation / 2),
                    extendoxidetypebottom = _select_switch(((rownum == 1) or _P.splitoxidetype), _select_parameter("extendoxidetypebottom", device, row), _P.yseparation / 2),
                    extendoxidetypeleft = _select_parameter("extendoxidetypeleft", device, row),
                    extendoxidetyperight = _select_parameter("extendoxidetyperight", device, row),
                    extendvthtypetop = _select_switch(((rownum == #_P.rows) or _P.splitvthtype), _select_parameter("extendvthtypetop", device, row), _P.yseparation / 2),
                    extendvthtypebottom = _select_switch(((rownum == 1) or _P.splitvthtype), _select_parameter("extendvthtypebottom", device, row), _P.yseparation / 2),
                    extendvthtypeleft = _select_parameter("extendvthtypeleft", device, row),
                    extendvthtyperight = _select_parameter("extendvthtyperight", device, row),
                    extendimplanttop = _select_switch(((rownum == #_P.rows) or _P.splitimplant), _select_parameter("extendimplanttop", device, row), _P.yseparation / 2),
                    extendimplantbottom = _select_switch(((rownum == 1) or _P.splitimplant), _select_parameter("extendimplantbottom", device, row), _P.yseparation / 2),
                    extendimplantleft = _select_parameter("extendimplantleft", device, row),
                    extendimplantright = _select_parameter("extendimplantright", device, row),
                    extendwelltop = _select_switch(((rownum == #_P.rows) or _P.splitwell), _select_parameter("extendwelltop", device, row), _P.yseparation / 2),
                    extendwellbottom = _select_switch(((rownum == 1) or _P.splitwell), _select_parameter("extendwellbottom", device, row), _P.yseparation / 2),
                    extendwellleft = _select_parameter("extendwellleft", device, row),
                    extendwellright = _select_parameter("extendwellright", device, row),
                    extendlvsmarkertop = _select_switch(((rownum == #_P.rows) or _P.splitlvsmarker), _select_parameter("extendlvsmarkertop", device, row), _P.yseparation / 2),
                    extendlvsmarkerbottom = _select_switch(((rownum == 1) or _P.splitlvsmarker), _select_parameter("extendlvsmarkerbottom", device, row), _P.yseparation / 2),
                    extendlvsmarkerleft = _select_parameter("extendlvsmarkerleft", device, row),
                    extendlvsmarkerright = _select_parameter("extendlvsmarkerright", device, row),
                    extendrotationmarkertop = _select_switch(((rownum == #_P.rows) or _P.splitrotationmarker), _select_parameter("extendrotationmarkertop", device, row), _P.yseparation / 2),
                    extendrotationmarkerbottom = _select_switch(((rownum == 1) or _P.splitrotationmarker), _select_parameter("extendrotationmarkerbottom", device, row), _P.yseparation / 2),
                    extendrotationmarkerleft = _select_parameter("extendrotationmarkerleft", device, row),
                    extendrotationmarkerright = _select_parameter("extendrotationmarkerright", device, row),
                    extendanalogmarkertop = _select_switch(((rownum == #_P.rows) or _P.splitanalogmarker), _select_parameter("extendanalogmarkertop", device, row), _P.yseparation / 2),
                    extendanalogmarkerbottom = _select_switch(((rownum == 1) or _P.splitanalogmarker), _select_parameter("extendanalogmarkerbottom", device, row), _P.yseparation / 2),
                    extendanalogmarkerleft = _select_parameter("extendanalogmarkerleft", device, row),
                    extendanalogmarkerright = _select_parameter("extendanalogmarkerright", device, row),
                    drawwell = _select_parameter("drawwell", device, row, _P),
                    drawtopwelltap = _select_parameter("drawtopwelltap", device, row),
                    topwelltapwidth = _select_parameter("topwelltapwidth", device, row),
                    topwelltapspace = _select_parameter("topwelltapspace", device, row),
                    topwelltapextendleft = _select_parameter("topwelltapextendleft", device, row),
                    topwelltapextendright = _select_parameter("topwelltapextendright", device, row),
                    drawbotwelltap = _select_parameter("drawbotwelltap", device, row),
                    drawguardring = _P.drawguardring,
                    guardringwidth = _P.guardringwidth,
                    guardringleftsep = _P.guardringleftsep,
                    guardringrightsep = _P.guardringrightsep,
                    guardringtopsep = _P.guardringtopsep,
                    guardringbottomsep = _P.guardringbottomsep,
                    guardringrespectactivedummies = _P.guardringrespectactivedummies,
                    guardringrespectgatestraps = _P.guardringrespectgatestraps,
                    guardringrespectgateextensions = _P.guardringrespectgateextensions,
                    guardringrespectsourcestraps = _P.guardringrespectsourcestraps,
                    guardringrespectdrainstraps = _P.guardringrespectdrainstraps,
                    guardringfillimplant = _P.guardringfillimplant,
                    guardringfillwell = _P.guardringfillwell,
                    guardringdrawoxidetype = _P.guardringdrawoxidetype,
                    guardringfilloxidetype = _P.guardringfilloxidetype,
                    guardringoxidetype = _P.guardringoxidetype,
                    guardringimplantinnerextension = _P.guardringimplantinnerextension,
                    guardringimplantouterextension = _P.guardringimplantouterextension,
                    guardringwellinnerextension = _P.guardringwellinnerextension,
                    guardringwellouterextension = _P.guardringwellouterextension,
                    guardringsoiopeninnerextension = _P.guardringsoiopeninnerextension,
                    guardringsoiopenouterextension = _P.guardringsoiopenouterextension,
                    botwelltapwidth = _select_parameter("botwelltapwidth", device, row),
                    botwelltapspace = _select_parameter("botwelltapspace", device, row),
                    botwelltapextendleft = _select_parameter("botwelltapextendleft", device, row),
                    botwelltapextendright = _select_parameter("botwelltapextendright", device, row),
                    drawstopgatetopgatecut = _select_parameter("drawstopgatetopgatecut", device, row),
                    drawstopgatebotgatecut = _select_parameter("drawstopgatebotgatecut", device, row),
                    leftpolylines = _select_parameter("leftpolylines", device, row),
                    rightpolylines = _select_parameter("rightpolylines", device, row),
                    drawrotationmarker = _select_parameter("drawrotationmarker", device, row),
                    drawanalogmarker = _select_parameter("drawanalogmarker", device, row),
                    checkshorts = _select_parameter("checkshorts", device, row, _P),
                })
                if not status then -- call failed, but show detailed error here
                    cellerror(string.format("could not create device %d in row %d (\"%s\"): %s", devnum, rownum, device.name, mosfet))
                end
                table.insert(mosfetrow, { mosfet = mosfet, name = device.name }) -- save for late positioning
            end -- if not device.skip
        end -- for-loop for row devices
        table.insert(mosfetrows, { mosfets = mosfetrow, shift = row.shift })
    end -- for-loop across rows

    -- place all devices in one row (only x-position relatively within one row)
    for rownum = 1, #mosfetrows do
        local mosfetrow = mosfetrows[rownum].mosfets
        for fetnum = 2, #mosfetrow do
            local lastmosfet = mosfetrow[fetnum - 1].mosfet
            local mosfet = mosfetrow[fetnum].mosfet
            mosfet:abut_right(lastmosfet)
            mosfet:translate_x(_P.xseparation)
        end -- for-loop across row devices
    end -- for-loop across rows

    -- place all device rows (x- and y-position)
    for rownum = 2, #mosfetrows do
        local lastmosfetrow = mosfetrows[rownum - 1].mosfets
        local mosfetrow = mosfetrows[rownum].mosfets
        -- determine x- and y-shift for the entire row
        local xshift = 0
        if _P.centermosfets then
                local xcenter1 = point.xaverage(
                    lastmosfetrow[1].mosfet:get_area_anchor("active").bl,
                    lastmosfetrow[#lastmosfetrow].mosfet:get_area_anchor("active").tr
                )
                local xcenter2 = point.xaverage(
                    mosfetrow[1].mosfet:get_area_anchor("active").bl,
                    mosfetrow[#mosfetrow].mosfet:get_area_anchor("active").tr
                )
                xshift = xcenter1 - xcenter2
        else
            if _P.xalignmosfetsatactive then
                xshift = point.xdistance(
                    lastmosfetrow[1].mosfet:get_area_anchor("active").bl,
                    mosfetrow[1].mosfet:get_area_anchor("active").bl
                )
            else
                xshift = point.xdistance(
                    lastmosfetrow[1].mosfet:get_alignment_anchor("outerbl"),
                    mosfetrow[1].mosfet:get_alignment_anchor("outerbl")
                )
            end
        end
        local yshift = 0
        if _P.yalignmosfetsatactive then
            yshift = point.ydistance(
                lastmosfetrow[1].mosfet:get_area_anchor("active").tl,
                mosfetrow[1].mosfet:get_area_anchor("active").bl
            )
        else
            yshift = point.ydistance(
                lastmosfetrow[1].mosfet:get_alignment_anchor("innertl"),
                mosfetrow[1].mosfet:get_alignment_anchor("outerbl")
            )
        end
        -- position the entire row
        for fetnum = 1, #mosfetrow do
            local mosfet = mosfetrow[fetnum].mosfet
            mosfet:translate(xshift, yshift)
            mosfet:translate_y(mosfetrows[rownum].shift or 0)
            mosfet:translate_y(_P.yseparation)
        end -- for-loop across row devices
    end -- for-loop across rows

    -- merge mosfets into main cell
    for rownum = 1, #mosfetrows do
        local mosfetrow = mosfetrows[rownum].mosfets
        for fetnum = 1, #mosfetrow do
            local mosfet = mosfetrow[fetnum].mosfet
            cell:merge_into(mosfet)
        end
    end

    -- inherit anchors and alignmentboxes
    for rownum = 1, #mosfetrows do
        local mosfetrow = mosfetrows[rownum].mosfets
        for fetnum = 1, #mosfetrow do
            local mosfet = mosfetrow[fetnum].mosfet
            local name = mosfetrow[fetnum].name
            cell:inherit_alignment_box(mosfet)
            cell:inherit_all_anchors_with_prefix(mosfet, name .. "_")
        end
    end

    -- derive/inherit anchors
    for rownum = 1, #mosfetrows do
        local mosfetrow = mosfetrows[rownum].mosfets
        local activebl = mosfetrow[1].mosfet:get_area_anchor("active").bl
        local activetr = mosfetrow[#mosfetrow].mosfet:get_area_anchor("active").tr
        local wellbl = mosfetrow[1].mosfet:get_area_anchor("well").bl
        local welltr = mosfetrow[#mosfetrow].mosfet:get_area_anchor("well").tr
        local implantbl = mosfetrow[1].mosfet:get_area_anchor("implant").bl
        local implanttr = mosfetrow[#mosfetrow].mosfet:get_area_anchor("implant").tr
        cell:add_area_anchor_bltr(string.format("active_%d", rownum), activebl, activetr)
        cell:add_area_anchor_bltr(string.format("well_%d", rownum), wellbl, welltr)
        cell:add_area_anchor_bltr(string.format("implant_%d", rownum), implantbl, implanttr)
    end -- for-loop across rows

    -- add anchors encompassing all active regions/implants/wells for guardring placement
    cell:add_area_anchor_bltr("active_all",
        cell:get_area_anchor_fmt("active_%d", 1).bl,
        cell:get_area_anchor_fmt("active_%d", #_P.rows).tr
    )
    cell:add_area_anchor_bltr("well_all",
        cell:get_area_anchor_fmt("well_%d", 1).bl,
        cell:get_area_anchor_fmt("well_%d", #_P.rows).tr
    )
    cell:add_area_anchor_bltr("implant_all",
        cell:get_area_anchor_fmt("implant_%d", 1).bl,
        cell:get_area_anchor_fmt("implant_%d", #_P.rows).tr
    )

    -- aligned cell pitch anchors (individual alignment boxes of the transistors)
    for rownum = 1, #mosfetrows do
        local mosfetrow = mosfetrows[rownum].mosfets
        for fetnum = 1, #mosfetrow do
            local mosfet = mosfetrow[fetnum].mosfet
            local name = mosfetrow[fetnum].name
            cell:add_area_anchor_bltr(string.format("outeralignmentbox_%d_%d", rownum, fetnum),
                mosfet:get_alignment_anchor("outerbl"),
                mosfet:get_alignment_anchor("outertr")
            )
            cell:add_area_anchor_bltr(string.format("inneralignmentbox_%d_%d", rownum, fetnum),
                mosfet:get_alignment_anchor("innerbl"),
                mosfet:get_alignment_anchor("innertr")
            )
        end
    end
end

