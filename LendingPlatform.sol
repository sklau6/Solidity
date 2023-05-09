pragma solidity ^0.5.0;

contract LendingPlatform {

    struct Lender {
        uint balance;
        uint[] loanIds;
        mapping(uint => bool) activeLoans;
    }

    struct Loan {
        uint amount;
        uint interestRate;
        uint duration;
        address borrower;
        address lender;
        uint startTime;
        bool active;
        bool paidBack;
    }

    uint public lenderCount;
    uint public loanCount;
    mapping(address => Lender) public lenders;
    mapping(uint => Loan) public loans;

    event LoanCreated(uint loanId, address borrower, uint amount, uint interestRate, uint duration);
    event LoanFunded(uint loanId, address lender, uint amount);
    event LoanRepaid(uint loanId, uint amount);

    constructor() public {
        lenderCount = 0;
        loanCount = 0;
    }

    function createLoan(uint _amount, uint _interestRate, uint _duration) public {
        require(_amount > 0, "The loan amount must be greater than 0.");
        require(_interestRate > 0, "The interest rate must be greater than 0.");
        require(_duration > 0, "The loan duration must be greater than 0.");
        Loan memory newLoan = Loan({
            amount: _amount,
            interestRate: _interestRate,
            duration: _duration,
            borrower: msg.sender,
            lender: address(0),
            startTime: now,
            active: true,
            paidBack: false
        });
        loans[loanCount] = newLoan;
        lenders[msg.sender].loanIds.push(loanCount);
        lenders[msg.sender].activeLoans[loanCount] = true;
        emit LoanCreated(loanCount, msg.sender, _amount, _interestRate, _duration);
        loanCount++;
    }

    function fundLoan(uint _loanId) public payable {
        require(loans[_loanId].borrower != address(0), "The loan does not exist.");
        require(msg.value == loans[_loanId].amount, "The amount sent does not match the loan amount.");
        require(lenders[msg.sender].balance >= msg.value, "The lender does not have enough funds.");
        require(!loans[_loanId].paidBack, "The loan has already been paid back.");
        loans[_loanId].lender = msg.sender;
        lenders[msg.sender].balance -= msg.value;
        lenders[msg.sender].activeLoans[_loanId] = true;
        emit LoanFunded(_loanId, msg.sender, msg.value);
    }

    function repayLoan(uint _loanId) public payable {
        require(loans[_loanId].borrower == msg.sender, "Only the borrower can repay the loan.");
        require(loans[_loanId].active, "The loan is no longer active.");
        require(msg.value == loans[_loanId].amount + loans[_loanId].amount * loans[_loanId].interestRate / 100, "The amount sent does not match the loan amount plus interest.");
        loans[_loanId].active = false;
        loans[_loanId].paidBack = true;
        lenders[loans[_loanId].lender].balance += msg.value;
        lenders[loans[_loanId].lender].activeLoans[_loanId] = false;
        emit LoanRepaid(_loanId, msg.value);
    }

    function getActiveLoans() public view returns (uint[] memory) {
		uint activeLoanCount = 0;
		for (uint i = 0; i < loans.length; i++) {
			if (loans[i].active && loans[i].borrower == msg.sender) {
				activeLoanCount++;
			}
		}
		uint[] memory activeLoanIds = new uint[](activeLoanCount);
		uint index = 0;
		for (uint i = 0; i < loans.length; i++) {
			if (loans[i].active && loans[i].borrower == msg.sender) {
				activeLoanIds[index] = i;
				index++;
			}
		}
		return activeLoanIds;
	}
}