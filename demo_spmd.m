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
  disp(['this is display from worker: ',num2str(labindex)])
end

