#!/usr/bin/env bash
#
# TITLE       : k8s scheduleir demo
# DESCRIPTION : k8s-scheduleir-demo
# AUTHOR      : Theo Cincotta <theodorecincotta@gmail.com>
# DATE        : 05272024
# VERSION     : 0.0.1
# USAGE       : bash kubernetes.sh or ./kubernetes.sh or …
# REPOSITORY  : https://github.com/theocincotta/k8s-scheduler-demo
# -------------------------------------------------------------------
#
# https://kubernetes.io/docs/concepts/scheduling-eviction/
# https://kind.sigs.k8s.io/

pause_script() {
  echo
  echo -n "Press SPACE to continue or Ctrl+C to exit ... "
  while true; do
    # Set IFS to empty string so that read doesn't trim
    # See http://mywiki.wooledge.org/BashFAQ/001#Trimming
    IFS= read -n1 -r key
    [[ $key == ' ' ]] && break
  done
  echo
  echo "Continuing ..."
}

function exec_cmd() {
  {
    printf " \n"
    printf "######################################## \n"
    printf "$(date '+%Y-%m-%d %H:%M:%S') %s\n" 
    printf "$* \n" 
    "$@"
  }
}

echo ""
echo "We are about to install a four node kind kubernetes cluster." 
echo "If you want to stop at any time you can Control-C."
echo "Run this to delete the cluster."
echo "kind delete cluster --name k8s-scheduling-demo"
echo "Have fun!"

pause_script

# kind create cluster
exec_cmd cat kind/kind-config.yaml
exec_cmd kind create cluster --name k8s-scheduling-demo --config kind/kind-config.yaml

# node names 
exec_cmd kubectl get nodes | grep -v NAME | awk '{print $1}'

# NAME
# k8s-scheduling-demo-control-plane
# k8s-scheduling-demo-worker
# k8s-scheduling-demo-worker2
# k8s-scheduling-demo-worker3

# nodeName
echo ""
exec_cmd cat kubernetes/01-tetris-deployment.yaml
exec_cmd kubectl apply -f kubernetes/01-tetris-deployment.yaml
exec_cmd kubectl wait --for=condition=ready pod -l app=tetris --timeout=120s
exec_cmd kubectl get pods -o wide 

pause_script

# label one node
echo ""
#echo "kubectl label node k8s-scheduling-demo-worker2 team=devops"
exec_cmd kubectl label node k8s-scheduling-demo-worker2 team=devops

echo ""
echo "kubectl label node k8s-scheduling-demo-worker3 team=devops"
exec_cmd kubectl label node k8s-scheduling-demo-worker3 team=devops

echo ""
exec_cmd kubectl get nodes --show-labels 
echo ""
exec_cmd kubectl get nodes k8s-scheduling-demo-worker2 --show-labels

echo ""
echo "kubectl get nodes -l team=devops"
exec_cmd kubectl get nodes -l team=devops

# nodeSelector
echo ""
exec_cmd diff kubernetes/01-tetris-deployment.yaml kubernetes/02-tetris-deployment.yaml 
exec_cmd kubectl apply -f kubernetes/02-tetris-deployment.yaml
exec_cmd kubectl wait --for=condition=ready pod -l app=tetris --timeout=120s
exec_cmd kubectl get pods -o wide

pause_script

# nodeAffinity
echo ""
exec_cmd diff kubernetes/02-tetris-deployment.yaml kubernetes/03-tetris-deployment.yaml
exec_cmd kubectl apply -f kubernetes/03-tetris-deployment.yaml 
exec_cmd kubectl wait --for=condition=ready pod -l app=tetris --timeout=10s


exec_cmd kubectl get pods -o wide

pause_script

echo ""
exec_cmd kubectl label node k8s-scheduling-demo-worker2 rank=3
echo ""
echo ""
exec_cmd kubectl label node k8s-scheduling-demo-worker3 rank=3

echo ""
exec_cmd diff kubernetes/03-tetris-deployment.yaml kubernetes/04-tetris-deployment.yaml
exec_cmd kubectl apply -f kubernetes/04-tetris-deployment.yaml
exec_cmd kubectl wait --for=condition=ready pod -l app=tetris --timeout=10s

exec_cmd kubectl get pods -o wide
pause_script

echo ""
exec_cmd diff kubernetes/04-tetris-deployment.yaml kubernetes/05-tetris-deployment.yaml
exec_cmd kubectl apply -f kubernetes/05-tetris-deployment.yaml
exec_cmd kubectl wait --for=condition=ready pod -l app=tetris --timeout=10s

exec_cmd kubectl get pods -o wide
pause_script

echo ""
exec_cmd cat kubernetes/01-frogger-deployment.yaml
exec_cmd kubectl apply -f kubernetes/01-frogger-deployment.yaml
exec_cmd kubectl wait --for=condition=ready pod -l app=frogger --timeout=10s

exec_cmd kubectl get pods -o wide
pause_script

echo ""
exec_cmd diff kubernetes/01-frogger-deployment.yaml kubernetes/02-frogger-deployment.yaml
exec_cmd kubectl apply -f kubernetes/02-frogger-deployment.yaml
exec_cmd kubectl wait --for=condition=ready pod -l app=frogger --timeout=10s

exec_cmd kubectl get pods -o wide
pause_script

echo ""
exec_cmd kubectl taint node k8s-scheduling-demo-worker2 evn=production:NoSchedule
# Remove taint.
# kubectl taint node k8s-scheduling-demo-worker2 evn=production:NoSchedule-

echo ""
exec_cmd kubectl describe node k8s-scheduling-demo-worker2 
pause_script

echo "Now you can play the two games you setup by running these in two new termias"
echo "kubectl port-forward deployment/frogger 8080:80"
echo "kubectl port-forward deployment/frogger 8081:80"
echo "open http://localhost:8081/"
echo "open http://localhost:8082/"
pause_script

echo "Delete cluster?"
pause_script
echo ""
echo "kind delete cluster --name k8s-scheduling-demo"
exec_cmd kind delete cluster --name k8s-scheduling-demo

echo "End of k8s-scheduling-demo."
echo "Have an amazing day!"
