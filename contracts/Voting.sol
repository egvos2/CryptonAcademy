pragma solidity ^0.8.4;


// === Voting smart contract ===
contract Voting {

	// Contract owner, votes creator, voting owner (Maybe it's Pu)
    address public owner;

	// Contract address
	address public contr_addr;
	
	// Owner commission 10 percent
	uint public comm;
	// Voting price
	uint public price = 0.01 ether;

	
	// Voter
	struct Voter {
		address addr;
		uint amount;
		bool voting;
		uint counter;
	}
	
	// Vote structure
	struct Vote {
        uint start_time; // Time of vote creation
        uint voteDepo; // Vote depo
        uint numVoters;
        mapping (uint => Voter) voters;
    }

    uint public numVotes;
	
    mapping (uint => Vote) votes;

	/**
     * Contract initialization.
     * The `constructor` is executed only once when the contract is created.
     */
    constructor() {
        owner = msg.sender;
		contr_addr = address(this);
		comm = 10;
    }
	

	// Create Voting
    function createVote () public returns (uint voteID) {
		require (owner == msg.sender, "You are not an owner!");
		
		voteID = numVotes++; // voteID is return variable
		Vote storage v = votes[voteID];
		v.start_time = block.timestamp; // Voting time creation
		v.voteDepo = 0; // Depo
    }
	
	// Send depo 0.01 ETH
    function sendDepo (uint voteID) public payable {
		require (msg.value < price, "Rejected!");

        Vote storage v = votes[voteID];
		v.voters[v.numVoters++] = Voter({addr: msg.sender, amount: msg.value, voting: false, counter: 0});
        v.voteDepo += msg.value;
    }

	// Get vote balance
	function getVoteBalance (uint voteID) public view returns (uint) {
		return votes[voteID].voteDepo;
	}
	
	// Get vote users Info
    function getVoteUsers (uint voteID) public view returns (address[] memory) {
		address[] memory ret = new address[](votes[voteID].numVoters);
		for (uint i = 0; i < votes[voteID].numVoters; i++) {
			ret[i] = votes[voteID].voters[i].addr;
		}
		return ret;
    }
	
	// Get votes IDs
    function getVotesIds () public view returns (uint numVotes) {
		return numVotes;
    }
	
	// Cast your vote
    function sendVote (uint voteID, uint userID) public returns (bool)	{
		if (voteID <= 0 || voteID>numVotes)
			return false;
		bool up_count = false;
		// Find  sender
        for (uint i=0; i<votes[voteID].numVoters; i++) {
			if (msg.sender == votes[voteID].voters[i].addr) { // if we have voter in voters list
				if (votes[voteID].voters[i].voting == false) { // if hi is not voting
					up_count = true; // May voting (and O(1) dificulty)
				}
			}
		}
		if (!up_count || userID <= 0 || userID>votes[voteID].numVoters)
			return false;
		else {
			votes[voteID].voters[userID].counter++; // Add vote
			return true;
		}
	}
	
	// Close voting
    function closeVote (uint voteID) public returns (bool) {
		// Check 3 day time (1000*60*60*24*3 = 259200000 ms)
		if (block.timestamp - votes[voteID].start_time > 259200000) {
			// find winner
			uint winner_id = 0;
			// if voting has only one user
			if (votes[voteID].numVoters == 1) {

			} else {	// if not
				for (uint i=1; i<votes[voteID].numVoters; i++) {
					if (votes[voteID].voters[i].counter>votes[voteID].voters[winner_id].counter)
						winner_id = i;
				}
			}
			// calculate owner reward
			uint owner_reward = votes[voteID].voteDepo/100*comm;
			// calculate winner reward
			uint winner_reward = votes[voteID].voteDepo - owner_reward;
			// send winner reward
			address payable winner_pay = payable (votes[voteID].voters[winner_id].addr);
			winner_pay.transfer (winner_reward);
			// send owner reward
			address payable owner_pay = payable (owner);
			owner_pay.transfer (owner_reward);
			return true;
		} else
			return false;
    }
}