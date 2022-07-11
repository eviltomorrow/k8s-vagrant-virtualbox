# master 节点执行

## 拉取镜像

```sh
kubeadm config images list --image-repository registry.aliyuncs.com/google_containers
kubeadm config images pull --image-repository registry.aliyuncs.com/google_containers
```

## 初始化 master 集群

```sh
kubeadm init --config=/vagrant/kubeadm.yml --upload-certs --ignore-preflight-errors=ImagePull
```

## 添加到 profile

```sh
export KUBECONFIG=/etc/kubernetes/admin.conf"
alias k='kubectl' 
source <(kubectl completion bash | sed s/kubectl/k/g)

## general user
source /etc/profile
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

## root user
export KUBECONFIG=/etc/kubernetes/admin.conf
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


# 补充

## master节点服务器执行, 如果用户不在管理员组，则需要添加管理员权限

```sh
usermod -g root vagrant
su vagrant
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/admin.conf
[sudo] password for vagrant: 
sudo chown $(id -u):$(id -g) $HOME/.kube/admin.conf
echo "export KUBECONFIG=$HOME/.kube/admin.conf" >> ~/.bashrc


# 如果在执行过程中出现权限相关问题，可能时因为没有将zgs用户添加至sudo权限组中，执行下面命令。执行时需要切换至root用户下。
chmod u+w /etc/sudoers
vim /etc/sudoers

# 在文件内找到："root ALL=(ALL) ALL"在起下面添加XXX ALL=(ALL) ALL"
# (这里的XXX是我的用户名)，然后保存退出。

chmod u-w /etc/sudoers
exit
```
