pragma circom 2.0.0;

include "../node_modules/circomlib/circuits/poseidon.circom";
include "../node_modules/circomlib/circuits/mux1.circom";

template PoseidonHash() {
    var n = 2;
    signal input inputs[n];
    signal output out;

    component hash = Poseidon(n);
    for (var i = 0; i < n; i ++) {
        hash.inputs[i] <== inputs[i];
    }
    out <== hash.out;
}

template Hasher() {
    var length = 2;
    signal input in[length];
    signal output hash;

    component hasher = PoseidonHash();

    for (var i = 0; i < length; i++) {
        hasher.inputs[i] <== in[i];
    }

    hash <== hasher.out;
}

template HashLeftRight() {
    signal input left;
    signal input right;

    signal output hash;

    component hasher = PoseidonHash();
    left ==> hasher.inputs[0];
    right ==> hasher.inputs[1];

    hash <== hasher.out;
}

template CheckRoot(n) { // compute the root of a MerkleTree of n Levels 
    signal input leaves[2**n];
    signal output root;

    //[assignment] insert your code here to calculate the Merkle root from 2^n leaves
    var nLeafHashers = 2 ** (n - 1);

    var i;
    var j;

    // The total number of hashers
    var nHashers = 0;
    for (i = 0; i < n; i ++) {
        nHashers += 2 ** i;
    }

    component hashers[nHashers];

    for (i = 0; i < nHashers; i++) {
        hashers[i] = Hasher();
    }

    for (i = 0; i < nLeafHashers; i++){
        for (j = 0; j < 2; j++){
            hashers[i].in[j] <== leaves[i * 2 + j];
        }
    }

    var k = 0;
    for (i = nLeafHashers; i < nHashers; i++) {
        for (j = 0; j < 2; j ++){
            hashers[i].in[j] <== hashers[k * 2 + j].hash;
        }
        k ++;
    }

    root <== hashers[nHashers-1].hash;

}

template MerkleTreeInclusionProof(n) {
    signal input leaf;
    signal input path_elements[n];
    signal input path_index[n]; // path index are 0's and 1's indicating whether the current element is on the left or right
    signal output root; // note that this is an OUTPUT signal

    //[assignment] insert your code here to compute the root from a leaf and elements along the path
    component hashers[n];
    component mux[n];

    signal nlevelHashes[n + 1];
    nlevelHashes[0] <== leaf;

    for (var i = 0; i < n; i++) {
        path_index[i] * (1 - path_index[i]) === 0;

        hashers[i] = HashLeftRight();
        mux[i] = MultiMux1(2);

        mux[i].c[0][0] <== nlevelHashes[i];
        mux[i].c[0][1] <== path_elements[i];

        mux[i].c[1][0] <== path_elements[i];
        mux[i].c[1][1] <== nlevelHashes[i];

        mux[i].s <== path_index[i];
        hashers[i].left <== mux[i].out[0];
        hashers[i].right <== mux[i].out[1];

        nlevelHashes[i + 1] <== hashers[i].hash;
    }

    root <== nlevelHashes[n];
}