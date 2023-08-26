// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import "project/land registry.sol"; // Import the Asset contract

contract manage {
        
    Asset private assetContract;

    constructor(address _assetContractAddress) {
        assetContract = Asset(_assetContractAddress);
    }


    function setPrice(uint256 _propId, uint256 _price) external {
        require(msg.sender == assetContract.getPropertyCurrentOwner(_propId));
        require(assetContract.getPropertyStatus(_propId) == Asset.Status.Approved, "Property is not approved for sale.");
        assetContract.setPropertyValue(_propId, _price * 10**18);
    }

    function setToSell(uint256 _propId) external {
        require(msg.sender == assetContract.getPropertyCurrentOwner(_propId));
        require(assetContract.getPropertyStatus(_propId) == Asset.Status.Approved, "Property is not approved for sale.");
        require(assetContract.getPropertySaleStatus(_propId) == Asset.Sale.noSale, "Property is already for sale.");

        assetContract.setPropertySaleStatus(_propId, Asset.Sale.Selling);
    }

    function setToNoSell(uint256 _propertyId) external {
        require(msg.sender == assetContract.getPropertyCurrentOwner(_propertyId));
        require(assetContract.getPropertySaleStatus(_propertyId) == Asset.Sale.Selling, "Property is already not for sale.");
        assetContract.setPropertySaleStatus(_propertyId, Asset.Sale.noSale);
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