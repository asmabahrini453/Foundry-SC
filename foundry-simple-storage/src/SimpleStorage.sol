//SPDX-License-Identifier: MIT

// we need to specify the solidity version we're working with every time
pragma solidity 0.8.19;

contract SimpleStorage {
    uint256 myFavoriteNbr; //0 //it gets initialized to 0 if we don't initialize ourselves
    //uint256[] listOfFavoriteNbrs

    //any variable outside of a function and we didn't assign a visibilty type to it,
    // is by default a storage internal variable

    struct Person {
        uint256 favoriteNbr;
        string name;
    }
    Person[] public ListOfPeople;

    //Person public myFriend = Person(7,"asma"); 
    //excplicit:
    //Person public myFriend = Person({favoriteNbr:7,name:"asma"});

    mapping(string => uint256) public nameToFavoriteNbr;

    //the store func is updating a state of favoriteNbr when it assigns a nbr to it
    //-> so , we send a tx->we spend gaz
    function store(uint256 _favoriteNbr) public {
        myFavoriteNbr = _favoriteNbr;
    }

    //a function marked with "view" or "pure" : means that we are only wanting to read a state from a blockchain
    //so we don't send a transaction -> we don't spend any gas
    //NB: a view or pure func does cost gas ONLY when another gas cost tx is calling it ->this is called EXECUTION GAS
    function get() public view returns (uint256) {
        return myFavoriteNbr;
    }

    //memory , calldata , storage
    //calldata and memory both mean that the variable is only going to exist temporarily ,
    // it only going to exist for the call function duration.
    //the diff between memory and calldata , meomary is a temporarily valuable that can be modified but calldata can't be modified
    // storage are permanent variable that can be modified
    //complex types :(struct, array , mappings ) cannot be assigned to memory
    function addPerson(string memory _name, uint256 _favoriteNbr) public {
        ListOfPeople.push(Person(_favoriteNbr, _name));
        //map over the name to have their nbr
        nameToFavoriteNbr[_name] = _favoriteNbr;
    }
}
