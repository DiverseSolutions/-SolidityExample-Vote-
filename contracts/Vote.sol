// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

contract Vote{

    struct Proposal {
        string name;
        uint voteNeeded;
        bool isVoteFinished;
        address[] votedPeople;
    }

    event proposalAdded(string name,uint voteNeeded);
    event proposalRemoved(string name);
    event proposalVoteFinished(string name,uint voteNeeded);
    event proposalVoteAdded(string name,uint voteNeeded);

    error VoteNotFound(string _name);
    error YouAlreadyVoted(string _name);

    Proposal[] public proposals;


    function addProposal(string memory _name,uint _neededVote) public {
        address[] memory _votePeople;
        Proposal memory newProposal = Proposal(_name,_neededVote,false,_votePeople);

        proposals.push(newProposal);
        emit proposalAdded(_name, _neededVote);
    }

    function removeProposal(string memory _name) public returns(bool) {
        for(uint i=0; i < proposals.length; i++){
            if(keccak256(abi.encodePacked(proposals[i].name)) == keccak256(abi.encodePacked(_name))){
                removeFromArray(i);
                emit proposalRemoved(_name);
                return true;
            }
        }
        return false;
    }

    function voteToProposal(string memory _name) public returns(bool) {
        for(uint i=0; i < proposals.length; i++){
            if(keccak256(abi.encodePacked(proposals[i].name)) == keccak256(abi.encodePacked(_name))){
                require(proposals[i].votedPeople.length != proposals[i].voteNeeded,"Vote Is Already Finished");

                for(uint x=0; x < proposals[i].votedPeople.length; x++){
                    if(proposals[i].votedPeople[x] == msg.sender){
                        revert YouAlreadyVoted(_name);
                    }
                }

                proposals[i].votedPeople.push(msg.sender);
                emit proposalVoteAdded(_name,proposals[i].voteNeeded);

                if(proposals[i].votedPeople.length == proposals[i].voteNeeded){
                    proposals[i].isVoteFinished = true;
                    emit proposalVoteFinished(_name,proposals[i].voteNeeded);
                }

                return true;
            }
        }
        return false;
    }
    
    function getProposalsLength() public view returns( uint ){
        return proposals.length;
    }


    function getProposalVoteLength(string memory _name) public view returns( uint ){
        for(uint i=0; i < proposals.length; i++){
            if(keccak256(abi.encodePacked(proposals[i].name)) == keccak256(abi.encodePacked(_name))){
                return proposals[i].votedPeople.length;
            }
        }

        revert VoteNotFound(_name);
    }



    function removeFromArray(uint _index) private {
        require(_index < proposals.length, "index out of bound");

        for (uint i = _index; i < proposals.length - 1; i++) {
            proposals[i] = proposals[i + 1];
        }
        proposals.pop();
    }

}