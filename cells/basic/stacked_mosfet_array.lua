function parameters()
    pcell.add_parameters(
        { "rows", {} },
        { "alignmosfetsatactive", false },
        { "sdwidth", technology.get_dimension("Minimum M1 Width") },
        { "separation", 0 }
    )
end

function check(_P)
    local rowfingers = {}
    for rownum, row in ipairs(_P.rows) do
        local f = 0
        if not row.devices or #row.devices == 0 then
            return false, string.format("row %d defines no devices", rownum)
        end
        for devicenum, device in ipairs(row.devices) do
            if not device.fingers then
                return false, string.format("device %d in row %d has no finger specification", devicenum, rownum)
            end
            if device.fingers <= 0 then
                return false, string.format("device %d in row %d has zero or negative amount of fingers (%d)", devicenum, rownum, device.fingers)
            end
            if not math.tointeger(device.fingers) then
                return false, string.format("device %d in row %d has a non-integer number of fingers (%f)", devicenum, rownum, device.fingers)
            end
            f = f + device.fingers
        end
        rowfingers[rownum] = f
    end
    local fingersperrow = rowfingers[1]
    --for i = 2, #rowfingers do
    --    if fingersperrow ~= rowfingers[i] then
    --        return false, string.format("rows don't have the same number of fingers (first row has %d fingers, %d. row has %d fingers)", fingersperrow, i, rowfingers[i])
    --    end
    --end

    local names = {}
    for rownum, row in ipairs(_P.rows) do
        if not row.channeltype then
            return false, string.format("row %d does not have a channeltype", rownum)
        end
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

