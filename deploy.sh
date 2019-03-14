docker build -t donibtk/beta-sabre-server:latest -t donibtk/beta-sabre-server:$SHA ./

docker push donibtk/beta-sabre-server:latest

docker push donibtk/beta-sabre-server:$SHA
