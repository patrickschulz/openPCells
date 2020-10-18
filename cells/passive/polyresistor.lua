return function(args)
    pcell.setup(args)
    pcell.process_args("width",    0.2)
    pcell.process_args("length",   1.0)
    pcell.process_args("segments", 4)
    pcell.check_args()


end
