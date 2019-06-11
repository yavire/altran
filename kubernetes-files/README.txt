
#Construimos la imagen docker con el spring boot. Con anterioridad ya hemos compilado con maven el fuente.

docker build -t yavire/altran-demo .

#Subimos la imagen a docker hub

docker push yavire/altran-demo