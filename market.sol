// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import "project/land registry.sol"; // Import the Asset contract

contract PropertyMarketplace {
    Asset private assetContract;
    mapping(address => uint256) private balances;

    constructor(address _assetContractAddress) {
        assetContract = Asset(_assetContractAddress);
    }

    // Modifier to ensure only verified users can buy properties
    modifier onlyVerifiedUser() {
        require(assetContract.verifiedUsers(msg.sender), "You must be a verified user");
        _;
    }

    // Function to check the balance of the caller in wei
    function getBalance() external view returns (uint256) {
        return balances[msg.sender] / 10**18;
    }

    // Function to allow a verified user to buy a property
    function buyProperty(uint256 _propId) external onlyVerifiedUser payable {
        // The buyProperty function remains the same as before
        require(assetContract.getPropertySaleStatus(_propId) == Asset.Sale.Selling, "Property is not for sale");

        address currentOwner = assetContract.getPropertyCurrentOwner(_propId);
        uint256 propertyValue = assetContract.getPropertyValue(_propId);

        // Check if the buyer has enough balance to buy the property
        require(balances[msg.sender] >= propertyValue, "Insufficient balance to buy the property");

        uint256 pay = propertyValue;
        require(pay > 0, "No balance to withdraw");

        // Set the user's balance to zero before transferring Ether
        balances[msg.sender] -= propertyValue;

        (bool sent, ) = currentOwner.call{value: pay}("");
        require(sent, "Failed to send Ether");

        // Transfer ownership of the property to the buyer
        assetContract.OwnerChange(_propId, msg.sender);

        // Set the property sale status to noSale after the property is bought
        assetContract.setPropertySaleStatus(_propId, Asset.Sale.noSale);
    }


    // Function to allow external users to deposit Ether to their balance in the contract
    function deposit() public payable {
        require(msg.value > 0, "You must send Ether to deposit");
        balances[msg.sender] += msg.value;
    }

    // Receive function to accept Ether and deposit it to the user's balance
    receive() external payable {
        deposit();
    }

    // Function to allow users to withdraw their deposited Ether back to their wallet
    function withdraw() external {
        uint256 balance = balances[msg.sender];
        require(balance > 0, "No balance to withdraw");

        balances[msg.sender] = 0; // Set the user's balance to zero before transferring Ether
        (bool sent,) = msg.sender.call{value: balance}("");
        require(sent, "Failed to send Ether");
    }

        // Public getter function for the property details
    function getPropertyDetails(uint256 _propId) external view returns (
        string memory status,
        string memory sale,
        uint256 value,
        address currOwner,
        string memory location,
        uint256 landSize
    )
    {
        return assetContract.getPropertyDetails(_propId);
    }
}
