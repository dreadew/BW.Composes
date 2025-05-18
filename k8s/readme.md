# Настройка

При использовании minikube или при работе на 1 сервере все настройки остаются такими же.

В случае использования на нескольких серверах, нужно добавить дополнительный `nodeSelector` в каждый `deploymen.yaml`:
```
nodeSelector
    role: data # data, messaging, monitoring, secrets, storage
```
Роль ставится в соответствии с неймспейсом сервиса

Далее, один из серверов выделяется под мастер ноду и подключает все worker-ноды. После этого, необходимо каждому серверу выдать метку по его назначению:
```
kubectl label node vps1 role=data
kubectl label node vps2 role=messaging
kubectl label node vps3 role=monitoring
kubectl label node vps4 role=secrets
kubectl label node vps5 role=storage
```

После этого создаются неймспейсы:
```
kubectl create namespace data
kubectl create namespace messaging
kubectl create namespace monitoring
kubectl create namespace secrets
kubectl create namespace storage
```

Теперь у сервисов можно указывать количество реплик в файлах `deployment.yaml`:
```
spec:
    replicas: 2 # Количество реплик
```

# Настройка в k3s

На сервер, через который будет происходить управление необходимо установить серверную ноду:
```
curl -sfL https://get.k3s.io | sh -
```

Из файла `/var/lib/rancher/k3s/server/node-token` нужно скопировать токен

На всех worker нодах необходимо выполнить следующую команду:
```
curl -sfL https://get.k3s.io | K3S_URL="https://MASTER_IP:6443" K3S_TOKEN="TOKEN" sh -
```

Проверка добавления нод доступна через команду `kubectl get nodes -o wide`

Теперь необходимо обновить `ingress.yaml`:
1) Определяем внешний IP (EXTERNAL-IP) worker-нод `kubectl get nodes -o wide`
2) В файле `/etc/hosts` необходимо указать таблицу маршрутов по каждому лейблу (data, messaging, mointoring, secrets, storage)

# Дефолтное распределение NodePort's:

- Базы данных для сервисов (30100 - 30110)
- Брокеры сообщений (30120 - 30130)
- Мониторинг (31110 - 31150)
- Хранилище секретов (32000 - 32010)
- S3-хранилища (32050 - 32060)

TODO: Добавление CI