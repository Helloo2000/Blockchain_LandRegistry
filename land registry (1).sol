// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

/// @title Asset
/// @dev Store & retrieve value of a property

contract Asset {
    address public creatorAdmin;
    enum Status {NotExist, Pending, Approved, Rejected}
    enum Role {Visitor, User, Admin, SuperAdmin}
    enum Sale {Selling, noSale, onHold}

    // Struct to store all property related details
    struct PropertyDetail {
        Status _status;
        Sale _sale;
        uint256 _value;
        address _currOwner;
        uint256 _propId;
        uint256 _landSize;
        string _location;
        uint256 _taxValue;
    }

    mapping(uint256 => PropertyDetail) public properties; // Stores all properties propId -> property Detail
    mapping(uint256 => address) public propOwnerChange; // Keeps track of property owner propId -> Owner Address
    mapping(address => Role) public userRoles; // Keeps track of user roles
    mapping(address => bool) public verifiedUsers; // Keeps track of verified user, userId -> verified (true / false)
    mapping(Status => string) private statusToString;
    mapping(Sale => string) private saleToString;

    // Initialize the mappings in the constructor
    constructor() {
        statusToString[Status.NotExist] = "NotExist";
        statusToString[Status.Pending] = "Pending";
        statusToString[Status.Approved] = "Approved";
        statusToString[Status.Rejected] = "Rejected";

        saleToString[Sale.Selling] = "Selling";
        saleToString[Sale.noSale] = "noSale";
        saleToString[Sale.onHold] = "onHold";

        creatorAdmin = msg.sender;
        userRoles[creatorAdmin] = Role.SuperAdmin;
        verifiedUsers[creatorAdmin] = true;
    }

    // Helper function to convert Status enum to string
    function getStatusString(Status status) private view returns (string memory) {
        return statusToString[status];
    }

    // Helper function to convert Sale enum to string
    function getSaleString(Sale sale) private view returns (string memory) {
        return saleToString[sale];
    }

    // Modifier to ensure only the property owner access
    // a specific property
    modifier onlyOwner(uint256 _propId) {
        require(properties[_propId]._currOwner == msg.sender);
        _;
    }

    // Modifier to ensure only the verified user access
    // a specific property
    modifier verifiedUser(address _user) {
        require(verifiedUsers[_user]);
        _;
    }

    // Modifier to ensure only the verified admin access a function
    modifier verifiedAdmin() {
        require(
            userRoles[msg.sender] >= Role.Admin && verifiedUsers[msg.sender]
        );
        _;
    }

    

    // Modifier to ensure only the verified super admin admin access a function
    modifier verifiedSuperAdmin() {
        require(
            userRoles[msg.sender] == Role.SuperAdmin &&
                verifiedUsers[msg.sender]
        );
        _;
    }

    /// @dev Function to create property
    /// @param _propId Identifier for property
    /// @param _value Property Price
    /// @param _Currowner Owns the address property
    function createProperty(
    uint256 _propId,
    uint256 _value,
    address _Currowner,
    uint256 _landSize,
    uint256 _taxValue,
    string memory _location
    ) external verifiedAdmin verifiedUser(msg.sender) returns (bool) {
    require(properties[_propId]._status == Status.NotExist, "Property with this ID already exists");

    properties[_propId] = PropertyDetail(Status.Pending, Sale.noSale, _value*10**18, _Currowner, _propId, _landSize, _location, _taxValue);
    return true;
    }

    /// @dev Approve property
    /// @param _propId Identifier for property
    function approveProperty(uint256 _propId)
        external
        verifiedSuperAdmin
        returns (bool)
        {
        require(properties[_propId]._currOwner != msg.sender);
        require(properties[_propId]._status == Status.Pending, "ID doen not exist or already approved!");
        properties[_propId]._status = Status.Approved;
        return true;
        }

    // Public getter function for the _sale field
    function getPropertySaleStatus(uint256 _propId) external view returns (Asset.Sale) {
        return properties[_propId]._sale;
    }

    /// @dev Function to reject property
    /// @param _propId Identifier for property
    function rejectProperty(uint256 _propId)
        external
        verifiedSuperAdmin
        returns (bool)
    {
        require(properties[_propId]._currOwner != msg.sender);
        require(properties[_propId]._status == Status.Pending, "ID doen not exist or already rejected!");
        properties[_propId]._status = Status.Rejected;
        return true;
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
    status = getStatusString(properties[_propId]._status);
    sale = getSaleString(properties[_propId]._sale);
    value = properties[_propId]._value / 10**18;
    currOwner = properties[_propId]._currOwner;
    location = properties[_propId]._location;
    landSize = properties[_propId]._landSize;
    }



    /// @dev Function to add a new user
    /// @param _newUser new user address
    function addNewUser(address _newUser)
        external
        verifiedAdmin
        returns (bool)
    {
        require(userRoles[_newUser] == Role.Visitor);
        require(verifiedUsers[_newUser] == false);
        userRoles[_newUser] = Role.User;
        return true;
    }

    /// @dev Function to add a new admin
    /// @param _newAdmin new admin user address
    function addNewAdmin(address _newAdmin)
        external
        verifiedSuperAdmin
        returns (bool)
    {
        require(userRoles[_newAdmin] == Role.Visitor);
        require(verifiedUsers[_newAdmin] == false);
        userRoles[_newAdmin] = Role.Admin;
        return true;
    }

    /// @dev Function to add a new admin
    /// @param _newSuperAdmin new super admin user address
    function addNewSuperAdmin(address _newSuperAdmin)
        external
        verifiedSuperAdmin
        returns (bool)
    {
        require(userRoles[_newSuperAdmin] == Role.Visitor);
        require(verifiedUsers[_newSuperAdmin] == false);
        userRoles[_newSuperAdmin] = Role.SuperAdmin;
        return true;
    }

    // Function to get the value of a property
    function getPropertyValue(uint256 _propId) external view returns (uint256) {
        return properties[_propId]._value;
    }

    // Getter function for the current owner of a property
    function getPropertyCurrentOwner(uint256 _propId) external view returns (address) {
        return properties[_propId]._currOwner;
    }

    /// @dev Function to add a new admin
    /// @param _newUser user address to approve
    function approveUsers(address _newUser)
        external
        verifiedSuperAdmin
        returns (bool)
    {
        require(userRoles[_newUser] != Role.Visitor);
        require(verifiedUsers[_newUser] == false);
        verifiedUsers[_newUser] = true;
        return true;
    }

    // Function to change the owner of a property
    function OwnerChange(uint256 _propId, address _newOwner) external {
        properties[_propId]._currOwner = _newOwner;
    }

    // Getter function for the status of a property
    function getPropertyStatus(uint256 _propId) external view returns (Status) {
        return properties[_propId]._status;
    }

    // Setter function for the property value
    function setPropertyValue(uint256 _propId, uint256 _value) external {
        properties[_propId]._value = _value;
    }

    // Setter function for the property sale status
    function setPropertySaleStatus(uint256 _propId, Sale _sale) external {
        properties[_propId]._sale = _sale;
    }
    

}