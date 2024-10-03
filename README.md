Creazione delle immagini
```shell
docker compose build
```
Avvio dei container
```shell
docker compose up -d
```
Interruzione dei container
```shell
docker compose down && docker volume rm $(docker volume ls -qf dangling=true)
```