// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// Uncomment this line to use console.log
import "hardhat/console.sol";


import "@openzeppelin/contracts/access/Ownable.sol";


contract OrganisationToken is ERC20, Ownable {
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {}

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}


contract Vesting {
    struct stakeHolder {
        string role;
        address stakeHolderAddress;
        uint timeLock;
        uint tokens;
    }
    struct Organisation {
        string tokenName;
        string tokenSymbol;
        address contractAddress;
        address admin;
    }
    mapping (address => Organisation) organisationAddress;
    mapping (address => stakeHolder[]) stakeHolders;
    event addedStakeHolder(address organisationAddress ,  string  role, address stakeHolderAddress ,uint timeLock ,uint tokens);


    Organisation[] organisations;
    address megaAdmin;

    constructor() {
        megaAdmin = msg.sender;
    }

    function registerOrganisation(
        string memory _tokenName,
        string memory _tokenSymbol
    ) public {
        address _contractAddress = address(new OrganisationToken(_tokenName, _tokenSymbol));
        Organisation memory organisation = Organisation({
            tokenName: _tokenName,
            tokenSymbol: _tokenSymbol,
            contractAddress: _contractAddress,
            admin: msg.sender
        });
        organisations.push(organisation);
        organisationAddress[_contractAddress] = organisation;
    }

    function getOrganisations() public view  returns (Organisation[] memory) {
        return organisations;
    }
    function addStakeHolders(address _organisationAddress ,  string memory _role, address _stakeHolderAddress ,uint _timeLock ,uint _tokens) public {

        require(msg.sender == organisationAddress[_organisationAddress].admin, "Only admins can add Stakeholders");
        OrganisationToken tokenContract = OrganisationToken(_organisationAddress);
        tokenContract.mint(_stakeHolderAddress , _tokens );
        stakeHolders[_organisationAddress].push(stakeHolder(_role , _stakeHolderAddress , _timeLock ,_tokens ));
        emit addedStakeHolder(_organisationAddress ,  _role,  _stakeHolderAddress ,_timeLock , _tokens);
    }
    
    function getStakeHolders(address _organisationAddress) public view returns (stakeHolder[] memory){
        return stakeHolders[_organisationAddress];
    }
}

