package main

import (
	"context"
	"log"
	"net/http"

	gw "productinfo/gen/gw/product"

	"github.com/grpc-ecosystem/grpc-gateway/v2/runtime"
	"google.golang.org/grpc"
)

var (
	// command-line options:
	// gRPC server endpoint
	grpcServerEndpoint = "localhost:50051"
)

func main() {
	ctx := context.Background()
	ctx, cancel := context.WithCancel(ctx)
	defer cancel()

	// Register gRPC server endpoint
	// Note: Make sure the gRPC server is running properly and accessible
	mux := runtime.NewServeMux()
	opts := []grpc.DialOption{grpc.WithInsecure()}
	err := gw.RegisterProductInfoHandlerFromEndpoint(ctx, mux, grpcServerEndpoint, opts)
	if err != nil {
		log.Fatalf("Fail to register gRPC service endpoint: %v", err)
		return
	}
	if err := http.ListenAndServe(":8081", mux); err != nil {
		log.Fatalf("Could not setup HTTP endpoint: %v", err)
	}
}
