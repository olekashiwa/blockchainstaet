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

library SafeMath {

  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return a / b;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}

contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  uint256 totalSupply_;

  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  function balanceOf(address _owner) public view returns (uint256) {
    return balances[_owner];
  }

}

contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;

  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }

  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}

contract MintableToken is StandardToken, Ownable {
  event Mint(address indexed to, uint256 amount);
  event MintFinished();

  bool public mintingFinished = false;


  modifier canMint() {
    require(!mintingFinished);
    _;
  }

  function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
    totalSupply_ = totalSupply_.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    emit Mint(_to, _amount);
    emit Transfer(address(0), _to, _amount);
    return true;
  }

  function finishMinting() onlyOwner canMint public returns (bool) {
    mintingFinished = true;
    emit MintFinished();
    return true;
  }
}


contract HonoreToken is MintableToken{
 
    HonoreToken public token;
    uint256 rate = 1;
    uint256 uploadReward = 1000; 
    uint256 recallReward = 10;
    
    uint256 rating_buy = 5; // increase file rating on value
    uint256 rating_comment = 1; // increase file rating on value
    
    // array for users genres
    mapping (address => uint[]) genres;
    
    // each address has array of links, that person can use
    // each address has array of prices of their files
    // each address has array of links with comments to their files
    mapping (address => string[]) file_links;
    mapping (address => mapping(string => uint)) file_links_price;
    mapping (string => string[]) file_link_comments;
    mapping (string => uint256) file_rating; 
    mapping (string => string[]) file_genres;
    
    function HonoreToken() {
        
    }
    
    // function for author to upload new file. Reward for uploading. 
    function uploadFile(string _link, uint _price, string[] _genres) public {
        file_links[msg.sender].push(_link);
        file_links_price[msg.sender][_link] = _price;
        file_rating[_link] = 0;
        file_genres[_link] = _genres;
        
        totalSupply_ = totalSupply_.add(uploadReward);
        balances[msg.sender] = balances[msg.sender].add(uploadReward);
    }
    
    // function for buying files. Rights are transferred for sender. 
    function buyFile(address file_owner, string _link) external payable {
        uint256 weiAmount = msg.value;
        uint256 tokens = _getTokenAmount(weiAmount);
        if (file_links_price[file_owner][_link] == tokens) {
            file_links[msg.sender].push(_link);
            file_links_price[msg.sender][_link] = tokens;
            file_rating[_link] += rating_buy;
            
        }
    }
    // show your arrays of files
    function showFiles() public constant returns(string[]){
        return file_links[msg.sender];
    }
    
    // Users can comment texts and they are given a small reward for activity in network. 
    function makeRecall(string _link, string _comment, uint _rate) constant returns(bool){
        if (_rate > 2) {
            return false;
        }
        file_link_comments[_link].push(_comment);
        file_rating[_link] += _rate + rating_comment;
        
        totalSupply_ = totalSupply_.add(uploadReward);
        balances[msg.sender] = balances[msg.sender].add(uploadReward);
        
        return true;

    }

    // function for choose genres. Each number will be equal to genre.
    function changeGenres(uint[] _genre) public{
        genres[msg.sender] =  _genre;
    }
    
    // show your genres 
    function showGenres(address _person) public constant returns(uint[]) {
        if (genres[_person].length != 0) {
           return genres[_person];
        }
    }
    
    // change reward for uploading files. Only owner can do this. 
    function changeUploadReward(uint256 _newReward) onlyOwner public returns (bool){
        uploadReward = _newReward;
        return true;
    }
     // change reward for commenting files. Only owner can do this.
    function changeRecallReward(uint256 _newReward) onlyOwner public returns (bool){
        recallReward = _newReward;
        return true;
    }
    
    // amount of wei was sended -> token
    function _getTokenAmount(uint256 _weiAmount) internal view returns (uint256) {
        return _weiAmount.mul(rate);
    }
    
}

