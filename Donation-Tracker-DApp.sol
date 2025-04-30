// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title DonationTracker
 * @dev A simple donation tracking smart contract that records donations and provides transparency
 */
contract DonationTracker {
    address public owner;
    uint256 public totalDonations;
    uint256 public donationCount;
    
    struct Donation {
        address donor;
        uint256 amount;
        string message;
        uint256 timestamp;
    }
    
    // Map donation ID to Donation struct
    mapping(uint256 => Donation) public donations;
    
    // Map donor address to total donated amount
    mapping(address => uint256) public donorTotalAmount;
    
    // Events
    event DonationReceived(uint256 indexed donationId, address indexed donor, uint256 amount, string message);
    event FundsWithdrawn(address indexed recipient, uint256 amount);
    
    // Constructor
    constructor() {
        owner = msg.sender;
    }
    
    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }
    
    /**
     * @dev Make a donation with an optional message
     * @param _message A message from the donor (optional)
     */
    function donate(string memory _message) external payable {
        require(msg.value > 0, "Donation amount must be greater than 0");
        
        // Create donation record
        uint256 donationId = donationCount;
        donations[donationId] = Donation({
            donor: msg.sender,
            amount: msg.value,
            message: _message,
            timestamp: block.timestamp
        });
        
        // Update state
        donationCount++;
        totalDonations += msg.value;
        donorTotalAmount[msg.sender] += msg.value;
        
        // Emit event
        emit DonationReceived(donationId, msg.sender, msg.value, _message);
    }
    
    /**
     * @dev Withdraw funds (only owner)
     * @param _amount Amount to withdraw
     * @param _recipient Address to send funds to
     */
    function withdrawFunds(uint256 _amount, address payable _recipient) external onlyOwner {
        require(_amount <= address(this).balance, "Insufficient contract balance");
        require(_recipient != address(0), "Invalid recipient address");
        
        _recipient.transfer(_amount);
        
        emit FundsWithdrawn(_recipient, _amount);
    }
    
    /**
     * @dev Get donation details by ID
     * @param _donationId The ID of the donation
     * @return donor The address of the donor
     * @return amount The donation amount
     * @return message The donation message
     * @return timestamp When the donation was made
     */
    function getDonationDetails(uint256 _donationId) external view 
        returns (address donor, uint256 amount, string memory message, uint256 timestamp) 
    {
        require(_donationId < donationCount, "Donation does not exist");
        
        Donation memory donation = donations[_donationId];
        return (
            donation.donor,
            donation.amount,
            donation.message,
            donation.timestamp
        );
    }
}
