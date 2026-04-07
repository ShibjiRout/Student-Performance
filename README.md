## End to End MAchine Learning Project



## Run from terminal

docker build -t studentdocker.azurecr.io/predictor:latest .

docker login studentdocker.azurecr.io

docker push studentdocker.azurecr.io/predictor:latest