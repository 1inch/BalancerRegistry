pragma solidity ^0.5.0;

import "@openzeppelin/contracts/math/Math.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "./IBalancerRegistry.sol";
import "./IBalancerPool.sol";
import "./BalancerLib.sol";
import "./AddressSet.sol";


contract BalancerRegistry is IBalancerRegistry {
    using SafeMath for uint256;
    using AddressSet for AddressSet.Data;

    struct PoolPairInfo {
        uint80 weight1;
        uint80 weight2;
        uint80 swapFee;
    }

    struct SortedPools {
        AddressSet.Data pools;
        bytes32 indices;
    }

    AddressSet.Data private _allTokens;
    AddressSet.Data private _addedPools;
    mapping(bytes32 => SortedPools) private _pools;
    mapping(address => mapping(bytes32 => PoolPairInfo)) private _infos;

    function checkAddedPools(address pool)
        external view returns(bool)
    {
        return _addedPools.contains(pool);
    }

    function getAddedPoolsLength()
        external view returns(uint256)
    {
        return _addedPools.items.length;
    }

    function getAddedPools()
        external view returns(address[] memory)
    {
        return _addedPools.items;
    }

    function getAddedPoolsWithLimit(uint256 offset, uint256 limit)
        external view returns(address[] memory result)
    {
        result = new address[](Math.min(limit, _addedPools.items.length - offset));
        for (uint i = 0; i < result.length; i++) {
            result[i] = _addedPools.items[offset + i];
        }
    }

    function getAllTokensLength()
        external view returns(uint256)
    {
        return _allTokens.items.length;
    }

    function getAllTokens()
        external view returns(address[] memory)
    {
        return _allTokens.items;
    }

    function getAllTokensWithLimit(uint256 offset, uint256 limit)
        external view returns(address[] memory result)
    {
        result = new address[](Math.min(limit, _allTokens.items.length - offset));
        for (uint i = 0; i < result.length; i++) {
            result[i] = _allTokens.items[offset + i];
        }
    }

    function getPairInfo(address pool, address fromToken, address destToken)
        external view returns(uint256 weight1, uint256 weight2, uint256 swapFee)
    {
        bytes32 key = _createKey(fromToken, destToken);
        PoolPairInfo memory info = _infos[pool][key];
        return (info.weight1, info.weight2, info.swapFee);
    }

    function getPoolsLength(address fromToken, address destToken)
        external view returns(uint256)
    {
        bytes32 key = _createKey(fromToken, destToken);
        return _pools[key].pools.items.length;
    }

    function getPools(address fromToken, address destToken)
        external view returns(address[] memory)
    {
        bytes32 key = _createKey(fromToken, destToken);
        return _pools[key].pools.items;
    }

    function getPoolsWithLimit(address fromToken, address destToken, uint256 offset, uint256 limit)
        public view returns(address[] memory result)
    {
        bytes32 key = _createKey(fromToken, destToken);
        result = new address[](Math.min(limit, _pools[key].pools.items.length - offset));
        for (uint i = 0; i < result.length; i++) {
            result[i] = _pools[key].pools.items[offset + i];
        }
    }

    function getBestPools(address fromToken, address destToken)
        external view returns(address[] memory pools)
    {
        return getBestPoolsWithLimit(fromToken, destToken, 32);
    }

    function getBestPoolsWithLimit(address fromToken, address destToken, uint256 limit)
        public view returns(address[] memory pools)
    {
        bytes32 key = _createKey(fromToken, destToken);
        bytes32 indices = _pools[key].indices;
        uint256 len = 0;
        while (indices[len] > 0 && len < Math.min(limit, indices.length)) {
            len++;
        }

        pools = new address[](len);
        for (uint i = 0; i < len; i++) {
            uint256 index = uint256(uint8(indices[i])).sub(1);
            pools[i] = _pools[key].pools.items[index];
        }
    }

    // Swap info

    function getPoolReturn(address pool, address fromToken, address destToken, uint256 amount)
        external view returns(uint256)
    {
        uint256[] memory amounts = new uint256[](1);
        amounts[0] = amount;
        return getPoolReturns(pool, fromToken, destToken, amounts)[0];
    }

    function getPoolReturns(address pool, address fromToken, address destToken, uint256[] memory amounts)
        public view returns(uint256[] memory result)
    {
        bytes32 key = _createKey(fromToken, destToken);
        PoolPairInfo memory info = _infos[pool][key];
        result = new uint256[](amounts.length);
        for (uint i = 0; i < amounts.length; i++) {
            result[i] = BalancerLib.calcOutGivenIn(
                IBalancerPool(pool).getBalance(fromToken),
                uint256(fromToken < destToken ? info.weight1 : info.weight2),
                IBalancerPool(pool).getBalance(destToken),
                uint256(fromToken < destToken ? info.weight2 : info.weight1),
                amounts[i],
                info.swapFee
            );
        }
    }

    // Add and update registry

    function addPool(address pool) public returns(uint256 listed) {
        if (!_addedPools.add(pool)) {
            return 0;
        }
        emit PoolAdded(pool);

        address[] memory tokens = IBalancerPool(pool).getFinalTokens();
        uint256[] memory weights = new uint256[](tokens.length);
        for (uint i = 0; i < tokens.length; i++) {
            weights[i] = IBalancerPool(pool).getDenormalizedWeight(tokens[i]);
        }

        uint256 swapFee = IBalancerPool(pool).getSwapFee();

        for (uint i = 0; i < tokens.length; i++) {
            _allTokens.add(tokens[i]);
            for (uint j = i + 1; j < tokens.length; j++) {
                bytes32 key = _createKey(tokens[i], tokens[j]);
                if (_pools[key].pools.add(pool)) {
                    _infos[pool][key] = PoolPairInfo({
                        weight1: uint80(weights[tokens[i] < tokens[j] ? i : j]),
                        weight2: uint80(weights[tokens[i] < tokens[j] ? j : i]),
                        swapFee: uint80(swapFee)
                    });

                    emit PoolTokenPairAdded(
                        pool,
                        tokens[i] < tokens[j] ? tokens[i] : tokens[j],
                        tokens[i] < tokens[j] ? tokens[j] : tokens[i]
                    );
                    listed++;
                }
            }
        }
    }

    function addPools(address[] calldata pools) external returns(uint256[] memory listed) {
        listed = new uint256[](pools.length);
        for (uint i = 0; i < pools.length; i++) {
            listed[i] = addPool(pools[i]);
        }
    }

    function updatedIndices(address[] calldata tokens, uint256 lengthLimit) external {
        for (uint i = 0; i < tokens.length; i++) {
            for (uint j = i + 1; j < tokens.length; j++) {
                bytes32 key = _createKey(tokens[i], tokens[j]);
                address[] memory pools = getPoolsWithLimit(tokens[i], tokens[j], 0, lengthLimit);
                uint256[] memory invs = _getInvsForPools(tokens[i], tokens[j], pools);
                bytes32 indices = _buildSortIndices(invs);

                if (indices != _pools[key].indices) {
                    emit IndicesUpdated(
                        tokens[i] < tokens[j] ? tokens[i] : tokens[j],
                        tokens[i] < tokens[j] ? tokens[j] : tokens[i],
                        _pools[key].indices,
                        indices
                    );
                    _pools[key].indices = indices;
                }
            }
        }
    }

    // Internal

    function _createKey(address token1, address token2)
        internal pure returns(bytes32)
    {
        return bytes32(
            (uint256(uint128((token1 < token2) ? token1 : token2)) << 128) |
            (uint256(uint128((token1 < token2) ? token2 : token1)))
        );
    }

    function _getInvsForPools(address fromToken, address destToken, address[] memory pools)
        internal view returns(uint256[] memory invs)
    {
        invs = new uint256[](pools.length);
        for (uint i = 0; i < pools.length; i++) {
            bytes32 key = _createKey(fromToken, destToken);
            PoolPairInfo memory info = _infos[pools[i]][key];
            invs[i] = IBalancerPool(pools[i]).getBalance(fromToken)
                .mul(IBalancerPool(pools[i]).getBalance(destToken));
            invs[i] = invs[i]
                .mul(info.weight1 + info.weight2).div(info.weight1)
                .mul(info.weight1 + info.weight2).div(info.weight2);
        }
    }

    function _buildSortIndices(uint256[] memory invs)
        internal pure returns(bytes32)
    {
        uint256 result = 0;
        uint256 prevInv = uint256(-1);
        for (uint i = 0; i < 32; i++) {
            uint256 bestIndex = 0;
            for (uint j = 0; j < invs.length; j++) {
                if ((invs[j] > invs[bestIndex] && invs[j] < prevInv) || invs[bestIndex] >= prevInv) {
                    bestIndex = j;
                }
            }
            prevInv = invs[bestIndex];
            result |= (bestIndex + 1) << (248 - i * 8);
        }
        return bytes32(result);
    }
}
