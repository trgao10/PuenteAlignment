/*
  Copyright: Copyright (c) MOSEK ApS, Denmark. All rights reserved.

  File:      response.c

  Purpose:   This examples demonstrates proper response handling.
*/


#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "mosek.h"

void MSKAPI printlog(void *ptr,
                     MSKCONST char s[])
{
  printf("%s",s);
} /* printlog */  

int main(int argc,char const *argv[])
{
  MSKenv_t    env;
  MSKrescodee r;
  MSKtask_t   task;

  if ( argc<2 )
  {
    printf("No input file specified\n");
    exit(0);
  }
  else
    printf("Inputfile:  %s\n",argv[1]);

  r = MSK_makeenv(&env,NULL);
 
  if ( r==MSK_RES_OK )
  {
    r = MSK_makeemptytask(env,&task);
    if ( r==MSK_RES_OK )
      MSK_linkfunctotaskstream(task, MSK_STREAM_LOG, NULL,     printlog); 

    r = MSK_readdata(task,argv[1]);
    if ( r==MSK_RES_OK )
    {
      MSKrescodee trmcode;
      MSKsolstae  solsta;

      r = MSK_optimizetrm(task,&trmcode); /* Do the optimization. */ 

      /* Expected result: The solution status of the basic solution is optimal. */

      if ( MSK_RES_OK==MSK_getsolsta(task,MSK_SOL_ITR,&solsta) )
      {
        switch( solsta )
        {
          case MSK_SOL_STA_OPTIMAL:   
          case MSK_SOL_STA_NEAR_OPTIMAL:
            printf("An optimal basic solution is located.\n");

            MSK_solutionsummary(task,MSK_STREAM_MSG);
            break;
          case MSK_SOL_STA_DUAL_INFEAS_CER:
          case MSK_SOL_STA_NEAR_DUAL_INFEAS_CER:
            printf("Dual infeasibility certificate found.\n");
            break;
          case MSK_SOL_STA_PRIM_INFEAS_CER:
          case MSK_SOL_STA_NEAR_PRIM_INFEAS_CER:
            printf("Primal infeasibility certificate found.\n");
            break;
          case MSK_SOL_STA_UNKNOWN:
          {
            char symname[MSK_MAX_STR_LEN];
            char desc[MSK_MAX_STR_LEN];

            /* The solutions status is unknown. The termination code 
               indicating why the optimizer terminated prematurely. */

            printf("The solution status is unknown.\n");
            if ( r!=MSK_RES_OK )
            {
              /* A system failure e.g. out of space. */

              MSK_getcodedesc(r,symname,desc);

              printf("  Response code: %s\n",symname);  
            }
            else
            {
              /* No system failure e.g. an iteration limit is reached.  */

              MSK_getcodedesc(trmcode,symname,desc);

              printf("  Termination code: %s\n",symname);  
            }
            break;
          }
          default:
            printf("An unexpected solution status is obtained.\n");
            break;
        }
      }
      else
        printf("Could not obtain the solution status for the requested solution.\n");  
    }
    MSK_deletetask(&task);
  }

  MSK_deleteenv(&env);
  printf("Return code: %d (0 means no error occurred.)\n",r);

  return ( r );
} /* main */


