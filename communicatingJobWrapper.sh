#!/bin/bash

FULL_SMPD=${MDCE_CMR:+${MDCE_CMR}/bin/}mw_smpd
FULL_MPIEXEC=${MDCE_CMR:+${MDCE_CMR}/bin/}mw_mpiexec
SMPD_LAUNCHED_HOSTS=""
MPIEXEC_CODE=0

port_taken(){
    netstat -tuplen | grep 0.0.0.0:$1 &> /dev/null
}

declare -i port    

chooseSmpdPort() {
    port=`expr ${SLURM_JOBID} % 10000 + 20000` 
    until ! port_taken $port;
    do
	port=$port+1
    done
    SMPD_PORT=$port
    echo using port number $SMPD_PORT
}

chooseMachineArg() {
    scontrol show hostnames ${SLURM_JOB_NODELIST} > /tmp/kon1uaLw3sOZnkvg
    echo ${SLURM_TASKS_PER_NODE} | tr "," "\n" |sed -e's+(++g' | sed -e's+)++g'|sed -e's+x+ +g' | awk '{
if (length($2) == 0)
print $1
for (i=1; i<= $2; i++)
print $1
}' > /tmp/kon1uaLw3sOZnkvg2

    MACHINE_ARG=$(paste /tmp/kon1uaLw3sOZnkvg /tmp/kon1uaLw3sOZnkvg2 | xargs)
}

cleanupAndExit() {
    rm -fr /tmp/kon1uaLw3sOZnkvg /tmp/kon1uaLw3sOZnkvg2
    echo "Stopping SMPD over port $SMPD_PORT" 
    pdsh -S -t 30 -u 30 -f 1 -w $SLURM_NODELIST ${FULL_SMPD} -shutdown -phrase MATLAB -port ${SMPD_PORT}
    if [ $? == 1 ]; then
        echo
        echo ============
        echo SMPD shutdown stalled, job has finished, exiting this job
        echo ============
        echo
        scancel $SLURM_JOB_ID 
        exit 1
    else
        echo "Exiting with code: ${MPIEXEC_CODE}"
        exit ${MPIEXEC_CODE}
    fi
}

launchSmpds() {
    echo "Starting SMPD over port $SMPD_PORT..."
    echo "launching $SLURM_NODELIST ${FULL_SMPD} -phrase MATLAB -port ${SMPD_PORT} "
    pdsh -t 30 -f 1 -w $SLURM_NODELIST ${FULL_SMPD} -phrase MATLAB -port ${SMPD_PORT}  &>/dev/null &
    sleep 60
    pdsh -S -w $SLURM_NODELIST "ps aux | grep ^$USER | grep '[b]in/glnxa64/smpd -phrase MATLAB -port'" &> /dev/null
    if [ $? == 1 ]; then
        echo
        echo ============
        echo SMPD launch failed, cancelling/exiting this job
        echo ============
        echo
        scancel $SLURM_JOB_ID 
        exit 1
    else
        echo "All SMPDs launched"
    fi
}

runMpiexec() {
    echo \"${FULL_MPIEXEC}\" -noprompt -l -exitcodes -phrase MATLAB -port ${SMPD_PORT} -hosts $SLURM_NNODES ${MACHINE_ARG} -genvlist \
        MDCE_DECODE_FUNCTION,MDCE_STORAGE_LOCATION,MDCE_STORAGE_CONSTRUCTOR,MDCE_JOB_LOCATION,MDCE_DEBUG,MDCE_LICENSE_NUMBER,MLM_WEB_LICENSE,MLM_WEB_USER_CRED,MLM_WEB_ID \
        \"${MDCE_MATLAB_EXE}\" ${MDCE_MATLAB_ARGS}

    # ...and then execute it
    eval \"${FULL_MPIEXEC}\" -noprompt -l -exitcodes -phrase MATLAB -port ${SMPD_PORT} -hosts $SLURM_NNODES ${MACHINE_ARG} -genvlist \
        MDCE_DECODE_FUNCTION,MDCE_STORAGE_LOCATION,MDCE_STORAGE_CONSTRUCTOR,MDCE_JOB_LOCATION,MDCE_DEBUG,MDCE_LICENSE_NUMBER,MLM_WEB_LICENSE,MLM_WEB_USER_CRED,MLM_WEB_ID \
        \"${MDCE_MATLAB_EXE}\" ${MDCE_MATLAB_ARGS}
    MPIEXEC_CODE=${?}
}

# Define the order in which we execute the stages defined above
MAIN() {
    trap "cleanupAndExit" 0 1 2 15
    chooseSmpdPort
    launchSmpds
    chooseMachineArg
    runMpiexec
    exit ${MPIEXEC_CODE}
}

# Call the MAIN loop
MAIN
