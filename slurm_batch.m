c=get_SLURM_cluster('-t 10:00:00 --mem-per-cpu=2G -p isi')

j=c.batch('demo_spmd','Pool',16,'CaptureDiary',true) %by default diary is captured

diary(j) % will display the matlab's output from the batch job
diary(j,'~/demo_output')
