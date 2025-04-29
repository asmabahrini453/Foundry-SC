// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// Note: The AggregatorV3Interface might be at a different location than what was in the video!
import {AggregatorV3Interface} from "lib/chainlink-brownie-contracts/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

import {PriceConverter} from "./PriceConverter.sol";
//Define custom error 
error NotOwner();

//this project is about funding a SC: sending ETH to a contract in exchange for a reward
//Steps are: 1/ Get funds from users 2/ Withdraw funds 3/ Set a minimum funding value in USD
contract FundMe {
    using PriceConverter for uint256; //attaching all uint256 to the fcts defined in PriceConverter.sol so they can have access to them

    mapping(address => uint256) public addressToAmountFunded;

    address[] public funders; //<-- state variable

    //constant,immutable are values that are fixed at compile time and connot change

    address public immutable i_owner; //immutable: we can only assign it once, at the time of deployment

    uint256 public constant MINIMUM_USD = 5 * 10 ** 18;
     //when u add "constatnt" the variable doesn't take up space in the blockchain -->No Storage spot( the compiler hardcodes the literal value directly into the contract's bytecode.)
     // -->easier to read

    //assign an address to the owner of the contract at the time of deployment
    //constructor will be called the moment we deploy the contract
    constructor() {
        i_owner = msg.sender;
    }

    //allow all users tosend ETH to the contract
    //payable : is a keyword that allows the function to receive ETH
    //msg.value:to access the amount of ETH sent to the contract
    //require: to spend at least a minimum amount of ETH
    function fund() public payable {
        require(
            msg.value.getConversionRate() >= MINIMUM_USD,
            "You need to spend more ETH!"
        );
        // require(PriceConverter.getConversionRate(msg.value) >= MINIMUM_USD, "You need to spend more ETH!");
        addressToAmountFunded[msg.sender] += msg.value;
        funders.push(msg.sender);
    }

    function getVersion() public view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(
            0x694AA1769357215DE4FAC081bf1f309aDC325306
        );
        return priceFeed.version();
    }

    //modifiers: are reusable code blocks that can be used to change or add conditions to the behavior of functions, often for access control or validations.
    modifier onlyOwner() {
        // require(msg.sender == owner);
        //custom errors are more gas efficient
        if (msg.sender != i_owner) revert NotOwner();
        _; //this refering to executing the code later than the modifier code
        //if we put it before the if then we execute the code before the modifier code
    }

    //only the owner can withdraw ETH
    //execute the modifier "onlyOwner" first then the   _; then everything else
    function withdraw() public onlyOwner {
        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0; //reset what they funded in fund() back to 0
        }
        funders = new address[](0); //reset the funders array to 0
        // Now, withdraw the funds : send eth back to the sender
        // // way1: transfer
        // // transfer is a function that sends ether to an address
        //.balance :returns the some of money in ETH
        //payable(msg.sender) = payable address of the sender : in solidity, to send the native currency (ETH) to an address, we need to convert it to a payable address
        //issue with transfer: it only sends 2300 gas, which is not enough for some contracts to execute otherwise it throws an error
        // payable(msg.sender).transfer(address(this).balance);

        // //way2:  send
        // issue with send: it only sends 2300 gas and returns a boolean value indicating whether the transfer was successful or not. If it fails, it doesn't throw an error, but it doesn't send the ether either.
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess, "Send failed");

        //way3: call :the recommanded way to send native ETH to an address
        //with call we can send all the gas to the recipient and it returns a boolean value indicating whether the transfer was successful or not. If it fails, it throws an error.
        // call is a low-level fct, we can use it to call any fct in ethereum without the need to an ABI
        //call forward all gas or set gas
        //("") is empty because we're not calling any fct in the recipient contract, we're just sending ether , so using call to send TX
        //call returns 2 variables a (bool callSuccess,) and b (bytes memory dataReturned)
        //if we use call to call a fct that returns a value we can use the second variable to get the data returned
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "Call failed");
    }

    // Explainer from: https://solidity-by-example.org/fallback/
    // Ether is sent to contract
    //      is msg.data empty?
    //          /   \
    //         yes  no
    //         /     \
    //    receive()?  fallback()
    //     /   \
    //   yes   no
    //  /        \
    //receive()  fallback()

//In Solidity, the receive() function handles plain Ether transfers with no data,
// while the fallback() function is called when a non-existent function is invoked or when Ether is sent with data.
    fallback() external payable {
        fund();
    }
    receive() external payable {
        fund();
    }
}

