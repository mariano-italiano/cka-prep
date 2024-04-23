
kubectl create ns enigma
kubectl run backend-pod --image nginx -l app=backend -n enigma
kubectl run db1-pod --image marcinkujawski/echo:1.1 -l app=db1 -n enigma
kubectl run db2-pod --image marcinkujawski/echo:2.2 -l app=db1 -n enigma
kubectl run vault-pod --image marcinkujawski/echo:3.3 -l app=vault -n enigma
