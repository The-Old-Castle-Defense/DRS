// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


interface IReferral {
    function setReferral(address _user, address _referrer) external;
    function getReferral(address _user) external view returns (address);
}


contract ETHLisbonTickets is ReentrancyGuard {
    uint256 private constant PERCENT_DENOMINATOR = 10000; // 100% in basis points
    uint256 public referralFee = 1000; // 10% referral fee in basis points
    IReferral public referralContract;
    address public owner = msg.sender;
    address public bankAddress;
    address public currency; // USDT currency interface

    // 1 TICKET = 10 USDT or equivalent ETH
    uint256 public ticketPrice = 10 * 1e18; // Assuming that currency is USDT and it has 18 decimals

    event BuyTicket(address indexed user, uint32 count, uint256 amount, uint256 referralFee, address referrer);

    constructor(
        address _referralContract,
        address _bankAddress,
        address _currency
    ) {
        bankAddress = _bankAddress;
        referralContract = IReferral(_referralContract);
        currency = _currency;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only Owner can call this function");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "New owner cannot be the zero address");
        owner = newOwner;
    }

    function getAmount(uint _amount) private view returns (uint) {
        uint amount;
        if (currency == address(0)) {
            amount = msg.value;
        } else {
            amount = _amount;
        }
        return amount;
    }

    function buyTicket(uint32 count, uint256 amount) public {

        amount = getAmount(amount);
        require(count > 0, "Incorrect amount.");
        uint _req_amount = count * ticketPrice;
        require(amount == _req_amount, "Incorrect amount.");


        uint refFee = (amount * referralFee) / 10000;
        uint bankAmount = amount - refFee;

        address refAddress = referralContract.getReferral(msg.sender);
        if (refAddress == address(0)) {refAddress = bankAddress;}

        if (currency == address(0)) {
            // Referral Fee
            (bool success1, ) = payable(refAddress).call{value: refFee}("");
            // Bank Amount
            (bool success2, ) = payable(address(this)).call{value: bankAmount}("");
            require(success1 && success2, "Transfer Failed");
        } else {
            require(IERC20(currency).allowance(msg.sender, address(this)) >= amount,"Tokens not approved");
            // Referral Fee
            require(IERC20(currency).transferFrom(msg.sender, address(this), amount), "Token transfer to contract failed");
            // Transfer referral fee to referrer
            require(IERC20(currency).transfer(refAddress, refFee), "Token transfer to referrer failed");
            // Transfer bank amount to bank address
            require(IERC20(currency).transfer(bankAddress, bankAmount), "Token transfer to bank failed");
        }

        emit BuyTicket(msg.sender, count, amount, refFee, refAddress);
    }    


    function emergencyWithdrawal(address asset, uint amount) external onlyOwner {
        // Transfer the specified amount of the asset to the owner
        if (asset == address(0)) {
            // For Ether (ETH)
            payable(owner).transfer(amount);
        } else {
            // For ERC20 tokens
            require(
                IERC20(asset).transfer(owner, amount),
                "Token transfer failed"
            );
        }
    }

}

