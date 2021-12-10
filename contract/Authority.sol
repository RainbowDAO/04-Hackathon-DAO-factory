pragma solidity ^0.6.0;

contract Authority{
    address public owner;
    struct Act{
        uint actId;
        string contractName;
        string funcName;
    }
    uint index;
    mapping(address => mapping(uint => bool)) public ifAllowd;
    mapping(string => mapping(string => uint)) public funcActId;
    mapping(uint => Act) public actionInfo;
    
    modifier onlyOwner(){
        require(msg.sender == owner, "only owner");
        _;
    }
    
    constructor(address _owner) public{
        owner = _owner;
    }
    
     
    function getActId(string memory _contractName, string memory _func) public view returns(uint){
        return funcActId[_contractName][_func];
    }
    
    function hasAuthority(address _account, string memory _contractName,string memory _func) public view returns(bool){
        if(funcActId[_contractName][_func] != 0){
            uint id = funcActId[_contractName][_func];
            return ifAllowd[_account][id];
        }
        
        return false;
    }
    
    function addAct(string memory _contractName, string memory _func) public {
        require(msg.sender == owner || hasAuthority(msg.sender,"Authority","addAct"), "No permission");
        require(funcActId[_contractName][_func] !=0, "existed");
        
        index++;
        Act memory act = Act({
            actId: index,
            contractName: _contractName,
            funcName: _func
        });
        
        actionInfo[index] = act;
        funcActId[_contractName][_func] = index;
    }
    
    function removeAct(string memory _contractName, string memory _func) public {
        require(msg.sender == owner || hasAuthority(msg.sender,"Authority","removeAct"), "No permission");
        require(funcActId[_contractName][_func] == 0, "Not existed");
        funcActId[_contractName][_func] = 0;
        delete actionInfo[index];
    }
    
    function addAuthority(address _account,string memory _contractName, string memory _func) public {
        require(msg.sender == owner || hasAuthority(msg.sender,"Authority","addAuthority"), "No permission");
        require(funcActId[_contractName][_func] != 0, "Not existed");
        uint actId = funcActId[_contractName][_func];
        require(!ifAllowd[_account][actId], "Have authority");
        
        ifAllowd[_account][actId] = true;
    }
    
    function removeAuthority(address _account,string memory _contractName, string memory _func) public {
        require(msg.sender == owner || hasAuthority(msg.sender,"Authority","removeAuthority"), "No permission");
        require(funcActId[_contractName][_func] != 0, "Not existed");
        uint actId = funcActId[_contractName][_func];
        require(ifAllowd[_account][actId], "No authority");
        
        ifAllowd[_account][actId] = false;
    }
    
}