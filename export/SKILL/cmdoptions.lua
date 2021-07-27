return {
    switch{
        name = "group", short = "-g", long = "--group",
        help = "create a figure group where all shapes are collected"
    },
    store{
        name = "groupname", short = "-n", long = "--group-name",
        help = "name of the figure group"
    },
    switch{
        name = "nolet", short = "-l", long = "--no-let",
        help = "don't create shapes in a let() construct"
    },
}
