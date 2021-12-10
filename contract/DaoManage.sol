pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;
import "./interface/IAuthority.sol";
import "./interface/IERC20.sol";

contract DaoManage{
    using Set for Set.Address;
    address public creator;
    IAuthority auth;
    address vault;
    string  name;
    string  logo;
    string  des;
    uint public voteId;
    
    mapping(address => string) public memberName;
    mapping(address => bool) public moderators;
    mapping(uint => Proposal) public proposalInfo;
    mapping(uint => mapping(address => bool)) public voters;
    
    Set.Address applying;
    Set.Address members;
    Proposal[] public proposalArray;
    
    constructor(address _creator,string memory _name,string memory _logo, string memory _des,IAuthority _auth, address _vault) public {
        creator = _creator;
        auth = _auth;
        vault = _vault;
        _init(_name,_logo,_des);
    }
    
    modifier onlyManage(){
        require(msg.sender == creator || moderators[msg.sender], "No permisstion");
        _;
    }
    
    function applyJoin(address addr) public returns(bool){
        require(!members.contains(addr),"Is memeber");
        require(!applying.contains(addr),"Applying");
        applying.add(addr);
        return true;
    }
    
    function approveApply(address addr) public returns(bool){
        require(msg.sender == creator || auth.hasAuthority(msg.sender,"DaoManage","approveApply"));
        applying.remove(addr);
        members.add(addr);
        return true;
    }
    
    function vetoApply(address addr) public returns(bool){
        require(msg.sender == creator || auth.hasAuthority(msg.sender,"DaoManage","vetoApply"));
        applying.remove(addr);
        return true;
    }
    struct Proposal{
        uint voteId;
        bool executed;
        string title;
        string description;
        bool trigger;
        
        uint startTime;
        uint endTime;
        uint voteTime;
        uint supportAmount;
        uint minAmount;
        address erc20;
        address to;
        uint amount;
    }
    
    function newProposal(string memory title, string memory description, bool trigger, uint endTime, uint voteTime, uint minAmount,address token, address to, uint amount) external {
        require(auth.hasAuthority(msg.sender,"DaoManage","newProposal"));
        
        Proposal memory pro = Proposal({
            voteId: voteId++,
            executed: false,
            title: title,
            description: description,
            trigger: trigger,
            startTime: block.timestamp,
            endTime: endTime,
            voteTime: voteTime,
            supportAmount: 0,
            minAmount: minAmount,
            erc20: token,
            to: to,
            amount: amount
        });
        
        proposalInfo[voteId] = pro;
        proposalArray.push(pro);
    }
    
    function vote(uint _voteId,address _account, bool _support) public {
        require(_voteId <= voteId,"Not exsited");
        require(members.contains(_account),"Not member");
        require(proposalInfo[voteId].endTime >= block.timestamp && proposalInfo[voteId].executed == false, "expired");
        require(!voters[_voteId][_account]);
        
        proposalInfo[_voteId].supportAmount ++;
        voters[_voteId][_account] = true;
    }
    
    function execute(uint _voteId) public {
        require(_voteId <= voteId,"Not exsited");
        require(!proposalInfo[_voteId].executed);
        require(proposalInfo[_voteId].supportAmount !=0);
        require(proposalInfo[_voteId].supportAmount >= proposalInfo[_voteId].minAmount);
        
        proposalInfo[_voteId].executed = true;
        
        //Trading methods should be moved to Treasury contracts
        IERC20(proposalInfo[_voteId].erc20).transferFrom(vault,proposalInfo[_voteId].to,proposalInfo[_voteId].amount);
        
    }
    
    function getProposalByVoteId(uint voteId) public view returns(Proposal memory){
        return proposalInfo[voteId];
    }
    
    function _init(string memory _name,string memory _logo, string memory _des) internal {
        name = _name;
        logo = _logo;
        des = _des;
    }
    
    
    function getApplyingLength() public view returns(uint){
        return applying.length();
    }
    
    function getApplyingByIndex(uint index) public view returns(address){
        return applying.at(index);
    }
    
    function getMemberLength() public view returns(uint){
        return members.length();
    }
    
    function getMemberByIndex(uint index) public view returns(address){
        return members.at(index);
    }
    
    function getName() public view returns(string memory){
        return name;
    }
    
    function getCreator() public view returns(address){
        return creator;
    }
    
    function getLogo() public view returns(string memory){
        return logo;
    }
    
    function getDes() public view returns(string memory){
        return des;
    }
    
    function getProposalArrayLength() public view returns(uint){
        return proposalArray.length;
    }
    
    function getProposalByIndex(uint index) public view returns(Proposal memory){
        return proposalArray[index];
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
