pragma solidity ^0.4.14;

contract Payroll {
    
    struct Employee{
        address id;
        uint salary;
        uint lastPayday;
        
    }
    
    uint constant payDuration = 30 seconds;
    uint totalSalary = 0;

    address owner;
    mapping (address => Employee) public employees;

    function Payroll() {
        owner = msg.sender;
    }
    
    function _partialPaid  (Employee employee)  private {
         uint payment = employee.salary * (now - employee.lastPayday) / payDuration;
         employee.id.transfer(payment);
        
    }
    

    
    function addEmployee(address employeeId, uint salary) {
        require(msg.sender == owner);
        
        var employee = employees[employeeId];
        assert(employee.id == 0x0);
        employees[employeeId] = Employee(employeeId,salary*1 ether,now);
        totalSalary += salary*1 ether;
        
    }
    
    function removeEmployee(address employeeId) {
        require(msg.sender == owner);
        var employee = employees[employeeId];
        assert(employee.id != 0x0);
        
        _partialPaid(employee);
        totalSalary -= employees[employeeId].salary;
        delete employees[employeeId];
        
    }
    
    function updateEmployee(address employeeId, uint salary) {
        require(msg.sender == owner);
        
        var employee = employees[employeeId];
        assert(employee.id != 0x0);
        
        _partialPaid(employee);
        totalSalary -= employees[employeeId].salary;
        employees[employeeId].salary = salary *1 ether;
        employees[employeeId].lastPayday = now;
        totalSalary += employees[employeeId].salary;
        
    }
    
    function addFund() payable returns (uint) {
        return this.balance;
    }
    
    function calculateRunway() returns (uint) {
        
        
        return this.balance / totalSalary;
    }
    
    function viewtotalSalary() returns(uint) {
        
        return totalSalary;
    }
    
    function hasEnoughFund() returns (bool) {
        return calculateRunway() > 0;
    }
    
/*  function checkEmployee(address employeeId) returns(uint salary,uint lastPayday) {
        var employee = employees[employeeId];
        salary = employee.salary;
        lastPayday = employee.lastPayday;
    }
*/
    function getPaid() {
        
        var employee = employees[msg.sender];
        require(employee.id != 0x0);
        
        uint nextPayday = employee.lastPayday + payDuration;
        assert(nextPayday < now);

        employees[msg.sender].lastPayday = nextPayday;
        employee.id.transfer(employee.salary);
    }
    
}