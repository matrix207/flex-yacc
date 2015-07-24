#ifndef __SQL_DEFINE__
#define __SQL_DEFINE__

#define NAME_SIZE   24
#define MAX_BUFFER_SIZE  8192

typedef enum
{
    SQL_SELECT = 1,
    SQL_INSERT,
    SQL_UPDATE,
    SQL_DELETE,
    SQL_COUNT_ALL
}sql_action;

typedef struct{
    char field_name[NAME_SIZE];
    char field_value[256];
}FieldNameValue;

typedef struct{
    int list_len;
    FieldNameValue fnv_par[5];
}FieldNameValue_List;

typedef struct{
    int    action;   
    char tab_name[256];
    FieldNameValue_List w_fnv_list;
    char u_field_name[256];
    char u_field_value[256];
    int pos;
    char buffer[MAX_BUFFER_SIZE];
}SQL_PLAN;

extern SQL_PLAN sql_plan;

#endif
