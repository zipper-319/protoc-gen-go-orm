package main

import (
	"flag"
	"google.golang.org/protobuf/compiler/protogen"
	"google.golang.org/protobuf/types/pluginpb"
	"log"
	"protoc-gen-go-orm/generator"
)

const version = "v1.0.1"

func main() {

	var flags flag.FlagSet
	showVersion := flags.Bool("version", false, "show version")

	options := protogen.Options{
		ParamFunc: flags.Set,
	}

	options.Run(func(gen *protogen.Plugin) error {
		if *showVersion {
			log.Println("gen-go-orm version is ", version)
		}

		gen.SupportedFeatures = uint64(pluginpb.CodeGeneratorResponse_FEATURE_PROTO3_OPTIONAL)
		for _, f := range gen.Files {
			if !f.Generate {
				continue
			}
			generator.GenerateFile(gen, f)
		}
		return nil
	})

}
