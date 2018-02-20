c=parallel.cluster.Local();
evalc('system(''export TZ=America/Los_Angeles && mkdir -p ~/MATLAB_JOB_STORAGE_local'')');
c.JobStorageLocation='~/MATLAB_JOB_STORAGE_local';

[a,b]=evalc('system(''nproc --all'')');
n=str2num(a);
c.NumWorkers=n;

c.parpool(n)
%do parfor

delete(gcp)

