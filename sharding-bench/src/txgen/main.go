package main

import (
	"bytes"
	"fmt"
	"os"
	"strings"
	"time"

	sdk "github.com/ontio/ontology-go-sdk"
	"github.com/ontio/ontology-go-sdk/client"
	"github.com/ontio/ontology/common/log"
	"github.com/ontio/ontology/core/types"
	"github.com/ontio/ontology/smartcontract/service/native/shardhotel"
	"github.com/ontio/ontology/smartcontract/service/native/shardping"
	"github.com/ontio/ontology/smartcontract/service/native/utils"
	"github.com/ontspace/ontology-bench/sharding-bench/src/config"
)

func main() {
	log.InitLog(log.InfoLog, log.PATH, log.Stdout)
	if len(os.Args) < 3 {
		log.Errorf("missed config file and wallet path")
		return
	}
	configPath := os.Args[1]
	walletPath := os.Args[2]

	testMethod := "ping"
	if len(os.Args) > 3 {
		testMethod = strings.ToLower(os.Args[3])
	}

	cfg, err := config.ParseConfig(configPath)
	if err != nil {
		log.Error(err)
		return
	}

	wallet, err := sdk.OpenWallet(walletPath)
	if err != nil {
		log.Errorf("parse wallet err: %s", err)
		return
	}
	account, err := wallet.GetDefaultAccount([]byte(cfg.Password))
	if err != nil {
		log.Errorf("get account err: %s", err)
		return
	}

	shardTxTest(cfg, account, testMethod)
}

func shardTxTest(cfg *config.Config, account *sdk.Account, testMethod string) {
	if len(cfg.Rpc) == 0 {
		return
	}
	shardPerNode := 1
	allShards := make([]int, 0)
	for _, shards := range cfg.Rpc {
		shardPerNode = len(shards)
		allShards = append(allShards, shards...)
	}
	nextShardMap := make(map[int]int)
	for i, s := range allShards {
		if i == len(allShards) - 1 {
			nextShardMap[s] = allShards[0]
		} else {
			nextShardMap[s] = allShards[i+1]
		}
	}
	exitChan := make(chan time.Duration)
	routineNum := len(cfg.Rpc) * shardPerNode
	for server, shards := range cfg.Rpc {
		for _, id := range shards {
			go func(ipaddr string, shardId uint64, targetShardId uint64, nTxs int) {
				sendTxSdk := sdk.NewOntologySdk()
				rpcClient := client.NewRpcClient()
				rpcAddress := fmt.Sprintf("http://%s:%d", ipaddr, shardId*10+20336)
				rpcClient.SetAddress(rpcAddress)
				sendTxSdk.SetDefaultClient(rpcClient)

				timeAll := time.Duration(0)
				for k := 0; k < nTxs; k++ {
					startTime := time.Now()
					txPayload := fmt.Sprintf("%d", k)
					switch testMethod {
					case "ping":
						if err := sendPing(sendTxSdk, cfg, account, shardId, txPayload); err != nil {
							log.Errorf("send ping to %s, shard %d failed: %s", ipaddr, shardId, err)
							return
						}
					case "shardping":
						if err := sendShardPing(sendTxSdk, cfg, account, shardId, targetShardId, txPayload); err != nil {
							log.Errorf("send ping to %s, shard %d failed: %s", ipaddr, shardId, err)
							return
						}
					case "hotelreserve":
					default:
						return
					}
					timeAll += time.Since(startTime)
					if time.Since(startTime) < time.Microsecond {
						time.Sleep(time.Microsecond - time.Since(startTime))
					}
				}
				exitChan <- timeAll
			}(server, uint64(id), uint64(nextShardMap[id]), cfg.TxNum)
		}
	}
	timeSum := time.Duration(0)
	for i := 0; i < routineNum; i++ {
		t := <-exitChan
		timeSum += t / time.Millisecond
	}
	tps := int64(routineNum * routineNum) * int64(cfg.TxNum) * 1000000 / int64(timeSum)
	log.Errorf("tps: %d.%d", tps/1000, tps%1000)
}

func sendPing(sdk *sdk.OntologySdk, cfg *config.Config, user *sdk.Account, shardID uint64, txt string) error {
	tShardId, _ := types.NewShardID(shardID)
	param := shardping.ShardPingParam{
		FromShard: tShardId,
		ToShard:   tShardId,
		Param:     txt,
	}
	buf := new(bytes.Buffer)
	if err := param.Serialize(buf); err != nil {
		return fmt.Errorf("failed to ser shard deposit gas param: %s", err)
	}

	method := shardping.SHARD_PING_NAME
	contractAddress := utils.ShardPingAddress
	txParam := []interface{}{buf.Bytes()}

	_, err := sdk.Native.InvokeShardNativeContract(shardID, cfg.GasPrice, cfg.GasLimit, user, 0, contractAddress, method, txParam)
	if err != nil {
		return fmt.Errorf("invokeNativeContract error : %s", err)
	}
	return nil
}

func sendShardPing(sdk *sdk.OntologySdk, cfg *config.Config, user *sdk.Account, fromShardID, toShardID uint64, txt string) error {
	tFromShardId, _ := types.NewShardID(fromShardID)
	tToShardId, _ := types.NewShardID(toShardID)
	param := shardping.ShardPingParam{
		FromShard: tFromShardId,
		ToShard:   tToShardId,
		Param:     txt,
	}
	buf := new(bytes.Buffer)
	if err := param.Serialize(buf); err != nil {
		return fmt.Errorf("failed to ser shard deposit gas param: %s", err)
	}

	method := shardping.SEND_SHARD_PING_NAME
	contractAddress := utils.ShardPingAddress
	txParam := []interface{}{buf.Bytes()}

	_, err := sdk.Native.InvokeShardNativeContract(fromShardID, cfg.GasPrice, cfg.GasLimit, user, 0, contractAddress, method, txParam)
	if err != nil {
		return fmt.Errorf("invokeNativeContract error : %s", err)
	}
	return nil
}

func sendShardReserve(sdk *sdk.OntologySdk, cfg *config.Config, user *sdk.Account, fromShardID, toShardID uint64, roomNo int) error {
	shardId2, err := types.NewShardID(toShardID)
	if err != nil {
		return err
	}
	param := shardhotel.ShardHotelReserve2Param{
		User:             user.Address,
		RoomNo1:          roomNo,
		Shard2:           shardId2,
		ContractAddress2: utils.ShardHotelAddress,
		RoomNo2:          roomNo,
		Transactional:    false,
	}
	buf := new(bytes.Buffer)
	if err := param.Serialize(buf); err != nil {
		return fmt.Errorf("failed to ser shard hotel reserve2: %s", err)
	}

	method := shardhotel.SHARD_DOUBLE_RESERVE_NAME
	contractAddr := utils.ShardHotelAddress
	txParam := []interface{}{buf.Bytes()}
	_, err = sdk.Native.InvokeShardNativeContract(fromShardID, cfg.GasPrice, cfg.GasLimit, user, 0, contractAddr, method, txParam)
	if err != nil {
		return fmt.Errorf("invoke Native contract err: %s", err)
	}
	return nil
}
