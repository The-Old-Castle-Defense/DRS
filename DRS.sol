// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Referral {
    address public owner;
    // Mapping to store user referrals
    mapping(address => address) public referrals;
    

    // Event to log when a referral is set
    event SetReferral(address indexed user, address indexed referrer);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    constructor() {
        owner = msg.sender; 
    }

    // Function to set a user's referral
    function setReferral(address _referrer) public onlyOwner {
        // Check that the user doesn't already have a referral
        require(referrals[msg.sender] == address(0), "Referral already set");

        // Check that the referrer is a valid address
        require(_referrer != address(0), "Invalid referrer address");

        // Set the referral
        referrals[msg.sender] = _referrer;

        // Emit an event to log the referral set
        emit SetReferral(msg.sender, _referrer);
    }
    
    // Function to set a user's referral
    function setReferralOwner(address _user, address _referrer) public onlyOwner {
        // ONLY THE OLD CASTLE DEFENSE WITH ITS RESPONSIBILITY CAN CALL THIS METHOD. PROTECTED FROM OVERWRITING and SCAMMERS.
        // Check that the user doesn't already have a referral
        require(referrals[_user] == address(0), "Referral already set");

        // Check that the referrer is a valid address
        require(_referrer != address(0), "Invalid referrer address");

        // Set the referral
        referrals[_user] = _referrer;

        // Emit an event to log the referral set
        emit SetReferral(_user, _referrer);
    }

    // Function to get a user's referral
    function getReferral(address _user) public view returns (address) {
        return referrals[_user];
    }

    function setOwner(address _newOwner) public onlyOwner {
        owner = _newOwner;
    }

    function setReferralsOwner(address[] memory users, address[] memory referrers) public onlyOwner {
        // ONLY THE OLD CASTLE DEFENSE WITH ITS RESPONSIBILITY CAN CALL THIS METHOD. PROTECTED FROM OVERWRITING and SCAMMERS.
        require(users.length == referrers.length, "Incorrect Arrays");

        for (uint256 i = 0; i < users.length; i++) {
            address _user = users[i];
            address _referrer = referrers[i];

            require(referrals[_user] == address(0), "Referral already set");

            // Check if the referrer address is not zero (address(0))
            require(_referrer != address(0), "Referrer address cannot be zero");

            // Set the referral
            referrals[_user] = _referrer;

            // Emit an event to log the referral set
            emit SetReferral(_user, _referrer);
        }
    }
}

