// SPDX-License-Identifier: UNLICENSED
// ALL RIGHTS RESERVED

// Unicrypt by SDDTech reserves all rights on this code. You may NOT copy these contracts.


// This contract logs all tokens on the platform

pragma solidity 0.8.17;

import "./libraries/EnumerableSet.sol";
import "./libraries/Ownable.sol";


contract MintFactory is Ownable {
    using EnumerableSet for EnumerableSet.AddressSet;
    
    EnumerableSet.AddressSet private tokens;
    EnumerableSet.AddressSet private tokenGenerators;

    struct TaxHelper {
        string Name;
        address Address;
        uint256 Index;
    }

    mapping(uint => TaxHelper) public taxHelpersData;
    address[] public taxHelpers;
     
    mapping(address => address[]) private tokenOwners;

    address public FacetHelper;
    address public FeeHelper;
    address public LosslessController;

    event TokenRegistered(address tokenOwner, address tokenContract);
    event AllowTokenGenerator(address _address, bool _allow);

    event AddedTaxHelper(string _name, address _address, uint256 _index);
    event UpdatedTaxHelper(address _newAddress, uint256 _index);

    event UpdatedFacetHelper(address _newAddress);
    event UpdatedFeeHelper(address _newAddress);
    event UpdatedLosslessController(address _newAddress);
    
    function adminAllowTokenGenerator (address _address, bool _allow) public onlyOwner {
        if (_allow) {
            tokenGenerators.add(_address);
        } else {
            tokenGenerators.remove(_address);
        }
        emit AllowTokenGenerator(_address, _allow);
    }

    function addTaxHelper(string calldata _name, address _address) public onlyOwner {
        uint256 index = taxHelpers.length;
        TaxHelper memory newTaxHelper;
        newTaxHelper.Name = _name;
        newTaxHelper.Address = _address;
        newTaxHelper.Index = index;
        taxHelpersData[index] = newTaxHelper;
        taxHelpers.push(_address);
        emit AddedTaxHelper(_name, _address, index);
    }

    function updateTaxHelper(uint256 _index, address _address) public onlyOwner {
        taxHelpersData[_index].Address = _address;
        taxHelpers[_index] = _address;
        emit UpdatedTaxHelper(_address, _index);
    }

    function getTaxHelperAddress(uint256 _index) public view returns(address){
        return taxHelpers[_index];
    }

    function getTaxHelpersDataByIndex(uint256 _index) public view returns(TaxHelper memory) {
        return taxHelpersData[_index];
    }
    
    /**
     * @notice called by a registered tokenGenerator upon token creation
     */
    function registerToken (address _tokenOwner, address _tokenAddress) public {
        require(tokenGenerators.contains(msg.sender), 'FORBIDDEN');
        tokens.add(_tokenAddress);
        tokenOwners[_tokenOwner].push(_tokenAddress);
        emit TokenRegistered(_tokenOwner, _tokenAddress);
    }

     /**
     * @notice gets a token at index registered under a user address
     * @return token addresses registered to the user address
     */
     function getTokenByOwnerAtIndex(address _tokenOwner, uint256 _index) external view returns(address) {
         return tokenOwners[_tokenOwner][_index];
     }
     
     /**
     * @notice gets the total of tokens registered under a user address
     * @return uint total of token addresses registered to the user address
     */
     
     function getTokensLengthByOwner(address _tokenOwner) external view returns(uint256) {
         return tokenOwners[_tokenOwner].length;
     }
    
    /**
     * @notice Number of allowed tokenGenerators
     */
    function tokenGeneratorsLength() external view returns (uint256) {
        return tokenGenerators.length();
    }
    
    /**
     * @notice Gets the address of a registered tokenGenerator at specified index
     */
    function tokenGeneratorAtIndex(uint256 _index) external view returns (address) {
        return tokenGenerators.at(_index);
    }

    /**
     * @notice returns true if user is allowed to generate tokens
     */
    function tokenGeneratorIsAllowed(address _tokenGenerator) external view returns (bool) {
        return tokenGenerators.contains(_tokenGenerator);
    }
    
    /**
     * @notice returns true if the token address was generated by the Unicrypt token platform
     */
    function tokenIsRegistered(address _tokenAddress) external view returns (bool) {
        return tokens.contains(_tokenAddress);
    }
    
    /**
     * @notice The length of all tokens on the platform
     */
    function tokensLength() external view returns (uint256) {
        return tokens.length();
    }
    
    /**
     * @notice gets a token at a specific index. Although using Enumerable Set, since tokens are only added and not removed, indexes will never change
     * @return the address of the token contract at index
     */
    function tokenAtIndex(uint256 _index) external view returns (address) {
        return tokens.at(_index);
    }

    // Helpers and Controllers
    
    function getFacetHelper() public view returns (address) {
        return FacetHelper;
    }

    function updateFacetHelper(address _newFacetHelperAddress) public onlyOwner {
        require(_newFacetHelperAddress != address(0));
        FacetHelper = _newFacetHelperAddress;
        emit UpdatedFacetHelper(_newFacetHelperAddress);
    }

    function getFeeHelper() public view returns (address) {
        return FeeHelper;
    }

    function updateFeeHelper(address _newFeeHelperAddress) public onlyOwner {
        require(_newFeeHelperAddress != address(0));
        FeeHelper = _newFeeHelperAddress;
        emit UpdatedFeeHelper(_newFeeHelperAddress);
    }

    function getLosslessController() public view returns (address) {
        return LosslessController;
    }

    function updateLosslessController(address _newLosslessControllerAddress) public onlyOwner {
        require(_newLosslessControllerAddress != address(0));
        LosslessController = _newLosslessControllerAddress;
        emit UpdatedLosslessController(_newLosslessControllerAddress);
    }
}