package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io/ioutil"

	sdk "github.com/ontio/ontology-go-sdk"
	config2 "github.com/ontio/ontology/common/config"
	"github.com/ontio/ontology/common/log"
	"github.com/ontio/ontology/core/types"
	"github.com/ontio/ontology/smartcontract/service/native/shardmgmt"
	"github.com/ontio/ontology/smartcontract/service/native/utils"
	"github.com/ontspace/ontology-bench/sharding-bench/src/config"
)

type ShardConfigParam struct {
	Path        string              `json:"path"`
	ShardID     uint64              `json:"shard_id"`
	NetworkSize uint32              `json:"network_size"`
	GasPrice    uint64              `json:"gas_price"`
	GasLimit    uint64              `json:"gas_limit"`
	VbftConfig  *config2.VBFTConfig `json:"vbft"`
}

func ShardConfig(sdk *sdk.OntologySdk, cfg *config.Config, configFile string) error {
	data, err := ioutil.ReadFile(configFile)
	if err != nil {
		return fmt.Errorf("read config from %s: %s", configFile, err)
	}

	param := &ShardConfigParam{}
	if err := json.Unmarshal(data, param); err != nil {
		return fmt.Errorf("unmarshal shard create param: %s", err)
	}

	user, ok := getAccountByPassword(sdk, param.Path, cfg.Password)
	if !ok {
		return fmt.Errorf("get account failed")
	}

	tShardId, _ := types.NewShardID(param.ShardID)
	configParam := &shardmgmt.ConfigShardParam{
		ShardID:           tShardId,
		NetworkMin:        param.NetworkSize,
		StakeAssetAddress: utils.OntContractAddress,
		GasAssetAddress:   utils.OngContractAddress,
		GasPrice:          param.GasPrice,
		GasLimit:          param.GasLimit,
		VbftConfigData:    param.VbftConfig,
	}

	buf := new(bytes.Buffer)
	if err := configParam.Serialize(buf); err != nil {
		return fmt.Errorf("failed to ser config shard param: %s", err)
	}

	method := shardmgmt.CONFIG_SHARD_NAME
	contractAddress := utils.ShardMgmtContractAddress
	txHash, err := sdk.Native.InvokeNativeContract(cfg.GasPrice, cfg.GasLimit, user, 0,
		contractAddress, method, []interface{}{buf.Bytes()})
	if err != nil {
		return fmt.Errorf("invokeNativeContract error :", err)
	}
	log.Infof("shard config txHash is :%s", txHash.ToHexString())
	return nil
}
