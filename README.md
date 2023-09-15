# 部署流程

行结束问题

## requirement

- k8s版本：1.27.3
- 容器运行时：containerd

## 1、

``````
#在所有有GPU的节点上打上标签
kubectl label node <你的GPU节点> nvidia-device-enable=enable
#在master节点上复制yamlfile文件夹中的文件到指定文件夹
cp scheduler-extender.yaml /etc/kubernetes
cp scheduler-policy-config.json /etc/kubernetes
``````

## 2、修改kube-scheduler.yaml文件

- 备份kube-scheduler.yaml文件

``````
cp /etc/kubernetes/kube-scheduler.yaml ./
``````

- command处增加

``````
- command:
  - --config=/etc/kubernetes/scheduler-extender.yaml
``````

- volumeMounts处增加

``````
volumeMounts:
- mountPath: /etc/localtime
      name: localtime
      readOnly: true
- mountPath: /etc/kubernetes/scheduler-extender.yaml
      name: extender
      readOnly: true
- mountPath: /etc/kubernetes/scheduler-policy-config.json
      name: extender-policy
      readOnly: true
``````

- volumes处增加

``````
volumes:
- hostPath:
      path: /etc/localtime
      type: File
    name: localtime
- hostPath:
      path: /etc/kubernetes/scheduler-extender.yaml
      type: FileOrCreate
    name: extender
- hostPath:
      path: /etc/kubernetes/scheduler-policy-config.json
      type: FileOrCreate
    name: extender-policy
``````

## 3、

``````
chmod +x gpuDeploy.sh
./gpuDeploy.sh
``````



