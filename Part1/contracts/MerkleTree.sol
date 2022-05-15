//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import { PoseidonT3 } from "./Poseidon.sol"; //an existing library to perform Poseidon hash on solidity
import "./verifier.sol"; //inherits with the MerkleTreeInclusionProof verifier contract

contract MerkleTree is Verifier {
    uint256[] public hashes; // the Merkle tree in flattened array form
    uint256 public index = 0; // the current index of the first unfilled leaf
    uint256 public root; // the current Merkle root

    uint256[] public nodes1;
    uint256[] public nodes2;
    uint256[] public nodes3;
    
    constructor() {
        // [assignment] initialize a Merkle tree of 8 with blank leaves
        for (uint256 i=0; i < 14; i++){
            hashes.push(0);
        }
    }

    function insertLeaf(uint256 hashedLeaf) public returns (uint256) {
        // [assignment] insert a hashed leaf into the Merkle tree
        hashes[index] = hashedLeaf;
        for (uint256 i = 0; i < 7; i++) {
            nodes1.push( PoseidonT3.poseidon([hashes[i*2], hashes[i*2+1]]));
        }
// nodes1 is seven. Add 1 node.
        nodes1.push(nodes1[6]);
        for (uint i = 0; i < 4; i++) {
            nodes2.push( PoseidonT3.poseidon([nodes1[i*2], nodes1[i*2+1]]));
        }

// nodes2 is four
        for (uint i = 0; i < 2; i++) {
            nodes3.push( PoseidonT3.poseidon([nodes1[i*2], nodes1[i*2+1]]));
        }

        index++;
        root = PoseidonT3.poseidon([nodes3[0], nodes3[1]]);
        return root;
    }

    function verify(
            uint[2] memory a,
            uint[2][2] memory b,
            uint[2] memory c,
            uint[1] memory input
        ) public view returns (bool) {

        // [assignment] verify an inclusion proof and check that the proof root matches current root
        return Verifier.verifyProof(a, b, c, input);
    }
}
