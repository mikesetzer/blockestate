pragma solidity ^0.8.0;

/**
 * @title IERC721 Interface
 */
interface IERC721 {
    function transferFrom(address from, address to, uint256 tokenId) external;
}

/**
 * @title Escrow Contract for NFT-based Real Estate Transactions
 * This contract manages the escrow process for buying real estate represented as NFTs.
 */
contract Escrow {
    address public nftAddress;
    address payable public seller;
    address public inspector;
    address public lender;

    // State variables
    mapping(uint256 => bool) public isListed;
    mapping(uint256 => uint256) public purchasePrice;
    mapping(uint256 => uint256) public escrowAmount;
    mapping(uint256 => address) public buyer;
    mapping(uint256 => bool) public inspectionPassed;
    mapping(uint256 => mapping(address => bool)) public approval;

    // Modifiers to restrict function calls
    modifier onlyBuyer(uint256 nftID) {
        require(msg.sender == buyer[nftID], "Caller is not the buyer");
        _;
    }

    modifier onlySeller() {
        require(msg.sender == seller, "Caller is not the seller");
        _;
    }

    modifier onlyInspector() {
        require(msg.sender == inspector, "Caller is not the inspector");
        _;
    }

    /**
     * @notice Constructor to initialize the contract with relevant addresses
     * @param _nftAddress Address of the NFT contract representing real estate
     * @param _seller Address of the seller (owner) of the property
     * @param _inspector Address of the property inspector
     * @param _lender Address of the lender
     */
    constructor(
        address _nftAddress,
        address payable _seller,
        address _inspector,
        address _lender
    ) {
        nftAddress = _nftAddress;
        seller = _seller;
        inspector = _inspector;
        lender = _lender;
    }

    /**
     * @notice Lists a property for sale, transferring the NFT to this contract
     * @param nftID The unique identifier of the property NFT
     * @param buyer Address of the potential buyer
     * @param price Sale price of the property
     * @param escrow Required escrow amount to secure the sale
     */
    function list(
        uint256 nftID,
        address buyer,
        uint256 price,
        uint256 escrow
    ) public payable onlySeller {
        IERC721(nftAddress).transferFrom(msg.sender, address(this), nftID);
        isListed[nftID] = true;
        purchasePrice[nftID] = price;
        escrowAmount[nftID] = escrow;
        buyer[nftID] = buyer;
    }

    /**
     * @notice Deposits earnest money into escrow
     */
    function depositEarnest(uint256 nftID) public payable onlyBuyer(nftID) {
        require(msg.value >= escrowAmount[nftID], "Insufficient deposit");
    }

    /**
     * @notice Updates the inspection status of the property
     * @param passed Boolean for passed/failed inspection
     */
    function updateInspectionStatus(
        uint256 nftID,
        bool passed
    ) public onlyInspector {
        inspectionPassed[nftID] = passed;
    }

    /**
     * @notice Marks the sale as approved by the caller
     */
    function approveSale(uint256 nftID) public {
        approval[nftID][msg.sender] = true;
    }

    /**
     * @notice Finalizes the sale, transferring the property to the buyer and funds to the seller
     * @dev Requires all conditions to be met: inspection passed, all parties' approval, and sufficient funds
     * @param nftID The unique identifier of the property NFT
     */
    function finalizeSale(uint256 nftID) public {
        require(inspectionPassed[nftID], "Inspection not passed");
        require(approval[nftID][buyer[nftID]], "Buyer has not approved");
        require(approval[nftID][seller], "Seller has not approved");
        require(approval[nftID][lender], "Lender has not approved");
        require(
            address(this).balance >= purchasePrice[nftID],
            "Insufficient funds for sale"
        );

        isListed[nftID] = false;
        (bool success, ) = seller.call{value: address(this).balance}("");
        require(success, "Transfer to seller failed");

        IERC721(nftAddress).transferFrom(address(this), buyer[nftID], nftID);
    }

    /**
     * @notice Cancels the sale and handles the earnest deposit based on inspection status
     */
    function cancelSale(uint256 nftID) public {
        require(isListed[nftID], "Property not listed");
        if (!inspectionPassed[nftID]) {
            payable(buyer[nftID]).transfer(escrowAmount[nftID]);
        } else {
            payable(seller).transfer(escrowAmount[nftID]);
        }
        isListed[nftID] = false;
    }

    /**
     * @notice Allows the contract to receive Ether directly
     */
    receive() external payable {}

    /**
     * @notice Returns the contract's current Ether balance
     * @return The Ether balance held by the contract
     */
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
