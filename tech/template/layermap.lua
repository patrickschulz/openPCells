-- this is the layermap for mapping generic layers to technology-specific layers
-- the layermap does not have to be complete, but you will have to provide the necessary mappings for the cells you want to use
-- That means for example if you are only using inductors, you don't need to provide any data on FEOL layers
-- If any mappings are missing you will receive an error during runtime

-- For every generic layer, mappings for the layer and the purpose must be given
-- For the support of different export types, every export type needs and entry for every layer.
-- Some generic layers are mapped to nothing, for example a standard p-bulk process has no pwell.
-- You have to explicitly state that by setting it to empty ('{}')

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
--             \                                                               /------------------------------------------------------------*
--              \                       n-well                                /                                                             |
--               *-----------------------------------------------------------*                                                              *
--                                                                           |                          deep n-well                         |
--                                                                           |                                                              |
--                                                                           *--------------------------------------------------------------*
--                                                                                   
--                                                                                   
--                                                                            p-bulk
--                                                                                   
--                                                                                   
--=====================================================================================================================================================
return {
    -- every entry has the following form:
    -- {
    --  layer = {
    --      name = <name>, -- layer name (string, optional)
    --      export1 = {
    --          <export-related data>
    --      },
    --      export2 = {
    --          <export-related data>
    --      },
    --  },
    -- }
    -- for instance, the GDS export requires a datatype and a purpose, the SKILL export requires similar data, but as strings:
    -- gds = {
    --    layer = 42,
    --    purpose = 0,
    -- }
    -- SKILL = {
    --    layer = "somelayer",
    --    purpose = "drawing",
    -- }
    -- the vthtypes in this 'technology node' map to the same layer
    -- this shall demonstrate how the internal mapping can be modified to fit the layer handling of different nodes
    vthtypen1   = { gds = { layer = 42, number = 0, }, SKILL = { name = "rvt", purpose = "drawing" } },
    vthtypen2   = { gds = { layer = 43, number = 0, }, SKILL = { name = "lvt", purpose = "drawing" } },
    vthtypep1   = { gds = { layer = 42, number = 0, }, SKILL = { name = "rvt", purpose = "drawing" } },
    vthtypep2   = { gds = { layer = 43, number = 0, }, SKILL = { name = "lvt", purpose = "drawing" } },
    oxide1      = {}, -- unused
    oxide2      = { gds = { layer = 44, number = 0, }, SKILL = { name = "io", purpose = "drawing" } },
    nwell       = { gds = { layer = 16, number = 0, }, SKILL = { name = "nwell", purpose = "drawing" } },
    pwell       = {}, -- unused
    deepnwell   = { gds = { layer = 17, number = 0, }, SKILL = { name = "deepnwell", purpose = "drawing" } },
    deeppwell   = {}, -- unused
    active      = { gds = { layer =  1, number = 0, }, SKILL = { name = "active", purpose = "drawing" } },
    pimplant    = { gds = { layer =  2, number = 0, }, SKILL = { name = "pimpl", purpose = "drawing" } },
    nimplant    = { gds = { layer =  3, number = 0, }, SKILL = { name = "nimpl", purpose = "drawing" } },
    soiopen     = { gds = { layer =  4, number = 0, }, SKILL = { name = "soiopen", purpose = "drawing" } },
    gate        = { gds = { layer =  5, number = 0, }, SKILL = { name = "gate", purpose = "drawing" } },
    gatecut     = {}, -- unused
    wellcont    = { gds = { layer =  7, number = 0, }, SKILL = { name = "wellcont", purpose = "drawing" } },
    gatecont    = { gds = { layer =  8, number = 0, }, SKILL = { name = "gatecont", purpose = "drawing" } },
    M1          = { gds = { layer =  9, number = 0, }, SKILL = { name = "M1", purpose = "drawing" } },
    viacutM1M2  = { gds = { layer = 10, number = 0, }, SKILL = { name = "viaM1M2", purpose = "drawing" } },
    M2          = { gds = { layer = 11, number = 0, }, SKILL = { name = "M2", purpose = "drawing" } },
    viacutM2M3  = { gds = { layer = 12, number = 0, }, SKILL = { name = "viaM1M2", purpose = "drawing" } },
    M3          = { gds = { layer = 13, number = 0, }, SKILL = { name = "M2", purpose = "drawing" } },
}
