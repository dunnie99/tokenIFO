// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract launchPadIFO {
    
    event createdPad(
        string indexed tokenName,
        uint indexed duration,
        uint indexed totalSupply
    );
    event launched(
        address moderator,
        uint256 indexed _padId,
        string indexed _tokenName
    );
    event stakeSuccessful(
        uint256 indexed _amount,
        uint256 indexed _padId,
        string indexed _tokenName
    );
    event Received(address, uint);

    struct Pad {
        uint256 IDs;
        string tokenName;
        address padOwner;
        IERC20 padToken;
        uint duration;
        uint totalSupply;
        bool startPad;
    }

    address moderator;
    mapping(uint256 => bool) idUsed;
    mapping(string => Pad) tokenPadNames;
    mapping(uint256 => Pad) internal padIds;
    mapping(address => bool) tokenAlreadyLaunched;
    mapping(address => mapping(uint256 => uint256)) amountBought;

    uint256[] public padIDs;

    string[] public pads;

    constructor() {
        moderator = msg.sender;
    }

    function createPad(
        uint256 _padId,
        string memory _tokenName,
        address _padToken,
        uint _totalSupply
    ) public {
        require(_padToken != address(0), "can't be address zero");
        require(idUsed[_padId] == false, "ID already exists");
        require(tokenAlreadyLaunched[_padToken] == false, "Pad exists already");

        idUsed[_padId] = true;
        tokenAlreadyLaunched[_padToken] == true;
        pads.push(_tokenName);

        IERC20(_padToken).transferFrom(msg.sender, address(this), _totalSupply);
        uint256 period = block.timestamp + 7200;

        Pad memory newPad = Pad({
            IDs: _padId,
            tokenName: _tokenName,
            padOwner: msg.sender,
            padToken: IERC20(_padToken),
            duration: period,
            totalSupply: _totalSupply,
            startPad: false
        });

        tokenPadNames[_tokenName] = newPad;

        emit createdPad(_tokenName, period, _totalSupply);
    }

    function launchPad(uint256 _padId, string memory _tokenName) public {
        require(msg.sender == moderator, "Access denied");
        require(idUsed[_padId], "Pad does not exist");
        Pad storage pad = padIds[_padId];
        require(pad.startPad == false, "Pad already launched");
        bytes32 padNameInput = keccak256(abi.encodePacked(_tokenName));
        bytes32 padName = keccak256(abi.encodePacked(pad.tokenName));
        require(padName == padNameInput, "Invalid token name");

        pad.startPad = true;
        emit launched(moderator, _padId, _tokenName);
    }

    function stakeOnPad_(
        uint256 _amount,
        uint256 _padId,
        string memory _tokenName
    ) public payable returns (bool) {
        require(idUsed[_padId], "Pad does not exist");
        require(_amount == msg.value, "Amount must be equal");

        Pad storage pad = padIds[_padId];
        require(pad.startPad == true, "Pad not available");
        bytes32 padNameInput = keccak256(abi.encodePacked(_tokenName));
        bytes32 padName = keccak256(abi.encodePacked(pad.tokenName));
        require(padName == padNameInput, "Invalid token name");
        amountBought[msg.sender][_padId] = _amount;

        emit stakeSuccessful(_amount, _padId, _tokenName);
    }

    fallback() external payable {}

    receive() external payable {
        emit Received(msg.sender, msg.value);
    }
}
