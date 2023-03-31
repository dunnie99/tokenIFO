// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;
import "../node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract launchPadIFO {
    
    event createdPad(
        string indexed tokenName,
        uint256 indexed padId,
        uint256 indexed tokenPerMinETH,
        uint256 amountToRaise
    );
    event launched(
        address moderator,
        uint256 indexed _padId,
        uint indexed duration,
        string indexed _tokenName
    );
    event stakeSuccessful(
        uint256 indexed _amount,
        uint256 indexed _padId,
        string indexed _tokenName
    );
    event claimedSuccessfully(
        address indexed receiver, 
        uint256 indexed claimAmount, 
        address indexed padToken
    );
    event Received(address, uint);

    struct Pad {
        uint256 padID;
        string tokenName;
        address padOwner;
        IERC20 padToken;
        uint totalSupply;
        uint duration;
        uint256 tokenPerMinETH;
        uint256 amountToRaise;
        bool startPad;
    }
    uint256 public minETH = 0.001 ether;

    address moderator;
    mapping(uint256 => bool) idUsed;
    mapping(uint256 => Pad) padIds;
    mapping(address => bool) launchPadExists;
    mapping(address => mapping(uint256 => uint256)) amountBought;

    uint256[] padIDs;

    constructor() {
        moderator = msg.sender;
    }

    function createPad(
        uint256 _padId,
        string memory _tokenName,
        address _padToken,
        uint256 _tokenPerMinETH,
        uint256 _amountEthToRaise,
        uint256 _totalSupply
    ) public {
        require(_padToken != address(0), "tokenContract can't be address zero");
        require(idUsed[_padId] == false, "ID already exists");
        require(launchPadExists[_padToken] == false, "Pad exists already");
        require(
            (((_tokenPerMinETH / minETH) * _amountEthToRaise) * 1e18 <= _totalSupply),
            "_total?Supply not enough for amountEthToRaise"
        );

        idUsed[_padId] = true;
        launchPadExists[_padToken] == true;
        padIDs.push(_padId);
        IERC20(_padToken).transferFrom(msg.sender, address(this), _totalSupply);

        Pad memory newPad = Pad({
            padID: _padId,
            tokenName: _tokenName,
            padOwner: msg.sender,
            padToken: IERC20(_padToken),
            duration: 0,
            totalSupply: _totalSupply,
            tokenPerMinETH: _tokenPerMinETH,
            amountToRaise: _amountEthToRaise,
            startPad: false
        });

        padIds[_padId] = newPad;

        emit createdPad(_tokenName, _padId, _tokenPerMinETH, _amountEthToRaise);
    }

    function launchPad(uint256 _padId, string memory _tokenName) public {
        require(msg.sender == moderator, "Access denied");
        require(idUsed[_padId], "Pad does not exist");
        Pad storage pad = padIds[_padId];
        require(pad.startPad == false, "Pad already launched");
        bytes32 padNameInput = keccak256(abi.encodePacked(_tokenName));
        bytes32 padName = keccak256(abi.encodePacked(pad.tokenName));
        require(padName == padNameInput, "Invalid token name");
        uint256 period = block.timestamp + 7200;
        pad.startPad = true;
        pad.duration = period;
        emit launched(moderator, period, _padId, _tokenName);
    }

    function stakeOnPad(
        uint256 _padId,
        string memory _tokenName
    ) external payable {
        stakeOnPad_(_padId, _tokenName);
    }

    function stakeOnPad_(
        uint256 _padId,
        string memory _tokenName
    ) internal returns (bool) {
        Pad storage pad = padIds[_padId];
        require(pad.startPad == true, "Pad is not launched");
        require(block.timestamp < pad.duration, "LaunchPad Ended");
        require(msg.value >= minETH, "Insufficient Ethers");
        require(idUsed[_padId], "Pad does not exist");
        require(pad.startPad == true, "Pad not available");

        uint256 _amount = msg.value;
        bytes32 padNameInput = keccak256(abi.encodePacked(_tokenName));
        bytes32 padName = keccak256(abi.encodePacked(pad.tokenName));
        require(padName == padNameInput, "Invalid token name");
        amountBought[msg.sender][_padId] = _amount;

        emit stakeSuccessful(_amount, _padId, _tokenName);

        bool success = true;
        return success;
    }

    function claimLaunchPad(uint _padId, string memory _tokenName) public {
        require(idUsed[_padId], "Pad doesn't exist");
        Pad storage pad = padIds[_padId];
        bytes32 padNameInput = keccak256(abi.encodePacked(_tokenName));
        bytes32 padName = keccak256(abi.encodePacked(pad.tokenName));
        require(padName == padNameInput, "Incorrect token name");
        if (block.timestamp >= pad.duration) {
            pad.startPad = false;
            launchPadExists[address(pad.padToken)] == false;
        } else {
            revert("Launchpad duration not over");
        }
        uint256 _amountToClaim = amountBought[msg.sender][_padId];
        if (_amountToClaim == 0) revert("User did not stake on Launchpad");
        uint256 claimAmount = ((_amountToClaim / minETH) * pad.tokenPerMinETH) * 1e18;
        bool transferSuccessful = (pad.padToken).transfer(
            msg.sender,
            claimAmount
        );
        require(transferSuccessful, "transfer failed");
        // if (transferSuccessful == false) revert("claimAmount transfer failed");
        amountBought[msg.sender][_padId] = 0;
        pad.totalSupply -= claimAmount;

        emit claimedSuccessfully(msg.sender, claimAmount, address(pad.padToken));
    }

    function increasePadDuration(uint256 _padId, uint256 _timeInSeconds) public returns (bool timeAdded){
        require(msg.sender == moderator, "Access denied");
        Pad storage pad = padIds[_padId];
        pad.duration += _timeInSeconds;
        timeAdded = true;
        return timeAdded;
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getTokenBalance(address _tokenContract) public view returns (uint256) {
            return IERC20(_tokenContract).balanceOf(address(this));
    }

    function transferTokenBal(address _tokenContract, address _to, uint256 _amount) public returns (bool success) {
        require(msg.sender == moderator, "Access denied");
        require(IERC20(_tokenContract).balanceOf(address(this)) >= _amount * 1e18, "Insufficient balance");
        IERC20(_tokenContract).transfer(_to, _amount);
        success = true;
        return success;
    }

    function withdraw(address _to, uint256 _amount) external returns(bool success) {
        require(msg.sender == moderator, "Access denied");
        require(address(this).balance >= _amount, "Insufficient balance");
        payable(_to).transfer(_amount);
        success = true;
        return success;
    }

    fallback() external payable {}

    receive() external payable {
        emit Received(msg.sender, msg.value);
    }
}
