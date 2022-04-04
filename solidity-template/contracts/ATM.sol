// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract AirlineTicketManager {
    // Task 01 - Using Struct to store Information of Ticket Owner
    struct Ticket {
        string name;
        string destination;
        string passportID;
        uint256 price;
        TicketClass ticketClass;
    }

    address public owner;
    uint256 balance = 0;

    constructor(address _owner) {
        owner = _owner;
    }

    // Task 01 - Mapping each ticket to an address i.e of the owner
    mapping(address => Ticket) ticketOwners;

    // Task 02 - Using enum to store Ticket Classes
    enum TicketClass { FirstClass, BusinessClass, EconomyClass }

    // Task 01 - Function to initiliaze the struct and set the ticket price according to the ticket class
    function createTicket( string memory _name, string memory _destination, string memory _passportID, uint _ticketClass) public {
        uint256 _price;
        TicketClass TC;

        TC = setTicketClass(_ticketClass);
        setTicketPrice(_ticketClass, _price);

        Ticket memory userTicket = Ticket( _name, _destination, _passportID, _price, TC);
        ticketOwners[msg.sender] = userTicket;
    }

    function setTicketClass(uint _classVal) public pure returns (TicketClass) {
        require(uint(TicketClass.EconomyClass) >= _classVal);

        TicketClass _TC;
        _TC = TicketClass(_classVal);
        return _TC;
    }
    
    // Task 03 - Set Ticket Prices according to the Ticket Class
    function setTicketPrice(uint _ticketClass, uint256 _ticketPrice) public pure {
        // Converted the given ether units to wei units
        if (_ticketClass == 0) {
            _ticketPrice = 10000000000000000 wei;
        } else if (_ticketClass == 1) {
            _ticketPrice = 7000000000000000 wei;
        } else if (_ticketClass == 2) {
            _ticketPrice = 5000000000000000 wei;
        }
    }

    // Task 04 - Function to receive payments and using the functions to trigger an event
    event amountReceived(uint256 val);

    receive() external payable {
        balance += msg.value;
        emit amountReceived(msg.value);
    }

    fallback() external payable {
        balance += msg.value;
        emit amountReceived(msg.value);
    }
}

// Task 06 - Factory Contract to deploy the child contract of AirlineTicketManager
contract AirlineTicketManagerFactory {
    // Task 05 - Implementing whiteList address
    address public owner;
    mapping(address => bool) whitelist;
    event AddedToWhitelist(address indexed account);
    event RemovedFromWhitelist(address indexed account);   

    AirlineTicketManager[] atmOwners;

    constructor(address _owner) {
        owner = _owner;
    }

    function createATMOwner( string memory _name, string memory _destination, string memory _passportID, uint256 _ticketClass) public onlyOwner {
        AirlineTicketManager newATM = new AirlineTicketManager(msg.sender);

        newATM.createTicket(_name, _destination, _passportID, _ticketClass);

        atmOwners.push(newATM);
    }

    modifier onlyWhitelisted() {
        require(isWhitelisted(msg.sender));
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function add(address _address) public onlyOwner {
        whitelist[_address] = true;
        emit AddedToWhitelist(_address);
    }

    function remove(address _address) public onlyOwner {
        whitelist[_address] = false;
        emit RemovedFromWhitelist(_address);
    }

    function isWhitelisted(address _address) public view returns (bool) {
        return whitelist[_address];
    }
}
