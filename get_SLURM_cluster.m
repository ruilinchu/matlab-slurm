function cluster = get_SLURM_cluster(sbatch_arg)
  % input is slurm sbatch arguments minus ntasks, e.g.:
  % '--time 24:00:00 --partition scec --mem-per-cpu 2G', list goes on
setenv('TZ','America/Los_Angeles') % does not work, better put into bashrc file
evalc('system(''mkdir -p ~/MATLAB_JOB_STORAGE'')');
cluster = parallel.cluster.Generic('JobStorageLocation', '~/MATLAB_JOB_STORAGE');
set(cluster, 'HasSharedFilesystem', true);
set(cluster, 'ClusterMatlabRoot', '/usr/usc/matlab/default/');
set(cluster, 'OperatingSystem', 'unix');

set(cluster, 'IndependentSubmitFcn', {@independentSubmitFcn, sbatch_arg});
set(cluster, 'CommunicatingSubmitFcn', {@communicatingSubmitFcn, sbatch_arg});
set(cluster, 'GetJobStateFcn', @getJobStateFcn);
set(cluster, 'DeleteJobFcn', @deleteJobFcn);

end
