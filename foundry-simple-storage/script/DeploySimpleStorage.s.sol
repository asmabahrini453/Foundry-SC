//SPDX-License-Identifier: MIT

pragma solidity 0.8.19;
//we need to tell forge that this is  a script
//we need to import the script interface

import {Script} from "forge-std/Script.sol";
import {SimpleStorage} from "../src/SimpleStorage.sol";

contract DeploySimpleStorage is Script{  
    //main func that gets called to deploy our contract
    function run() external returns (SimpleStorage) {
        //vm is only used in Foundry. (you can find it in docs/sheetcodes)
        //start broadcasting to the rpc , so everything (tx) inside startBroadcasting and stopBroadcasting is going to be sent
        //to the RPC and get deployed. 
        vm.startBroadcast();
        //deploy the contract
        SimpleStorage simpleStorage = new SimpleStorage(); //instantiate SC
        //stop broadcasting
        vm.stopBroadcast();
        //return the deployed contract
        return simpleStorage;
    }

}