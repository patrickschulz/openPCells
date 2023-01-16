    -- connect rslatch together
    geometry.viabltr(comparator, 1, 4, 
        pmosrslatchleft2:get_anchor("botgatestrapbl"), 
        pmosrslatchleft2:get_anchor("botgatestraptr")
    )
    geometry.viabltr(comparator, 1, 4, 
        pmosrslatchright2:get_anchor("botgatestrapbl"), 
        pmosrslatchright2:get_anchor("botgatestraptr")
    )
    geometry.viabltr(comparator, 1, 4, 
        pmosrslatchleft2:get_anchor(string.format("sourcedrain%dbl", 2)), 
        pmosrslatchleft2:get_anchor(string.format("sourcedrain%dtr", 2))
    )
    geometry.viabltr(comparator, 1, 4, 
        nmosrslatchright2:get_anchor(string.format("sourcedrain%dbl", 2)), 
        nmosrslatchright2:get_anchor(string.format("sourcedrain%dtr", 2))
    )

    geometry.path(comparator, generics.metal(4), { 
        pmosrslatchleft2:get_anchor(string.format("sourcedrain%dcc", 2)), 
        point.combine_12(pmosrslatchright2:get_anchor("botgatestrapcc"), pmosrslatchleft2:get_anchor(string.format("sourcedrain%dcc", 2))),
        pmosrslatchright2:get_anchor("botgatestrapcc")
    },  _P.sdwidth) 
    geometry.path(comparator, generics.metal(4), { 
        nmosrslatchright2:get_anchor(string.format("sourcedrain%dcc", 2)), 
        point.combine_12(pmosrslatchleft2:get_anchor("botgatestrapcc"), nmosrslatchright2:get_anchor(string.format("sourcedrain%dcc", 2))),
        pmosrslatchleft2:get_anchor("botgatestrapcc")
    },  _P.sdwidth) 
