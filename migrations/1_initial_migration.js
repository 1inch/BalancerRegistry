const Migrations = artifacts.require('./Migrations.sol');
// const BalancerRegistry = artifacts.require('./BalancerRegistry.sol');

module.exports = function (deployer) {
    deployer.deploy(Migrations);
    // deployer.deploy(BalancerRegistry);
};
