tic
c=parallel.cluster.Local();
evalc('system(''mkdir -p ~/MATLAB_JOB_STORAGE_local'')');
c.JobStorageLocation='~/MATLAB_JOB_STORAGE_local';

[a,b]=evalc('system(''nproc --all'')');
n=str2num(a);
c.NumWorkers=n;

c.parpool(n)
toc

delete(gcp)

