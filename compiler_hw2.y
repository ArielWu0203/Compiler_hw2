/*	Definition section */
%{

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

extern int yylineno;
extern int yylex();
extern void yyerror(char *s);
extern char* yytext;   // Get current token from lex
extern char buf[256];  // Get current code line from lex

/* Symbol table function - you can add new function if needed. */
int lookup_symbol(char *name,bool variable,int scope,bool declare);//true;undeclare false: redclare
int error = 0;
char ID_name[30] = "";

void insert_symbol(int index,char *name,char *kind,char *type,int scope_level,char *attr);
void create_symbol();
void dump_symbol(int scope);

typedef struct symble_entry{
    int index;
    char name[50];
    char kind[15];
    char type[10];
    int scope_level;
    char attr[500];
    struct symbol_entry *next;
    struct symbol_entry *prev;
} Entry;

Entry *front,*rear;
void del_node(Entry *node);

int now_level = 0,now_index=0 ;
%}

/* Use variable or self-defined structure to represent
 * nonterminal and token type
 */

%union {
    int i_val;
    double f_val;
    char* string;
}

/* Token without return */

/* Arithmetic */
%token ADD SUB MUL DIV MOD INC DEC

/* Relational */
%token MT LT MTE LTE EQ NE

/* Assignment */
%token ASGN ADDASGN SUBASGN MULASGN DIVASGN MODASGN

/* Logical */
%token AND OR NOT

/* Delimeters */
%token LB RB LCB RCB LSB RSB COMMA

/* Print Keywords*/
%token PRINT 

/* Condition and Loop Keywords */
%token IF ELSE FOR WHILE

/* boolean Keywords */
%token TRUE FALSE
%token RET CONT BREAK

/* String Constant */
%token QUOTA

/* Comment */

/* Variable ID & others */
%token SEMICOLON

/* precedence */
%left EQ NE LT LTE MT MTE
%left ADD SUB
%left MUL DIV MOD
%left INC DEC
%left LB RB

/* Token with return, which need to sepcify type */

%token <i_val> I_CONST
%token <f_val> F_CONST
%token <string> VOID INT FLOAT BOOL STRING ID STR_CONST

/* Nonterminal with return, which need to sepcify type */
/*
%type <f_val> stat
*/
%type <string> type func_declaration declaration_list

/* Yacc will start at this nonterminal */
%start program

/* Grammar section */
%%

program
    : statement
    | program statement
;


declaration
    : type ID SEMICOLON 
    {  
      if(error == 0) error = lookup_symbol($2,true,now_level,false); 
      if(error>0) {
        strcpy(ID_name,$2);
      } else {
        insert_symbol(now_index,$2,"variable",$1,now_level,"");
        now_index++; 
      }
    }
    | type ID ASGN initializer SEMICOLON 
    { 
      if(error == 0) error = lookup_symbol($2,true,now_level,false); 
      if(error>0) {
        strcpy(ID_name,$2);
      } else {
        insert_symbol(now_index,$2,"variable",$1,now_level,"");
        now_index++; 
      }
    }
 
;

statement
    : if_stat
    | while_stat
    | compound_stat
    | function_stat
    | assign_stat
    | declaration
    | return_stat
    | print_func
;

if_stat
    : IF LB operator_stat RB compound_stat 
    | IF LB operator_stat RB compound_stat else_stat
;

else_stat
    : ELSE statement 
;

while_stat
    : WHILE LB operator_stat RB compound_stat
;

function_stat
    : type ID LB declaration_list RB SEMICOLON 
    | type ID LB declaration_list RB compound_stat 
    { 
      if(error == 0) error = lookup_symbol($2,false,now_level,false); 
      if(error>0) {
        strcpy(ID_name,$2);
      }else {
        insert_symbol(now_index,$2,"function",$1,now_level,$4); 
        now_index++;
      }
    }
    | type ID LB RB SEMICOLON
    | type ID LB RB compound_stat
    {       
      if(error == 0) error = lookup_symbol($2,false,now_level,false); 
      if(error>0) {
        strcpy(ID_name,$2);
      }else {
        insert_symbol(now_index,$2,"function",$1,now_level,""); 
        now_index++;}

    }
    | ID LB RB SEMICOLON 
    {
      if(error == 0) error = lookup_symbol($1,false,now_level,true); 
      if(error>0) {
        strcpy(ID_name,$1);
      }
    }
    | ID LB parameter_list RB SEMICOLON 
    {
      printf("ID = %s\n",$1);
      if(error == 0) error = lookup_symbol($1,false,now_level,true); 
      if(error>0) {
        strcpy(ID_name,$1);
      }
    }

;

return_stat
    : RET SEMICOLON
    | RET operator_stat SEMICOLON
    | RET ID assign_operator operator_stat SEMICOLON
;
    
parameter_list
    : parameter_list COMMA operator_stat
    | operator_stat
;

declaration_list
    : func_declaration
    | declaration_list COMMA func_declaration
    {
      strcat($$,", "); strcat($$, $3);
    }

;

func_declaration
    : type ID 
    {
      $$ = $1;
      insert_symbol(now_index,$2,"parameter",$1,now_level+1,""); now_index++; 
    }
    | type ID ASGN initializer
    { 
      $$ = $1;  
      insert_symbol(now_index,$2,"parameter",$1,now_level+1,""); now_index++; 
    }
;

