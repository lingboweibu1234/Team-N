pragma solidity ^0.4.14;

import './SafeMath.sol';
import './Ownable.sol';

contract Payroll is Ownable {
    
    using SafeMath for uint;
    
    struct Employee{
        address id;
        uint salary;
        uint lastPayday;
        
    }
    
    uint constant payDuration = 30 seconds;
    uint totalSalary = 0;

    mapping (address => Employee) public employees;

    function Payroll() {
        owner = msg.sender;
    }
    
    
    modifier employeeExist (address employeeId) {
        var employee = employees[employeeId];
        assert(employee.id != 0x0);
        _;
    }
    
    modifier employeeNotExist (address employeeId) {
        var employee = employees[employeeId];
        assert(employee.id == 0x0);
        _;
    }
    function _partialPaid  (Employee employee)  private {
         uint payment = employee.salary.mul(now.sub(employee.lastPayday)).div(payDuration);
         employee.id.transfer(payment);
        
    }
    

    function addEmployee(address employeeId, uint salary) onlyOwner {
        
        var employee = employees[employeeId];
        assert(employee.id == 0x0);
        employees[employeeId] = Employee(employeeId,salary.mul(1 ether),now);
        totalSalary = totalSalary.add(salary.mul(1 ether));
        
    }
    
    function removeEmployee(address employeeId) onlyOwner employeeExist (employeeId) {
        
        var employee = employees[employeeId];
        
        _partialPaid(employee);
        totalSalary = totalSalary.sub(employees[employeeId].salary);
        delete employees[employeeId];
        
    }
    
    function updateEmployee(address employeeId, uint salary) onlyOwner employeeExist (employeeId) {
        
        var employee = employees[employeeId];
        
        _partialPaid(employee);
        totalSalary = totalSalary.sub (employees[employeeId].salary);
        employees[employeeId].salary = salary.mul(1 ether);
        employees[employeeId].lastPayday = now;
        totalSalary = totalSalary.add (employees[employeeId].salary);
        
    }
    
    function changePaymentAddress(address employeeNewId) employeeExist (msg.sender) employeeNotExist(employeeNewId) {
    
    var employee = employees[msg.sender];
    employees[employeeNewId] = employee;
    employees[employeeNewId].id = employeeNewId;
    delete employees[msg.sender];
    
    }
    
    function addFund() payable returns (uint) {
        return this.balance;
    }
    
    function calculateRunway() returns (uint) {
        
        
        return this.balance.div(totalSalary);
    }
    
    function viewtotalSalary() returns(uint) {
        
        return totalSalary;
    }
    
    function hasEnoughFund() returns (bool) {
        return calculateRunway() > 0;
    }
    
/*  

    function checkEmployee(address employeeId) returns(uint salary,uint lastPayday) {
        var employee = employees[employeeId];
        salary = employee.salary;
        lastPayday = employee.lastPayday;
    }
    
*/

    function getPaid() employeeExist (msg.sender) {
        
        var employee = employees[msg.sender];
        require(employee.id != 0x0);
        
        uint nextPayday = employee.lastPayday.add(payDuration);
        assert(nextPayday < now);

        employees[msg.sender].lastPayday = nextPayday;
        employee.id.transfer(employee.salary);
    }
    
}
