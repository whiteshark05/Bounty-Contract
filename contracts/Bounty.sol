pragma solidity ^0.4.24;

contract Bounty {
    address owner;
    uint[] problemID;
    uint[] solutionID;
    
    struct Problem {
        address setterAddress;
        string name;
        string description;
        uint input;
        uint output;
        uint priceTag;
        bool isActive;
    }
    
    mapping(uint => Problem) problems;
    
    struct Solution {
        address solverAddress;
        bool isCorrect;
    }
    
    mapping(uint => Solution) solutions;
    
    
    // Initialise the contract
    constructor() public payable {
        owner = msg.sender;
    } 
    
    //Fallback function
    function () public payable {}
    
    // Create Problem
    function create(string name_, string description_, uint input_, uint output_) public payable
    {
        require(msg.value > 0, "Please deposit more bounties");
        uint newID = problemID.length;
        problemID.push(newID);
        Problem storage newProblem = problems[newID];
        newProblem.setterAddress = msg.sender;
        newProblem.name = name_;
        newProblem.description = description_;
        newProblem.input = input_;
        newProblem.output = output_;
        newProblem.priceTag = msg.value;  // Check the unit of msg.value (ether or wei?)
        newProblem.isActive = true;
    }
    
    
    // Retrieve Problem
    function retrieve(uint id_) public view
            returns (string name, string description, uint input, uint output, uint priceTag, bool isActive)
    {
        Problem storage currentProblem = problems[id_];
        require(currentProblem.isActive, "Invalid ID");
        return(
        currentProblem.name,
        currentProblem.description,
        currentProblem.input,
        currentProblem.output,
        currentProblem.priceTag,
        currentProblem.isActive);
    }
    
    
    // Update Problem
    function updateName(uint id_, string name_) public
    {
        require(msg.sender == problems[id_].setterAddress, "Only problem setter can edit");
        require(problems[id_].isActive, "Invalid ID");
        problems[id_].name = name_;
    }
    
    
    function updateDescription(uint id_, string description_) public
    {
        require(msg.sender == problems[id_].setterAddress, "Only problem setter can edit");
        require(problems[id_].isActive, "Invalid ID");
        problems[id_].description = description_;
    }
    
    
    function updateInput(uint id_, uint input_) public
    {
        require(msg.sender == problems[id_].setterAddress, "Only problem setter can edit");
        require(problems[id_].isActive, "Invalid ID");
        problems[id_].input = input_;
    }
    
    
    function updateOutput(uint id_, uint output_) public
    {
        require(msg.sender == problems[id_].setterAddress, "Only problem setter can edit");
        require(problems[id_].isActive, "Invalid ID");
        problems[id_].output = output_;
    }
    
    
    function updatePriceTag(uint id_) public payable
    {
        require(msg.sender == problems[id_].setterAddress, "Only problem setter can edit");
        require(problems[id_].isActive, "Invalid ID");
        problems[id_].priceTag += msg.value;
    }
    
    
    // Remove Problem (inactive)
    function remove(uint id_) public {
        Problem storage currentProblem = problems[id_];
        require(msg.sender == currentProblem.setterAddress, " Only problem setter can remove the problem");
        require(currentProblem.isActive, "Problem already archieved");
        currentProblem.isActive = false;
        uint retrieval = currentProblem.priceTag;
        currentProblem.priceTag = 0;
        currentProblem.setterAddress.transfer(retrieval);
    }
    
    
    // Check Answer [internal]
    function submitAnswer(uint id_, uint output_) public 
    {   
        uint newSolutionID = solutionID.length;
        solutionID.push(newSolutionID);
        Solution storage solution = solutions[newSolutionID];
        solution.solverAddress = msg.sender;
        if (problems[id_].output == output_){
            solution.isCorrect = true;
            address winner = solution.solverAddress;
            uint prize = problems[id_].priceTag;
            problems[id_].priceTag = 0;
            winner.transfer(prize);
        }
        else
            solution.isCorrect = false;
        
    }
    
    // View personal solutions (tbd)
}