pragma solidity ^0.5.0;


interface IBalancerPool {
    function getFinalTokens() external view returns(address[] memory tokens);
    function getDenormalizedWeight(address token) external view returns(uint256);
    function getTotalDenormalizedWeight() external view returns(uint256);
    function getBalance(address token) external view returns(uint256);
    function getSwapFee() external view returns(uint256);
}
