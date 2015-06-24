# Puente Alignment
MST-based Generalized Dataset Procrustes Distance by Jesús Puente

MATLAB Code originally written by Jesús Puente (jparrubarrena@gmail.com ); currently maintained by Tingran Gao (trgao10@math.duke.edu). Christopher Glynn (cdglynn@gmail.com) implemented this algorithm in R, see [here](https://stat.duke.edu/~sayan/auto3dgm/).

-----------
#### Sequential Execution
The entry point is the script `code/main.m`; see comments at the top of that script for a quick introduction. 

-----------
#### Parallel Execution
The current version of PuenteAlignment supports parallel computations on a cluster managed by Sun Grid Engine (SGE). To enable parallel execution, follow the steps below.

1. Get the current version of PuenteAlignment. Simply `cd` into your desired path, and then
```
git clone https://github.com/trgao10/PuenteAlignment.git
```
2. 

-----------
#### Please Cite:

Boyer, Doug M., et al. "A New Fully Automated Approach for Aligning and Comparing Shapes." The Anatomical Record 298.1 (2015): 249-276.

Puente, Jesús. "Distances and Algorithms to Compare Sets of Shapes for Automated Biological Morphometrics." PhD Thesis, Princeton University, 2013.
