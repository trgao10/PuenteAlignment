# Puente Alignment
MST-based Generalized Dataset Procrustes Distance by Jesús Puente

MATLAB Code originally written by Jesús Puente (jparrubarrena@gmail.com ); currently maintained by Tingran Gao (trgao10@math.duke.edu). Christopher Glynn (cdglynn@gmail.com) implemented this algorithm in R, see [here](https://stat.duke.edu/~sayan/auto3dgm/).

-----------
#### Sequential Execution
The entry point is the script `code/main.m`; see comments at the top of that script for a quick introduction. 

-----------
#### Parallel Execution
The current version of PuenteAlignment supports parallel computations on a cluster managed by Sun Grid Engine (SGE). To enable parallel execution, follow the steps 1 to 6 below.

1. Get the current version of PuenteAlignment. Simply `cd` into your desired path, and then
```
git clone https://github.com/trgao10/PuenteAlignment.git
```
2. Find script ```jadd_path.m``` in the folder *PuenteAlignment/code/*, and set paths and parameters there. If you set up assign an email address to the varialbe `email_notification`, a notification will be sent automatically to that email address whenever a cluster job completes or aborts.
3. Launch ```MATLAB```, `cd` into the folder *PuenteAlignment/code/*, type
```
clusterMapLowRes
```
All jobs should then be submitted to the cluster. Use `qstat` to monitor job status.
4. After all jobs are completed, type
```
clusterReduceLowRes
```
This generates low-resolution alignment results in the `output` folder you specified in ```jadd_path.m```.
5. Type
```
clusterMapHighRes
```
to submit high-resolution alignment jobs to the cluster. Use `qstat` to monitor job status.
6. After all jobs are completed, type
```
clusterReduceHighRes
```
This generates high-resolution alignment results in the `output` folder you specified in ```jadd_path.m```.

-----------
#### Please Cite:

Boyer, Doug M., et al. "A New Fully Automated Approach for Aligning and Comparing Shapes." The Anatomical Record 298.1 (2015): 249-276.

Puente, Jesús. "Distances and Algorithms to Compare Sets of Shapes for Automated Biological Morphometrics." PhD Thesis, Princeton University, 2013.
