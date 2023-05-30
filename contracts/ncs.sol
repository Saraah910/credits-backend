//SPDX-License-Identifier:MIT
pragma solidity ^0.8.9;

error ncs__StudentAlreadyPresent();
error ncs__StudentNotPresent();
error ncs__studentNotEnrolledInTheCourse();
error ncs__studentEnrolledInTheCourse();
error ncs__notTheAdminError();
error ncs__approvedAlready();
error ncs__certificationNotRequested(string courseName);
error ncs__AlreadyRequested(string courseName);

contract ncs{

    //1. storing student information.✅
    //2. storing the enrolled courses and fees.✅
    //3. Aproving degree certification.✅
    //4. show collected credits.✅
    //5. showing the collected degrees.✅

    struct Student{
        string Name;
        uint256 Age;
        string College;
    }

    address private immutable i_admin;
    mapping(address => Student) private s_studentDetails;
    mapping(address => mapping(string => uint256)) private courseToFees;
    mapping(address => uint256) private totalCreditsEarned;
    mapping(address => string []) private studentToCourseEnrolled;
    mapping(address => string []) private requested;
    uint256 requiredCredits = 0;
    mapping(address => string[]) private approvedCertificates;
    address [] public existingStudent;

    constructor(address admin){
        i_admin = admin;
    }

    event StudentData(
        address indexed Sender,
        uint256 Age,
        string indexed Address
    );

    event CourseEnrolled(
        address indexed sender,
        string indexed courseName
    );

    event certificateAproved(
        address indexed sender,
        string indexed courseName
    );

    modifier notAlreadyPresent(address sender){
        for(uint256 i=0; i<existingStudent.length; i++){
            if(existingStudent[i] == sender){
                revert ncs__StudentAlreadyPresent();
            }else{
                continue;
            }
        }
        _;
    }

    modifier alreadyPresent(address sender){
        bool flag = false;
        for(uint256 i=0; i<existingStudent.length; i++){
            if(existingStudent[i] == sender){
                flag = true;
            }else{
                continue;
            }
        }
        if(!flag){
            revert ncs__StudentNotPresent();
        }       
        _; 
        
    }

    modifier alreadyEnrolled(address sender, string memory courseName){
        bool flag = false;
        for(uint256 i=0; i<studentToCourseEnrolled[sender].length; i++){
            if(keccak256(bytes(courseName)) == keccak256(bytes(studentToCourseEnrolled[sender][i]))){
                flag = true;
            }
        }
        if(!flag){
            revert ncs__studentNotEnrolledInTheCourse();
        }
        _;
        
    }

    modifier NotEnrolled(address sender, string memory courseName){

        for(uint256 i=0; i<studentToCourseEnrolled[sender].length; i++){
            if(keccak256(bytes(courseName)) == keccak256(bytes(studentToCourseEnrolled[sender][i]))){
                revert ncs__studentEnrolledInTheCourse();
            }
        }
        _;
        
    }

    modifier onlyAdmin(){
        if(msg.sender != i_admin){
            revert ncs__notTheAdminError();
        }
        _;
    }

    modifier aprovedAlready(address sender, string memory courseName){
        for(uint256 i=0; i<approvedCertificates[sender].length; i++){
            if(keccak256(bytes(approvedCertificates[sender][i])) == keccak256(bytes(courseName))){
                revert ncs__approvedAlready();
            }
        }
        _;
    }

    modifier isPresentInRequestQueue(address requester, string memory courseName){
        bool flag = false;
        for(uint i=0; i<requested[requester].length; i++){
            if(keccak256(bytes(requested[requester][i])) == keccak256(bytes(courseName))){
                flag = true;
            }
        }
        if(!flag){
            revert ncs__certificationNotRequested(courseName);
        }
        _;
    }

    modifier isAlreadyRequested(address requester, string memory courseName){
        for(uint i=0; i<requested[requester].length; i++){
            if(keccak256(bytes(requested[requester][i])) == keccak256(bytes(courseName))){
                revert ncs__AlreadyRequested(courseName);
            }
        }
        _;
    }

    function addStudentDetails(string memory name, uint256 age, string memory college) notAlreadyPresent(msg.sender)external{
        Student memory newStudent = Student({
                                Name: name,
                                Age: age,
                                College:college
                            });
        existingStudent.push(msg.sender);
        s_studentDetails[msg.sender] = newStudent;
        emit StudentData(msg.sender,age,college);
    }

    function enrollIntoCourse(string memory courseName) alreadyPresent(msg.sender) NotEnrolled(msg.sender,courseName) external payable{
        
        uint256 CourseFees;

        if(keccak256(bytes(courseName)) == keccak256(bytes("9th")) || 
            keccak256(bytes(courseName)) == keccak256(bytes("10th"))
        ){
            CourseFees = 2000000000000000000;
            require(msg.value == CourseFees,"Insufficient Funds");
            requiredCredits = 20;
             
        }
        else if(keccak256(bytes(courseName)) == keccak256(bytes("11th")) || 
            keccak256(bytes(courseName)) == keccak256(bytes("12th"))
        ){
            CourseFees = 4000000000000000000;
            require(msg.value == CourseFees,"Insufficient Funds.");
            require(totalCreditsEarned[msg.sender] >= 40, "Insufficient credits.");
            requiredCredits = 40;
        }
        else if(keccak256(bytes(courseName)) == keccak256(bytes("Diploma")) || 
            keccak256(bytes(courseName)) == keccak256(bytes("Degree")) ||
            keccak256(bytes(courseName)) == keccak256(bytes("hm")) || 
            keccak256(bytes(courseName)) == keccak256(bytes("art"))
        ){
            CourseFees = 6000000000000000000;
            require(msg.value == CourseFees,"Insufficient Funds");
            require(totalCreditsEarned[msg.sender] >= 120,"Insufficient credits.");
            requiredCredits = 60;
        }
        
        studentToCourseEnrolled[msg.sender].push(courseName);
        courseToFees[msg.sender][courseName] = CourseFees;
        emit CourseEnrolled(msg.sender,courseName);

    }

    function AproveCertification(address requester, string memory courseName) 
        isPresentInRequestQueue(requester,courseName)
        alreadyPresent(requester) 
        alreadyEnrolled(requester,courseName) 
        aprovedAlready(requester,courseName) onlyAdmin() external{

        if(keccak256(bytes(courseName)) == keccak256(bytes("9th")) || 
            keccak256(bytes(courseName)) == keccak256(bytes("10th"))
        ){
            totalCreditsEarned[requester] += 20;
        }
        else if(keccak256(bytes(courseName)) == keccak256(bytes("11th")) || 
            keccak256(bytes(courseName)) == keccak256(bytes("12th"))
        ){
            totalCreditsEarned[requester] += 40;
        }
        else if(keccak256(bytes(courseName)) == keccak256(bytes("Diploma")) || 
            keccak256(bytes(courseName)) == keccak256(bytes("Degree")) ||
            keccak256(bytes(courseName)) == keccak256(bytes("hm")) || 
            keccak256(bytes(courseName)) == keccak256(bytes("art"))
        ){
            totalCreditsEarned[requester] += 60;
        }
        
        approvedCertificates[requester].push(courseName);
        emit certificateAproved(requester,courseName);
        this.removeElement(requester,courseName);
    }

    function removeElement(address requester,string memory value) external {
        for(uint i = 0; i < requested[requester].length; i++){
            if(keccak256(bytes(requested[requester][i]))  == keccak256(bytes(value)) ){
                for(uint j=i; j< requested[requester].length-1; j++){
                    requested[requester][j] = requested[requester][j+1];
                }
                requested[requester].pop();
            }
        }
        
    }

    function requestDegree(address requester, string memory courseName) 
        alreadyEnrolled(requester,courseName)
        isAlreadyRequested(requester,courseName)
        aprovedAlready(requester,courseName)
        external{
        requested[requester].push(courseName);

    }
    // function getAllPendingRequests()
    // function requestQueue(string memory courseName) external {
    //     requested[msg.sender].push(courseName);
    // }

    function withDrawFunds() onlyAdmin() external{
        // courseToFees = new mapping(address => mapping(string => uint256))("")(0);
        for(uint256 i=0; i<existingStudent.length; i++){
            // delete studentToCourseEnrolled[existingStudent[i]];
            totalCreditsEarned[existingStudent[i]] = 0;
            studentToCourseEnrolled[existingStudent[i]] = new string[](0);
            approvedCertificates[existingStudent[i]] = new string[](0);
            requested[existingStudent[i]] = new string[](0);
            delete s_studentDetails[existingStudent[i]];
        }
        // delete existingStudent;
        // existingStudent = new address[](0);
        (bool success, ) = payable(msg.sender).call{value:address(this).balance}("");
        require(success, "Funds transfer failed!");
    }

    //View or pure functions

    function showAllEnrolledCourses(address requester) alreadyPresent(requester) external view returns(string [] memory){        
        return studentToCourseEnrolled[requester];        
    }

    function showAvailableCredits(address requester) alreadyPresent(requester) external view returns(uint256){
        return totalCreditsEarned[requester];
    }

    function ShowDetailsofStudent(address requester) alreadyPresent(requester) external view returns(Student memory){
        return s_studentDetails[requester];
    }

    function showApprovedCertification(address requester) external view returns(string []memory){
        return approvedCertificates[requester];
    }

    function showAllStudents() onlyAdmin() external view returns(address []memory){
        return existingStudent;
    }

    function showRequestedCertifications(address requester) alreadyPresent(requester) external view returns(string []memory){
        return requested[requester];
    }

}