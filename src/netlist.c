#include "netlist.h"

#include <stdlib.h>

#include "util.h"
#include "vector.h"

struct netlist {
    struct vector* subcircuits; // stores struct subcircuit*
};

struct subcircuit {
    char* name;
    struct vector* ports; // stores char*
    struct vector* instances; // stores struct instance*
};

static void _destroy_subcircuit(void* v)
{
    struct subcircuit* subcircuit = v;
    free(subcircuit->name);
    vector_destroy(subcircuit->ports);
    vector_destroy(subcircuit->instances);
    free(subcircuit);
}

struct instance {
    char* identifier;
    char* type;
    struct vector* connections; // stores struct connection*
    struct vector* parameters; // stores struct parameter*
};

static void _destroy_instance(void* v)
{
    struct instance* instance = v;
    free(instance->identifier);
    free(instance->type);
    vector_destroy(instance->connections);
    vector_destroy(instance->parameters);
    free(instance);
}

struct connection {
    char* port;
    char* net;
};

struct parameter {
    char* key;
    char* value;
};

struct netlist* netlist_create(void)
{
    struct netlist* netlist = malloc(sizeof(*netlist));
    netlist->subcircuits = vector_create(8, _destroy_subcircuit);
    return netlist;
}

void netlist_destroy(struct netlist* netlist)
{
    vector_destroy(netlist->subcircuits);
    free(netlist);
}

struct subcircuit* netlist_make_subcircuit(void)
{
    struct subcircuit* subcircuit = malloc(sizeof(*subcircuit));
    subcircuit->name = NULL;
    subcircuit->ports = vector_create(8, free);
    subcircuit->instances = vector_create(8, _destroy_instance);
    return subcircuit;
}

void netlist_add_subcircuit(struct netlist* netlist, struct subcircuit* subcircuit)
{
    vector_append(netlist->subcircuits, subcircuit);
}

void netlist_subcircuit_set_name(struct subcircuit* subcircuit, const char* name)
{
    if(subcircuit->name)
    {
        free(subcircuit->name);
    }
    subcircuit->name = util_strdup(name);
}

void netlist_subcircuit_add_instance(struct subcircuit* subcircuit, struct instance* instance)
{
    vector_append(subcircuit->instances, instance);
}

static void _destroy_connection(void* v)
{
    struct connection* connection = v;
    free(connection->port);
    free(connection->net);
    free(connection);
}

static void _destroy_parameter(void *v)
{
    struct parameter* parameter = v;
    free(parameter->key);
    free(parameter->value);
    free(parameter);
}

struct instance* netlist_make_instance(const char* identifier)
{
    struct instance* instance = malloc(sizeof(*instance));
    instance->identifier = util_strdup(identifier);
    instance->type = NULL;
    instance->connections = vector_create(8, _destroy_connection);
    instance->parameters = vector_create(8, _destroy_parameter);
    return instance;
}

void netlist_instance_set_type(struct instance* instance, const char* type)
{
    if(instance->type)
    {
        free(instance->type);
    }
    instance->type = util_strdup(type);
}

static struct connection* _make_connection(const char* portname, const char* netname)
{
    struct connection* connection = malloc(sizeof(*connection));
    connection->port = util_strdup(portname);
    connection->net = util_strdup(netname);
    return connection;
}

void netlist_instance_add_connection(struct instance* instance, const char* portname, const char* netname)
{
    struct connection* connection = _make_connection(portname, netname);
    vector_append(instance->connections, connection);
}

static struct parameter* _make_parameter(const char* key, const char* value)
{
    struct parameter* parameter = malloc(sizeof(*parameter));
    parameter->key = util_strdup(key);
    parameter->value = util_strdup(value);
    return parameter;
}

void netlist_instance_add_parameter(struct instance* instance, const char* key, const char* value)
{
    struct parameter* parameter = _make_parameter(key, value);
    vector_append(instance->parameters, parameter);
}

void netlist_create_lua_representation(struct netlist* netlist, lua_State* L)
{
    // netlist table
    lua_newtable(L);
    for(size_t scidx = 0; scidx < vector_size(netlist->subcircuits); ++scidx)
    {
        const struct subcircuit* subcircuit = vector_get(netlist->subcircuits, scidx);
        // subcircuit table
        lua_newtable(L);
        // subcircuit name
        lua_pushstring(L, subcircuit->name);
        lua_setfield(L, -2, "name");
        // instances
        for(size_t instidx = 0; instidx < vector_size(subcircuit->instances); ++instidx)
        {
            const struct instance* instance = vector_get(subcircuit->instances, instidx);
            // instance table
            lua_newtable(L);
            // instance name
            lua_pushstring(L, instance->identifier);
            lua_setfield(L, -2, "identifier");
            // instance type
            lua_pushstring(L, instance->type);
            lua_setfield(L, -2, "type");
            // connection table
            lua_newtable(L);
            for(size_t connidx = 0; connidx < vector_size(instance->connections); ++connidx)
            {
                const struct connection* connection = vector_get(instance->connections, connidx);
                lua_pushstring(L, connection->port);
                lua_pushstring(L, connection->net);
                lua_rawset(L, -3);
            }
            lua_setfield(L, -2, "connections");
            // parameter table
            lua_newtable(L);
            for(size_t paramidx = 0; paramidx < vector_size(instance->parameters); ++paramidx)
            {
                const struct parameter* parameter = vector_get(instance->parameters, paramidx);
                lua_pushstring(L, parameter->key);
                lua_pushstring(L, parameter->value);
                lua_rawset(L, -3);
            }
            lua_setfield(L, -2, "parameters");
            lua_rawseti(L, -2, instidx + 1);
        }
        lua_rawseti(L, -2, scidx + 1);
    }
}

