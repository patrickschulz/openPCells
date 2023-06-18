function parameters()
    pcell.add_parameters(
        { "bits",    8 },
        { "rwidth",    100 }
    )
end


function layout(cap_array, _P)
    -- unit cap
    local capref = pcell.create_layout("passive/capacitor/mom", "unit_capacitor", {
        fingers = 11,
        fwidth = 44,
        fspace = 46,
    })

    -- basic array
    local row = 10
    local column = 26

    local caps = {}
    for i = 1, row do
        caps[i] = {}
        for j = 1, column do
            local cap = cap_array:add_child(capref, string.format("cap_%d_%d", i, j))
            if (i == 1 and j > 1) then
                cap:align_top(caps[i][j - 1])
                cap:abut_right(caps[i][j - 1])
                cap:translate_x(4 * _P.rwidth)
            end
            if i > 1 then
                cap:align_left(caps[i - 1][j])
                cap:abut_top(caps[i - 1][j])
                cap:translate_y(2 * _P.rwidth)
            end
            caps[i][j] = cap
        end
    end

    -- conncect for each group
    if _P.bits == 8 then
        --128
        geometry.rectanglebltr(cap_array, generics.metal(1),
            caps[1][2]:get_area_anchor("upperrail").br,
            caps[1][25]:get_area_anchor("upperrail").tl
        )
        geometry.rectanglebltr(cap_array, generics.metal(2),
            caps[1][2]:get_area_anchor("lowerrail").br,
            caps[1][25]:get_area_anchor("lowerrail").tl
        )
        geometry.rectanglebltr(cap_array, generics.metal(1),
            caps[10][2]:get_area_anchor("upperrail").br,
            caps[10][25]:get_area_anchor("upperrail").tl
        )
        geometry.rectanglebltr(cap_array, generics.metal(2),
            caps[10][2]:get_area_anchor("lowerrail").br,
            caps[10][25]:get_area_anchor("lowerrail").tl
        )

        for i = 2, 9 do
            geometry.rectanglebltr(cap_array, generics.metal(1),
                caps[i][1]:get_area_anchor("upperrail").br,
                caps[i][5]:get_area_anchor("upperrail").tl
            )
            geometry.rectanglebltr(cap_array, generics.metal(2),
                caps[i][1]:get_area_anchor("lowerrail").br,
                caps[i][5]:get_area_anchor("lowerrail").tl
            )
            geometry.rectanglebltr(cap_array, generics.metal(1),
                caps[i][1]:get_area_anchor("upperrail").br,
                caps[i][5]:get_area_anchor("upperrail").tl
            )
            geometry.rectanglebltr(cap_array, generics.metal(2),
                caps[i][1]:get_area_anchor("lowerrail").br,
                caps[i][5]:get_area_anchor("lowerrail").tl
            )

            geometry.rectanglebltr(cap_array, generics.metal(1),
                caps[i][22]:get_area_anchor("upperrail").br,
                caps[i][26]:get_area_anchor("upperrail").tl
            )
            geometry.rectanglebltr(cap_array, generics.metal(2),
                caps[i][22]:get_area_anchor("lowerrail").br,
                caps[i][26]:get_area_anchor("lowerrail").tl
            )
            geometry.rectanglebltr(cap_array, generics.metal(1),
                caps[i][22]:get_area_anchor("upperrail").br,
                caps[i][26]:get_area_anchor("upperrail").tl
            )
            geometry.rectanglebltr(cap_array, generics.metal(2),
                caps[i][22]:get_area_anchor("lowerrail").br,
                caps[i][26]:get_area_anchor("lowerrail").tl
            )
        end

        --geometry.path_cshape(cap_array, generics.metal(1),
        --caps[1][2]:get_area_anchor("upperrail").cl,
        --caps[10][2]:get_area_anchor("upperrail").cl,
        --caps[1][2]:get_area_anchor("upperrail").cl:translate( -2 * _P.rwidth, 0),
        --_P.rwidth)

        --geometry.path_cshape(cap_array, generics.metal(2),
        --caps[1][2]:get_area_anchor("lowerrail").cl,
        --caps[10][2]:get_area_anchor("lowerrail").cl,
        --caps[1][2]:get_area_anchor("lowerrail").cl:translate( -2 * _P.rwidth, 0),
        --_P.rwidth)

        --geometry.path_cshape(cap_array, generics.metal(1),
        --caps[1][25]:get_area_anchor("upperrail").cr,
        --caps[10][25]:get_area_anchor("upperrail").cr,
        --caps[1][25]:get_area_anchor("upperrail").cr:translate( 2 * _P.rwidth, 0),
        --_P.rwidth)

        --geometry.path_cshape(cap_array, generics.metal(2),
        --caps[1][25]:get_area_anchor("lowerrail").cr,
        --caps[10][25]:get_area_anchor("lowerrail").cr,
        --caps[1][25]:get_area_anchor("lowerrail").cr:translate( 2 *_P.rwidth, 0),
        --_P.rwidth)

        ---64
        for i = 2, 3 do
            geometry.rectanglebltr(cap_array, generics.metal(1),
                caps[i][6]:get_area_anchor("upperrail").br,
                caps[i][9]:get_area_anchor("upperrail").tl
            )

            geometry.rectanglebltr(cap_array, generics.metal(2),
                caps[i][6]:get_area_anchor("lowerrail").br,
                caps[i][9]:get_area_anchor("lowerrail").tl
            )

            geometry.rectanglebltr(cap_array, generics.metal(1),
                caps[i][18]:get_area_anchor("upperrail").br,
                caps[i][21]:get_area_anchor("upperrail").tl
            )
            geometry.rectanglebltr(cap_array, generics.metal(2),
                caps[i][18]:get_area_anchor("lowerrail").br,
                caps[i][21]:get_area_anchor("lowerrail").tl
            )
        end

        geometry.rectanglebltr(cap_array, generics.metal(1),
            caps[8][6]:get_area_anchor("upperrail").br,
            caps[8][9]:get_area_anchor("upperrail").tl
        )

        geometry.rectanglebltr(cap_array, generics.metal(2),
            caps[8][6]:get_area_anchor("lowerrail").br,
            caps[8][9]:get_area_anchor("lowerrail").tl
        )

        geometry.rectanglebltr(cap_array, generics.metal(1),
            caps[8][18]:get_area_anchor("upperrail").br,
            caps[8][21]:get_area_anchor("upperrail").tl
        )
        geometry.rectanglebltr(cap_array, generics.metal(2),
            caps[8][18]:get_area_anchor("lowerrail").br,
            caps[8][21]:get_area_anchor("lowerrail").tl
        )

        for i = 4, 7 do
            geometry.rectanglebltr(cap_array, generics.metal(1),
                caps[i][6]:get_area_anchor("upperrail").br,
                caps[i][8]:get_area_anchor("upperrail").tl
            )

            geometry.rectanglebltr(cap_array, generics.metal(2),
                caps[i][6]:get_area_anchor("lowerrail").br,
                caps[i][8]:get_area_anchor("lowerrail").tl
            )

            geometry.rectanglebltr(cap_array, generics.metal(1),
                caps[i][19]:get_area_anchor("upperrail").br,
                caps[i][21]:get_area_anchor("upperrail").tl
            )
            geometry.rectanglebltr(cap_array, generics.metal(2),
                caps[i][19]:get_area_anchor("lowerrail").br,
                caps[i][21]:get_area_anchor("lowerrail").tl
            )
        end

        geometry.rectanglebltr(cap_array, generics.metal(1),
            caps[9][6]:get_area_anchor("upperrail").br,
            caps[9][21]:get_area_anchor("upperrail").tl
        )

        geometry.rectanglebltr(cap_array, generics.metal(2),
            caps[9][6]:get_area_anchor("lowerrail").br,
            caps[9][21]:get_area_anchor("lowerrail").tl
        )

        geometry.rectanglebltr(cap_array, generics.metal(1),
            caps[2][7]:get_area_anchor("upperrail").bl:translate_x(-_P.rwidth),
            caps[9][7]:get_area_anchor("upperrail").bl
            --caps[2][7]:get_area_anchor("upperrail").bl:translate( -2 * _P.rwidth, 0),
        )

        --geometry.path_cshape(cap_array, generics.metal(2),
        --    caps[2][7]:get_area_anchor("lowerrail").cl,
        --    caps[9][7]:get_area_anchor("lowerrail").cl,
        --    caps[2][7]:get_area_anchor("lowerrail").cl:translate( -2 * _P.rwidth, 0),
        --_P.rwidth)

        --geometry.path_cshape(cap_array, generics.metal(1),
        --    caps[2][20]:get_area_anchor("upperrail").cr,
        --    caps[9][20]:get_area_anchor("upperrail").cr,
        --    caps[2][20]:get_area_anchor("upperrail").cr:translate( 2 * _P.rwidth, 0),
        --_P.rwidth)

        --geometry.path_cshape(cap_array, generics.metal(2),
        --    caps[2][20]:get_area_anchor("lowerrail").cr,
        --    caps[9][20]:get_area_anchor("lowerrail").cr,
        --    caps[2][20]:get_area_anchor("lowerrail").cr:translate( 2 *_P.rwidth, 0),
        --_P.rwidth)
    end

    --[[
    if _P.bits >= 6 then
        --32
        geometry.path(cap_array, generics.metal(1),{
            caps[2][10]:get_anchor("upperrailcc"),
            caps[2][17]:get_anchor("upperrailcc")
        }, _P.rwidth)

        geometry.path(cap_array, generics.metal(2),{
            caps[2][10]:get_anchor("lowerrailcc"),
            caps[2][17]:get_anchor("lowerrailcc")
        }, _P.rwidth)

        geometry.path(cap_array, generics.metal(1),{
            caps[8][10]:get_anchor("upperrailcc"),
            caps[8][17]:get_anchor("upperrailcc")
        }, _P.rwidth)
        geometry.path(cap_array, generics.metal(2),{
            caps[8][10]:get_anchor("lowerrailcc"),
            caps[8][17]:get_anchor("lowerrailcc")
        }, _P.rwidth)

        geometry.path(cap_array, generics.metal(1),{
            caps[3][10]:get_anchor("upperrailcl"),
            caps[3][10]:get_anchor("upperrailcl"):translate( - 2 * _P.rwidth, 0)
        }, _P.rwidth)

        geometry.path(cap_array, generics.metal(2),{
            caps[3][10]:get_anchor("lowerrailcl"),
            caps[3][10]:get_anchor("lowerrailcl"):translate( - 2 * _P.rwidth, 0)
        }, _P.rwidth)
        geometry.path(cap_array, generics.metal(1),{
            caps[3][17]:get_anchor("upperrailcr"),
            caps[3][17]:get_anchor("upperrailcr"):translate( 2 * _P.rwidth, 0)
        }, _P.rwidth)

        geometry.path(cap_array, generics.metal(2),{
            caps[3][17]:get_anchor("lowerrailcr"),
            caps[3][17]:get_anchor("lowerrailcr"):translate( 2 * _P.rwidth, 0)
        }, _P.rwidth)


        geometry.path(cap_array, generics.metal(1),{
            caps[4][9]:get_anchor("upperrailcc"),
            caps[4][10]:get_anchor("upperrailcc")
        }, _P.rwidth)

        geometry.path(cap_array, generics.metal(2),{
            caps[4][9]:get_anchor("lowerrailcc"),
            caps[4][10]:get_anchor("lowerrailcc")
        }, _P.rwidth)

        geometry.path(cap_array, generics.metal(1),{
            caps[4][17]:get_anchor("upperrailcc"),
            caps[4][18]:get_anchor("upperrailcc")
        }, _P.rwidth)

        geometry.path(cap_array, generics.metal(2),{
            caps[4][17]:get_anchor("lowerrailcc"),
            caps[4][18]:get_anchor("lowerrailcc")
        }, _P.rwidth)

        geometry.path(cap_array, generics.metal(1),{
            caps[5][9]:get_anchor("upperrailcr"),
            caps[5][9]:get_anchor("upperrailcr"):translate( 2 * _P.rwidth, 0)
        }, _P.rwidth)

        geometry.path(cap_array, generics.metal(2),{
            caps[5][9]:get_anchor("lowerrailcr"),
            caps[5][9]:get_anchor("lowerrailcr"):translate( 2 * _P.rwidth, 0)
        }, _P.rwidth)
        geometry.path(cap_array, generics.metal(1),{
            caps[5][18]:get_anchor("upperrailcl"),
            caps[5][18]:get_anchor("upperrailcl"):translate( - 2 * _P.rwidth, 0)
        }, _P.rwidth)

        geometry.path(cap_array, generics.metal(2),{
            caps[5][18]:get_anchor("lowerrailcl"),
            caps[5][18]:get_anchor("lowerrailcl"):translate( - 2 * _P.rwidth, 0)
        }, _P.rwidth)

        for i = 6, 7 do
            geometry.path(cap_array, generics.metal(1),{
                caps[i][9]:get_anchor("upperrailcc"),
                caps[i][10]:get_anchor("upperrailcc")
            }, _P.rwidth)

            geometry.path(cap_array, generics.metal(2),{
                caps[i][9]:get_anchor("lowerrailcc"),
                caps[i][10]:get_anchor("lowerrailcc")
            }, _P.rwidth)

            geometry.path(cap_array, generics.metal(1),{
                caps[i][17]:get_anchor("upperrailcc"),
                caps[i][18]:get_anchor("upperrailcc")
            }, _P.rwidth)

            geometry.path(cap_array, generics.metal(2),{
                caps[i][17]:get_anchor("lowerrailcc"),
                caps[i][18]:get_anchor("lowerrailcc")
            }, _P.rwidth)
        end

        geometry.path_cshape(cap_array, generics.metal(1),
        caps[2][10]:get_anchor("upperrailcl"),
        caps[8][10]:get_anchor("upperrailcl"),
        caps[2][10]:get_anchor("upperrailcl"):translate( -2 * _P.rwidth, 0),
        _P.rwidth)

        geometry.path_cshape(cap_array, generics.metal(2),
        caps[2][10]:get_anchor("lowerrailcl"),
        caps[8][10]:get_anchor("lowerrailcl"),
        caps[2][10]:get_anchor("lowerrailcl"):translate( -2 * _P.rwidth, 0),
        _P.rwidth)

        geometry.path_cshape(cap_array, generics.metal(1),
        caps[2][17]:get_anchor("upperrailcr"),
        caps[8][17]:get_anchor("upperrailcr"),
        caps[2][17]:get_anchor("upperrailcr"):translate( 2 * _P.rwidth, 0),
        _P.rwidth)

        geometry.path_cshape(cap_array, generics.metal(2),
        caps[2][17]:get_anchor("lowerrailcr"),
        caps[8][17]:get_anchor("lowerrailcr"),
        caps[2][17]:get_anchor("lowerrailcr"):translate( 2 *_P.rwidth, 0),
        _P.rwidth)

        --16
        geometry.path(cap_array, generics.metal(1),{
            caps[3][11]:get_anchor("upperrailcc"),
            caps[3][16]:get_anchor("upperrailcc")
        }, _P.rwidth)

        geometry.path(cap_array, generics.metal(2),{
            caps[3][11]:get_anchor("lowerrailcc"),
            caps[3][16]:get_anchor("lowerrailcc")
        }, _P.rwidth)
        for i = 4, 7 do
            geometry.path(cap_array, generics.metal(1),{
                caps[i][11]:get_anchor("upperrailcl"),
                caps[i][11]:get_anchor("upperrailcl"):translate( - 2 * _P.rwidth, 0)
            }, _P.rwidth)
            geometry.path(cap_array, generics.metal(2),{
                caps[i][11]:get_anchor("lowerrailcl"),
                caps[i][11]:get_anchor("lowerrailcl"):translate( - 2 * _P.rwidth, 0)
            }, _P.rwidth)
            geometry.path(cap_array, generics.metal(1),{
                caps[i][16]:get_anchor("upperrailcr"),
                caps[i][16]:get_anchor("upperrailcr"):translate( 2 * _P.rwidth, 0)
            }, _P.rwidth)
            geometry.path(cap_array, generics.metal(2),{
                caps[i][16]:get_anchor("lowerrailcr"),
                caps[i][16]:get_anchor("lowerrailcr"):translate( 2 * _P.rwidth, 0)
            }, _P.rwidth)
        end
        geometry.path(cap_array, generics.metal(1),{
            caps[5][10]:get_anchor("upperrailcc"),
            caps[5][11]:get_anchor("upperrailcc")
        }, _P.rwidth)

        geometry.path(cap_array, generics.metal(2),{
            caps[5][10]:get_anchor("lowerrailcc"),
            caps[5][11]:get_anchor("lowerrailcc")
        }, _P.rwidth)
        geometry.path(cap_array, generics.metal(1),{
            caps[5][16]:get_anchor("upperrailcc"),
            caps[5][17]:get_anchor("upperrailcc")
        }, _P.rwidth)

        geometry.path(cap_array, generics.metal(2),{
            caps[5][16]:get_anchor("lowerrailcc"),
            caps[5][17]:get_anchor("lowerrailcc")
        }, _P.rwidth)

        geometry.path_cshape(cap_array, generics.metal(1),
        caps[3][11]:get_anchor("upperrailcl"),
        caps[7][11]:get_anchor("upperrailcl"),
        caps[3][11]:get_anchor("upperrailcl"):translate( - 2 * _P.rwidth, 0),
        _P.rwidth)
        geometry.path_cshape(cap_array, generics.metal(2),
        caps[3][11]:get_anchor("lowerrailcl"),
        caps[7][11]:get_anchor("lowerrailcl"),
        caps[3][11]:get_anchor("lowerrailcl"):translate( - 2 * _P.rwidth, 0),
        _P.rwidth)
        geometry.path_cshape(cap_array, generics.metal(1),
        caps[3][16]:get_anchor("upperrailcr"),
        caps[7][16]:get_anchor("upperrailcr"),
        caps[3][16]:get_anchor("upperrailcr"):translate( 2 *_P.rwidth, 0),
        _P.rwidth)
        geometry.path_cshape(cap_array, generics.metal(2),
        caps[3][16]:get_anchor("lowerrailcr"),
        caps[7][16]:get_anchor("lowerrailcr"),
        caps[3][16]:get_anchor("lowerrailcr"):translate( 2 *_P.rwidth, 0),
        _P.rwidth)
    end

    --8
    geometry.path(cap_array, generics.metal(1),{
        caps[4][12]:get_anchor("upperrailcc"),
        caps[4][15]:get_anchor("upperrailcc")
    }, _P.rwidth)
    geometry.path(cap_array, generics.metal(2),{
        caps[4][12]:get_anchor("lowerrailcc"),
        caps[4][15]:get_anchor("lowerrailcc")
    }, _P.rwidth)
    for i = 5, 6 do
        geometry.path(cap_array, generics.metal(1),{
            caps[i][12]:get_anchor("upperrailcl"),
            caps[i][12]:get_anchor("upperrailcl"):translate( - 2 * _P.rwidth, 0)
        }, _P.rwidth)
        geometry.path(cap_array, generics.metal(2),{
            caps[i][12]:get_anchor("lowerrailcl"),
            caps[i][12]:get_anchor("lowerrailcl"):translate( - 2 * _P.rwidth, 0)
        }, _P.rwidth)
        geometry.path(cap_array, generics.metal(1),{
            caps[i][15]:get_anchor("upperrailcr"),
            caps[i][15]:get_anchor("upperrailcr"):translate( 2 * _P.rwidth, 0)
        }, _P.rwidth)
        geometry.path(cap_array, generics.metal(2),{
            caps[i][15]:get_anchor("lowerrailcr"),
            caps[i][15]:get_anchor("lowerrailcr"):translate( 2 * _P.rwidth, 0)
        }, _P.rwidth)
    end
    geometry.path_cshape(cap_array, generics.metal(1),
    caps[4][12]:get_anchor("upperrailcl"),
    caps[6][12]:get_anchor("upperrailcl"),
    caps[4][12]:get_anchor("upperrailcl"):translate( - 2 * _P.rwidth, 0),
    _P.rwidth)
    geometry.path_cshape(cap_array, generics.metal(2),
    caps[4][12]:get_anchor("lowerrailcl"),
    caps[6][12]:get_anchor("lowerrailcl"),
    caps[4][12]:get_anchor("lowerrailcl"):translate( - 2 * _P.rwidth, 0),
    _P.rwidth)
    geometry.path_cshape(cap_array, generics.metal(1),
    caps[4][15]:get_anchor("upperrailcr"),
    caps[6][15]:get_anchor("upperrailcr"),
    caps[4][15]:get_anchor("upperrailcr"):translate( 2 *_P.rwidth, 0),
    _P.rwidth)
    geometry.path_cshape(cap_array, generics.metal(2),
    caps[4][15]:get_anchor("lowerrailcr"),
    caps[6][15]:get_anchor("lowerrailcr"),
    caps[4][15]:get_anchor("lowerrailcr"):translate( 2 *_P.rwidth, 0),
    _P.rwidth)

    --4
    geometry.path(cap_array, generics.metal(1),{
        caps[7][12]:get_anchor("upperrailcc"),
        caps[7][15]:get_anchor("upperrailcc")
    }, _P.rwidth)
    geometry.path(cap_array, generics.metal(2),{
        caps[7][12]:get_anchor("lowerrailcc"),
        caps[7][15]:get_anchor("lowerrailcc")
    }, _P.rwidth)

    --2
    geometry.path(cap_array, generics.metal(1),{
        caps[5][13]:get_anchor("upperrailcc"),
        caps[5][14]:get_anchor("upperrailcc")
    }, _P.rwidth)
    geometry.path(cap_array, generics.metal(2),{
        caps[5][13]:get_anchor("lowerrailcc"),
        caps[5][14]:get_anchor("lowerrailcc")
    }, _P.rwidth)


    --connect vout
    if _P.bits == 8 then
        geometry.path(cap_array, generics.metal(3),{
            caps[5][1]:get_anchor("upperrailcl"),
            caps[5][26]:get_anchor("upperrailcr")
        }, _P.rwidth)
        geometry.path_cshape(cap_array, generics.metal(3),
        caps[5][13]:get_anchor("upperrailcl"),
        caps[10][1]:get_anchor("lowerrailbr"):translate( 2 *_P.rwidth, - 1 *_P.rwidth),
        caps[10][1]:get_anchor("lowerrailbr"):translate( 2 *_P.rwidth, - 1 *_P.rwidth),
        _P.rwidth)
        cap_array:add_area_anchor_bltr("vout",
        caps[10][1]:get_anchor("lowerrailbr"):translate( 1.5 *_P.rwidth, - 1 *_P.rwidth),
        caps[10][1]:get_anchor("lowerrailbr"):translate( 2.5 *_P.rwidth, 0)
        )
    elseif _P.bits == 6 then
        geometry.path(cap_array, generics.metal(3),{
            caps[5][9]:get_anchor("upperrailcl"),
            caps[5][18]:get_anchor("upperrailcr")
        }, _P.rwidth)
        geometry.path_cshape(cap_array, generics.metal(3),
        caps[5][13]:get_anchor("upperrailcl"),
        caps[8][8]:get_anchor("lowerrailbr"):translate( 2 *_P.rwidth, - 1 *_P.rwidth),
        caps[8][8]:get_anchor("lowerrailbr"):translate( 2 *_P.rwidth, - 1 *_P.rwidth),
        _P.rwidth)
        cap_array:add_area_anchor_bltr("vout",
        caps[8][8]:get_anchor("lowerrailbr"):translate( 1.5 *_P.rwidth, - 1 *_P.rwidth),
        caps[8][8]:get_anchor("lowerrailbr"):translate( 2.5 *_P.rwidth, 0)
        )
    elseif _P.bits == 4 then
        geometry.path(cap_array, generics.metal(3),{
            caps[5][12]:get_anchor("upperrailcl"),
            caps[5][15]:get_anchor("upperrailcr")
        }, _P.rwidth)
        geometry.path_cshape(cap_array, generics.metal(3),
        caps[5][13]:get_anchor("upperrailcl"),
        caps[7][11]:get_anchor("lowerrailbr"):translate( 0, - 1 *_P.rwidth),
        caps[7][11]:get_anchor("lowerrailbr"):translate( 0, - 1 *_P.rwidth),
        _P.rwidth)
        cap_array:add_area_anchor_bltr("vout",
        caps[7][11]:get_anchor("lowerrailbr"):translate( - 0.5 *_P.rwidth, - 1 *_P.rwidth),
        caps[7][11]:get_anchor("lowerrailbr"):translate( 0.5 *_P.rwidth, 0)
        )
    end

    local srow = 7	--for 4 bits

    if _P.bits >= 6 then
        srow = _P.bits + 2
    end

    --port metal and anchor
    --sdummy
    geometry.path_cshape(cap_array, generics.metal(3),
    caps[6][13]:get_anchor("upperrailcr"),
    caps[5][14]:get_anchor("upperrailcr"):translate( 2 *_P.rwidth, 0),
    caps[5][14]:get_anchor("upperrailcr"):translate( 2 *_P.rwidth, 0),
    _P.rwidth)
    geometry.path_cshape(cap_array, generics.metal(3),
    caps[6][14]:get_anchor("lowerrailcr"),
    caps[ srow ][14]:get_anchor("lowerrailbr"):translate( 2 *_P.rwidth, - 1 * _P.rwidth),
    caps[ srow ][14]:get_anchor("lowerrailbr"):translate( 2 *_P.rwidth, - 1 * _P.rwidth),
    _P.rwidth)
    cap_array:add_area_anchor_bltr("sdummy",
    caps[ srow ][14]:get_anchor("lowerrailbr"):translate( 1.5 *_P.rwidth, - 1 * _P.rwidth),
    caps[ srow ][14]:get_anchor("lowerrailbr"):translate( 2.5 *_P.rwidth, 0)
    )

    --S0
    geometry.path_cshape(cap_array, generics.metal(3),
    caps[6][13]:get_anchor("lowerrailcr"),
    caps[ srow ][13]:get_anchor("lowerrailbr"):translate( 2 *_P.rwidth, - 2 *_P.rwidth),
    caps[ srow ][13]:get_anchor("lowerrailbr"):translate( 2 *_P.rwidth, - 2 *_P.rwidth),
    _P.rwidth)
    cap_array:add_area_anchor_bltr("s0",
    caps[ srow ][13]:get_anchor("lowerrailbr"):translate( 1.5 *_P.rwidth, - 2 * _P.rwidth),
    caps[ srow ][13]:get_anchor("lowerrailbr"):translate( 2.5 *_P.rwidth, 0)
    )

    --S1
    geometry.path_cshape(cap_array, generics.metal(3),
    caps[5][14]:get_anchor("lowerrailcl"),
    caps[ srow ][13]:get_anchor("lowerrailbl"):translate( - _P.rwidth, - 3 *_P.rwidth),
    caps[ srow ][13]:get_anchor("lowerrailbl"):translate( - _P.rwidth, - 3 *_P.rwidth),
    _P.rwidth)
    cap_array:add_area_anchor_bltr("s1",
    caps[ srow ][13]:get_anchor("lowerrailbl"):translate( - 1.5 *_P.rwidth, - 3 * _P.rwidth),
    caps[ srow ][13]:get_anchor("lowerrailbl"):translate( - 0.5 *_P.rwidth, 0)
    )

    --S2
    geometry.path_cshape(cap_array, generics.metal(3),
    caps[7][12]:get_anchor("upperrailcr"),
    caps[5][12]:get_anchor("upperrailcr"):translate( _P.rwidth, 0),
    caps[5][12]:get_anchor("upperrailcr"):translate( _P.rwidth, 0),
    _P.rwidth)
    geometry.path_cshape(cap_array, generics.metal(3),
    caps[7][12]:get_anchor("lowerrailcr"),
    caps[ srow ][12]:get_anchor("lowerrailbr"):translate( _P.rwidth, - 4 *_P.rwidth),
    caps[ srow ][12]:get_anchor("lowerrailbr"):translate( _P.rwidth, - 4 *_P.rwidth),
    _P.rwidth)
    cap_array:add_area_anchor_bltr("s2",
    caps[ srow ][12]:get_anchor("lowerrailbr"):translate( 0.5 *_P.rwidth, - 4 * _P.rwidth),
    caps[ srow ][12]:get_anchor("lowerrailbr"):translate( 1.5 *_P.rwidth, 0)
    )

    --S3
    geometry.path_cshape(cap_array, generics.metal(3),
    caps[6][12]:get_anchor("lowerrailcl"),
    caps[ srow ][11]:get_anchor("lowerrailbr"):translate(  2 * _P.rwidth, - 5 *_P.rwidth),
    caps[ srow ][11]:get_anchor("lowerrailbr"):translate(  2 * _P.rwidth, - 5 *_P.rwidth),
    _P.rwidth)
    cap_array:add_area_anchor_bltr("s3",
    caps[ srow ][11]:get_anchor("lowerrailbr"):translate( 1.5 *_P.rwidth, - 5 * _P.rwidth),
    caps[ srow ][11]:get_anchor("lowerrailbr"):translate( 2.5 *_P.rwidth, 0)
    )

    if  _P.bits >= 6 then
        --S4
        geometry.path_cshape(cap_array, generics.metal(3),
        caps[7][11]:get_anchor("lowerrailcl"),
        caps[ _P.bits + 2 ][10]:get_anchor("lowerrailbr"):translate( 2 * _P.rwidth, - 6 *_P.rwidth),
        caps[ _P.bits + 2 ][10]:get_anchor("lowerrailbr"):translate( 2 * _P.rwidth, - 6 *_P.rwidth),
        _P.rwidth)
        cap_array:add_area_anchor_bltr("s4",
        caps[ _P.bits + 2 ][10]:get_anchor("lowerrailbr"):translate( 1.5 *_P.rwidth, - 6 * _P.rwidth),
        caps[ _P.bits + 2 ][10]:get_anchor("lowerrailbr"):translate( 2.5 *_P.rwidth, 0)
        )

        --S5
        geometry.path_cshape(cap_array, generics.metal(3),
        caps[8][10]:get_anchor("lowerrailcl"),
        caps[ _P.bits + 2 ][9]:get_anchor("lowerrailbr"):translate( 2 * _P.rwidth, - 4 *_P.rwidth),
        caps[ _P.bits + 2 ][9]:get_anchor("lowerrailbr"):translate( 2 * _P.rwidth, - 4 *_P.rwidth),
        _P.rwidth)
        cap_array:add_area_anchor_bltr("s5",
        caps[ _P.bits + 2 ][9]:get_anchor("lowerrailbr"):translate( 1.5 *_P.rwidth, - 4 * _P.rwidth),
        caps[ _P.bits + 2 ][9]:get_anchor("lowerrailbr"):translate( 2.5 *_P.rwidth, 0)
        )
    end

    if  _P.bits == 8 then
        --S6
        geometry.path_cshape(cap_array, generics.metal(3),
        caps[9][8]:get_anchor("lowerrailcl"),
        caps[10][7]:get_anchor("lowerrailbr"):translate( 2 * _P.rwidth, - 3 *_P.rwidth),
        caps[10][7]:get_anchor("lowerrailbr"):translate( 2 * _P.rwidth, - 3 *_P.rwidth),
        _P.rwidth)
        cap_array:add_area_anchor_bltr("s6",
        caps[10][7]:get_anchor("lowerrailbr"):translate( 1.5 *_P.rwidth, - 3 * _P.rwidth),
        caps[10][7]:get_anchor("lowerrailbr"):translate( 2.5 *_P.rwidth, 0)
        )
        --S7
        geometry.path_cshape(cap_array, generics.metal(3),
        caps[10][5]:get_anchor("lowerrailcl"),
        caps[10][4]:get_anchor("lowerrailbr"):translate( 2 * _P.rwidth, - 2 *_P.rwidth),
        caps[10][4]:get_anchor("lowerrailbr"):translate( 2 * _P.rwidth, - 2 *_P.rwidth),
        _P.rwidth)
        cap_array:add_area_anchor_bltr("s7",
        caps[10][4]:get_anchor("lowerrailbr"):translate( 1.5 *_P.rwidth, - 2 * _P.rwidth),
        caps[10][4]:get_anchor("lowerrailbr"):translate( 2.5 *_P.rwidth, 0)
        )
    end

    -- alignment box
    if _P.bits == 8 then
        cap_array:set_alignment_box(
        caps[10][1]:get_anchor("lowerrailbl"),
        caps[1][10]:get_anchor("upperrailtr")
        )
    elseif _P.bits == 6 then
        cap_array:set_alignment_box(
        caps[8][9]:get_anchor("lowerrailbl"),
        caps[2][18]:get_anchor("upperrailtr")
        )
    elseif _P.bits == 4 then
        cap_array:set_alignment_box(
        caps[7][12]:get_anchor("lowerrailbl"),
        caps[4][15]:get_anchor("upperrailtr")
        )
    end
    --]]
end
