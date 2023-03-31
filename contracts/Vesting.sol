// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract OrganisationToken is ERC20, Ownable {
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {}

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}

contract Vesting {
    struct stakeHolder {
        UserRole userType;
        address stakeHolderAddress;
        uint timeLock;
        uint tokens;
        bool isWhiteListed;
    }

    struct Organisation {
        string tokenName;
        string tokenSymbol;
        address contractAddress;
        address admin;
    }
    enum UserRole {
        Founder,
        Investor,
        Advisor
    }

    mapping(address => Organisation) organisationAddress;
    mapping(address => mapping (UserRole => stakeHolder[] )) Holders;

    event addedStakeHolder(
        address organisationAddress,
        UserRole userRole,
        address stakeHolderAddress,
        uint timeLock,
        uint tokens
    );

    Organisation[] organisations;
    address megaAdmin;

    constructor() {
        megaAdmin = msg.sender;
    }

    function registerOrganisation(
        string memory _tokenName,
        string memory _tokenSymbol
    ) public {
        address _contractAddress = address(
            new OrganisationToken(_tokenName, _tokenSymbol)
        );
        Organisation memory organisation = Organisation({
            tokenName: _tokenName,
            tokenSymbol: _tokenSymbol,
            contractAddress: _contractAddress,
            admin: msg.sender
        });
        organisations.push(organisation);
        organisationAddress[_contractAddress] = organisation;
    }

    function getOrganisations() public view returns (Organisation[] memory) {
        return organisations;
    }
    // UserRole userType;
        address stakeHolderAddress;
        uint timeLock;
        uint tokens;
        bool isWhiteListed;

    function addStakeHolders(
        UserRole _userRole,
        address _stakeHolderAddress,
        uint _timeLock,
        uint _tokens,
        address _organisationAddress
    ) public {
        require(
            msg.sender == organisationAddress[_organisationAddress].admin,
            "Only admins can add Stakeholders"
        );
        
        Holders[_organisationAddress][_userRole].push(stakeHolder(_userRole, _stakeHolderAddress, _timeLock, _tokens, false));
        emit addedStakeHolder(
            _organisationAddress,
            _userRole,
            _stakeHolderAddress,
            _timeLock,
            _tokens
        );
    }

    function getHolders(
        address _organisationAddress ,
        UserRole _userRole

    ) public view returns (stakeHolder[] memory) {
        return Holders[_organisationAddress][_userRole] ;
    }

    function whitelist(
        UserRole _userRole,
        address _organisationAddress
    ) public {
        require(
            msg.sender == organisationAddress[_organisationAddress].admin,
            "Only admins can Whitelist Stakeholders"
        );
        stakeHolder[] storage roleHolders = Holders[_organisationAddress][_userRole];
        for (uint i = 0; i < roleHolders.length; i++) {
            roleHolders[i].isWhiteListed = true;
        }
    }

    function mintTokens(address _organisationAddress , address _stakeHolderAddress , uint _tokens) public{
        OrganisationToken tokenContract = OrganisationToken(_organisationAddress);
        tokenContract.mint(_stakeHolderAddress , _tokens );
    }
}
