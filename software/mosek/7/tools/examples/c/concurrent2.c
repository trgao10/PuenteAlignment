/*
  Copyright: Copyright (c) MOSEK ApS, Denmark. All rights reserved.

  File:      concurrent2.c

  Purpose:   To demonstrate a more flexible interface for concurrent optimization. 
*/


#include "mosek.h"

static void MSKAPI printstr(void *handle,
                            MSKCONST char str[])
{
  printf("env: %s",str);
} /* printstr */

static void MSKAPI printstr1(void *handle,
                            MSKCONST char str[])
{
  printf("simplex: %s",str);
} /* printstr */

static void MSKAPI printstr2(void *handle,
                             MSKCONST char str[])
{
  printf("intpnt: %s",str);
} /* printstr */

#define NUMTASKS 1

int main(int argc,char **argv)
{
  MSKintt   r=MSK_RES_OK,i;
  MSKenv_t  env = NULL;
  MSKtask_t task = NULL;
  MSKtask_t task_list[NUMTASKS];

  /* Ensure that we can delete tasks even if they are not allocated */
  task_list[0] = NULL;

  /* Create mosek environment. */
  r = MSK_makeenv(&env,NULL); 
  
  /* Create a task for each concurrent optimization.
     The 'task' is the master task that will hold the problem data.
  */ 

  if ( r==MSK_RES_OK )
    r = MSK_maketask(env,0,0,&task);

  if (r == MSK_RES_OK)
    r = MSK_maketask(env,0,0,&task_list[0]); 
     
  /* Assign call-back functions to each task */

  if (r == MSK_RES_OK)
    MSK_linkfunctotaskstream(task,
                             MSK_STREAM_LOG,
                             NULL,
                             printstr1);

  if (r == MSK_RES_OK)
    MSK_linkfunctotaskstream(task_list[0],
                             MSK_STREAM_LOG,
                             NULL,
                             printstr2);

  if (r == MSK_RES_OK)
     r = MSK_linkfiletotaskstream(task,
                                  MSK_STREAM_LOG,
                                  "simplex.log",
                                  0);

   if (r == MSK_RES_OK)
     r = MSK_linkfiletotaskstream(task_list[0],
                                  MSK_STREAM_LOG,
                                  "intpnt.log",
                                  0);


  if (r == MSK_RES_OK)
    r = MSK_readdata(task,argv[1]);

  /* Assign different parameter values to each task.
     In this case different optimizers. */

  if (r == MSK_RES_OK)
    r = MSK_putintparam(task,
                        MSK_IPAR_OPTIMIZER,
                        MSK_OPTIMIZER_PRIMAL_SIMPLEX);

  if (r == MSK_RES_OK)
    r = MSK_putintparam(task_list[0],
                        MSK_IPAR_OPTIMIZER,
                        MSK_OPTIMIZER_INTPNT);


  /* Optimize task and task_list[0] in parallel.
     The problem data i.e. C, A, etc.
     is copied from task to task_list[0].
   */

  if (r == MSK_RES_OK)
    r = MSK_optimizeconcurrent (task,
                                task_list,
                                NUMTASKS);

  printf ("Return Code = %d\n",r);

  MSK_solutionsummary(task,
                      MSK_STREAM_LOG);

  MSK_deletetask(&task);
  MSK_deletetask(&task_list[0]);
  MSK_deleteenv(&env);

  return r;
}
