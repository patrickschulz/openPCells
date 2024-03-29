function parameters()
    pcell.add_parameters(
        { "width", 5000 },
        { "length", 50000 },
        { "groundwidth", 10000 },
        { "groundspace", 5000 },
        { "shieldwidth", 100 },
        { "shieldspace", 100 },
        { "metalnum", -1 },
        { "shieldmetal", 1 }
    )
end

function layout(tline, _P)
    geometry.rectangle(tline, generics.metal(_P.metalnum), _P.length, _P.width)
    geometry.rectangle(tline, generics.metal(_P.metalnum), _P.length, _P.groundwidth, 0, 0, 1, 2, 0, _P.width + 2 * _P.groundspace + _P.groundwidth)
    geometry.rectangle(tline, generics.metal(_P.shieldmetal), _P.shieldwidth, _P.width + 2 * _P.groundspace + 2 * _P.groundwidth, 0, 0, _P.length // (_P.shieldwidth + _P.shieldspace), 1, _P.shieldwidth + _P.shieldspace, 0)
    geometry.via(tline, _P.shieldmetal, _P.metalnum, _P.length, _P.groundwidth, 0, 0, 1, 2, 0, _P.width + 2 * _P.groundwidth)
    tline:add_port("P1", generics.metalport(_P.metalnum), point.create(-_P.length / 2, 0))
    tline:add_port("PG1", generics.metalport(_P.metalnum), point.create(-_P.length / 2, _P.width / 2 + _P.groundspace + _P.groundwidth / 2))
    tline:add_port("PG1", generics.metalport(_P.metalnum), point.create(-_P.length / 2, -_P.width / 2 - _P.groundspace - _P.groundwidth / 2))
    tline:add_port("P2", generics.metalport(_P.metalnum), point.create( _P.length / 2, 0))
    tline:add_port("PG2", generics.metalport(_P.metalnum), point.create( _P.length / 2, _P.width / 2 + _P.groundspace + _P.groundwidth / 2))
    tline:add_port("PG2", generics.metalport(_P.metalnum), point.create( _P.length / 2, -_P.width / 2 - _P.groundspace - _P.groundwidth / 2))
end
