# Remove all containers (stopped and running)
docker rm -f $(docker ps -aq)

# Remove all volumes
docker volume rm $(docker volume ls -q)