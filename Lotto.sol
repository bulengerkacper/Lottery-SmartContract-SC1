pragma solidity ^0.4.19;

/* author @BulKac
OpenSource drawing lots in purpose of learning smart contracts 
4 days smart Lottery */

/* To draw lots*/
contract TDL {

	uint64 public ticketPrize;
	uint private jackpot;
	uint public ticketsSold;
	uint public lotteryEndTime;
	address[] public players;

	event TicketsBought(address accountAddress, uint amount);
	event LotteryWinnerSet(address accountAddress, uint jackpotAmount);
	event playerReCharged(address accountAddres, uint chargedMoney);

	function TDL(uint _whenEnd, uint64 _ticketPrize) public {
		lotteryEndTime = now + _whenEnd;
		ticketPrize = _ticketPrize;
	}

	function buyTicket() public payable returns (uint) {
		require (now <= lotteryEndTime);
		require (msg.value > ticketPrize);
	
		uint howManyTickets = msg.value/ticketPrize;
		for(uint counter = 0; counter < howManyTickets; counter++) {
			players.push(msg.sender);
		}
		uint realPrize = howManyTickets * ticketPrize;
		jackpot += realPrize;
		playerReCharged(msg.sender, realPrize);
		msg.sender.transfer(msg.value-realPrize);
		ticketsSold += howManyTickets;
		return howManyTickets;
	}

	function random() private view returns (uint) {
		return uint(keccak256(block.difficulty, now, players));
	}

	function getJackpot() public constant returns (uint) {
		return jackpot;
	}

	function getTicketSold() public constant returns (uint) {
		return ticketsSold;
	}

	function endLottery () public payable {
		require (now > lotteryEndTime);
	 	uint index = random() % players.length;
	 	LotteryWinnerSet(players[index], jackpot);
		if(players[index].send(jackpot)) {
		} else {
			revert();
		}
	}
}
