pragma solidity ^0.6.0;
import "./DaoManage.sol";
import "./Vault.sol";

contract DaoMain{
    address public owner;
    uint public index;
    
    struct DaoInfo{
        string name;
        string logo;
        string des;
        address authority;
        address manage;
        address vault;
    }
    mapping(address => uint[]) public userDaos;
    DaoInfo[] public array;
    
    constructor(address _owner) public {
        owner = _owner;
    }
    
    modifier onlyOnwer(){
        require(msg.sender == owner, "only owner");
        _;
    }
    
    function creatDao(string memory _name,string memory _logo,string memory _des) public {
        require(msg.sender != address(0), "Invalid address");
        address manage = address(new DaoManage(msg.sender,_name,_logo,_des));
        address vault = address(new Vault(msg.sender,manage, address(0)));
        DaoInfo memory addr = DaoInfo({
            name: _name,
            logo: _logo,
            des: _des,
            authority: address(0),
            manage: manage,
            vault: address(0)
        });
        
        index++;
        array.push(addr);
        userDaos[msg.sender].push(index);
    }
    
    function getArrayLength() public view returns(uint){
        return array.length;
    }
    
    // function _init_contracts(string memory _name,string memory _logo, string memory _des) internal {
        
    // }
    
    function getOwnedDaos() public view returns(uint[] memory){
        return userDaos[msg.sender];
    }
    
}