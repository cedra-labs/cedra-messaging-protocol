module wormhole::keccak256 {
    use cedra_framework::cedra_hash;

    spec module {
        pragma verify=false;
    }

    public fun keccak256(bytes: vector<u8>): vector<u8> {
        cedra_hash::keccak256(bytes)
    }

    spec keccak256 {
        pragma opaque;
    }

}
