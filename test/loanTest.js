const { expectRevert, time } = require("@openzeppelin/test-helpers");

const Loan = artifacts.require("Loan.sol");
contract("Loan", (accounts) => { 
    let loan; const amount = 1000; const interest = 10; const duration = 100;
    const [borrower, lender] = [accounts[1], accounts[2]]; 
    before(async () => { 
        loan = await Loan.deployed(); //1 
});  

it("should not accept lend if not lender", async () => { 
    await expectRevert( loan.lend({ from: borrower, value: amount }), //2 
    "only lender can lend" ); 
}); 
    it("should not accept lend amount if not exact amount", async () => { 
        await expectRevert( loan.lend({ from: lender, value: 100 }), //3 
        "can only lend the exact amount" ); 
});

it("should accept lend amount", async () => { 
    const balanceBefore = web3.utils.toBN(await web3.eth.getBalance(borrower)); //0 
    await loan.lend({ from: lender, value: amount }); //1000 //4 
    const balanceAfter = web3.utils.toBN(await web3.eth.getBalance(borrower)); //1000 
    const state = await loan.state(); assert(state.toNumber() == 1); 
    assert(balanceAfter.sub(balanceBefore).toNumber() === amount); //1000-0 ===1000 
}); 

it("should not reimburse if not borrower", async () => { 
    await expectRevert( loan.reimburse({ from: accounts[3], value: amount + interest }), //5 
    "only borrower can reimburse" ); 
});

it("should not reimbures if not exact amount", async () => { 
    await expectRevert( loan.reimburse({ from: borrower, value: 50 }), //6 
    "borrower need to reimburse exactly amount + interest" ); 
}); 

it("should not reimburse of loan has not matured", async () => { 
    await expectRevert( loan.reimburse({ from: borrower, value: amount + interest }), //7 
    "loan has not matured yet" ); 
});

it("should reimburse", async () => { 
    time.increase(duration + 10); //33+100+10=143 secs

const balanceBefore = web3.utils.toBN(await web3.eth.getBalance(lender));
await loan.reimburse({ from: borrower, value: amount + interest });
const balanceAfter = web3.utils.toBN(await web3.eth.getBalance(lender));

const state = await loan.state();
assert(state.toNumber() === 2);
assert(balanceAfter.sub(balanceBefore).toNumber() === amount + interest);
}); 
});