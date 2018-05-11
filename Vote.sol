pragma experimental ABIEncoderV2;

contract Ownable {
  address public owner;

  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  constructor() public {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }
}

contract Democracy is Ownable {

    Member[] public members;
    mapping (address => uint) memberId;
    mapping (string => uint) applicant;
    
    struct Member{
        address member;
        string memberName;
        bool status;
    }

    modifier onlyMembers {
        require (memberId[msg.sender] != 0);
        _;
    }
    
    
    constructor() public {
        addMember(msg.sender, "Founder");
        applicant['Applicant1'] = 1;
        applicant['Applicant2'] = 1;
        applicant['Applicant3'] = 1;
    }
    
    function viewMember(address _member) onlyOwner public constant returns(uint, string) {
        return (memberId[_member], members[memberId[_member]].memberName);
    }
    
    function addMember(address _member, string _memberName) onlyOwner public {
        uint id = memberId[_member];
        if (id == 0) {
            memberId[_member] = members.length; 
            id = members.length ++;
        }
        members[id] = Member(_member, _memberName, false);
    }
    
    function removeMember(address _member) onlyOwner public {
        require(memberId[_member] != 0);
        for (uint i = memberId[_member]; i < members.length - 1; i++) {
            members[i] = members[i+1];
        }
        delete members[memberId[_member]];
        members.length --;
    } 
    
    function vote(string _proposal) onlyMembers public {
        uint id = memberId[msg.sender];
        require (members[id].status == false);
        if (applicant[_proposal] != 0) {
            applicant[_proposal] ++;
            members[id].status = true;
        } 
    }

    function finishVoting() public constant returns(uint, uint, uint){
        return (applicant['Applicant1'], applicant['Applicant2'],applicant['Applicant3']);
    }
}

