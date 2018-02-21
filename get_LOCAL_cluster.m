function c = get_LOCAL_cluster()

setenv('TZ','America/Los_Angeles')
evalc('system(''mkdir -p ~/MATLAB_JOB_STORAGE_local'')');
c=parallel.cluster.Local();
c.JobStorageLocation='~/MATLAB_JOB_STORAGE_local';

[a,b]=evalc('system(''nproc --all'')');
n=str2num(a);
c.NumWorkers=n;

end

