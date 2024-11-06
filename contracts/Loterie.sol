// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "@chainlink/contracts/src/v0.8/vrf/VRFConsumerBase.sol";

contract Loterie is VRFConsumerBase {
    address public owner;
    address[] public participants;
    address public gagnant;
    uint256 public dernierTirage;
    bytes32 internal keyHash;
    uint256 internal fee; // Montant en LINK pour Chainlink VRF (0.1 LINK);

    constructor(
        address _vrfCoordinator,
        address _linkToken,
        bytes32 _keyHash,
        uint256 _fee
    ) VRFConsumerBase(_vrfCoordinator, _linkToken) {
        owner = msg.sender;
        keyHash = _keyHash;
        fee = _fee;
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

    // Fonction pour lancer le tirage, nécessite des frais LINK pour Chainlink VRF
    function lancerTirage()
        public
        uniquementProprietaire
        returns (bytes32 requestId)
    {
        require(
            participants.length > 0, // Vérifie qu'il y a des participants
            "Aucun participant dans le tirage"
        );

        // Vérifie si le contrat a suffisamment de LINK pour le tirage
        require(
            LINK.balanceOf(address(this)) >= fee, // Par exemple 0.1 LINK pour la requête VRF
            "Pas assez de LINK pour utiliser Chainlink VRF"
        );

        // Demande un nombre aléatoire à Chainlink
        requestId = requestRandomness(keyHash, fee); // Frais Chainlink en LINK
        dernierTirage = block.timestamp;
    }

    function fulfillRandomness(
        bytes32 requestId,
        uint256 randomness
    ) internal override {
        uint256 indexGagnant = randomness % participants.length;
        gagnant = participants[indexGagnant];
        payable(gagnant).transfer(address(this).balance);
        delete participants;
    }

    function recupererParticipants() public view returns (address[] memory) {
        return participants;
    }

    function recupererGagnant() public view returns (address) {
        return gagnant;
    }

    receive() external payable {}
}
