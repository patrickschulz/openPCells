void objectproxy_initialize(struct object_proxy* proxy, const struct object* reference)
{
    obj->private.reference = reference;
    proxy->private.xrep = 1;
    proxy->private.yrep = 1;
    proxy->private.xpitch = 0;
    proxy->private.ypitch = 0;
}

void objectproxy_copy_to(const struct object_proxy* proxy, struct object_proxy* new)
{
    new->private.reference = proxy->private.reference;
    new->private.isarray = proxy->private.isarray;
    new->private.xrep = proxy->private.xrep;
    new->private.yrep = proxy->private.yrep;
    new->private.xpitch = proxy->private.xpitch;
    new->private.ypitch = proxy->private.ypitch;
    transformationmatrix_destroy(new->private.array_trans);
    if(proxy->private.isarray)
    {
        new->private.array_trans = transformationmatrix_copy(proxy->private.array_trans);
    }
}

void objectproxy_destroy(struct object_proxy* proxy)
{
    transformationmatrix_destroy(proxy->private.array_trans);
}

const struct object* objectproxy_get_reference(const struct object_proxy* proxy)
{
    return proxy->private.reference;
}

void objectproxy_set_array(struct object_proxy* proxy, unsigned int xrep, unsigned int yrep, coordinate_t xpitch, coordinate_t ypitch)
{
    proxy->private.isarray = 1;
    proxy->private.xrep = xrep;
    proxy->private.yrep = yrep;
    proxy->private.xpitch = xpitch;
    proxy->private.ypitch = ypitch;
    proxy->private.array_trans = transformationmatrix_create();
}

const struct transformationmatrix* objectproxy_get_array_tmatrix(const object_proxy* proxy)
{
    return proxy->private.array_trans;
}

unsigned int objectproxy_get_xrep(const struct object_proxy* proxy)
{
    return proxy->private.xrep;
}

unsigned int objectproxy_get_yrep(const struct object_proxy* proxy)
{
    return proxy->private.yrep;
}

void objectproxy_translate_pt_to_array(const struct object_proxy* proxy, struct point* pt, int xindex, int yindex)
{
    // resolve negative indices
    if(xindex < 0)
    {
        xindex = cell->private.xrep + xindex + 1;
    }
    if(yindex < 0)
    {
        yindex = cell->private.yrep + yindex + 1;
    }
    point_translate(pt, cell->private.xpitch * (xindex - 1), cell->private.ypitch * (yindex - 1));
}

void objectproxy_translate_x_to_array_end(coordinate_t* x)
{
    *x += (cell->private.xrep - 1) * cell->private.xpitch;
}

void objectproxy_translate_y_to_array_end(coordinate_t* y)
{
    *y += (cell->private.yrep - 1) * cell->private.ypitch;
}

int objectproxy_check_array_bounds(const struct object_proxy* proxy, int xindex, int yindex)
{

    if(xindex > (int)proxy->private.xrep)
    {
        return 0;
    }
    if(yindex > (int)proxy->private.yrep)
    {
        return 0;
    }
    return 1;
}
