docker build -t donibtk/beta-sabre-server:latest -t donibtk/beta-sabre-server:$SHA ./

docker push donibtk/beta-sabre-server:latest

docker push donibtk/beta-sabre-server:$SHA

kubectl set image deployments/server-deployment server=donibtk/beta-sabre-server:$SHA
