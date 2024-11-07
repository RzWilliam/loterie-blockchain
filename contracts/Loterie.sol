// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Loterie {
    address public owner;
    address[] public participants;
    address public gagnant;

    constructor() {
        owner = msg.sender;
    }

    modifier uniquementProprietaire() {
        require(
            msg.sender == owner,
            "Acces refuse : Vous n'etes pas le proprietaire"
        );
        _;
    }

    function participer() public payable {
        require(
            msg.value >= 0.001 ether,
            "Vous devez envoyer au moins 0.001 ether pour participer"
        );
        participants.push(msg.sender);
    }

    function lancerTirage() public {
        require(participants.length > 0, "Aucun participant dans le tirage");

        uint256 indexGagnant = random() % participants.length;
        gagnant = participants[indexGagnant];

        // Transférer le solde du contrat au gagnant
        payable(gagnant).transfer(address(this).balance);

        // Réinitialiser les participants pour un nouveau tirage
        delete participants;
    }

    function random() private view returns (uint256) {
        return
            uint256(
                keccak256(
                    abi.encodePacked(
                        block.prevrandao,
                        block.timestamp,
                        participants
                    )
                )
            );
    }

    function recupererParticipants() public view returns (address[] memory) {
        return participants;
    }

    function recupererGagnant() public view returns (address) {
        return gagnant;
    }

    receive() external payable {}
}
