build:
	docker build -t ausgaben .

run:
	docker run --rm -d -p 127.0.0.1:5000:5000 --name ausgaben --link mysql:mysql ausgaben

bash:
	docker run --rm -t -i -p 127.0.0.1:5000:5000 --name ausgaben --link mysql:mysql ausgaben /bin/bash
