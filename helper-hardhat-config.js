const networkConfig = {
    5:{
        name: "goerli",
        
    },
    31337:{
        name: "hardhat",

    },
    11155111:{
        name: "sepolia"
    }
}
const developmentChains = ["hardhat","goerli","sepolia"]
const admin = "0x90F79bf6EB2c4f870365E785982E1f101E93b906"
module.exports = {networkConfig, admin, developmentChains}