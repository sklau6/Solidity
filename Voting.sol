pragma solidity ^0.4.24;

contract Voting {
    
    struct Voter {
        bool isRegistered;
        bool hasVoted;
        uint votedProposalId;
    }

    struct Proposal {
        string description;
        uint voteCount;
    }

    address public chairperson;
    mapping(address => Voter) public voters;
    Proposal[] public proposals;

    event ProposalAdded(uint proposalId, string description);
    event Voted(address voter, uint proposalId);
    event ProposalPassed(uint proposalId);

    constructor() public {
        chairperson = msg.sender;
    }

    function addProposal(string _description) public {
        require(msg.sender == chairperson, "Only the chairperson can add a proposal.");
        proposals.push(Proposal({
            description: _description,
            voteCount: 0
        }));
        emit ProposalAdded(proposals.length - 1, _description);
    }

    function registerVoter(address _voter) public {
        require(msg.sender == chairperson, "Only the chairperson can register voters.");
        voters[_voter].isRegistered = true;
    }

    function vote(uint _proposalId) public {
        require(voters[msg.sender].isRegistered, "Only registered voters can vote.");
        require(!voters[msg.sender].hasVoted, "The voter has already voted.");
        voters[msg.sender].hasVoted = true;
        voters[msg.sender].votedProposalId = _proposalId;
        proposals[_proposalId].voteCount++;
        emit Voted(msg.sender, _proposalId);
        if (proposals[_proposalId].voteCount > (voters.length / 2)) {
            emit ProposalPassed(_proposalId);
        }
    }
}
