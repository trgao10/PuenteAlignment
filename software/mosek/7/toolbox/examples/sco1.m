% sco1.m

% Specify the linear part of the problem.

c           = [1;0;0];
a           = sparse([[0 0 0];[1 2 -1]]);
blc         = [-inf; 0];
buc         = [1;0];
blx         = [-inf;-inf;0];

% Specify the nonlinear part.

opr         = ['log'; 'pow'; 'pow'];
opri        = [0;     1;     1    ];
oprj        = [3;     1;     2    ];
oprf        = [-1;    1;     1    ];
oprg        = [0;     2;     2    ];

% Call the optimizer.
% Note that bux is an optional parameter which should be added if the variables
% have an upper bound. 

[res]       = mskscopt(opr,opri,oprj,oprf,oprg,c,a,blc,buc,blx); 
                                                                 

% Print the solution.
res.sol.itr.xx
