protoc:
	protoc  -I ./proto --go_out ./pb --go_opt paths=source_relative --go-grpc_out ./pb --go-grpc_opt paths=source_relative ./proto/product/product_info.proto
	protoc  -I ./proto --go_out ./gw --go_opt paths=source_relative --go-grpc_out ./gw --go-grpc_opt paths=source_relative --grpc-gateway_out ./gw --grpc-gateway_opt logtostderr=true --grpc-gateway_opt paths=source_relative ./proto/product/product_info.proto
	go mod tidy

swagger:
	protoc -I ./proto --openapiv2_out ./gen/openapi --openapiv2_opt logtostderr=true ./proto/product/product_info.proto


proto-dep:
	go get github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-grpc-gateway
	go get github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-openapiv2
	go get google.golang.org/protobuf/cmd/protoc-gen-go
	go get google.golang.org/grpc/cmd/protoc-gen-go-grpc
	go install github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-grpc-gateway
	go install github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-openapiv2
	go install google.golang.org/protobuf/cmd/protoc-gen-go
	go install google.golang.org/grpc/cmd/protoc-gen-go-grpc
	
run-server:
	go run ./server/main.go

run-client:
	go run ./client/main.go

test-post:
	curl -X POST http://localhost:8081/v1/product -d '{"name": "Apple", "description": "iphone7", "price": 699}'

test-get:
	curl http://localhost:8081/v1/product/350cc1d5-833c-11ec-b2d6-7085c2d5cc1a

create-image:
	docker build -t grpc-productinfo-server -f server/Dockerfile .
	docker build -t grpc-productinfo-client -f client/Dockerfile .

delete-image:
	docker image rm grpc-productinfo-server
	docker image rm grpc-productinfo-client

create-network:
	docker network create my-net

run-d-server:
	docker run -it --network=my-net --name=productinfo --hostname=productinfo -p 50051:50051  grpc-productinfo-server

run-d-client: 
	docker run -it --network=my-net --hostname=client grpc-productinfo-client   

push-d-registry:
	docker image tag grpc-productinfo-server valdera/grpc-productinfo-server
	docker image tag grpc-productinfo-client valdera/grpc-productinfo-client
	docker image push valdera/grpc-productinfo-server
	docker image push valdera/grpc-productinfo-client

create-kube:
	kubectl apply -f server/grpc-productinfo-server.yaml
	kubectl apply -f client/grpc-productinfo-client.yaml
	kubectl apply -f ingress/grpc-prodinfo-ingress.yaml
	kubectl get pods

delete-kube:
	kubectl delete -f server/grpc-productinfo-server.yaml
	kubectl delete -f client/grpc-productinfo-client.yaml
	kubectl delete -f ingress/grpc-prodinfo-ingress.yaml
	kubectl get pods

test-kube-post:
	curl -X POST http://localhost:8081/v1/product -d '{"name": "Apple", "description": "iphone7", "price": 699}'

test-kube-get:
	curl http://10.1.1.5:8081/v1/product/350cc1d5-833c-11ec-b2d6-7085c2d5cc1a

port-forward:
	kubectl port-forward service/productinfo-client 8081:80
