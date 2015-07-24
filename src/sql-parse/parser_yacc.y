%{

#include "parser_yacc.h"
#include "sql_define.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int lineno = 1;
void yyerror(char *s);

void TrimString(char *str)
{
        char *copied, *tail = NULL;
        if ( str == NULL )
                return;

        for( copied = str; *str; str++ )
        {
                if ( *str != ' ' && *str != '\t' && *str != '\n' && *str != '\r' && *str != '\'' && *str != ';')
                {
                    *copied++ = *str;
                    tail = copied;                        
                }
                else
                {
                    if ( tail )
                        *copied++ = *str;
                }
        }

        if ( tail )
             *tail = 0;
        else
             *copied = 0;

        return;
}

char *_xInput;
int _xLen = 0;

int myinput(char *buff,int max)
{
    if(!_xLen) return 0;
    if(max > _xLen) max = _xLen   ;
    memcpy(buff,_xInput,max);
    _xInput += max;
    _xLen -= max;
    return   max;
}

#define YY_INPUT(b, r, m) (r = myinput(b, m))

%}

%%

and        { return AND; }
CHAR(ACTER)?    { return CHARACTER; }
CLOSE        { return CLOSE; }
CREATE        { return CREATE; }
CURRENT        { return CURRENT; }
CURSOR        { return CURSOR; }
count        { return COUNT; }
DECLARE        { return DECLARE; }
delete        { return DELETE; }
DOUBLE        { return DOUBLE; }
FETCH        { return FETCH; }
FLOAT        { return FLOAT; }
FOR        { return FOR; }
from        { return FROM; }
insert        { return INSERT; }
INT(EGER)?    { return INTEGER; }
into        { return INTO; }
NOT        { return NOT; }
NULL        { return NULLX; }
NUMERIC        { return NUMERIC; }
OF        { return OF; }
OPEN        { return OPEN; }
OR        { return OR; }
REAL        { return REAL; }
select        { return SELECT; }
set        { return SET; }
table        { return TABLE; }
update        { return UPDATE; }
values        { return VALUES; }
where        { return WHERE; }

    /* punctuation */
"=" { return L_EQ; }

"<>"     |
"<"    |
">"    |
"<="    |
">="        { return COMPARISON; }

[-+*/:(),.;]    { return yytext[0]; }

    /* names */

[A-Za-z][A-Za-z0-9_]*    { strcpy(yylval.nameval,yytext); return NAME; }

    /* numbers */

-?[0-9]+    { yylval.intval = atoi(yytext); return INTNUM; }
[0-9]+"."[0-9]* { yylval.floatval = atof(yytext); return FLOATNUM; }

[0-9]+[eE][+-]?[0-9]+    |
[0-9]+"."[0-9]*[eE][+-]?[0-9]+ |
"."[0-9]*[eE][+-]?[0-9]+    { return APPROXNUM; }

    /* strings */
'[^'/n]*'    { TrimString(yytext); strcpy(yylval.strval,yytext); return STRING; }   
       
'[^/'/n]*$    { yyerror("Unterminated string"); }

/n        lineno++;

[ /t/r]+    ;    /* white space */

"--".*$        ;    /* comment */

%%

void yyerror(char *s)
{
    printf("%d: %s at %s/n", lineno, s, yytext);
}

int yywrap()    {return 1;}

main(int argc, char **argv)
{
    int pos;
    int ret;   
    char *buffer;
    char prompt_buffer[MAX_BUFFER_SIZE];
    char last_prompt_buffer[MAX_BUFFER_SIZE];
    int count;
           
    while(1)
    {
        printf("mdbsql>>");   
        fgets(prompt_buffer, sizeof(prompt_buffer), stdin);       
       
        _xInput = prompt_buffer;
        _xLen = strlen(prompt_buffer);
       
        if (prompt_buffer[0]=='//')
        {
            strcpy(prompt_buffer, last_prompt_buffer);
            _xLen = strlen(prompt_buffer);
        }
        if (strncmp(prompt_buffer, "quit", 4)==0 ||
            strncmp(prompt_buffer, "exit", 4)==0
            )
        {
            break;
        }
               
        memset(&sql_plan, 0, sizeof(sql_plan) );
        strcpy(last_prompt_buffer, prompt_buffer);
        if(!yyparse())
        {                           
            if (sql_plan.action == SQL_SELECT)
            {                             
                  printf("%d records are retrieved/n", count);
              }
              else if (sql_plan.action == SQL_DELETE)
              {
                  printf("%d records are deleted/n", ret);
              }
              else if (sql_plan.action == SQL_UPDATE)
              {
                  printf("%d records are updated/n", ret);
              }
              else if (sql_plan.action == SQL_INSERT)
              {
                  if (ret>0) printf("1 record is inserted/n");
              }
              else if (sql_plan.action == SQL_COUNT_ALL)
              {
                  if (ret>0) printf("1 record is retrieved/n");
              }
        }
        else
        {   
            printf("SQL parse failed/n");
        }       
    }
}
