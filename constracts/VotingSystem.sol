// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract VotingSystem {
    struct Candidate {
        string name;
        uint256 voteCount;
    }

    struct Voter {
        bool hasVoted;
        uint256 voteIndex;
    }

    address public admin;
    bool public votingActive;

    Candidate[] public candidates;
    mapping(address => Voter) public voters;

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action.");
        _;
    }

    modifier votingOngoing() {
        require(votingActive, "Voting is not active.");
        _;
    }

    constructor(string[] memory _candidateNames) {
        admin = msg.sender;
        for (uint i = 0; i < _candidateNames.length; i++) {
            candidates.push(Candidate({name: _candidateNames[i], voteCount: 0}));
        }
        votingActive = true;
    }

    function vote(uint256 candidateIndex) external votingOngoing {
        require(!voters[msg.sender].hasVoted, "Already voted.");
        require(candidateIndex < candidates.length, "Invalid candidate index.");

        voters[msg.sender] = Voter({hasVoted: true, voteIndex: candidateIndex});
        candidates[candidateIndex].voteCount += 1;
    }

    function getCandidate(uint256 index) public view returns (string memory name, uint256 voteCount) {
        require(index < candidates.length, "Invalid candidate index.");
        Candidate memory candidate = candidates[index];
        return (candidate.name, candidate.voteCount);
    }

    function endVoting() external onlyAdmin {
        votingActive = false;
    }

    function getWinner() external view returns (string memory winnerName, uint256 votes) {
        require(!votingActive, "Voting is still active.");
        uint256 winningVoteCount = 0;
        uint256 winningIndex = 0;

        for (uint i = 0; i < candidates.length; i++) {
            if (candidates[i].voteCount > winningVoteCount) {
                winningVoteCount = candidates[i].voteCount;
                winningIndex = i;
            }
        }

        return (candidates[winningIndex].name, candidates[winningIndex].voteCount);
    }
}