compound_stat
    : LCB RCB 
    | LCB stat_list RCB 
;

stat_list
    : statement
    | stat_list statement
;

assign_stat
    : ID assign_operator operator_stat SEMICOLON 
    {
      if(error == 0) error = lookup_symbol($1,true,now_level,true); 
      if(error>0) {
        strcpy(ID_name,$1);
      }
    }
    | ID INC SEMICOLON
    { 
      if(error == 0) error = lookup_symbol($1,true,now_level,true); 
      if(error>0) {
        strcpy(ID_name,$1);
      }
    }
    | ID DEC SEMICOLON 
    { 
      if(error == 0) error = lookup_symbol($1,true,now_level,true); 
      if(error>0) {
        strcpy(ID_name,$1);
      }
    }

;

assign_operator
    : ASGN
    | ADDASGN
    | SUBASGN
    | MULASGN
    | DIVASGN
    | MODASGN
;

initializer
    : operator_stat
;

operator_stat
    : operator_stat ADD operator_stat
    | operator_stat SUB operator_stat
    | operator_stat MUL operator_stat
    | operator_stat DIV operator_stat
    | operator_stat MOD operator_stat
    | operator_stat MT operator_stat  
    | operator_stat LT operator_stat
    | operator_stat MTE operator_stat
    | operator_stat LTE operator_stat
    | operator_stat EQ operator_stat
    | operator_stat NE operator_stat
    | ID INC 
    { 
      if(error == 0) error = lookup_symbol($1,true,now_level,true); 
      if(error>0) {
        strcpy(ID_name,$1);
      }
    }
    | ID DEC
    { 
      if(error == 0) error = lookup_symbol($1,true,now_level,true); 
      if(error>0) {
        strcpy(ID_name,$1);
      }
    }
    | ADD operator_stat
    | SUB operator_stat
    | term
    | LB operator_stat RB
;

print_func
    : PRINT LB ID RB SEMICOLON 
    { 
      if(error == 0) error = lookup_symbol($3,true,now_level,true); 
      if(error>0) {
        strcpy(ID_name,$3);
      }
    }
    | PRINT LB STR_CONST RB SEMICOLON
;

term
    : F_CONST
    | I_CONST
    | STR_CONST
    | TRUE
    | FALSE
    | ID
;

/* actions can be taken when meet the token or rule */
type
    : INT
    | FLOAT
    | BOOL 
    | STRING 
    | VOID 
;


%%

/* C code section */
int main(int argc, char** argv)
{
    yylineno = 0;

    create_symbol();

    yyparse();

    return 0;
}

void yyerror(char *s)
{
    printf("%d: %s\n",yylineno, buf);
    printf("\n|-----------------------------------------------|\n");
    printf("| Error found in line %d: %s\n", yylineno, buf);
    printf("| %s", s);
    printf("\n|-----------------------------------------------|\n\n");
}

void create_symbol() {
    front = rear= NULL;
}

void insert_symbol(int index,char *name,char *kind,char *type,int scope_level,char *attr) {

    Entry *new;
    new = (Entry*) malloc(sizeof(Entry));
    new->index = index;
    strcpy(new->name,name);
    strcpy(new->kind,kind);
    strcpy(new->type,type);
    new->scope_level=scope_level;
    strcpy(new->attr,attr);

    //First node
    if(front == NULL && rear == NULL) {
        new->next = NULL;
        new->prev = NULL;
        front = rear = new;
    }
    else {
        new->prev = rear;
        new->next = NULL;
        rear->next = new;
        rear = new;
    }
}

int lookup_symbol( char *name,bool variable,int scope,bool declare )  {
    if(declare) {
        Entry *head = rear;
        while(head!=NULL) {
            if(head->scope_level <= scope && !strcmp(name,head->name)) { 
                return 0;
            }
            head = head->prev;
        }
        if(variable) {
            return 1;
        }else {
            return 2;
        }
    }else {  
        Entry *head = rear;
        while(head!=NULL) {
            if(head->scope_level == scope && !strcmp(name,head->name)) { 
                if(variable) {
                    return 3;
                }else {
                    return 4;
                }
            }
            head = head->prev;
        }
    }
    return 0;
}

void del_node(Entry *node) {
    if(node == front && front==rear) {
        front = rear = NULL;
        free(node);
    }else if(node == front) {
        front = node->next;
        front->prev = NULL;
        free(node);
    }else if(node == rear) {
        rear = node->prev;
        rear->next = NULL;
        free(node);
    }else {
        Entry *tmp_f = node->prev,*tmp_r = node->next;
        tmp_f->next = tmp_r;
        tmp_r->prev = tmp_f;
        free(node);
    }
}
void dump_symbol(int scope) {

    int index = 0;
    
    Entry *head = front;
    
    while(head!=NULL) {
        
        if(head->scope_level == scope) {
            
            printf("\n%-10s%-10s%-12s%-10s%-10s%-10s\n\n",
                "Index", "Name", "Kind", "Type", "Scope", "Attribute");
            while(head != NULL && head->scope_level == scope) {
                printf("%-10d%-10s%-12s%-10s%-10d%s\n",index,head->name,head->kind,head->type,head->scope_level,head->attr);
                index++;

                Entry *tmp = head;
                head = head->next;
                del_node(tmp);
            }
            printf("\n");
            return;
        }
        
        head = head->next;
    }
    return;
}
