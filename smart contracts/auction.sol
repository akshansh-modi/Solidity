// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Auction {
    address payable auctioneer;
    // uint public stblock; //start time
    // uint public etblock; //end time
    // enum Auc_state {
    //     Started,
    //     Running,
    //     Ended,
    //     Cancelled
    // }
    // Auc_state public auctionstate;

    address payable[] bidders;
    address  payable highestBidder;

    constructor() {
        auctioneer = payable(msg.sender);
    }

    mapping(address => uint) mapBidders;
    mapping(address => bool) isBidder;
    modifier onlyAuctioneer() {
        require(msg.sender == auctioneer, "only auctioneer");
        _;
    }
    modifier notAuctioneer() {
        require(msg.sender != auctioneer, "no auctioneer plz");
        _;
    }
    modifier onlyBidder() {
        require(isBidder[msg.sender] == true, "only bidder");
        _;
    }
    event BidPlaced(address bidder, uint amount);
    event BidIncreased(address bidder, uint amount);
    event BidderRemoved(address bidder);
    event AuctionEnded(address winner, uint amount);

    function bid() public payable notAuctioneer {
        require(isBidder[msg.sender] != true, "already a  bidder");
        require(msg.value > 0, "greater than 0");
        mapBidders[msg.sender] = msg.value;
        isBidder[msg.sender] = true;
        bidders.push(payable(msg.sender));
        updateHighestBidder();
    }

    function updateHighestBidder() public onlyBidder {
        if (mapBidders[msg.sender] > mapBidders[highestBidder]) {
            highestBidder = payable(msg.sender);
        }
    }

    function incrementBid() public payable onlyBidder {
        mapBidders[msg.sender] += msg.value;
        updateHighestBidder();
    }

    function removeBidder(address payable _address) public {
        mapBidders[_address] = 0;
        isBidder[_address] = false;
        _address.transfer(mapBidders[_address]);
    }

    function succesfullBid() public onlyAuctioneer {
        auctioneer.transfer(mapBidders[highestBidder]);
        mapBidders[highestBidder] = 0;
        isBidder[highestBidder] = false;
        endBid();
    }

    function endBid() public onlyAuctioneer {
        for (uint i = 0; i < bidders.length; i++) {
            removeBidder(bidders[i]);
        }
        bidders = new address payable[](0);
    }

    function exitBid() public payable onlyBidder {
        for (uint i = 0; i < bidders.length; i++) {
            if (bidders[i] == payable(msg.sender)) {
                bidders[i] = bidders[bidders.length - 1];
                bidders.pop();
                break;
            }
        }
        removeBidder(payable(msg.sender));
    }
}
