// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "@forge-std/Script.sol";

import {BagelToken} from "../src/BagelToken.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DeployMerkleAirdrop is Script {
    bytes32 private s_merkleRoot = 0xa58a42519e6d2f83c936953136cde4042cb7abeafec3b085d0c2e5091d1522e3;
    uint256 private s_amountToTransfer = 4 * 25e18;
    BagelToken token;
    MerkleAirdrop airdrop;

    function run() external returns (MerkleAirdrop, BagelToken) {
        return deployMerkleAirdrop();
    }

    function deployMerkleAirdrop() internal returns (MerkleAirdrop, BagelToken) {
        vm.startBroadcast();
        token = new BagelToken();
        airdrop = new MerkleAirdrop(s_merkleRoot, IERC20(address(token)));
        token.mint(token.owner(), s_amountToTransfer);
        token.transfer(address(airdrop), s_amountToTransfer);
        vm.stopBroadcast();
        return (airdrop, token);
    }
}
