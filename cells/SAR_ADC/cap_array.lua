function parameters()
    pcell.add_parameters(
        { "bits",    8 },
        { "rwidth",    100 }
    )
end


function layout(cap_array, _P)
    --unit cap
    local capref = object.create("capref")
    geometry.rectanglebltr(capref, generics.premapped(nil, { SKILL = { layer = "C1", purpose = "drawing" } }), point.create(450, 200), point.create(494, 1500))
    geometry.rectanglebltr(capref, generics.premapped(nil, { SKILL = { layer = "C1", purpose = "drawing" } }), point.create(540, 100), point.create(584, 1400))
    geometry.rectanglebltr(capref, generics.premapped(nil, { SKILL = { layer = "AY", purpose = "drawing" } }), point.create(760, 30), point.create(800, 70))
    geometry.rectanglebltr(capref, generics.premapped(nil, { SKILL = { layer = "M2", purpose = "drawing" } }), point.create(0, 200), point.create(40, 1500))
    geometry.rectanglebltr(capref, generics.premapped(nil, { SKILL = { layer = "M1", purpose = "vncap" } }), point.create(0, 100), point.create(1000, 1500))
    geometry.rectanglebltr(capref, generics.premapped(nil, { SKILL = { layer = "M2", purpose = "vncap" } }), point.create(0, 100), point.create(1000, 1500))
    geometry.rectanglebltr(capref, generics.premapped(nil, { SKILL = { layer = "C1", purpose = "drawing" } }), point.create(360, 100), point.create(404, 1400))
    geometry.rectanglebltr(capref, generics.premapped(nil, { SKILL = { layer = "AY", purpose = "drawing" } }), point.create(590, 30), point.create(630, 70))
    geometry.rectanglebltr(capref, generics.premapped(nil, { SKILL = { layer = "C1", purpose = "drawing" } }), point.create(0, 0), point.create(1000, 100))
    geometry.rectanglebltr(capref, generics.premapped(nil, { SKILL = { layer = "M1", purpose = "drawing" } }), point.create(0, 1500), point.create(1000, 1600))
    geometry.rectanglebltr(capref, generics.premapped(nil, { SKILL = { layer = "M1", purpose = "drawing" } }), point.create(0, 0), point.create(1000, 100))
    geometry.rectanglebltr(capref, generics.premapped(nil, { SKILL = { layer = "C1", purpose = "drawing" } }), point.create(0, 1500), point.create(1000, 1600))
    geometry.rectanglebltr(capref, generics.premapped(nil, { SKILL = { layer = "M2", purpose = "drawing" } }), point.create(0, 0), point.create(1000, 100))
    geometry.rectanglebltr(capref, generics.premapped(nil, { SKILL = { layer = "M2", purpose = "drawing" } }), point.create(0, 1500), point.create(1000, 1600))
    geometry.rectanglebltr(capref, generics.premapped(nil, { SKILL = { layer = "C1", purpose = "drawing" } }), point.create(630, 200), point.create(674, 1500))
    geometry.rectanglebltr(capref, generics.premapped(nil, { SKILL = { layer = "C1", purpose = "drawing" } }), point.create(720, 100), point.create(764, 1400))
    geometry.rectanglebltr(capref, generics.premapped(nil, { SKILL = { layer = "M2", purpose = "drawing" } }), point.create(100, 100), point.create(140, 1400))
    geometry.rectanglebltr(capref, generics.premapped(nil, { SKILL = { layer = "M2", purpose = "drawing" } }), point.create(200, 200), point.create(240, 1500))
    geometry.rectanglebltr(capref, generics.premapped(nil, { SKILL = { layer = "C1", purpose = "drawing" } }), point.create(900, 100), point.create(944, 1400))
    geometry.rectanglebltr(capref, generics.premapped(nil, { SKILL = { layer = "C1", purpose = "drawing" } }), point.create(810, 200), point.create(854, 1500))
    geometry.rectanglebltr(capref, generics.premapped(nil, { SKILL = { layer = "C1", purpose = "drawing" } }), point.create(180, 100), point.create(224, 1400))
    geometry.rectanglebltr(capref, generics.premapped(nil, { SKILL = { layer = "C1", purpose = "drawing" } }), point.create(0, 100), point.create(44, 1400))
    geometry.rectanglebltr(capref, generics.premapped(nil, { SKILL = { layer = "C1", purpose = "drawing" } }), point.create(0, 0), point.create(1000, 100))
    geometry.rectanglebltr(capref, generics.premapped(nil, { SKILL = { layer = "AY", purpose = "drawing" } }), point.create(590, 30), point.create(630, 70))
    geometry.rectanglebltr(capref, generics.premapped(nil, { SKILL = { layer = "AY", purpose = "drawing" } }), point.create(250, 30), point.create(290, 70))
    geometry.rectanglebltr(capref, generics.premapped(nil, { SKILL = { layer = "AY", purpose = "drawing" } }), point.create(760, 1530), point.create(800, 1570))
    geometry.rectanglebltr(capref, generics.premapped(nil, { SKILL = { layer = "C1", purpose = "drawing" } }), point.create(270, 200), point.create(314, 1500))
    geometry.rectanglebltr(capref, generics.premapped(nil, { SKILL = { layer = "C1", purpose = "drawing" } }), point.create(90, 200), point.create(134, 1500))
    geometry.rectanglebltr(capref, generics.premapped(nil, { SKILL = { layer = "C1", purpose = "drawing" } }), point.create(0, 1500), point.create(1000, 1600))
    geometry.rectanglebltr(capref, generics.premapped(nil, { SKILL = { layer = "AY", purpose = "drawing" } }), point.create(760, 30), point.create(800, 70))
    geometry.rectanglebltr(capref, generics.premapped(nil, { SKILL = { layer = "AY", purpose = "drawing" } }), point.create(420, 30), point.create(460, 70))
    geometry.rectanglebltr(capref, generics.premapped(nil, { SKILL = { layer = "AY", purpose = "drawing" } }), point.create(80, 30), point.create(120, 70))
    geometry.rectanglebltr(capref, generics.premapped(nil, { SKILL = { layer = "AY", purpose = "drawing" } }), point.create(760, 1530), point.create(800, 1570))
    geometry.rectanglebltr(capref, generics.premapped(nil, { SKILL = { layer = "AY", purpose = "drawing" } }), point.create(80, 1530), point.create(120, 1570))
    geometry.rectanglebltr(capref, generics.premapped(nil, { SKILL = { layer = "V1", purpose = "drawing" } }), point.create(250, 30), point.create(290, 70))
    geometry.rectanglebltr(capref, generics.premapped(nil, { SKILL = { layer = "V1", purpose = "drawing" } }), point.create(420, 1530), point.create(460, 1570))
    geometry.rectanglebltr(capref, generics.premapped(nil, { SKILL = { layer = "M1", purpose = "drawing" } }), point.create(800, 100), point.create(840, 1400))
    geometry.rectanglebltr(capref, generics.premapped(nil, { SKILL = { layer = "M1", purpose = "drawing" } }), point.create(400, 100), point.create(440, 1400))
    geometry.rectanglebltr(capref, generics.premapped(nil, { SKILL = { layer = "AY", purpose = "drawing" } }), point.create(80, 30), point.create(120, 70))
    geometry.rectanglebltr(capref, generics.premapped(nil, { SKILL = { layer = "AY", purpose = "drawing" } }), point.create(250, 1530), point.create(290, 1570))
    geometry.rectanglebltr(capref, generics.premapped(nil, { SKILL = { layer = "V1", purpose = "drawing" } }), point.create(420, 30), point.create(460, 70))
    geometry.rectanglebltr(capref, generics.premapped(nil, { SKILL = { layer = "V1", purpose = "drawing" } }), point.create(590, 1530), point.create(630, 1570))
    geometry.rectanglebltr(capref, generics.premapped(nil, { SKILL = { layer = "M1", purpose = "drawing" } }), point.create(900, 200), point.create(940, 1500))
    geometry.rectanglebltr(capref, generics.premapped(nil, { SKILL = { layer = "M1", purpose = "drawing" } }), point.create(500, 200), point.create(540, 1500))
    geometry.rectanglebltr(capref, generics.premapped(nil, { SKILL = { layer = "AY", purpose = "drawing" } }), point.create(590, 1530), point.create(630, 1570))
    geometry.rectanglebltr(capref, generics.premapped(nil, { SKILL = { layer = "AY", purpose = "drawing" } }), point.create(420, 1530), point.create(460, 1570))
    geometry.rectanglebltr(capref, generics.premapped(nil, { SKILL = { layer = "AY", purpose = "drawing" } }), point.create(250, 1530), point.create(290, 1570))
    geometry.rectanglebltr(capref, generics.premapped(nil, { SKILL = { layer = "AY", purpose = "drawing" } }), point.create(80, 1530), point.create(120, 1570))
    geometry.rectanglebltr(capref, generics.premapped(nil, { SKILL = { layer = "M2", purpose = "drawing" } }), point.create(900, 100), point.create(940, 1400))
    geometry.rectanglebltr(capref, generics.premapped(nil, { SKILL = { layer = "M2", purpose = "drawing" } }), point.create(800, 200), point.create(840, 1500))
    geometry.rectanglebltr(capref, generics.premapped(nil, { SKILL = { layer = "M2", purpose = "drawing" } }), point.create(700, 100), point.create(740, 1400))
    geometry.rectanglebltr(capref, generics.premapped(nil, { SKILL = { layer = "M2", purpose = "drawing" } }), point.create(600, 200), point.create(640, 1500))
    geometry.rectanglebltr(capref, generics.premapped(nil, { SKILL = { layer = "M2", purpose = "drawing" } }), point.create(500, 100), point.create(540, 1400))
    geometry.rectanglebltr(capref, generics.premapped(nil, { SKILL = { layer = "M2", purpose = "drawing" } }), point.create(400, 200), point.create(440, 1500))
    geometry.rectanglebltr(capref, generics.premapped(nil, { SKILL = { layer = "M2", purpose = "drawing" } }), point.create(300, 100), point.create(340, 1400))
    geometry.rectanglebltr(capref, generics.premapped(nil, { SKILL = { layer = "AY", purpose = "drawing" } }), point.create(250, 30), point.create(290, 70))
    geometry.rectanglebltr(capref, generics.premapped(nil, { SKILL = { layer = "AY", purpose = "drawing" } }), point.create(420, 1530), point.create(460, 1570))
    geometry.rectanglebltr(capref, generics.premapped(nil, { SKILL = { layer = "V1", purpose = "drawing" } }), point.create(590, 30), point.create(630, 70))
    geometry.rectanglebltr(capref, generics.premapped(nil, { SKILL = { layer = "V1", purpose = "drawing" } }), point.create(760, 1530), point.create(800, 1570))
    geometry.rectanglebltr(capref, generics.premapped(nil, { SKILL = { layer = "V1", purpose = "drawing" } }), point.create(80, 1530), point.create(120, 1570))
    geometry.rectanglebltr(capref, generics.premapped(nil, { SKILL = { layer = "M1", purpose = "drawing" } }), point.create(600, 100), point.create(640, 1400))
    geometry.rectanglebltr(capref, generics.premapped(nil, { SKILL = { layer = "AY", purpose = "drawing" } }), point.create(420, 30), point.create(460, 70))
    geometry.rectanglebltr(capref, generics.premapped(nil, { SKILL = { layer = "AY", purpose = "drawing" } }), point.create(590, 1530), point.create(630, 1570))
    geometry.rectanglebltr(capref, generics.premapped(nil, { SKILL = { layer = "V1", purpose = "drawing" } }), point.create(760, 30), point.create(800, 70))
    geometry.rectanglebltr(capref, generics.premapped(nil, { SKILL = { layer = "V1", purpose = "drawing" } }), point.create(80, 30), point.create(120, 70))
    geometry.rectanglebltr(capref, generics.premapped(nil, { SKILL = { layer = "V1", purpose = "drawing" } }), point.create(250, 1530), point.create(290, 1570))
    geometry.rectanglebltr(capref, generics.premapped(nil, { SKILL = { layer = "M1", purpose = "drawing" } }), point.create(700, 200), point.create(740, 1500))
    geometry.rectanglebltr(capref, generics.premapped(nil, { SKILL = { layer = "C1", purpose = "vncap" } }), point.create(0, 100), point.create(1000, 1500))
    geometry.rectanglebltr(capref, generics.premapped(nil, { SKILL = { layer = "VNCAP", purpose = "hv" } }), point.create(0, 0), point.create(1000, 1600))
    geometry.rectanglebltr(capref, generics.premapped(nil, { SKILL = { layer = "M1", purpose = "drawing" } }), point.create(300, 200), point.create(340, 1500))
    geometry.rectanglebltr(capref, generics.premapped(nil, { SKILL = { layer = "M1", purpose = "drawing" } }), point.create(200, 100), point.create(240, 1400))
    geometry.rectanglebltr(capref, generics.premapped(nil, { SKILL = { layer = "M1", purpose = "drawing" } }), point.create(100, 200), point.create(140, 1500))
    geometry.rectanglebltr(capref, generics.premapped(nil, { SKILL = { layer = "M1", purpose = "drawing" } }), point.create(0, 100), point.create(40, 1400))
    geometry.rectanglebltr(capref, generics.premapped(nil, { SKILL = { layer = "M2", purpose = "drawing" } }), point.create(0, 0), point.create(1000, 100))
    geometry.rectanglebltr(capref, generics.premapped(nil, { SKILL = { layer = "M2", purpose = "drawing" } }), point.create(0, 1500), point.create(1000, 1600))
    geometry.rectanglebltr(capref, generics.premapped(nil, { SKILL = { layer = "M1", purpose = "drawing" } }), point.create(0, 1500), point.create(1000, 1600))
    geometry.rectanglebltr(capref, generics.premapped(nil, { SKILL = { layer = "M1", purpose = "drawing" } }), point.create(0, 0), point.create(1000, 100))
    geometry.rectanglebltr(capref, generics.premapped(nil, { SKILL = { layer = "VNCAP", purpose = "count" } }), point.create(50, 1510), point.create(60, 1520))
    geometry.rectanglebltr(capref, generics.premapped(nil, { SKILL = { layer = "VNCAP", purpose = "count" } }), point.create(30, 1510), point.create(40, 1520))
    geometry.rectanglebltr(capref, generics.premapped(nil, { SKILL = { layer = "VNCAP", purpose = "count" } }), point.create(10, 1510), point.create(20, 1520))
    geometry.rectanglebltr(capref, generics.premapped(nil, { SKILL = { layer = "VNCAP", purpose = "parm" } }), point.create(10, 1530), point.create(20, 1540))

    --create anchors
    capref:add_area_anchor_bltr("plus",
        point.create(0, 1500), point.create(1000, 1600)
    )
    capref:add_area_anchor_bltr("minus", 
        point.create(0, 0), point.create(1000, 100)
    )
    capref:set_alignment_box(
        point.create(0, 0), point.create(1000, 1600)
    )

    --basic array
    local row = 10	
    local column = 26

    local caps = {}
    for i = 1, row do
        caps[i] = {}
        for j = 1, column do
            local cap = capref:copy()
            if (i == 1 and j > 1) then
                cap:move_anchor("left", caps[i][j-1]:get_anchor("right"):translate( 4 * _P.rwidth, 0))	
            end
            if i > 1 then
                cap:move_anchor("top", caps[i-1][j]:get_anchor("bottom"):translate( 0, - 2 * _P.rwidth))
            end
            if _P.bits == 8 then
                cap_array:merge_into_shallow(cap)
            elseif _P.bits == 6 and i >= 2 and i <= 8 and j >= 9 and j <=18 then
                cap_array:merge_into_shallow(cap)
            elseif _P.bits == 4 and i >= 4 and i <= 7 and j >= 12 and j <=15 then
                cap_array:merge_into_shallow(cap)
            end
            caps[i][j] = cap
        end
    end

    --conncect for each group
    if _P.bits == 8 then
        --128
        geometry.path(cap_array, generics.metal(1),{
            caps[1][2]:get_anchor("pluscc"), 
            caps[1][25]:get_anchor("pluscc")
        }, _P.rwidth)
        geometry.path(cap_array, generics.metal(2),{
            caps[1][2]:get_anchor("minuscc"), 
            caps[1][25]:get_anchor("minuscc")
        }, _P.rwidth)
        geometry.path(cap_array, generics.metal(1),{
            caps[10][2]:get_anchor("pluscc"), 
            caps[10][25]:get_anchor("pluscc")
        }, _P.rwidth)
        geometry.path(cap_array, generics.metal(2),{
            caps[10][2]:get_anchor("minuscc"), 
            caps[10][25]:get_anchor("minuscc")
        }, _P.rwidth)

        for i = 2, 9 do
            geometry.path(cap_array, generics.metal(1),{
                caps[i][1]:get_anchor("pluscc"), 
                caps[i][5]:get_anchor("pluscc")
            }, _P.rwidth)
            geometry.path(cap_array, generics.metal(2),{
                caps[i][1]:get_anchor("minuscc"), 
                caps[i][5]:get_anchor("minuscc")
            }, _P.rwidth)
            geometry.path(cap_array, generics.metal(1),{
                caps[i][1]:get_anchor("pluscc"), 
                caps[i][5]:get_anchor("pluscc")
            }, _P.rwidth)
            geometry.path(cap_array, generics.metal(2),{
                caps[i][1]:get_anchor("minuscc"), 
                caps[i][5]:get_anchor("minuscc")
            }, _P.rwidth)

            geometry.path(cap_array, generics.metal(1),{
                caps[i][22]:get_anchor("pluscc"), 
                caps[i][26]:get_anchor("pluscc")
            }, _P.rwidth)
            geometry.path(cap_array, generics.metal(2),{
                caps[i][22]:get_anchor("minuscc"), 
                caps[i][26]:get_anchor("minuscc")
            }, _P.rwidth)
            geometry.path(cap_array, generics.metal(1),{
                caps[i][22]:get_anchor("pluscc"), 
                caps[i][26]:get_anchor("pluscc")
            }, _P.rwidth)
            geometry.path(cap_array, generics.metal(2),{
                caps[i][22]:get_anchor("minuscc"), 
                caps[i][26]:get_anchor("minuscc")
            }, _P.rwidth)
        end

        geometry.path_cshape(cap_array, generics.metal(1),
        caps[1][2]:get_anchor("pluscl"), 
        caps[10][2]:get_anchor("pluscl"), 
        caps[1][2]:get_anchor("pluscl"):translate( -2 * _P.rwidth, 0), 
        _P.rwidth)

        geometry.path_cshape(cap_array, generics.metal(2),
        caps[1][2]:get_anchor("minuscl"), 
        caps[10][2]:get_anchor("minuscl"), 
        caps[1][2]:get_anchor("minuscl"):translate( -2 * _P.rwidth, 0), 
        _P.rwidth)

        geometry.path_cshape(cap_array, generics.metal(1),
        caps[1][25]:get_anchor("pluscr"), 
        caps[10][25]:get_anchor("pluscr"), 
        caps[1][25]:get_anchor("pluscr"):translate( 2 * _P.rwidth, 0), 
        _P.rwidth)

        geometry.path_cshape(cap_array, generics.metal(2),
        caps[1][25]:get_anchor("minuscr"), 
        caps[10][25]:get_anchor("minuscr"), 
        caps[1][25]:get_anchor("minuscr"):translate( 2 *_P.rwidth, 0), 
        _P.rwidth)

        ---64
        for i = 2, 3 do
            geometry.path(cap_array, generics.metal(1),{
                caps[i][6]:get_anchor("pluscc"), 
                caps[i][9]:get_anchor("pluscc")
            }, _P.rwidth)

            geometry.path(cap_array, generics.metal(2),{
                caps[i][6]:get_anchor("minuscc"), 
                caps[i][9]:get_anchor("minuscc")
            }, _P.rwidth)

            geometry.path(cap_array, generics.metal(1),{
                caps[i][18]:get_anchor("pluscc"), 
                caps[i][21]:get_anchor("pluscc")
            }, _P.rwidth)
            geometry.path(cap_array, generics.metal(2),{
                caps[i][18]:get_anchor("minuscc"), 
                caps[i][21]:get_anchor("minuscc")
            }, _P.rwidth)
        end

        geometry.path(cap_array, generics.metal(1),{
            caps[8][6]:get_anchor("pluscc"), 
            caps[8][9]:get_anchor("pluscc")
        }, _P.rwidth)

        geometry.path(cap_array, generics.metal(2),{
            caps[8][6]:get_anchor("minuscc"), 
            caps[8][9]:get_anchor("minuscc")
        }, _P.rwidth)

        geometry.path(cap_array, generics.metal(1),{
            caps[8][18]:get_anchor("pluscc"), 
            caps[8][21]:get_anchor("pluscc")
        }, _P.rwidth)
        geometry.path(cap_array, generics.metal(2),{
            caps[8][18]:get_anchor("minuscc"), 
            caps[8][21]:get_anchor("minuscc")
        }, _P.rwidth)


        for i = 4, 7 do
            geometry.path(cap_array, generics.metal(1),{
                caps[i][6]:get_anchor("pluscc"), 
                caps[i][8]:get_anchor("pluscc")
            }, _P.rwidth)

            geometry.path(cap_array, generics.metal(2),{
                caps[i][6]:get_anchor("minuscc"), 
                caps[i][8]:get_anchor("minuscc")
            }, _P.rwidth)

            geometry.path(cap_array, generics.metal(1),{
                caps[i][19]:get_anchor("pluscc"), 
                caps[i][21]:get_anchor("pluscc")
            }, _P.rwidth)
            geometry.path(cap_array, generics.metal(2),{
                caps[i][19]:get_anchor("minuscc"), 
                caps[i][21]:get_anchor("minuscc")
            }, _P.rwidth)
        end

        geometry.path(cap_array, generics.metal(1),{
            caps[9][6]:get_anchor("pluscc"), 
            caps[9][21]:get_anchor("pluscc")
        }, _P.rwidth)

        geometry.path(cap_array, generics.metal(2),{
            caps[9][6]:get_anchor("minuscc"), 
            caps[9][21]:get_anchor("minuscc")
        }, _P.rwidth)

        geometry.path_cshape(cap_array, generics.metal(1),
        caps[2][7]:get_anchor("pluscl"), 
        caps[9][7]:get_anchor("pluscl"), 
        caps[2][7]:get_anchor("pluscl"):translate( -2 * _P.rwidth, 0), 
        _P.rwidth)

        geometry.path_cshape(cap_array, generics.metal(2),
        caps[2][7]:get_anchor("minuscl"), 
        caps[9][7]:get_anchor("minuscl"), 
        caps[2][7]:get_anchor("minuscl"):translate( -2 * _P.rwidth, 0), 
        _P.rwidth)

        geometry.path_cshape(cap_array, generics.metal(1),
        caps[2][20]:get_anchor("pluscr"), 
        caps[9][20]:get_anchor("pluscr"), 
        caps[2][20]:get_anchor("pluscr"):translate( 2 * _P.rwidth, 0), 
        _P.rwidth)

        geometry.path_cshape(cap_array, generics.metal(2),
        caps[2][20]:get_anchor("minuscr"), 
        caps[9][20]:get_anchor("minuscr"), 
        caps[2][20]:get_anchor("minuscr"):translate( 2 *_P.rwidth, 0), 
        _P.rwidth)
    end

    if _P.bits >= 6 then
        --32
        geometry.path(cap_array, generics.metal(1),{
            caps[2][10]:get_anchor("pluscc"), 
            caps[2][17]:get_anchor("pluscc")
        }, _P.rwidth)

        geometry.path(cap_array, generics.metal(2),{
            caps[2][10]:get_anchor("minuscc"), 
            caps[2][17]:get_anchor("minuscc")
        }, _P.rwidth)

        geometry.path(cap_array, generics.metal(1),{
            caps[8][10]:get_anchor("pluscc"), 
            caps[8][17]:get_anchor("pluscc")
        }, _P.rwidth)
        geometry.path(cap_array, generics.metal(2),{
            caps[8][10]:get_anchor("minuscc"), 
            caps[8][17]:get_anchor("minuscc")
        }, _P.rwidth)

        geometry.path(cap_array, generics.metal(1),{
            caps[3][10]:get_anchor("pluscl"), 
            caps[3][10]:get_anchor("pluscl"):translate( - 2 * _P.rwidth, 0)
        }, _P.rwidth)

        geometry.path(cap_array, generics.metal(2),{
            caps[3][10]:get_anchor("minuscl"), 
            caps[3][10]:get_anchor("minuscl"):translate( - 2 * _P.rwidth, 0)
        }, _P.rwidth)
        geometry.path(cap_array, generics.metal(1),{
            caps[3][17]:get_anchor("pluscr"), 
            caps[3][17]:get_anchor("pluscr"):translate( 2 * _P.rwidth, 0)
        }, _P.rwidth)

        geometry.path(cap_array, generics.metal(2),{
            caps[3][17]:get_anchor("minuscr"), 
            caps[3][17]:get_anchor("minuscr"):translate( 2 * _P.rwidth, 0)
        }, _P.rwidth)


        geometry.path(cap_array, generics.metal(1),{
            caps[4][9]:get_anchor("pluscc"), 
            caps[4][10]:get_anchor("pluscc")
        }, _P.rwidth)

        geometry.path(cap_array, generics.metal(2),{
            caps[4][9]:get_anchor("minuscc"), 
            caps[4][10]:get_anchor("minuscc")
        }, _P.rwidth)

        geometry.path(cap_array, generics.metal(1),{
            caps[4][17]:get_anchor("pluscc"), 
            caps[4][18]:get_anchor("pluscc")
        }, _P.rwidth)

        geometry.path(cap_array, generics.metal(2),{
            caps[4][17]:get_anchor("minuscc"), 
            caps[4][18]:get_anchor("minuscc")
        }, _P.rwidth)

        geometry.path(cap_array, generics.metal(1),{
            caps[5][9]:get_anchor("pluscr"), 
            caps[5][9]:get_anchor("pluscr"):translate( 2 * _P.rwidth, 0)
        }, _P.rwidth)

        geometry.path(cap_array, generics.metal(2),{
            caps[5][9]:get_anchor("minuscr"), 
            caps[5][9]:get_anchor("minuscr"):translate( 2 * _P.rwidth, 0)
        }, _P.rwidth)
        geometry.path(cap_array, generics.metal(1),{
            caps[5][18]:get_anchor("pluscl"), 
            caps[5][18]:get_anchor("pluscl"):translate( - 2 * _P.rwidth, 0)
        }, _P.rwidth)

        geometry.path(cap_array, generics.metal(2),{
            caps[5][18]:get_anchor("minuscl"), 
            caps[5][18]:get_anchor("minuscl"):translate( - 2 * _P.rwidth, 0)
        }, _P.rwidth)

        for i = 6, 7 do
            geometry.path(cap_array, generics.metal(1),{
                caps[i][9]:get_anchor("pluscc"), 
                caps[i][10]:get_anchor("pluscc")
            }, _P.rwidth)

            geometry.path(cap_array, generics.metal(2),{
                caps[i][9]:get_anchor("minuscc"), 
                caps[i][10]:get_anchor("minuscc")
            }, _P.rwidth)

            geometry.path(cap_array, generics.metal(1),{
                caps[i][17]:get_anchor("pluscc"), 
                caps[i][18]:get_anchor("pluscc")
            }, _P.rwidth)

            geometry.path(cap_array, generics.metal(2),{
                caps[i][17]:get_anchor("minuscc"), 
                caps[i][18]:get_anchor("minuscc")
            }, _P.rwidth)
        end

        geometry.path_cshape(cap_array, generics.metal(1),
        caps[2][10]:get_anchor("pluscl"), 
        caps[8][10]:get_anchor("pluscl"), 
        caps[2][10]:get_anchor("pluscl"):translate( -2 * _P.rwidth, 0), 
        _P.rwidth)

        geometry.path_cshape(cap_array, generics.metal(2),
        caps[2][10]:get_anchor("minuscl"), 
        caps[8][10]:get_anchor("minuscl"), 
        caps[2][10]:get_anchor("minuscl"):translate( -2 * _P.rwidth, 0), 
        _P.rwidth)

        geometry.path_cshape(cap_array, generics.metal(1),
        caps[2][17]:get_anchor("pluscr"), 
        caps[8][17]:get_anchor("pluscr"), 
        caps[2][17]:get_anchor("pluscr"):translate( 2 * _P.rwidth, 0), 
        _P.rwidth)

        geometry.path_cshape(cap_array, generics.metal(2),
        caps[2][17]:get_anchor("minuscr"), 
        caps[8][17]:get_anchor("minuscr"), 
        caps[2][17]:get_anchor("minuscr"):translate( 2 *_P.rwidth, 0), 
        _P.rwidth)

        --16
        geometry.path(cap_array, generics.metal(1),{
            caps[3][11]:get_anchor("pluscc"), 
            caps[3][16]:get_anchor("pluscc")
        }, _P.rwidth)

        geometry.path(cap_array, generics.metal(2),{
            caps[3][11]:get_anchor("minuscc"), 
            caps[3][16]:get_anchor("minuscc")
        }, _P.rwidth)
        for i = 4, 7 do
            geometry.path(cap_array, generics.metal(1),{
                caps[i][11]:get_anchor("pluscl"), 
                caps[i][11]:get_anchor("pluscl"):translate( - 2 * _P.rwidth, 0)
            }, _P.rwidth)
            geometry.path(cap_array, generics.metal(2),{
                caps[i][11]:get_anchor("minuscl"), 
                caps[i][11]:get_anchor("minuscl"):translate( - 2 * _P.rwidth, 0)
            }, _P.rwidth)
            geometry.path(cap_array, generics.metal(1),{
                caps[i][16]:get_anchor("pluscr"), 
                caps[i][16]:get_anchor("pluscr"):translate( 2 * _P.rwidth, 0)
            }, _P.rwidth)
            geometry.path(cap_array, generics.metal(2),{
                caps[i][16]:get_anchor("minuscr"), 
                caps[i][16]:get_anchor("minuscr"):translate( 2 * _P.rwidth, 0)
            }, _P.rwidth)
        end
        geometry.path(cap_array, generics.metal(1),{
            caps[5][10]:get_anchor("pluscc"), 
            caps[5][11]:get_anchor("pluscc")
        }, _P.rwidth)

        geometry.path(cap_array, generics.metal(2),{
            caps[5][10]:get_anchor("minuscc"), 
            caps[5][11]:get_anchor("minuscc")
        }, _P.rwidth)
        geometry.path(cap_array, generics.metal(1),{
            caps[5][16]:get_anchor("pluscc"), 
            caps[5][17]:get_anchor("pluscc")
        }, _P.rwidth)

        geometry.path(cap_array, generics.metal(2),{
            caps[5][16]:get_anchor("minuscc"), 
            caps[5][17]:get_anchor("minuscc")
        }, _P.rwidth)

        geometry.path_cshape(cap_array, generics.metal(1),
        caps[3][11]:get_anchor("pluscl"), 
        caps[7][11]:get_anchor("pluscl"), 
        caps[3][11]:get_anchor("pluscl"):translate( - 2 * _P.rwidth, 0), 
        _P.rwidth)
        geometry.path_cshape(cap_array, generics.metal(2),
        caps[3][11]:get_anchor("minuscl"), 
        caps[7][11]:get_anchor("minuscl"), 
        caps[3][11]:get_anchor("minuscl"):translate( - 2 * _P.rwidth, 0), 
        _P.rwidth)
        geometry.path_cshape(cap_array, generics.metal(1),
        caps[3][16]:get_anchor("pluscr"), 
        caps[7][16]:get_anchor("pluscr"), 
        caps[3][16]:get_anchor("pluscr"):translate( 2 *_P.rwidth, 0), 
        _P.rwidth)
        geometry.path_cshape(cap_array, generics.metal(2),
        caps[3][16]:get_anchor("minuscr"), 
        caps[7][16]:get_anchor("minuscr"), 
        caps[3][16]:get_anchor("minuscr"):translate( 2 *_P.rwidth, 0), 
        _P.rwidth)
    end

    --8
    geometry.path(cap_array, generics.metal(1),{
        caps[4][12]:get_anchor("pluscc"), 
        caps[4][15]:get_anchor("pluscc")
    }, _P.rwidth)
    geometry.path(cap_array, generics.metal(2),{
        caps[4][12]:get_anchor("minuscc"), 
        caps[4][15]:get_anchor("minuscc")
    }, _P.rwidth)
    for i = 5, 6 do
        geometry.path(cap_array, generics.metal(1),{
            caps[i][12]:get_anchor("pluscl"), 
            caps[i][12]:get_anchor("pluscl"):translate( - 2 * _P.rwidth, 0)
        }, _P.rwidth)
        geometry.path(cap_array, generics.metal(2),{
            caps[i][12]:get_anchor("minuscl"), 
            caps[i][12]:get_anchor("minuscl"):translate( - 2 * _P.rwidth, 0)
        }, _P.rwidth)
        geometry.path(cap_array, generics.metal(1),{
            caps[i][15]:get_anchor("pluscr"), 
            caps[i][15]:get_anchor("pluscr"):translate( 2 * _P.rwidth, 0)
        }, _P.rwidth)
        geometry.path(cap_array, generics.metal(2),{
            caps[i][15]:get_anchor("minuscr"), 
            caps[i][15]:get_anchor("minuscr"):translate( 2 * _P.rwidth, 0)
        }, _P.rwidth)
    end
    geometry.path_cshape(cap_array, generics.metal(1),
    caps[4][12]:get_anchor("pluscl"), 
    caps[6][12]:get_anchor("pluscl"), 
    caps[4][12]:get_anchor("pluscl"):translate( - 2 * _P.rwidth, 0), 
    _P.rwidth)
    geometry.path_cshape(cap_array, generics.metal(2),
    caps[4][12]:get_anchor("minuscl"), 
    caps[6][12]:get_anchor("minuscl"), 
    caps[4][12]:get_anchor("minuscl"):translate( - 2 * _P.rwidth, 0), 
    _P.rwidth)
    geometry.path_cshape(cap_array, generics.metal(1),
    caps[4][15]:get_anchor("pluscr"), 
    caps[6][15]:get_anchor("pluscr"), 
    caps[4][15]:get_anchor("pluscr"):translate( 2 *_P.rwidth, 0), 
    _P.rwidth)
    geometry.path_cshape(cap_array, generics.metal(2),
    caps[4][15]:get_anchor("minuscr"), 
    caps[6][15]:get_anchor("minuscr"), 
    caps[4][15]:get_anchor("minuscr"):translate( 2 *_P.rwidth, 0), 
    _P.rwidth)

    --4
    geometry.path(cap_array, generics.metal(1),{
        caps[7][12]:get_anchor("pluscc"), 
        caps[7][15]:get_anchor("pluscc")
    }, _P.rwidth)
    geometry.path(cap_array, generics.metal(2),{
        caps[7][12]:get_anchor("minuscc"), 
        caps[7][15]:get_anchor("minuscc")
    }, _P.rwidth)

    --2
    geometry.path(cap_array, generics.metal(1),{
        caps[5][13]:get_anchor("pluscc"), 
        caps[5][14]:get_anchor("pluscc")
    }, _P.rwidth)
    geometry.path(cap_array, generics.metal(2),{
        caps[5][13]:get_anchor("minuscc"), 
        caps[5][14]:get_anchor("minuscc")
    }, _P.rwidth)


    --connect vout
    if _P.bits == 8 then
        geometry.path(cap_array, generics.metal(3),{
            caps[5][1]:get_anchor("pluscl"), 
            caps[5][26]:get_anchor("pluscr")
        }, _P.rwidth)
        geometry.path_cshape(cap_array, generics.metal(3),
        caps[5][13]:get_anchor("pluscl"), 
        caps[10][1]:get_anchor("minusbr"):translate( 2 *_P.rwidth, - 1 *_P.rwidth),  
        caps[10][1]:get_anchor("minusbr"):translate( 2 *_P.rwidth, - 1 *_P.rwidth), 
        _P.rwidth)
        cap_array:add_area_anchor_bltr("vout",
        caps[10][1]:get_anchor("minusbr"):translate( 1.5 *_P.rwidth, - 1 *_P.rwidth), 
        caps[10][1]:get_anchor("minusbr"):translate( 2.5 *_P.rwidth, 0)
        )
    elseif _P.bits == 6 then
        geometry.path(cap_array, generics.metal(3),{
            caps[5][9]:get_anchor("pluscl"), 
            caps[5][18]:get_anchor("pluscr")
        }, _P.rwidth)
        geometry.path_cshape(cap_array, generics.metal(3),
        caps[5][13]:get_anchor("pluscl"), 
        caps[8][8]:get_anchor("minusbr"):translate( 2 *_P.rwidth, - 1 *_P.rwidth),  
        caps[8][8]:get_anchor("minusbr"):translate( 2 *_P.rwidth, - 1 *_P.rwidth), 
        _P.rwidth)
        cap_array:add_area_anchor_bltr("vout",
        caps[8][8]:get_anchor("minusbr"):translate( 1.5 *_P.rwidth, - 1 *_P.rwidth), 
        caps[8][8]:get_anchor("minusbr"):translate( 2.5 *_P.rwidth, 0)
        )
    elseif _P.bits == 4 then
        geometry.path(cap_array, generics.metal(3),{
            caps[5][12]:get_anchor("pluscl"), 
            caps[5][15]:get_anchor("pluscr")
        }, _P.rwidth)
        geometry.path_cshape(cap_array, generics.metal(3),
        caps[5][13]:get_anchor("pluscl"), 
        caps[7][11]:get_anchor("minusbr"):translate( 0, - 1 *_P.rwidth),  
        caps[7][11]:get_anchor("minusbr"):translate( 0, - 1 *_P.rwidth), 
        _P.rwidth)
        cap_array:add_area_anchor_bltr("vout",
        caps[7][11]:get_anchor("minusbr"):translate( - 0.5 *_P.rwidth, - 1 *_P.rwidth), 
        caps[7][11]:get_anchor("minusbr"):translate( 0.5 *_P.rwidth, 0)
        )
    end

    local srow = 7	--for 4 bits

    if _P.bits >= 6 then
        srow = _P.bits + 2
    end

    --port metal and anchor
    --sdummy
    geometry.path_cshape(cap_array, generics.metal(3),
    caps[6][13]:get_anchor("pluscr"), 
    caps[5][14]:get_anchor("pluscr"):translate( 2 *_P.rwidth, 0), 
    caps[5][14]:get_anchor("pluscr"):translate( 2 *_P.rwidth, 0), 
    _P.rwidth)
    geometry.path_cshape(cap_array, generics.metal(3),
    caps[6][14]:get_anchor("minuscr"), 
    caps[ srow ][14]:get_anchor("minusbr"):translate( 2 *_P.rwidth, - 1 * _P.rwidth), 
    caps[ srow ][14]:get_anchor("minusbr"):translate( 2 *_P.rwidth, - 1 * _P.rwidth), 
    _P.rwidth)
    cap_array:add_area_anchor_bltr("sdummy",
    caps[ srow ][14]:get_anchor("minusbr"):translate( 1.5 *_P.rwidth, - 1 * _P.rwidth),
    caps[ srow ][14]:get_anchor("minusbr"):translate( 2.5 *_P.rwidth, 0)
    )

    --S0
    geometry.path_cshape(cap_array, generics.metal(3),
    caps[6][13]:get_anchor("minuscr"), 
    caps[ srow ][13]:get_anchor("minusbr"):translate( 2 *_P.rwidth, - 2 *_P.rwidth), 
    caps[ srow ][13]:get_anchor("minusbr"):translate( 2 *_P.rwidth, - 2 *_P.rwidth), 
    _P.rwidth)
    cap_array:add_area_anchor_bltr("s0",
    caps[ srow ][13]:get_anchor("minusbr"):translate( 1.5 *_P.rwidth, - 2 * _P.rwidth),
    caps[ srow ][13]:get_anchor("minusbr"):translate( 2.5 *_P.rwidth, 0)
    )

    --S1
    geometry.path_cshape(cap_array, generics.metal(3),
    caps[5][14]:get_anchor("minuscl"), 
    caps[ srow ][13]:get_anchor("minusbl"):translate( - _P.rwidth, - 3 *_P.rwidth), 
    caps[ srow ][13]:get_anchor("minusbl"):translate( - _P.rwidth, - 3 *_P.rwidth), 
    _P.rwidth)
    cap_array:add_area_anchor_bltr("s1",
    caps[ srow ][13]:get_anchor("minusbl"):translate( - 1.5 *_P.rwidth, - 3 * _P.rwidth),
    caps[ srow ][13]:get_anchor("minusbl"):translate( - 0.5 *_P.rwidth, 0)
    )

    --S2
    geometry.path_cshape(cap_array, generics.metal(3),
    caps[7][12]:get_anchor("pluscr"), 
    caps[5][12]:get_anchor("pluscr"):translate( _P.rwidth, 0), 
    caps[5][12]:get_anchor("pluscr"):translate( _P.rwidth, 0), 
    _P.rwidth)
    geometry.path_cshape(cap_array, generics.metal(3),
    caps[7][12]:get_anchor("minuscr"), 
    caps[ srow ][12]:get_anchor("minusbr"):translate( _P.rwidth, - 4 *_P.rwidth), 
    caps[ srow ][12]:get_anchor("minusbr"):translate( _P.rwidth, - 4 *_P.rwidth), 
    _P.rwidth)
    cap_array:add_area_anchor_bltr("s2",
    caps[ srow ][12]:get_anchor("minusbr"):translate( 0.5 *_P.rwidth, - 4 * _P.rwidth),
    caps[ srow ][12]:get_anchor("minusbr"):translate( 1.5 *_P.rwidth, 0)
    )

    --S3
    geometry.path_cshape(cap_array, generics.metal(3),
    caps[6][12]:get_anchor("minuscl"), 
    caps[ srow ][11]:get_anchor("minusbr"):translate(  2 * _P.rwidth, - 5 *_P.rwidth), 
    caps[ srow ][11]:get_anchor("minusbr"):translate(  2 * _P.rwidth, - 5 *_P.rwidth), 
    _P.rwidth)
    cap_array:add_area_anchor_bltr("s3",
    caps[ srow ][11]:get_anchor("minusbr"):translate( 1.5 *_P.rwidth, - 5 * _P.rwidth),
    caps[ srow ][11]:get_anchor("minusbr"):translate( 2.5 *_P.rwidth, 0)
    )

    if  _P.bits >= 6 then 
        --S4
        geometry.path_cshape(cap_array, generics.metal(3),
        caps[7][11]:get_anchor("minuscl"), 
        caps[ _P.bits + 2 ][10]:get_anchor("minusbr"):translate( 2 * _P.rwidth, - 6 *_P.rwidth), 
        caps[ _P.bits + 2 ][10]:get_anchor("minusbr"):translate( 2 * _P.rwidth, - 6 *_P.rwidth), 
        _P.rwidth)
        cap_array:add_area_anchor_bltr("s4",
        caps[ _P.bits + 2 ][10]:get_anchor("minusbr"):translate( 1.5 *_P.rwidth, - 6 * _P.rwidth),
        caps[ _P.bits + 2 ][10]:get_anchor("minusbr"):translate( 2.5 *_P.rwidth, 0)
        )

        --S5
        geometry.path_cshape(cap_array, generics.metal(3),
        caps[8][10]:get_anchor("minuscl"), 
        caps[ _P.bits + 2 ][9]:get_anchor("minusbr"):translate( 2 * _P.rwidth, - 4 *_P.rwidth), 
        caps[ _P.bits + 2 ][9]:get_anchor("minusbr"):translate( 2 * _P.rwidth, - 4 *_P.rwidth), 
        _P.rwidth)
        cap_array:add_area_anchor_bltr("s5",
        caps[ _P.bits + 2 ][9]:get_anchor("minusbr"):translate( 1.5 *_P.rwidth, - 4 * _P.rwidth),
        caps[ _P.bits + 2 ][9]:get_anchor("minusbr"):translate( 2.5 *_P.rwidth, 0)
        )
    end

    if  _P.bits == 8 then 
        --S6
        geometry.path_cshape(cap_array, generics.metal(3),
        caps[9][8]:get_anchor("minuscl"), 
        caps[10][7]:get_anchor("minusbr"):translate( 2 * _P.rwidth, - 3 *_P.rwidth), 
        caps[10][7]:get_anchor("minusbr"):translate( 2 * _P.rwidth, - 3 *_P.rwidth), 
        _P.rwidth)
        cap_array:add_area_anchor_bltr("s6",
        caps[10][7]:get_anchor("minusbr"):translate( 1.5 *_P.rwidth, - 3 * _P.rwidth),
        caps[10][7]:get_anchor("minusbr"):translate( 2.5 *_P.rwidth, 0)
        )
        --S7
        geometry.path_cshape(cap_array, generics.metal(3),
        caps[10][5]:get_anchor("minuscl"), 
        caps[10][4]:get_anchor("minusbr"):translate( 2 * _P.rwidth, - 2 *_P.rwidth), 
        caps[10][4]:get_anchor("minusbr"):translate( 2 * _P.rwidth, - 2 *_P.rwidth), 
        _P.rwidth)
        cap_array:add_area_anchor_bltr("s7",
        caps[10][4]:get_anchor("minusbr"):translate( 1.5 *_P.rwidth, - 2 * _P.rwidth),
        caps[10][4]:get_anchor("minusbr"):translate( 2.5 *_P.rwidth, 0)
        )
    end

    -- alignment box
    if _P.bits == 8 then
        cap_array:set_alignment_box(
        caps[10][1]:get_anchor("minusbl"),
        caps[1][10]:get_anchor("plustr")
        )
    elseif _P.bits == 6 then
        cap_array:set_alignment_box(
        caps[8][9]:get_anchor("minusbl"),
        caps[2][18]:get_anchor("plustr")
        )
    elseif _P.bits == 4 then
        cap_array:set_alignment_box(
        caps[7][12]:get_anchor("minusbl"),
        caps[4][15]:get_anchor("plustr")
        )
    end
end
