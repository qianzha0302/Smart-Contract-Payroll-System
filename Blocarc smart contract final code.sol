// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.4.4<0.9.0;

contract BlocarcpayrollSystem {
    
    address  companyAddress;   //this is company address
    struct company{
        uint balance;                //company account balance
        uint newfunds;              //company funds ready to deposit
        string lastdeposittime;           //last time company deposit money into contrat account
    }
    address payable employeeAddress;  //this is employee address
    struct employee {
            uint ID;           //employee ID
            string name;       //employee name
            string department; //employee department
            string country;    //employee country
            uint salary;       //employee salary(ETH)
            uint balance;      //employee account balance(ETH)
            string lastPaytime;//employee's salary last paytime
            bool active;       //employee's status active
            uint exchangerate;  //set employee's currency exchangerate based on the country stayed
            uint payment;       //employee payment
        }
    mapping(address => company) companyDetail;  //mapping company address to company account detail
    mapping(address => uint) private addressToID; //mapping employee address to employee ID
    mapping(address => employee) employeeDetails; //mapping employee address to employee information detail
    address[] employeeList;                       //employeelist includes all the employee's address

    //payroll constructor: set the company as payroll sender
      constructor () public {
        companyAddress = msg.sender;
    }

    //access control modifier
    modifier onlyCompany{
        require (msg.sender == companyAddress
        );
        _;
    }

    //to change company account detail, like lastdeposittime
    function changeCompanydetail(address _companyAddress, uint balance, uint newfunds,string memory lastdeposittime) public onlyCompany {
        companyDetail[ _companyAddress] = company(balance,newfunds,lastdeposittime);
    }

   //company add funds to smart conrtract account
    function addFunds() public payable onlyCompany{
    }
    
    //check smart contract balance
    function contractBalance() view public onlyCompany returns (uint) {
     return address(this).balance;
 }

    //to add an employee to the company's list of employees if not already registered
    function addEmployee(address _employeeAddress, uint ID, string memory name,
    string memory department, string memory country,uint balance,uint salary, 
    string memory lastPaytime,bool active,uint exchangerate, uint payment) public  onlyCompany{
        employeeDetails[ _employeeAddress] = employee(ID,name,department,country,balance,salary,lastPaytime,active,exchangerate,payment);
        employeeList.push(_employeeAddress);
    }
    
    
    //remove employee if the employee leave the company
    function removeEmployee(address _employeeAddress)  public onlyCompany{
        employeeDetails[ _employeeAddress].active = false;
    }
    
    //to get an employee's address from the company's list of employees
    function getEmployeeAddress(uint _employeeDetails) public view onlyCompany returns (address){
            return employeeList[_employeeDetails];
        }

    
    //set employee's salary based on the employee address
    function setEmployeesalary(address _employee, uint _salary) public onlyCompany returns (uint){
        require(_salary > 0, "salary must be greater than 0");
        return (employeeDetails[_employee].salary=_salary);
    }
    
    //get employee's salary based on the address, to ensure we set the right salary for employee
    function getEmployeesalary(address _employee) public view onlyCompany returns (uint){
        return (employeeDetails[_employee].salary);
    }

    
    //get employee's balance, the balance should equal to employee's (original balance plus newly set salary after contract sent salary)
    function getEmployebalance(address _employee) external onlyCompany returns (uint){
        return (employeeDetails[_employee].balance=employeeDetails[_employee].payment+employeeDetails[_employee].balance);
    }
    
    
    //set employee's payment, which equals employee's salary
    function setEmployeepayment(address _employee, uint _salary) external onlyCompany returns (uint){
        return (employeeDetails[_employee].payment= _salary);
    }

    //transfer the salary to employees
    function payrollSystem(address _employee) external payable returns (uint,uint){
        //send the payroll to the employee
        payable(companyAddress).transfer(employeeDetails[_employee].payment);
        return (employeeDetails[_employee].payment, block.timestamp);
        }
    
    //employee can choose to transfer to local currency if want
    function etherlocal(address _employee)external payable returns (uint){
     return (employeeDetails[_employee].payment= employeeDetails[_employee].payment*employeeDetails[_employee].exchangerate);  
    }

    
    //Destroys the current contract with selfdestruct call and sends remaining funds to the company
    function destroy() public {
        require(msg.sender == companyAddress, "msg.sender is not the owner");
        selfdestruct(payable(companyAddress));
    }
  }