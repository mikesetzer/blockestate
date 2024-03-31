const { expect } = require('chai');
const { ethers } = require('hardhat');

const tokens = (n) => {
    return ethers.utils.parseUnits(n.toString(), 'ether')
}

describe('Escrow', () => {
    let buyer, seller, inspector, lender
    let realEstate, escrow
    
    it('saves the addresses', async () => {

        // Get signers from blockchain with HardHat & setup accounts
        [buyer, seller, inspector, lender] = await ethers.getSigners()

        // Deploy Rest Estate
        const RealEstate = await ethers.getContractFactory('RealEstate')
        realEstate = await RealEstate.deploy()

        // Mint NFT using ipfs metadata
        let transaction = await realEstate.connect(seller).mint("https://ipfs.io/ipfs/QmTudSYeM7mz3PkYEWXWqPjomRPHogcMFSq7XAvsvsgAPS")
        await transaction.wait()
        
        const Escrow = await ethers.getContractFactory('Escrow')
        escrow = await Escrow.deploy(
            realEstate.address,
            seller.address,
            inspector.address,
            lender.address
        )

        let result = await escrow.nftAddress()
        expect(result).to.be.equal(realEstate.address)

        result = await escrow.seller()
        expect(result).to.be.equal(seller.address)
        
    })
})
