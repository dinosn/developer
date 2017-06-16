

# /opt/code is hardcoded, it runs inside the docker
dockerscript="/opt/code/github/jumpscale/developer/scripts9/js_builder_base9_build_step1-docker.sh"
docker exec -t $iname bash ${dockerscript} || dockerdie ${iname} ${logfile}

dockerscript="/opt/code/github/jumpscale/developer/scripts9/js_builder_base9_build_step2-docker.sh"
docker exec -t $iname bash ${dockerscript} || dockerdie ${iname} ${logfile}

if [ -n "$install_libs" ]; then
    dockerscript="/opt/code/github/jumpscale/developer/scripts9/js_builder_base9_build_step3-docker.sh"
    docker exec -t $iname bash ${dockerscript} || dockerdie ${iname} ${logfile}
else
    echo "[+]   installing jumpscale lib9"
    pip3 install -e /opt/code/github/jumpscale/lib9 --no-deps > ${logfile} 2>&1
fi

dockerscript="/opt/code/github/jumpscale/developer/scripts9/js_builder_base9_build_step4-docker.sh"
docker exec -t $iname bash ${dockerscript} || dockerdie ${iname} ${logfile}

echo "[+] commiting changes"
docker commit $iname jumpscale/$iname > ${logfile} 2>&1
docker rm -f $iname > ${logfile} 2>&1

echo "[+] build successful (use js9_start to start an env)"
