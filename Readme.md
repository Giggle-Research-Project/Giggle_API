```
docker build -t giggle-ml .

docker run -d --name giggle-ml -p 80:8000 giggle-ml
```

1. Remove All Containers
```
docker stop $(docker ps -aq)
```
```
docker rm $(docker ps -aq)
```
2. Remove All Images
```
docker rmi -f $(docker images -aq)
```
3. (Optional) Remove All Volumes and Networks
```
docker volume rm $(docker volume ls -q)
docker network rm $(docker network ls -q)
```
4. (Optional) Prune Everything
```
docker system prune -a --volumes
```