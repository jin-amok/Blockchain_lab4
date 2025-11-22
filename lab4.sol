    // SPDX-License-Identifier: MIT

pragma solidity >=0.8.1 <0.9.0;

contract bank{
    ///1. регистрация клиентов/первый депозит +
    //2. проверка баланса на смарт-контракте для клиента +
    //3. проверка баланса всего смарт-контракта +
    //4. вывод для клиента +

    //задание лабораторной:
    //4. вывод для владельца контракта
    //5. выдача VIP статуса
    //6. начисление процентов
    //7. оплата за услуги


    address public owner;

    enum Statuses{VIP,General}

    struct Customer{
        string name;
        uint customerBalance;
        Statuses status;
        uint registrationTime;
        uint lastDepositTime;
    }

    mapping(address=>Customer) public customers;

    constructor(){
        owner=msg.sender;
    }

    function registration(string memory _name) external{
        require(customers[msg.sender].registrationTime==0,"Already registrated!");
        customers[msg.sender]=Customer(_name,0,Statuses.General,block.timestamp,0);
    }   

    function deposit() external payable {
        require(customers[msg.sender].registrationTime>0,"You are not registered");
        customers[msg.sender].customerBalance+=msg.value;
    }

    function customerBalance() external view returns(uint){
        return customers[msg.sender].customerBalance;
    }

    function balanceSC() external view returns(uint){
        return address(this).balance;
    }

    function withdrawal(uint _value, address _to) external {
        require(customers[msg.sender].registrationTime>0,"You are not registered!");
        require(customers[msg.sender].customerBalance>=_value,"Insufficient money!");
        require(_value>0,"Incorrect value!");
        customers[msg.sender].customerBalance-=_value;
        payable(_to).transfer(_value);
    }

    // 5. вывод для владельца контракта
    function ownerWithdrawal(uint _value) external {
        require(msg.sender == owner, "Only owner can call this function!");
        require(_value <= address(this).balance, "Insufficient contract balance!");
        require(_value > 0, "Incorrect value!");
        payable(owner).transfer(_value);
    }

    // 6. выдача VIP статуса
    function setVIPStatus(address _customer) external {
        require(msg.sender == owner, "Only owner can set VIP status!");
        require(customers[_customer].registrationTime > 0, "Customer not registered!");
        customers[_customer].status = Statuses.VIP;
    }

    // 7. начисление процентов
    function applyInterest() external {
        require(customers[msg.sender].registrationTime > 0, "You are not registered!");
        require(customers[msg.sender].customerBalance > 0, "No balance to apply interest!");
        
        uint timePassed = block.timestamp - customers[msg.sender].lastDepositTime;
        uint interest = (customers[msg.sender].customerBalance * 5 * timePassed) / (100 * 365 days);
        
        customers[msg.sender].customerBalance += interest;
        customers[msg.sender].lastDepositTime = block.timestamp;
    }

    // 8. оплата за услуги
    function payForService(uint _amount) external {
        require(customers[msg.sender].registrationTime > 0, "You are not registered!");
        require(customers[msg.sender].customerBalance >= _amount, "Insufficient balance!");
        require(_amount > 0, "Incorrect amount!");
        
        customers[msg.sender].customerBalance -= _amount;
    }
}