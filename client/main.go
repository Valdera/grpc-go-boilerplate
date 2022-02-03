package main

import (
	"context"
	"log"
	"net/http"
	"os"

	gw "productinfo/gen/gw/product"

	"github.com/grpc-ecosystem/grpc-gateway/v2/runtime"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
)

var grpcServerEndpoint string
var port string

func init() {
	port = os.Getenv("PORT")

	grpcServerEndpoint = os.Getenv("SERVER_HOST") + os.Getenv("SERVER_PORT")

}

func main() {
	ctx := context.Background()
	ctx, cancel := context.WithCancel(ctx)
	defer cancel()

	// Register gRPC server endpoint
	// Note: Make sure the gRPC server is running properly and accessible
	mux := runtime.NewServeMux()
	opts := []grpc.DialOption{grpc.WithTransportCredentials(insecure.NewCredentials())}
	err := gw.RegisterProductInfoHandlerFromEndpoint(ctx, mux, grpcServerEndpoint, opts)
	if err != nil {
		log.Fatalf("Fail to register gRPC service endpoint: %v", err)
		return
	}
	if err := http.ListenAndServe(port, mux); err != nil {
		log.Fatalf("Could not setup HTTP endpoint: %v", err)
	}
}
