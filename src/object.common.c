void objectcommon_initialize(struct object_common* obc)
{
    obc->private.trans = transformationmatrix_create();
}

void objectcommon_set_name(struct object_common* obc, const char* name)
{
    if(obj->private.name)
    {
        free(obj->private.name;
    }
    if(name)
    {
        obc->private.name = util_strdup(name);
    }
    else
    {
        obc->private.name = NULL;
    }
}

void objectcommon_set_managed(struct object_common* obc, int ismanaged)
{
    obc->private.ismanaged = ismanaged;
}

int objectcommon_is_managed(const struct object_common* obc)
{
    return obc->private.ismanaged;
}

void objectcommon_set_used(struct object_common* obc, int isused)
{
    obc->private.isused = isused;
}

int objectcommon_is_used(const struct object_common* obc)
{
    return obc->private.isused;
}

void objectcommon_set_proxy(struct object_common* obc, int isproxy)
{
    obc->private.isproxy = isproxy;
}

int objectcommon_is_proxy(const struct object_common* obc)
{
    return obc->private.isproxy;
}

int objectcommon_is_full(const struct object_common* obc)
{
    return !obc->private.isproxy;
}

void objectcommon_copy_to(const struct object_common* obc, struct object_common* new)
{
    new->private.name = util_strdup(obc->private.name);
    new->private.isproxy = obc->private.isproxy;
    new->private.ismanaged = obc->private.ismanaged;
    new->private.isused = obc->private.isused;
    transformationmatrix_destroy(new->private.trans);
    new->private.trans = transformationmatrix_copy_to(obc->private.trans);
}

void objectcommon_destroy(struct object_common* obc)
{
    free(obc->private.name);
    transformationmatrix_destroy(obc->private.trans);

}

const struct transformationmatrix* objectcommon_get_tmatrix(const struct object_common* obc)
{
    return obc->private.trans;
}

void objectcommon_set_tmatrix(const struct object_common* obc, struct transformationmatrix* trans)
{
    obc->private.trans = trans;
}

void objectcommon_transform_to_local_coordinates_xy(const struct object_common* cell, coordinate_t* x, coordinate_t* y)
{
    transformationmatrix_apply_inverse_transformation_xy(cell->trans, x, y);
}

void objectcommon_transform_to_local_coordinates_pt(const struct object_common* cell, struct point* pt)
{
    transformationmatrix_apply_inverse_transformation(cell->trans, pt);
}

void objectcommon_transform_to_global_coordinates_xy(const struct object_common* cell, coordinate_t* x, coordinate_t* y)
{
    transformationmatrix_apply_transformation_xy(cell->trans, x, y);
}

void objectcommon_transform_to_global_coordinates_pt(const struct object_common* cell, struct point* pt)
{
    transformationmatrix_apply_transformation(cell->trans, pt);
}

void objectcommon_move_to(struct object_common* cell, coordinate_t x, coordinate_t y)
{
    transformationmatrix_move_to(cell->trans, x, y);
}

void objectcommon_translate(struct object_common* cell, coordinate_t x, coordinate_t y)
{
    transformationmatrix_translate(cell->trans, x, y);
}

void objectcommon_mirror_at_xaxis(struct object_common* cell)
{
    transformationmatrix_mirror_x(cell->trans);
}

void objectcommon_mirror_at_yaxis(struct object_common* cell)
{
    transformationmatrix_mirror_y(cell->trans);
}

void objectcommon_mirror_at_origin(struct object_common* cell)
{
    transformationmatrix_mirror_origin(cell->trans);
}

void objectcommon_rotate_90_left(struct object_common* cell)
{
    transformationmatrix_rotate_90_left(cell->trans);
}

void objectcommon_rotate_90_right(struct object_common* cell)
{
    transformationmatrix_rotate_90_right(cell->trans);
}

void objectcommon_array_rotate_90_left(struct object_common* cell)
{
    transformationmatrix_rotate_90_left(cell->content.proxy.array_trans);
}

void objectcommon_array_rotate_90_right(struct object_common* cell)
{
    transformationmatrix_rotate_90_right(cell->content.proxy.array_trans);
}

