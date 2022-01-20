pragma solidity ^0.8.11;
//SPDX-License-Identifier: GPL-3.0

/* To draw lots*/
contract TDL {

	uint64 public ticketPrize;
	uint private jackpot;
	uint public ticketsSold;
	uint public lotteryEndTime;
	address payable[] public players;
    address public owner;

	event LotteryWinnerSet(address accountAddress, uint jackpotAmount);

	constructor(uint _whenEnd, uint64 _ticketPrize) {
		lotteryEndTime = block.timestamp + _whenEnd;
		ticketPrize = _ticketPrize;
        owner=msg.sender;
	}

	function buyTicket() public payable returns (uint) {
		require (block.timestamp <= lotteryEndTime);
		require (msg.value >= ticketPrize);
	
		uint howManyTickets = msg.value/ticketPrize;
		for(uint counter = 0; counter < howManyTickets; counter++) {
			players.push(payable(msg.sender));
		}
		jackpot += msg.value;
		ticketsSold += 1;
		return howManyTickets;
	}

	function random() private view returns (uint) {
       return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, players.length)));
	}

	function getJackpot() public view returns (uint) {
		return jackpot;
	}

	function getTicketSold() public view returns (uint) {
		return ticketsSold;
	}

	function endLottery () public payable {
		require (block.timestamp > lotteryEndTime);
	 	uint index = random() % players.length;
	 	emit LotteryWinnerSet(players[index], jackpot);
		if(players[index].send(jackpot)) {
		} else {
			revert();
		}
	}
}