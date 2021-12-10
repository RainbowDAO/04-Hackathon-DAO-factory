pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;
import "./interface/IERC20.sol";
import "./interface/IAuthority.sol";

contract Vault{
    using Set for Set.Address;
    address public creator;
    address public manage;
    IAuthority auth;
    
    struct Transfer{
        uint transferId;
        uint direction; //1: in ,2: out
        string tokenName;
        address from;
        address to;
        uint amount;
        uint time;
    }
    
    uint public index;

    Transfer[] public transferArray;
    Set.Address tokenArray;
    
    constructor(address _creator,address _manage, IAuthority _auth) public {
        creator = _creator;
        manage = _manage;
        auth = _auth;
    }
    
    modifier onlyCreator(){
        require(msg.sender == creator, "only owner");
        _;
    }
    
    function deposit(address token, uint amount) public returns(bool){
        require(msg.sender != address(0));
        require(tokenIfExisted(token),"Not Allowed");
        //auth or member
        //require()
        
        Transfer memory info = Transfer({
            transferId: index++,
            direction: 1,
            tokenName: IERC20(token).name(),
            from: msg.sender,
            to: address(this),
            amount: amount,
            time: block.timestamp
            
        });
        
        transferArray.push(info);
    }
    
    function withdraw(address token,address to, uint amount) public returns(bool){
        require(msg.sender != address(0));
        require(tokenIfExisted(token),"Not Allowed");
        //auth or member
        //require()
        
        Transfer memory info = Transfer({
            transferId: index++,
            direction: 2,
            tokenName: IERC20(token).name(),
            from: address(this),
            to: to,
            amount: amount,
            time: block.timestamp
            
        });
        
        transferArray.push(info);
    }
    
    function getTransferArrayLength() public view returns(uint){
        return transferArray.length;
    }

    
    function getTokenAddr(uint _index) public view returns(address){
        return tokenArray.at(_index);
    }
    
    function getTokenNumber() public view returns(uint){
        return tokenArray.length();
    }
    
    function tokenIfExisted(address _addr) public view returns(bool){
        return tokenArray.contains(_addr);
    }
    
    function removeToken(address _addr) public {
        require(msg.sender == creator || auth.hasAuthority(msg.sender,"Vault","removeToken"));
        tokenArray.remove(_addr);
    }
    
    function addToken(address _addr) public{
        require(msg.sender == creator || auth.hasAuthority(msg.sender,"Vault","addToken"));
        tokenArray.add(_addr);
    }
    
    function getERC20Balance(address token) public view returns(uint){
        return IERC20(token).balanceOf(address(this));
    }
    
    function getTransferInfo(uint index) public view returns(Transfer memory){
        return transferArray[index];
    } 
    
    
    
}

library Set {
    struct Address {
        address[] _values;
        mapping (address => uint256) _indexes;
    }
   
    function add(Address storage set, address value) internal returns (bool) {
        if (!contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        }
        return false;
    }

    function remove(Address storage set, address value) internal returns (bool) {
        uint256 valueIndex = set._indexes[value];
        if (valueIndex != 0) {
            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;
            address lastvalue = set._values[lastIndex];
            set._values[toDeleteIndex] = lastvalue;
            set._indexes[lastvalue] = toDeleteIndex + 1;
            set._values.pop();
            delete set._indexes[value];
            return true;
        }
         return false;
    }
   
    function contains(Address storage set, address value) internal view returns (bool) {
        return set._indexes[value] != 0;
    }
    
    function length(Address storage set) internal view returns (uint256) {
        return set._values.length;
    }
    
    function at(Address storage set, uint256 index) internal view returns (address) {
        require(set._values.length > index,"out of size");
        return set._values[index];
    }
    
}