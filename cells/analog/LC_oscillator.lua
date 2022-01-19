function parameters()

end

function layout(osc, _P)
    local inductor = pcell.create_layout("passive/inductor/octagonal", { turns = 1, metalnum = -2 })
    osc:merge_into_shallow(inductor)

    local cap = pcell.create_layout("passive/capacitor/mom", { fingers = 20, fheight = 2000, firstmetal = 3, lastmetal = 5 })
    osc:merge_into_shallow(cap:translate(0, -20000))

    local ccp = pcell.create_layout("analog/cross_coupled_pair")
    osc:merge_into_shallow(ccp)
end
