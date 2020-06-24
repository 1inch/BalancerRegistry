// const { expectRevert } = require('openzeppelin-test-helpers');
// const { expect } = require('chai');

const BalancerRegistry = artifacts.require('BalancerRegistry');

contract('BalancerRegistry', function ([_, addr1]) {
    describe('BalancerRegistry', async function () {
        it('should be deployable', async function () {
            this.contract = await BalancerRegistry.new();
        });
    });
});
