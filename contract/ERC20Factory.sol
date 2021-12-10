
// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Token is ERC20{
    using SafeMath for uint256;
    address public admin;
    address public daoFactory;
    struct Checkpoint {
        uint32 fromBlock;
        uint96 votes;
    }
    struct DelegateInfo {
        mapping(uint => uint)  delegateDetail;  // proposalBlockNumber => amount
    }
    mapping (address => mapping (uint32 => Checkpoint)) public checkpoints;
    mapping (address => uint32) public numCheckpoints;
    mapping (address => mapping(uint => uint) ) public  delegateVotes; // to delegate
    mapping (address => mapping(uint => uint)) public doDelegateVotes; //from delegate
    mapping (uint => uint) public allDelegateVotes;
    mapping (address => mapping(address => DelegateInfo)) private userDelegateRelation; // from with to
    address public dao;
    event DelegateVotesChanged(address indexed delegate, uint previousBalance, uint newBalance);
    constructor(address manager,uint totalSupply,string memory name,string memory symbol)  public ERC20(name,symbol){
         daoFactory = msg.sender;
         admin = manager;
        _mint(manager, totalSupply);
        _addDelegates(manager, safe96(totalSupply,"token: token amount underflows"));
    }
    modifier  _isOwner() {
        require(msg.sender == admin);
        _;
    }

    function changeOwner(address manager) external _isOwner {
        admin = manager;
    }

    function initDaoAddr(address daoAddr) external {
        require (dao == address(0));
        dao = daoAddr;
    }

    function burn(address account, uint256 amount) external _isOwner{
        _burn(account, amount);
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transferToken(msg.sender,recipient,amount);
        return true;
    }



    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transferToken(sender,recipient,amount);
        uint256 currentAllowance = allowance(sender,_msgSender());
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance-amount);
        return true;
    }

    function getCurrentVotes(address account) external view returns (uint96) {
        uint32 nCheckpoints = numCheckpoints[account];
        return nCheckpoints > 0 ? checkpoints[account][nCheckpoints - 1].votes : 0;
    }

    function delegateVote(address to,uint amount) public {
        uint blockNumber = IDaoManage(dao).getBlockNumber();
        uint priorVotes = getPriorVotes(msg.sender,blockNumber);
        require(amount <= priorVotes,'not enough');
        doDelegateVotes[msg.sender][blockNumber]+=amount;
        delegateVotes[to][blockNumber]+=amount;
        userDelegateRelation[msg.sender][to].delegateDetail[blockNumber] = amount;
        allDelegateVotes[blockNumber] += amount;
    }

    function useDelegateVote(address sender,uint amount) override external {
        require(msg.sender == dao,'no access');
        uint blockNumber = IDaoManage(dao).getBlockNumber();
        require(amount <=  delegateVotes[sender][blockNumber],'not enough');
        delegateVotes[sender][blockNumber]-=amount;
    }

    function getPriorVotes(address account, uint blockNumber) public view returns (uint96) {
        require(blockNumber < block.number, "token::getPriorVotes: not yet determined");

        uint32 nCheckpoints = numCheckpoints[account];
        if (nCheckpoints == 0) {
            return 0;
        }

        // First check most recent balance
        if (checkpoints[account][nCheckpoints - 1].fromBlock <= blockNumber) {
            return checkpoints[account][nCheckpoints - 1].votes;
        }

        // Next check implicit zero balance
        if (checkpoints[account][0].fromBlock > blockNumber) {
            return 0;
        }

        uint32 lower = 0;
        uint32 upper = nCheckpoints - 1;
        while (upper > lower) {
            uint32 center = upper - (upper - lower) / 2; // ceil, avoiding overflow
            Checkpoint memory cp = checkpoints[account][center];
            if (cp.fromBlock == blockNumber) {
                return cp.votes;
            } else if (cp.fromBlock < blockNumber) {
                lower = center;
            } else {
                upper = center - 1;
            }
        }
        return checkpoints[account][lower].votes;
    }


    function _transferToken(address sender, address recipient, uint256 amount) internal {
        uint96 amount96 = safe96(amount,"token: token amount underflows");
        _transfer(sender, recipient, amount);
        _addDelegates(recipient, amount96);

        _devDelegates(sender, amount96);
    }

    function _addDelegates(address dstRep, uint96 amount) internal {

        uint32 dstRepNum = numCheckpoints[dstRep];
        uint96 dstRepOld = dstRepNum > 0 ? checkpoints[dstRep][dstRepNum - 1].votes : 0;
        uint96 dstRepNew = add96(dstRepOld, amount, "token: token amount overflows");
        _writeCheckpoint(dstRep, dstRepNum, dstRepOld, dstRepNew);

    }

    function _devDelegates(address srcRep,  uint96 amount) internal {

        uint32 srcRepNum = numCheckpoints[srcRep];
        uint96 srcRepOld = srcRepNum > 0 ? checkpoints[srcRep][srcRepNum - 1].votes : 0;
        uint96 srcRepNew = sub96(srcRepOld, amount, "token: token amount underflows");
        _writeCheckpoint(srcRep, srcRepNum, srcRepOld, srcRepNew);
    }

    function _writeCheckpoint(address delegatee, uint32 nCheckpoints, uint96 oldVotes, uint96 newVotes) internal {
        uint32 blockNumber = safe32(block.number, "token: block number exceeds 32 bits");

        if (nCheckpoints > 0 && checkpoints[delegatee][nCheckpoints - 1].fromBlock == blockNumber) {
            checkpoints[delegatee][nCheckpoints - 1].votes = newVotes;
        } else {
            checkpoints[delegatee][nCheckpoints] = Checkpoint(blockNumber, newVotes);
            numCheckpoints[delegatee] = nCheckpoints + 1;
        }

        emit DelegateVotesChanged(delegatee, oldVotes, newVotes);
    }
    function safe32(uint n, string memory errorMessage) internal pure returns (uint32) {
        require(n < 2**32, errorMessage);
        return uint32(n);
    }

    function safe96(uint256 n, string memory errorMessage) internal pure returns (uint96) {
        require(n < 2**96, errorMessage);
        return uint96(n);
    }

    function add96(uint96 a, uint96 b, string memory errorMessage) internal pure returns (uint96) {
        uint96 c = a + b;
        require(c >= a, errorMessage);
        return c;
    }

    function sub96(uint96 a, uint96 b, string memory errorMessage) internal pure returns (uint96) {
        require(b <= a, errorMessage);
        return a - b;
    }
}

interface IDaoManage {
    function getBlockNumber() external  view returns(uint);
}



