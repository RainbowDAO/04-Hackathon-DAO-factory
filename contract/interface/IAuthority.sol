pragma solidity ^0.6.0;


interface IAuthority {
    function addAct(string memory _contractName, string memory _func) external;
    function hasAuthority(address _account, string memory _contractName,string memory _func) external view returns(bool);
    function addAuthority(address _account,string memory _contractName, string memory _func) external;
}