# master 节点执行

## 拉取镜像

```sh
kubeadm config images list --image-repository registry.aliyuncs.com/google_containers
kubeadm config images pull --image-repository registry.aliyuncs.com/google_containers
```

## 初始化 master 集群

```sh
kubeadm init --config=kubeadm.yml --upload-certs --ignore-preflight-errors=ImagePull
```

## 添加到 profile

```sh
echo "export KUBECONFIG=/etc/kubernetes/admin.conf" >> /etc/profile
source /etc/profile
```

## 配置网络

```sh
kubectl apply -f /vagrant/kube-flannel.yml
```

## 查看 join 命令

```sh
kubeadm token create --print-join-command
```

# node 节点执行

## 加入 master

```sh
kubeadm join xxxxxx
```