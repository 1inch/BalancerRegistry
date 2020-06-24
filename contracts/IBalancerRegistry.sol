pragma solidity ^0.5.0;


interface IBalancerRegistry {
    // Get info about pool pair for 1 SLOAD
    function getPairInfo(address pool, address fromToken, address destToken)
        external view returns(uint256 weight1, uint256 weight2, uint256 swapFee);

    // Get pools for token pair
    function getPoolsLength(address fromToken, address destToken)
        external view returns(uint256);
    function getPools(address fromToken, address destToken)
        external view returns(address[] memory);
    function getPoolsWithLimit(address fromToken, address destToken, uint256 offset, uint256 limit)
        external view returns(address[] memory result);

    // Get swap rates
    function getPoolReturn(address pool, address fromToken, address destToken, uint256 amount)
        external view returns(uint256);
    function getPoolReturns(address pool, address fromToken, address destToken, uint256[] calldata amounts)
        external view returns(uint256[] memory result);

    // Add and update registry
    function addPool(address pool) external;
    function addPools(address[] calldata pools) external;
    function updatedIndices(address[] calldata tokens, uint256 lengthLimit) external;
}
