// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// Deployed at 0x3e9C748E9DBB864Ee4dE65FA16343Cde878DF7D0

contract OrganisationToken is ERC20 {
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {}

    function mint(address to, uint256 amount) public {
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
    //Make it public or getFunction
    mapping(address => mapping(UserRole => stakeHolder[])) Holders;

    event addedStakeHolder(
        address organisationAddress,
        UserRole userRole,
        address stakeHolderAddress,
        uint timeLock,
        uint tokens
    );
    event OrganisationListed(
        string tokenName,
        string tokenSymbol,
        address contractAddress,
        address admin
    );

    event Whitelist(UserRole userRole, address organisationAddress);

    event Minted(address receiver, uint tokensMinted);

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
        emit OrganisationListed(
            _tokenName,
            _tokenSymbol,
            _contractAddress,
            msg.sender
        );
    }

    function getOrganisations() public view returns (Organisation[] memory) {
        return organisations;
    }

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

        Holders[_organisationAddress][_userRole].push(
            stakeHolder(
                _userRole,
                _stakeHolderAddress,
                _timeLock,
                _tokens,
                false
            )
        );
        emit addedStakeHolder(
            _organisationAddress,
            _userRole,
            _stakeHolderAddress,
            _timeLock,
            _tokens
        );
    }

    function getHolders(
        address _organisationAddress,
        UserRole _userRole
    ) public view returns (stakeHolder[] memory) {
        return Holders[_organisationAddress][_userRole];
    }

    function whitelist(
        UserRole _userRole,
        address _organisationAddress
    ) public {
        require(
            msg.sender == organisationAddress[_organisationAddress].admin,
            "Only admins can Whitelist Stakeholders"
        );
        stakeHolder[] storage roleHolders = Holders[_organisationAddress][
            _userRole
        ];
        for (uint i = 0; i < roleHolders.length; i++) {
            roleHolders[i].isWhiteListed = true;
        }
        emit Whitelist(_userRole, _organisationAddress);
    }

    function getWhiteList(
        address _organisationAddress
    ) public view returns (stakeHolder[] memory) {
        if (
            Holders[_organisationAddress][UserRole.Founder].length > 0 &&
            (Holders[_organisationAddress][UserRole.Founder])[0].isWhiteListed
        ) {
            return Holders[_organisationAddress][UserRole.Founder];
        } else if (
            Holders[_organisationAddress][UserRole.Advisor].length > 0 &&
            (Holders[_organisationAddress][UserRole.Advisor])[0].isWhiteListed
        ) {
            return Holders[_organisationAddress][UserRole.Advisor];
        } else if (
            Holders[_organisationAddress][UserRole.Investor].length > 0 &&
            (Holders[_organisationAddress][UserRole.Investor])[0].isWhiteListed
        ) {
            return Holders[_organisationAddress][UserRole.Investor];
        } else revert("Not Found the Account");
    }

    function mintTokens(
        address _organisationAddress,
        UserRole _userRole,
        address _stakeHolderAddress,
        uint _tokens
    ) public {
        require(
            msg.sender == _stakeHolderAddress,
            "Only Owner of Tokens can Mint Tokens"
        );
        stakeHolder[] storage stakeHolders = Holders[_organisationAddress][
            _userRole
        ];
        OrganisationToken tokenContract = OrganisationToken(
            _organisationAddress
        );
        for (uint i = 0; i < stakeHolders.length; i++) {
            if (stakeHolders[i].stakeHolderAddress == _stakeHolderAddress) {
                require(stakeHolders[i].tokens >= _tokens, "Not Enough Tokens");
                require(
                    stakeHolders[i].timeLock < block.timestamp,
                    "Tokens are time Locked"
                );
                stakeHolders[i].tokens -= _tokens;
                tokenContract.mint(_stakeHolderAddress, _tokens);
                emit Minted(_stakeHolderAddress, _tokens);
            }
        }
    }
}
