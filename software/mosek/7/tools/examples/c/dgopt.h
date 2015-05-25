#ifndef DGOPT_H
#define DGOPT_H

/*
   Copyright: Copyright (c) MOSEK ApS, Denmark. All rights reserved. 

   File     : dgopt.h
*/

#include "mosek.h"

typedef void *dgohand_t;

MSKrescodee
MSK_dgoread(MSKtask_t task,
            char      *nldatafile,
            MSKintt   *numvar,       /* numterms in primal */
            MSKintt   *numcon,       /* numvar in primal */
            MSKintt   *t,            /* number of constraints in primal*/
            double    **v,           /* coiefients for terms in primal*/
            MSKintt   **p            /* corresponds to number of terms 
                                            in each constraint in the 
                                            primal */
            );

MSKrescodee
MSK_dgosetup(MSKtask_t task,
             MSKintt   numvar,
             MSKintt   numcon,
             MSKintt   t,
             double    *v,
             MSKintt   *p,   
             dgohand_t *nlh);

MSKrescodee
MSK_freedgo(MSKtask_t task,
            dgohand_t  *nlh);
#endif
