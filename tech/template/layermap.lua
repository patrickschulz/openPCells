-- this is the layermap for mapping generic layers to technology-specific layers
-- the layermap does not have to be complete, but you will have to provide the necessary mappings for the cells you want to use
-- That means for example if you are only using inductors, you don't need to provide any data on FEOL layers
-- If any mappings are missing you will receive an error during runtime

-- For every generic layer, mappings for the layer and the purpose must be given
-- For the support of different interfaces, a number (for GDS) and a name (for virtuoso) must be given, this may change in the future
-- Some generic layers are mapped to nothing, for example a standard p-bulk process has no pwell. You have to explicitly state that
-- the mapping is not needed, otherwise it would look like a missing mapping (see below)

-- Example for a standard triple-well p-bulk process
--
--             ---------------------------------------------------
--             |                                                 |
--             |                                                 |
--             |                                                 |
--             |             Metal 3                             |
--             |                                                 |
--             |                                                 |
--             |                                                 |
--             ---------------------------------------------------
--                       |             |
--                       |             |
--                       |     Via     |
--                       |    M2->M3   |
--                       |             |
--                       |             |
--                  ---------------------------------------------------
--                  |                                                 |
--                  |             Metal 2                             |
--                  |                                                 |
--                  ---------------------------------------------------
--                                                       |         |
--                                                       |   Via   |
--                                                       |  M1->M2 |
--                                                       |         |
--                                 ---------------------------------------------------
--                                 |                                                 |
--                                 |             Metal 1                             |
--                                 |                                                 |
--                                 ---------------------------------------------------
--                                    |  Gate   |      |          |
--                                    | Contact |      |          |
--                                    |         |      |   Well   |
--                                .-----------------.  | Conctact |
--                                |       Gate      |  |          |
--                                |                 |  |          |
-- ====================================================================================================================================================
--             |      |  p+ diff   |               |      p+ diff    |         |
--             |      \            /               \                 /         |
--             |       *----------*                 *---------------*          |       p-sub (no layer)
--             |                                                               |
--             \                                                               /-----------------------------------------------------------
--              \                       n-well                                /                         deep n-well                       |
--               *-----------------------------------------------------------*-------------------------------------------------------------
--
--                                                                            p-bulk
return {
    -- every entry has the following form:
    -- {
    --  layer = {
    --      number = xx, -- GDS layer (number)
    --      name,  = ss, -- layer name (string)
    --  },
    --  purpose = {
    --      number = xx, -- GDS datatype (number)
    --      name,  = ss, -- purpose name (string)
    --  }
    -- }
    vthtype1    = { layer = { number = 42, name = "rvt"         }, purpose = { number = 0, name = "drawing" } },
    vthtype2    = { layer = { number = 43, name = "lvt"         }, purpose = { number = 0, name = "drawing" } },
    oxthick1    = "UNUSED",
    oxthick2    = { layer = { number = 44, name = "io"          }, purpose = { number = 0, name = "drawing" } },
    nwell       = { layer = { number = 16, name = "nwell"       }, purpose = { number = 0, name = "drawing" } },
    pwell       = "UNUSED",
    deepnwell   = { layer = { number = 17, name = "deepnwell"   }, purpose = { number = 0, name = "drawing" } },
    deeppwell   = "UNUSED",
    active      = { layer = { number =  1, name = "active"      }, purpose = { number = 0, name = "drawing" } },
    pimpl       = { layer = { number =  2, name = "pimpl"       }, purpose = { number = 0, name = "drawing" } },
    nimpl       = { layer = { number =  3, name = "nimpl"       }, purpose = { number = 0, name = "drawing" } },
    soiopen     = { layer = { number =  4, name = "soiopen"     }, purpose = { number = 0, name = "drawing" } },
    gate        = { layer = { number =  5, name = "gate"        }, purpose = { number = 0, name = "drawing" } },
    gatecut     = { layer = { number =  6, name = "gatecut"     }, purpose = { number = 0, name = "drawing" } },
    wellcont    = { layer = { number =  7, name = "wellcont"    }, purpose = { number = 0, name = "drawing" } },
    gatecont    = { layer = { number =  8, name = "gatecont"    }, purpose = { number = 0, name = "drawing" } },
    M1          = { layer = { number =  9, name = "M1"          }, purpose = { number = 0, name = "drawing" } },
    viaM1M2     = { layer = { number = 10, name = "viaM1M2"     }, purpose = { number = 0, name = "drawing" } },
    M2          = { layer = { number = 11, name = "M2"          }, purpose = { number = 0, name = "drawing" } },
    viaM2M3     = { layer = { number = 12, name = "viaM1M2"     }, purpose = { number = 0, name = "drawing" } },
    M3          = { layer = { number = 13, name = "M2"          }, purpose = { number = 0, name = "drawing" } },
    firstmetal  = { layer = { number =  9, name = "M1"          }, purpose = { number = 0, name = "drawing" } },
    lastmetal   = { layer = { number = 11, name = "M2"          }, purpose = { number = 0, name = "drawing" } },
    outermetal  = { layer = { number = 13, name = "M3"          }, purpose = { number = 0, name = "drawing" } },
}
