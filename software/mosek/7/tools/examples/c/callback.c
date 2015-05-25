#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/*
   Copyright: Copyright (c) MOSEK ApS, Denmark. All rights reserved.

   File:      callback.c

   Purpose:   To demonstrate how to use the progress 
              callback. 

              Compile and link the file with  MOSE, then 
              use as follows:

              callback psim 25fv47.mps
              callback dsim 25fv47.mps
              callback intpnt 25fv47.mps

              The first argument tells which optimizer to use
              i.e. psim is primal simplex, dsim is dual simplex
              and intpnt is interior-point. 
 */


#include "mosek.h"


/* Note: This function is declared using MSKAPI,
         so the correct calling convention is
         employed. */
static int MSKAPI usercallback(MSKtask_t            task,
                               MSKuserhandle_t      handle,
                               MSKcallbackcodee     caller,
                               MSKCONST MSKrealt  * douinf,
                               MSKCONST MSKint32t * intinf,
                               MSKCONST MSKint64t * lintinf)
{
  double *maxtime=(double *) handle;

  switch ( caller )
  {
    case MSK_CALLBACK_BEGIN_INTPNT:
      printf("Starting interior-point optimizer\n");
      break;
    case MSK_CALLBACK_INTPNT:
      printf("Iterations: %-3d  Time: %6.2f(%.2f)  ",
             intinf[MSK_IINF_INTPNT_ITER],douinf[MSK_DINF_OPTIMIZER_TIME],douinf[MSK_DINF_INTPNT_TIME]);
      printf("Primal obj.: %-18.6e  Dual obj.: %-18.6e\n",
             douinf[MSK_DINF_INTPNT_PRIMAL_OBJ],douinf[MSK_DINF_INTPNT_DUAL_OBJ]);
      break;
    case MSK_CALLBACK_END_INTPNT:
      printf("Interior-point optimizer finished.\n");
      break;
    case MSK_CALLBACK_BEGIN_PRIMAL_SIMPLEX:
      printf("Primal simplex optimizer started.\n");
      break;
    case MSK_CALLBACK_UPDATE_PRIMAL_SIMPLEX:
      printf("Iterations: %-3d  ",
             intinf[MSK_IINF_SIM_PRIMAL_ITER]);
      printf("  Elapsed time: %6.2f(%.2f)\n",
             douinf[MSK_DINF_OPTIMIZER_TIME],douinf[MSK_DINF_SIM_TIME]);
      printf("Obj.: %-18.6e\n",
             douinf[MSK_DINF_SIM_OBJ]);
      break;
    case MSK_CALLBACK_END_PRIMAL_SIMPLEX:
      printf("Primal simplex optimizer finished.\n");
      break;
    case MSK_CALLBACK_BEGIN_DUAL_SIMPLEX:
      printf("Dual simplex optimizer started.\n");
      break;
    case MSK_CALLBACK_UPDATE_DUAL_SIMPLEX:
      printf("Iterations: %-3d  ",intinf[MSK_IINF_SIM_DUAL_ITER]);
      printf("  Elapsed time: %6.2f(%.2f)\n",
             douinf[MSK_DINF_OPTIMIZER_TIME],douinf[MSK_DINF_SIM_TIME]);
      printf("Obj.: %-18.6e\n",douinf[MSK_DINF_SIM_OBJ]);
      break;
    case MSK_CALLBACK_END_DUAL_SIMPLEX:
      printf("Dual simplex optimizer finished.\n");
      break;
    case MSK_CALLBACK_BEGIN_BI:
      printf("Basis identification started.\n");
      break;
    case MSK_CALLBACK_END_BI:
      printf("Basis identification finished.\n");
      break;
  }

  if ( douinf[MSK_DINF_OPTIMIZER_TIME]>=maxtime[0] )
  {
    /* mosek is spending too much time.
       Terminate it. */
    return ( 1 );
  }
  
  return ( 0 );
} /* usercallback */

static void MSKAPI printtxt(void          *info,
                            MSKCONST char *buffer)
{
  printf("%s",buffer); 
} /* printtxt */

int main(int argc, char *argv[])
{
  double    maxtime,
            *xx,*y;
  int       r,j,i,numcon,numvar;
  FILE      *f;
  MSKenv_t  env;
  MSKtask_t task;

  if ( argc<3 )
  {
    printf("Too few input arguments. mosek intpnt myfile.mps\n");
    exit(0);
  }

  /* Create mosek environment. */
  r = MSK_makeenv(&env,NULL);

  /* Check the return code. */
  if ( r==MSK_RES_OK )
  {
    /* Create an (empty) optimization task. */
    r = MSK_makeemptytask(env,&task);
    
    if ( r==MSK_RES_OK )
    {
      MSK_linkfunctotaskstream(task,MSK_STREAM_MSG,NULL, printtxt);
      MSK_linkfunctotaskstream(task,MSK_STREAM_ERR,NULL, printtxt);
    }

    /* Specifies that data should be read from the
       file argv[2].
     */

    if ( r==MSK_RES_OK )
      r = MSK_readdata(task,argv[2]);

    if ( r==MSK_RES_OK )
    {
      if ( 0==strcmp(argv[1],"psim") )
        MSK_putintparam(task,MSK_IPAR_OPTIMIZER,MSK_OPTIMIZER_PRIMAL_SIMPLEX);
      else  if ( 0==strcmp(argv[1],"dsim") )
        MSK_putintparam(task,MSK_IPAR_OPTIMIZER,MSK_OPTIMIZER_DUAL_SIMPLEX);
      else  if ( 0==strcmp(argv[1],"intpnt") )
        MSK_putintparam(task,MSK_IPAR_OPTIMIZER,MSK_OPTIMIZER_INTPNT);
        

      /* Tell mosek about the call-back function. */
      maxtime = 3600;
      MSK_putcallbackfunc(task,
                          usercallback,
                          (void *) &maxtime);

      /* Turn all MOSEK logging off. */  
      MSK_putintparam(task,
                      MSK_IPAR_LOG,
                      0);

      r = MSK_optimize(task);

      MSK_solutionsummary(task,MSK_STREAM_MSG);
    }


    MSK_deletetask(&task);
  }
  MSK_deleteenv(&env);

  printf("Return code - %d\n",r);

  return ( r );
} /* main */
