// const { expectRevert } = require('openzeppelin-test-helpers');
// const { expect } = require('chai');

const BalancerRegistry = artifacts.require('BalancerRegistry');

contract('BalancerRegistry', function ([_, addr1]) {
    describe('BalancerRegistry', async function () {
        beforeEach(async function () {
            this.registry = await BalancerRegistry.new();
        });

        it('should work', async function () {
            await this.registry.addPools([
                "0x454c1d458F9082252750ba42D60faE0887868A3B",
                "0x6b9887422E2a4aE11577F59EA9c01a6C998752E2",
                "0x987D7Cc04652710b74Fff380403f5c02f82e290a",
                "0xe969991CE475bCF817e01E1AAd4687dA7e1d6F83",
                "0x4304Ae5Fd14CEc2299caee4E9a4AFbedD046D612",
            ]);

            await this.registry.updatedIndices([
                "0xB4EFd85c19999D84251304bDA99E90B92300Bd93",
                "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2",
                "0xba100000625a3754423978a60c9317c58a424e3D",
                "0x9f8F72aA9304c8B593d555F12eF6589cC3A579A2",
                "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48",
                "0x80fb784b7ed66730e8b1dbd9820afd29931aab03",
                "0x6b175474e89094c44da98b954eedeac495271d0f",
                // "0xc011a73ee8576fb46f5e1c5751ca3b9fe0af2a6f",
                // "0x1985365e9f78359a9b6ad760e32412f4a445e862",
                // "0x57ab1ec28d129707052df4df418d58a2d46d5f51",
                // "0x5d3a536e4d6dbd6114cc1ead35777bab948e3643",
                // "0xf650c3d88d12db855b8bf7d11be6c55a4e07dcc9",
                // "0xc00e94cb662c3520282e6f5717214004a7f26888",
                // "0x39aa39c021dfbae8fac545936693ac917d5e7563",
                // "0x2260fac5e5542a773aa44fbcfedf7c193bc2c599",
                // "0xeb4c2781e4eba804ce9a9803c67d0893436bb27d",
                // "0x5e74c9036fb86bd7ecdcb084a0673efc32ea31cb",
                // "0x514910771af9ca656af840dff83e8264ecf986ca",
                // "0x8a9c67fee641579deba04928c4bc45f66e26343a",
                // "0x1f573d6fb3f13d689ff844b4ce37794d79a7ff1c",
                // "0xfe18be6b3bd88a2d2a7f928d00292e7a9963cfc6",
                // "0x960b236a07cf122663c4303350609a66a7b288c0",
                // "0x8f8221afbb33998d8584a2b05749ba73c37a938a",
                // "0x408e41876cccdc0f92210600ef50372656052a38",
                // "0x6c8c6b02e7b2be14d4fa6022dfd6d75921d90e4e",
                // "0xb3319f5d18bc0d84dd1b4825dcde5d5f7266d407",
                // "0x04fa0d235c4abf4bcf4787af4cf447de572ef828",
                // "0x9cb2f26a23b8d89973f08c957c4d7cdf75cd341c",
                // "0x9041fe5b3fdea0f5e4afdc17e75180738d877a01",
                // "0xa7de087329bfcda5639247f96140f9dabe3deed1",
                // "0xbf70a33a13fbe8d0106df321da0cf654d2e9ab50",
                // "0x27054b13b1b798b345b591a4d22e6562d47ea75a",
                // "0x0d8775f648430679a709e98d2b0cb6250d2887ef",
                // "0x0327112423f3a68efdf1fcf402f6c5cb9f7c33fd",
                // "0x9f49ed43c90a540d1cf12f6170ace8d0b88a14e6",
                // "0x58b6a8a3302369daec383334672404ee733ab239",
                // "0x93ed3fbe21207ec2e8f2d3c3de6e058cb73bc04d",
            ], 5);
        });
    });
});