function layout(cell, _P)
    local lastpoint = point.create(0, 0)
    local lastmosfet = nil
    for rownum, row in ipairs(_P.rows) do
        local activebl, activetr
        for devnum, device in ipairs(row.devices) do
            local mosfet = pcell.create_layout("basic/mosfet", device.name, {
                channeltype = row.channeltype,
                implantalignwithactive = row.implantalignwithactive,
                flippedwell = row.flippedwell,
                gatelength = row.gatelength,
                gatespace = row.gatespace,
                fwidth = row.width,
                fingers = device.fingers,
                oxidetype = row.oxidetype,
                oxidetypealignwithactive = row.oxidetypealignwithactive,
                vthtype = row.vthtype,
                vthtypealignwithactive = row.vthtypealignwithactive,
                gatemarker = row.gatemarker,
                mosfetmarker = row.mosfetmarker,
                mosfetmarkeralignatsourcedrain = row.mosfetmarkeralignatsourcedrain,
                actext = _select_parameter("actext", device, row),
                sdwidth = _select_parameter("sdwidth", device, row, _P),
                sdviawidth = _select_parameter("sdviawidth", device, row),
                sdmetalwidth = _select_parameter("sdmetalwidth", device, row),
                gtopext = _select_parameter("gtopext", device, row),
                gbotext = _select_parameter("gbotext", device, row),
                gtopextadd = _select_parameter("gtopextadd", device, row),
                gbotextadd = _select_parameter("gbotextadd", device, row),
                cliptop = _select_parameter("cliptop", device, row),
                clipbot = _select_parameter("clipbot", device, row),
                drawleftstopgate = _select_parameter("drawleftstopgate", device, row),
                drawrightstopgate = _select_parameter("drawrightstopgate", device, row),
                endleftwithgate = _select_parameter("endleftwithgate", device, row),
                endrightwithgate = _select_parameter("endrightwithgate", device, row),
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
                drawtopgcut = _select_parameter("drawtopgcut", device, row),
                topgcutwidth = _select_parameter("topgcutwidth", device, row),
                topgcutspace, row = _select_parameter("topgcutspace", device, row),
                topgcutleftext = _select_parameter("topgcutleftext", device, row),
                topgcutrightext = _select_parameter("topgcutrightext", device, row),
                drawbotgcut = _select_parameter("drawbotgcut", device, row),
                botgcutwidth = _select_parameter("botgcutwidth", device, row),
                botgcutspace = _select_parameter("botgcutspace", device, row),
                botgcutleftext = _select_parameter("botgcutleftext", device, row),
                botgcutrightext = _select_parameter("botgcutrightext", device, row),
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
                lvsmarkeralignwithactive = _select_parameter("lvsmarkeralignwithactive", device, row),
                extendalltop = _select_parameter("extendalltop", device, row),
                extendallbot = _select_parameter("extendallbot", device, row),
                extendallleft = _select_parameter("extendallleft", device, row),
                extendallright = _select_parameter("extendallright", device, row),
                extendoxidetop = _select_parameter("extendoxidetop", device, row),
                extendoxidebot = _select_parameter("extendoxidebot", device, row),
                extendoxideleft = _select_parameter("extendoxideleft", device, row),
                extendoxideright = _select_parameter("extendoxideright", device, row),
                extendvthtop = _select_parameter("extendvthtop", device, row),
                extendvthbot = _select_parameter("extendvthbot", device, row),
                extendvthleft = _select_parameter("extendvthleft", device, row),
                extendvthright = _select_parameter("extendvthright", device, row),
                extendimplanttop = _select_parameter("extendimplanttop", device, row),
                extendimplantbot = _select_parameter("extendimplantbot", device, row),
                extendimplantleft = _select_parameter("extendimplantleft", device, row),
                extendimplantright = _select_parameter("extendimplantright", device, row),
                extendwelltop = _select_parameter("extendwelltop", device, row),
                extendwellbot = _select_parameter("extendwellbot", device, row),
                extendwellleft = _select_parameter("extendwellleft", device, row),
                extendwellright = _select_parameter("extendwellright", device, row),
                extendwelltop = _select_parameter("extendwelltop", device, row),
                extendwellbot = _select_parameter("extendwellbot", device, row),
                extendwellleft = _select_parameter("extendwellleft", device, row),
                extendwellright = _select_parameter("extendwellright", device, row),
                extendlvsmarkertop = _select_parameter("extendlvsmarkertop", device, row),
                extendlvsmarkerbot = _select_parameter("extendlvsmarkerbot", device, row),
                extendlvsmarkerleft = _select_parameter("extendlvsmarkerleft", device, row),
                extendlvsmarkerright = _select_parameter("extendlvsmarkerright", device, row),
                extendrotationmarkertop = _select_parameter("extendrotationmarkertop", device, row),
                extendrotationmarkerbot = _select_parameter("extendrotationmarkerbot", device, row),
                extendrotationmarkerleft = _select_parameter("extendrotationmarkerleft", device, row),
                extendrotationmarkerright = _select_parameter("extendrotationmarkerright", device, row),
                drawwell = _select_parameter("drawwell", device, row),
                drawtopwelltap = _select_parameter("drawtopwelltap", device, row),
                topwelltapwidth = _select_parameter("topwelltapwidth", device, row),
                topwelltapspace = _select_parameter("topwelltapspace", device, row),
                topwelltapextendleft = _select_parameter("topwelltapextendleft", device, row),
                topwelltapextendright = _select_parameter("topwelltapextendright", device, row),
                drawbotwelltap = _select_parameter("drawbotwelltap", device, row),
                drawguardring = _select_parameter("drawguardring", device, row),
                guardringwidth = _select_parameter("guardringwidth", device, row),
                guardringxsep = _select_parameter("guardringxsep", device, row),
                guardringysep = _select_parameter("guardringysep", device, row),
                guardringsegments = _select_parameter("guardringsegments", device, row),
                botwelltapwidth = _select_parameter("botwelltapwidth", device, row),
                botwelltapspace = _select_parameter("botwelltapspace", device, row),
                botwelltapextendleft = _select_parameter("botwelltapextendleft", device, row),
                botwelltapextendright = _select_parameter("botwelltapextendright", device, row),
                drawstopgatetopgcut = _select_parameter("drawstopgatetopgcut", device, row),
                drawstopgatebotgcut = _select_parameter("drawstopgatebotgcut", device, row),
                leftpolylines = _select_parameter("leftpolylines", device, row),
                rightpolylines = _select_parameter("rightpolylines", device, row),
                drawrotationmarker = _select_parameter("drawrotationmarker", device, row),
            })
            if not lastmosfet then -- first mosfet in row
                if _P.alignmosfetsatactive then
                    mosfet:move_point(mosfet:get_area_anchor("active").bl, lastpoint)
                    lastpoint = mosfet:get_area_anchor("active").tl
                else
                    mosfet:move_point(mosfet:get_area_anchor("sourcedrainactiveleft").bl, lastpoint)
                    lastpoint = mosfet:get_area_anchor("sourcedrainactiveleft").tl
                end
            else
                mosfet:align_bottom(lastmosfet)
                mosfet:abut_right(lastmosfet)
            end
            lastmosfet = mosfet
            cell:merge_into(mosfet)
            cell:inherit_alignment_box(mosfet)
            cell:inherit_all_anchors_with_prefix(mosfet, device.name .. "_")
            if devnum == 1 then
                activebl = mosfet:get_area_anchor("active").bl
            end
            if devnum == #row.devices then
                activetr = mosfet:get_area_anchor("active").tr
            end
        end
        cell:add_area_anchor_bltr(string.format("active_%d", rownum), activebl, activetr)
        lastpoint:translate_y(_P.separation)
        lastmosfet = nil
    end
end

