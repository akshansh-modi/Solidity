// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// contract MyContract {
//     // Declare state variables here

//     // Constructor function
//     constructor() {
//         // Initialize state variables here
//     }

//     // Function declarations here

//     // Modifier declarations here

//     // Event declarations here

//     // Other contract code here
// }

contract Lottery {
    address public manager;
    address payable[] public players;
    // uint public minimumAmount;
    mapping(address => bool) public isPlayer;

    constructor(
        // uint _minimumAmount
        ) {
        manager = msg.sender;
        // minimumAmount = _minimumAmount;
    }

    modifier onlyManager() {
        require(msg.sender == manager);
        _;
    }
    

  

    function enter() public payable  {
        require(msg.sender!=manager,"manager cannot enter");
        require(msg.value >= 1 ether, "Not enough Ether to enter");
        require(!isPlayer[msg.sender], "Already registered as a player");
        isPlayer[msg.sender] = true;
        players.push(payable(msg.sender));
     
    }

    function random() private view returns (uint) {
        return
            uint(
                sha256(
                    abi.encodePacked(block.difficulty, block.number, players)
                )
            );
    }
      function pickWinner() public onlyManager {
        uint index = random() % players.length;
        players[index].transfer(address(this).balance);
        players = new address payable[](0);
    }

    function getPlayers() public view returns (address payable[] memory) {
        return players;
    }
}
