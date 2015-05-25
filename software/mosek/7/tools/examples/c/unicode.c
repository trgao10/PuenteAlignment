/*
   Copyright: Copyright (c) MOSEK ApS, Denmark. All rights reserved.

   File: unicode.c

   Purpose:   To demonstrate how to use a unicoded strings.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>


#include "mosek.h"

int main(int argc, char *argv[])
{
  char        output[512];
  wchar_t     *input=L"myfile.mps";
  MSKenv_t    env;
  MSKrescodee r;
  MSKtask_t   task;
  size_t      len,conv;


  r = MSK_makeenv(&env,NULL);

  if ( r==MSK_RES_OK ) 
  { 
    r = MSK_makeemptytask(env,&task);

    if ( r==MSK_RES_OK )   
    { 
      /*
         The wchar_t string "input" specifying a file name
         is converted to a UTF8 string that can be inputted 
         to MOSEK.
       */
    
      r = MSK_wchartoutf8(sizeof(output),&len,&conv,output,input);
    
      if ( r==MSK_RES_OK )
      {     
        /* output is now an UTF8 encoded string. */ 
        r = MSK_readdata(task,output);
      }  
    
      if ( r==MSK_RES_OK )
      {
        r = MSK_optimize(task);
        MSK_solutionsummary(task,MSK_STREAM_MSG);
      }
    }  
    MSK_deletetask(&task);
  }
  MSK_deleteenv(&env);

  printf("Return code - %d\n",r);

  return ( r );
} /* main */
