//SPDX-License-Identifier: UNLICENSED 
pragma solidity >=0.5.0 <0.9.0;

contract Loan {

    enum State { 
        NOT_ACTIVE,
        ACTIVE,
        CLOSED }



    State public state = State.NOT_ACTIVE;
    address payable public borrower;
    address payable public lender;
    uint256 public amount;
    uint256 public interest;
    uint256 public duration;
    uint256 public end;

    constructor ( uint256 _amount, uint256 _interest, uint256 _duration, address payable _borrower, address payable _lender){
         
         amount = _amount;
         interest = _interest;
         duration = _duration;
         borrower = _borrower;
         lender = _lender;
    }

    function lend() external payable {
           require(msg.sender==lender, " Only lender can lend");
           require(address(this).balance == amount,"can only lend the exact amount");

           changeState(State.ACTIVE);
           borrower.transfer(amount);  

    }

    function repay() external payable {
        require(msg.sender == borrower, " Only borrower can repay");
        require( msg.value == amount+interest, " borrower needs to repay exactly, amount + interest");

           changeState(State.CLOSED);
           lender.transfer(amount+interest);
    }

    function changeState( State _state) internal{
         require(_state != State.NOT_ACTIVE, "state is already inactive");
         require(_state != state, " transition state cannot be same");

         if(_state == State.ACTIVE){
                require(state== State.NOT_ACTIVE," state should be inactive first");
             state= State.ACTIVE;
             end = block.timestamp + duration;
         }

         if(_state == State.CLOSED){
             require(state == State.ACTIVE, " state should be active first");
             require(block.timestamp >= end, " loan has not matured yet");
             state= State.CLOSED;
         }

    }



}



// contract Loan { 
//     enum State { PENDING, ACTIVE, CLOSED } 
//     State public state = State.PENDING; 
//     uint256 public amount; 
//     uint256 public interest; 
//     uint256 public end; 
//     uint256 public duration; 
//     address payable public borrower; 
//     address payable public lender;
// constructor(
//     uint256 _amount,
//     uint256 _interest,
//     uint256 _duration,
//     address payable _borrower,
//     address payable _lender
// ) {
//     amount = _amount;
//     interest = _interest;
//     duration = _duration;
//     borrower = _borrower;
//     lender = _lender;
// }

// function lend() external payable {
//     require(msg.sender == lender, "only lender can lend");
//     require(
//         address(this).balance == amount,
//         "can only lend the exact amount"
//     );
//     changeState(State.ACTIVE);
//     borrower.transfer(amount);
// }

// function reimburse() external payable {
//     require(msg.sender == borrower, "only borrower can reimburse");
//     require(
//         msg.value == amount + interest,
//         "borrower need to reimburse exactly amount + interest"
//     );
//     changeState(State.CLOSED);
//     lender.transfer(amount + interest);
// }

// function changeState(State to) internal {
//     require(to != State.PENDING, "state is already in a pending state");
//     require(to != state, "transition state cannot be same");
//     if (to == State.ACTIVE) {
//         require(state == State.PENDING, "state is not pending");
//         state = State.ACTIVE;
//         end = block.timestamp + duration; //33+100 = 133 // 33+2 =35
//     }
//     if (to == State.CLOSED) {
//         require(state == State.ACTIVE, "state is not active");
//         require(block.timestamp >= end, "loan has not matured yet"); //35 <133 //35 =35
//         state = State.CLOSED;
//     }
// }
// }
