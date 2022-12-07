// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract DiasporaBond {
    // Bond details
    address public issuer;
    uint256 public bondAmount;
    uint256 public interestRate;
    uint256 public maturityDate;
    uint256 public paymentSchedule;

    // Bond state
    mapping(address => uint256) public investments;
    mapping(address => bool) public investors;
    uint256 public totalInvestments;

    // Project details
    string public projectName;
    string public projectDescription;
    string public projectLocation;
    uint256 public projectStartDate;
    uint256 public projectCompletionDate;

    constructor(
        address _issuer,
        uint256 _bondAmount,
        uint256 _interestRate,
        uint256 _maturityDate,
        uint256 _paymentSchedule,
        string memory _projectName,
        string memory _projectDescription,
        string memory _projectLocation,
        uint256 _projectStartDate,
        uint256 _projectCompletionDate
    ) {
        issuer = _issuer;
        bondAmount = _bondAmount;
        interestRate = _interestRate;
        maturityDate = _maturityDate;
        paymentSchedule = _paymentSchedule;
        projectName = _projectName;
        projectDescription = _projectDescription;
        projectLocation = _projectLocation;
        projectStartDate = _projectStartDate;
        projectCompletionDate = _projectCompletionDate;
    }

    function invest(uint256 amount) public payable {
        require(msg.value == amount, "Invalid investment amount");
        investments[msg.sender] += amount;
        totalInvestments += amount;
        investors[msg.sender] = true;
    }

    function calculateInterest(
        uint256 amount,
        uint256 rate,
        uint256 period
    ) internal view returns (uint256) {
        return (amount * rate * period) / (365 * 100);
    }

    function calculatePayment(
        address investor,
        uint256 amount,
        uint256 rate,
        uint256 period
    ) internal view returns (uint256) {
        uint256 interest = calculateInterest(amount, rate, period);
        return amount + interest;
    }

    function payInterest() public {
        require(now >= paymentSchedule, "Interest payment not due");
        uint256 period = now - paymentSchedule;
        uint256 interest = calculateInterest(bondAmount, interestRate, period);
        payable(issuer).transfer(interest);
        paymentSchedule = now;
    }

    function payPrincipal() public {
        require(now >= maturityDate, "Maturity date not reached");
        payable(issuer).transfer(bondAmount);
    }

    function redeem(address investor, uint256 amount) public {
        require(investors[investor], "Investor not registered");
        require(investments[investor] >= amount, "Insufficient investment balance");
        investments[investor] -= amount;
        totalInvestments -= amount;
        payable(investor).transfer(amount);
    }
}
