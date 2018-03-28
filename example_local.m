c = get_LOCAL_cluster;

c.parpool

spmd
switch labindex 
 case 1
  A = 1:5;
  labSend(A,2,199);
 case 2
  A = labReceive(1,199);
 otherwise
  A = 11:15;
 end
end

A{:}

spmd
if labindex == 1
  A=labBroadcast(1,1:5);
 else
  A=labBroadcast(1);
end
end

A{:}

delete(gcp('nocreate'))

