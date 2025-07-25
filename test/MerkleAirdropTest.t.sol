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

    bytes32 public ROOT = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
    uint256 AMOUNT_TO_CLAIM = 25 ether;
    uint256 AMOUNT_TO_SEND = AMOUNT_TO_CLAIM * 4;
    bytes32 proofOne = 0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a;
    bytes32 proofTwo = 0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    bytes32[] public PROOF = [proofOne, proofTwo];
    address user;
    uint256 public userPrivateKey;
    address public gasPayer;

    function setUp() public {
        if (!isZkSyncChain()) {
            //deploy with script
            // vm.chainId(31337);
            // vm.chainId(1);
            DeployMerkleAirdrop deployer = new DeployMerkleAirdrop();
            (airdrop, token) = deployer.deployMerkleAirdrop();
        } else {
            token = new BagelToken();
            airdrop = new MerkleAirdrop(ROOT, token);
            token.mint(token.owner(), AMOUNT_TO_SEND);
            token.transfer(address(airdrop), AMOUNT_TO_SEND);
        }
        (user, userPrivateKey) = makeAddrAndKey("user");
        gasPayer = makeAddr("gasPayer");
        // vm.deal(gasPayer, 5 ether);
    }

    function testUsersCanClaim() public {
        // console.log("user address is :", user);
        // console.log("address of user:", user);
        // console.log("address of gasPayer:", gasPayer);

        uint256 startingBalance = token.balanceOf(user);
        console.log("User starting balance:", startingBalance);
        console.log("chainid..............:", block.chainid);
        bytes32 digest = airdrop.getMessageHash(user, AMOUNT_TO_CLAIM);
        console.log("digest:");
        console.logBytes32(digest);
        // sign a message
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(userPrivateKey, digest);
        console.log("chainid---------", block.chainid);

        // console.logBytes32(airdrop.DOMAIN_SEPARATOR());
        //gas Payer calls claims using the signed message to send the transaction for them and pay the gas
        vm.prank(gasPayer);
        airdrop.claim(user, AMOUNT_TO_CLAIM, PROOF, v, r, s);

        uint256 endingBalance = token.balanceOf(user);
        console.log("ending balance:", endingBalance);
        assertEq(endingBalance - startingBalance, AMOUNT_TO_CLAIM);
    }
    // MerkleAirdrop airdrop;
    // BagelToken token;
    // address gasPayer;
    // address user;
    // uint256 userPrivKey;

    // bytes32 merkleRoot = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
    // uint256 amountToCollect = (25 * 1e18); // 25.000000
    // uint256 amountToSend = amountToCollect * 4;

    // bytes32 proofOne = 0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a;
    // bytes32 proofTwo = 0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    // bytes32[] proof = [proofOne, proofTwo];

    // function setUp() public {
    //     if (!isZkSyncChain()) {
    //         // vm.chainId(31_337);
    //         // vm.chainId(1);
    //         DeployMerkleAirdrop deployer = new DeployMerkleAirdrop();
    //         (airdrop, token) = deployer.deployMerkleAirdrop();
    //     } else {
    //         token = new BagelToken();
    //         airdrop = new MerkleAirdrop(merkleRoot, token);
    //         token.mint(token.owner(), amountToSend);
    //         token.transfer(address(airdrop), amountToSend);
    //     }
    //     gasPayer = makeAddr("gasPayer");
    //     (user, userPrivKey) = makeAddrAndKey("user");
    // }

    // function signMessage(uint256 privKey, address account) public view returns (uint8 v, bytes32 r, bytes32 s) {
    //     console.log("chain id:", block.chainid);
    //     bytes32 hashedMessage = airdrop.getMessageHash(account, amountToCollect);
    //     (v, r, s) = vm.sign(privKey, hashedMessage);
    // }

    // function testUsersCanClaim() public {
    //     uint256 startingBalance = token.balanceOf(user);

    //     // get the signature
    //     vm.startPrank(user);
    //     (uint8 v, bytes32 r, bytes32 s) = signMessage(userPrivKey, user);
    //     vm.stopPrank();

    //     // gasPayer claims the airdrop for the user
    //     vm.prank(gasPayer);
    //     airdrop.claim(user, amountToCollect, proof, v, r, s);
    //     uint256 endingBalance = token.balanceOf(user);
    //     console.log("Ending balance: %d", endingBalance);
    //     assertEq(endingBalance - startingBalance, amountToCollect);
    // }
}
