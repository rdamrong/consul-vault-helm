### Install HashiCorp Vault on K8s by Helm using HahsiCorp Consul storage backend

1. Create NFS Server and K8s Cluster (My Private Lab provided by oVirt)
```
cd /Users/drs/Dropbox/01-Kubernetes/provisioning/ng_lab_home_nfs
terraform destroy --auto-approve; terraform apply --auto-approve
cd /Users/drs/Dropbox/01-Kubernetes/provisioning/ng_lab_home_k8s
terraform destroy --auto-approve; terraform apply --auto-approve

rsync -av root@192.168.254.41:.kube/config $HOME/.kube
kubectl get nodes
```
2. create pv
```
cd /Users/drs/Dropbox/01-Kubernetes/scenario/vaultproject/helm
kubectl apply -f pv.yaml
```
3. Create Secret
```
kubectl create ns vault
kubectl -n vault create secret tls tls-server --cert ./pki/server1.crt --key ./pki/server1.key
kubectl -n vault create secret tls tls-ca --cert ./pki/ca.crt --key ./pki/ca.key
#kubectl -n vault create secret tls consul-consul-connect-inject-webhook-cert --cert ./pki/consul.crt --key ./pki/consul.key
kubectl -n vault create secret tls tls-consul --cert ./pki/consul.crt --key ./pki/consul.key
kubectl -n vault create secret tls  client-tls-init  --cert ./pki/consul.crt --key ./pki/consul.key
```
4. Install Consul
```
helm install consul hashicorp/consul --create-namespace --namespace vault -f consul-vaules.yaml
```
5. Install Vault
```
helm install vault hashicorp/vault --values vault-values.yaml --namespace vault
```

6. Unseal
```
rm -f init-result.txt
kubectl exec --stdin=true --tty=true -n vault  vault-0 -- vault operator init > init-result.txt

cat init-result.txt | grep "Key 1" |awk '{print "kubectl exec -it -n vault vault-0 -- vault operator unseal "$4}' | sed -r "s/\x1B\[[0-9;]*[a-zA-Z]//g" | sh
cat init-result.txt | grep "Key 2" |awk '{print "kubectl exec -it -n vault vault-0 -- vault operator unseal "$4}' | sed -r "s/\x1B\[[0-9;]*[a-zA-Z]//g" | sh
cat init-result.txt | grep "Key 3" |awk '{print "kubectl exec -it -n vault vault-0 -- vault operator unseal "$4}' | sed -r "s/\x1B\[[0-9;]*[a-zA-Z]//g" | sh


cat init-result.txt | grep "Key 1" |awk '{print "kubectl exec -it -n vault vault-1 -- vault operator unseal "$4}' | sed -r "s/\x1B\[[0-9;]*[a-zA-Z]//g" | sh
cat init-result.txt | grep "Key 2" |awk '{print "kubectl exec -it -n vault vault-1 -- vault operator unseal "$4}' | sed -r "s/\x1B\[[0-9;]*[a-zA-Z]//g" | sh
cat init-result.txt | grep "Key 3" |awk '{print "kubectl exec -it -n vault vault-1 -- vault operator unseal "$4}' | sed -r "s/\x1B\[[0-9;]*[a-zA-Z]//g" | sh
```

7. Expose and Test Connection
```
kubectl apply -f vault-svc.yaml
source .vaultrc
vault status
```

#### Unknonw Issue
1. Configuring Gossip Encryption
2. Use the same key in every Consul Compoment
