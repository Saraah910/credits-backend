const { network } = require("hardhat");
const { admin, developmentChains } = require("../helper-hardhat-config");
const { verify } = require("../utils/verify");

module.exports = async function({getNamedAccounts, deployments}){
    const {deploy, log} = deployments;
    const {deployer} = await getNamedAccounts();

    args = [admin]

    const ncs = await deploy("ncs",{
        from: deployer,
        log: true,
        args: args,
        waitConfirmations: network.config.blockConfirmations || 1

    })

    log("-------------------------------------------------")
    log(`Contract deployed at ${ncs.address}`)

    if(!developmentChains.includes(network.name) || process.env.ETHERSCAN_API_KEY){
        await verify(ncs.address, args);
    }
    log("Contract verified sucessfully.")

}

module.exports.tags = ["all","ncs"]