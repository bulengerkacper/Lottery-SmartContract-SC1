pragma solidity ^0.8.11;
//SPDX-License-Identifier: GPL-3.0

/* To draw lots*/
contract TDL {

	uint64 public ticketPrize;
	uint public jackpot;
	uint public ticketsSold;
	uint public lotteryEndTime;
	address payable[] public players;
    address public owner;

	event LotteryWinnerSet(address accountAddress, uint jackpotAmount);

	constructor(uint _whenEnd, uint64 _ticketPrize) {
        // convert_to_days=12*60*60*_whenEnd
		lotteryEndTime = block.timestamp + _whenEnd;
		ticketPrize = _ticketPrize;
        owner=msg.sender;
	}

	receive() external payable {
		require (block.timestamp <= lotteryEndTime);
		require (msg.value == ticketPrize);
	    players.push(payable(msg.sender));
		jackpot += msg.value;
		ticketsSold += 1;
	}

	function random() private view returns (uint) {
       return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, players.length)));
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