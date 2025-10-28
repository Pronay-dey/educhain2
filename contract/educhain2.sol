// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title EduChain - Decentralized Education Credential System
 * @dev Smart contract for issuing and verifying educational credentials on blockchain
 */
contract Project {
    
    // Struct to store credential information
    struct Credential {
        string studentName;
        string courseName;
        string institutionName;
        uint256 issueDate;
        string credentialHash;
        bool isValid;
    }
    
    // Mapping from credential ID to Credential
    mapping(uint256 => Credential) public credentials;
    
    // Mapping from institution address to authorized status
    mapping(address => bool) public authorizedInstitutions;
    
    // Contract owner
    address public owner;
    
    // Counter for credential IDs
    uint256 public credentialCount;
    
    // Events
    event CredentialIssued(uint256 indexed credentialId, string studentName, string courseName, address indexed institution);
    event CredentialRevoked(uint256 indexed credentialId);
    event InstitutionAuthorized(address indexed institution);
    event InstitutionRevoked(address indexed institution);
    
    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }
    
    modifier onlyAuthorized() {
        require(authorizedInstitutions[msg.sender], "Only authorized institutions can perform this action");
        _;
    }
    
    constructor() {
        owner = msg.sender;
        authorizedInstitutions[msg.sender] = true;
    }
    
    /**
     * @dev Core Function 1: Issue a new educational credential
     * @param _studentName Name of the student
     * @param _courseName Name of the course/degree
     * @param _institutionName Name of the issuing institution
     * @param _credentialHash Hash of the credential document (IPFS hash or similar)
     */
    function issueCredential(
        string memory _studentName,
        string memory _courseName,
        string memory _institutionName,
        string memory _credentialHash
    ) public onlyAuthorized returns (uint256) {
        credentialCount++;
        
        credentials[credentialCount] = Credential({
            studentName: _studentName,
            courseName: _courseName,
            institutionName: _institutionName,
            issueDate: block.timestamp,
            credentialHash: _credentialHash,
            isValid: true
        });
        
        emit CredentialIssued(credentialCount, _studentName, _courseName, msg.sender);
        
        return credentialCount;
    }
    
    /**
     * @dev Core Function 2: Verify a credential's authenticity
     * @param _credentialId ID of the credential to verify
     * @return isValid Whether the credential is valid
     * @return studentName Name of the student
     * @return courseName Name of the course
     * @return institutionName Name of the institution
     * @return issueDate Date when credential was issued
     */
    function verifyCredential(uint256 _credentialId) public view returns (
        bool isValid,
        string memory studentName,
        string memory courseName,
        string memory institutionName,
        uint256 issueDate
    ) {
        require(_credentialId > 0 && _credentialId <= credentialCount, "Invalid credential ID");
        
        Credential memory cred = credentials[_credentialId];
        
        return (
            cred.isValid,
            cred.studentName,
            cred.courseName,
            cred.institutionName,
            cred.issueDate
        );
    }
    
    /**
     * @dev Core Function 3: Revoke a credential (in case of fraud or error)
     * @param _credentialId ID of the credential to revoke
     */
    function revokeCredential(uint256 _credentialId) public onlyAuthorized {
        require(_credentialId > 0 && _credentialId <= credentialCount, "Invalid credential ID");
        require(credentials[_credentialId].isValid, "Credential already revoked");
        
        credentials[_credentialId].isValid = false;
        
        emit CredentialRevoked(_credentialId);
    }
    
    /**
     * @dev Authorize a new institution to issue credentials
     * @param _institution Address of the institution to authorize
     */
    function authorizeInstitution(address _institution) public onlyOwner {
        require(!authorizedInstitutions[_institution], "Institution already authorized");
        
        authorizedInstitutions[_institution] = true;
        
        emit InstitutionAuthorized(_institution);
    }
    
    /**
     * @dev Revoke an institution's authorization
     * @param _institution Address of the institution to revoke
     */
    function revokeInstitutionAccess(address _institution) public onlyOwner {
        require(authorizedInstitutions[_institution], "Institution not authorized");
        require(_institution != owner, "Cannot revoke owner's access");
        
        authorizedInstitutions[_institution] = false;
        
        emit InstitutionRevoked(_institution);
    }
    
    /**
     * @dev Get complete credential details
     * @param _credentialId ID of the credential
     */
    function getCredential(uint256 _credentialId) public view returns (Credential memory) {
        require(_credentialId > 0 && _credentialId <= credentialCount, "Invalid credential ID");
        return credentials[_credentialId];
    }
}
