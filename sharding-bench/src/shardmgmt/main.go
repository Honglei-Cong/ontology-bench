package main

import (
	"os"

	sdk "github.com/ontio/ontology-go-sdk"
	"github.com/ontio/ontology-go-sdk/client"
	"github.com/ontio/ontology/common/log"
	"github.com/ontspace/ontology-bench/sharding-bench/src/config"
)

const (
	SHARD_INIT     = "init"
	SHARD_CREATE   = "create"
	SHARD_CONFIG   = "config"
	SHARD_PEERAPPLY = "peerapply"
	SHARD_PEERAPPROVE = "peerapprove"
	SHARD_PEERJOIN = "peerjoin"
	SHARD_ACTIVATE = "activate"
)

func main() {
	log.InitLog(log.InfoLog, log.PATH, log.Stdout)
	if len(os.Args) < 2 {
		log.Errorf("not enough args")
	}
	cmd := os.Args[1]
	configPath := "config.json"
	if len(os.Args) >= 3 {
		configPath = os.Args[2]
	}
	cfg, err := config.ParseConfig(configPath)
	if err != nil {
		log.Error(err)
		return
	}

	paramFile := ""
	if len(os.Args) >= 4 {
		paramFile = os.Args[3]
	}
	sdk := sdk.NewOntologySdk()
	rpcClient := client.NewRpcClient()
	rpcClient.SetAddress(cfg.RootServer)
	sdk.SetDefaultClient(rpcClient)

	if cmd == SHARD_INIT {
		if err := ShardInit(sdk, cfg, paramFile); err != nil {
			log.Errorf("shard init err: %s", err)
		}
	} else if cmd == SHARD_CREATE {
		if err := ShardCreate(sdk, cfg, paramFile); err != nil {
			log.Errorf("shard create err: %s", err)
		}
	} else if cmd == SHARD_CONFIG {
		if err := ShardConfig(sdk, cfg, paramFile); err != nil {
			log.Errorf("shard config err: %s", err)
		}
	} else if cmd == SHARD_PEERAPPLY {
		if err := ShardPeerApply(sdk, cfg, paramFile); err != nil {
			log.Errorf("shard peer join err: %s", err)
		}
	} else if cmd == SHARD_PEERAPPROVE {
		if err := ShardPeerApprove(sdk, cfg, paramFile); err != nil {
			log.Errorf("shard peer join err: %s", err)
		}
	} else if cmd == SHARD_PEERJOIN {
		if err := ShardPeerJoin(sdk, cfg, paramFile); err != nil {
			log.Errorf("shard peer join err: %s", err)
		}
	} else if cmd == SHARD_ACTIVATE {
		if err := ShardActivate(sdk, cfg, paramFile); err != nil {
			log.Errorf("shard activate err: %s", err)
		}
	} else {
		log.Errorf("un support cmd")
		return
	}

}
