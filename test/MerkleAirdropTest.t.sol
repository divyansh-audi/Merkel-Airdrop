// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "@forge-std/Test.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {BagelToken} from "../src/BagelToken.sol";
import {ZkSyncChainChecker} from "lib/foundry-devops/src/ZkSyncChainChecker.sol";
import {DeployMerkleAirdrop} from "../script/DeployMerkleAirdrop.s.sol";

contract MerkleAirdropTest is ZkSyncChainChecker, Test {
    MerkleAirdrop public airdrop;
    BagelToken public token;
    DeployMerkleAirdrop public deployer;

    bytes32 public ROOT = 0xa58a42519e6d2f83c936953136cde4042cb7abeafec3b085d0c2e5091d1522e3;
    uint256 AMOUNT = 25 ether;
    uint256 AMOUNT_TO_SEND = AMOUNT * 4;
    bytes32 proofOne = 0xae41e39d8f898c53893153e478b0f6f97cb5819b0b78c617e539f93edd568f78;
    bytes32 proofTwo = 0xea59ad30b75fa97ba56428aca6099b1b28a3a0db3bcaa9cc3caedf03bf2c31bf;
    bytes32[] public PROOF = [proofOne, proofTwo];
    address user;
    uint256 userPrivateKey;

    function setUp() public {
        if (!isZkSyncChain()) {
            //deploy with script
            deployer = new DeployMerkleAirdrop();
            (airdrop, token) = deployer.run();
        } else {
            token = new BagelToken();
            airdrop = new MerkleAirdrop(ROOT, token);
            token.mint(token.owner(), AMOUNT_TO_SEND);
            token.transfer(address(airdrop), AMOUNT_TO_SEND);
        }
        (user, userPrivateKey) = makeAddrAndKey("user");
    }

    function testUsersCanClaim() public {
        // console.log("user address is :", user);
        uint256 startingBalance = token.balanceOf(user);

        vm.prank(user);
        airdrop.claim(user, AMOUNT, PROOF);

        uint256 endingBalance = token.balanceOf(user);
        console.log("ending balance:", endingBalance);
        assertEq(endingBalance - startingBalance, AMOUNT);
    }
}
