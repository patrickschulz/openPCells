# Todos
The todos are annotated with two numbers: (complexity and/or dificultness of the problem) and (integration complexity). 5/1 for instance is a hard, isolated
problem while 1/5 is a very easy problem breaking an aweful lot of existing code.
## implement union of polygons 5/1
no draft pushed to the repository. Complex problem, if you're not me and want to work on this, ask me for the existing code.
## implement partition of polygons 5/1
Opposite problem of polygon union. Very large any_angle_paths could create polygons with more points as allowed for e.g. GDS. These polygons have to be
partitioned.
## implement polygon triangulation 4/1
magic does not know polygons, so they have to be divided into triangles.
## fix layers of ports (currently hardcoded to M1) 2/3
Needs small rewrite of technology layermap
## fully implement any_angle_path 3/2
Almost finished, but the start and end points have to be at the correct locations (multiple of the grid). Also perhaps this requires more attention of
trigonometric stuff with integers
## calculate everything in integers 2/4
Currently, only integers are allowed for points, so this already kind of works. However, the entire lua VM and interpreter should be switched to only handling
integers. This affects trigonometric stuff, so this has to be done carefully and properly.
## create a logo -/- (not a code issue)
I would like to have a nice logo, perhaps something with a wafer in it.
