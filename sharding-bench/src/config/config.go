package config

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
)

type Config struct {
	Password            string
	ConsensusWalletPath string
	GasPrice            uint64
	GasLimit            uint64
	ShardPerNode        int
	RootServer          string
	Rpc                 []string
	TxNum               int // whole tx num is *TxFactor
	TPS                 int
	StartNonce          uint32
	SendTx              bool
}

func ParseConfig(path string) (*Config, error) {
	fileContent, err := ioutil.ReadFile(path)
	if err != nil {
		return nil, fmt.Errorf("ParseConfig: failed, err: %s", err)
	}
	config := &Config{}
	err = json.Unmarshal(fileContent, config)
	if err != nil {
		return nil, fmt.Errorf("ParseConfig: failed, err: %s", err)
	}
	return config, nil
}
