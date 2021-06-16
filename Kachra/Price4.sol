// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract price {
     uint256 constant internal tokenPriceInitial_ = 0.0000001 ether;
     uint256 constant internal tokenPriceIncremental_ = 0.00000001 ether;
     
     uint256 constant internal magnitude = 2**64;
    mapping (address => uint256) public _holderBalances;
    mapping (address => uint256) public _holderPaidOUt;
    mapping (address => uint256) public _holderPersonalEth;
    mapping (address => address) _referrerMapping;

    address public owner;
//    uint256 public RSupply;
    uint256 public TotalEthStaked;
    address _admin = 0x0000000000000000A0D000000000000000000000;  
    address _Referer = 0x412fc8F58D2c68D5C1c7A011660aefA5f261d862;
    address I_Referer = 0x7cfa8CD3DA48dE9D86aD221662f38A1295D177eC;
    uint256 commission = 25;
    uint256 redistribution = 10;
    uint256 direcREferCommission = 7;
    uint256 inDirecREferCommission = 3;
    uint256 adminFee = 5;
    uint256 SellingCommission = 7;
    uint256 public rateOfDiv;
//    uint256 public DividendPool;
 //   uint256 public DividendPerToken;
    
    uint256 public TotalSupply = 0;
    
    constructor (){
        owner = msg.sender;
    }
    
    
    
    function buy(address referrer)public payable returns(uint256){
        uint256 remainder = msg.value % 100000000000;
        uint256 tokenToBuy = msg.value - remainder;
        uint256 tokens = ethereumToTokens_(tokenToBuy);
        address indRferrer = _referrerMapping[referrer];
        
            (
          uint256 tTransfer,
          uint256 dist,
         uint256 drc,
         uint256 Idrc,
         uint256 afee) = getTValues(tokens);
        _holderBalances[msg.sender] += tTransfer; 
        _holderBalances[_admin]+=afee;
        _holderBalances[address(this)]+=dist;
        if(referrer != 0x0000000000000000000000000000000000000000)
            {_holderBalances[referrer] += drc;
                if(indRferrer != 0x0000000000000000000000000000000000000000){_holderBalances[indRferrer] += Idrc;}
                else{_holderBalances[_admin]+=Idrc;}
            }
        else{_holderBalances[_admin]= drc; _holderBalances[_admin]= Idrc;}
        

    
        
        TotalSupply += tokens;
        processDiv();
        return tokens;
        
        }
        
     uint256 public payment;
    
    function sell(uint256 number) public payable {
        (
          uint256 tTransfer,uint256 tfee) = getSValues(number);
        

        _holderBalances[msg.sender] -= number;
        _holderBalances[address(this)] += tfee;
         TotalSupply -= tTransfer;
         
         uint256 rate = ethereumToTokens_(100000000000);
         uint256 valueOFSell = tTransfer*rate / (100000000000 * 1000000000000000000);
        _holderPersonalEth[msg.sender] += valueOFSell;
        processDiv();
    }
    
    
    function Dividendsell(uint256 number) public payable {
    
        

        _holderBalances[address(this)] -= number;
    
         TotalSupply -= number;
         
         uint256 rate = ethereumToTokens_(100000000000);
         uint256 valueOFSell = number*rate / (100000000000 * 1000000000000000000);
        _holderPersonalEth[msg.sender] += valueOFSell;
        
    }
    
    function processDiv() internal {
        rateOfDiv = _holderBalances[address(this)] * magnitude / TotalSupply;
    }
    
    function dividendBalance(address holder) public view returns(uint256) {
        uint256 _dividendBalance = _holderBalances[holder] * rateOfDiv / magnitude;
        uint256 dividendTopay = _dividendBalance - _holderPaidOUt[holder];
        return dividendTopay;
    }
    
    function withdrawDividend(uint256 amount) public {
        require(dividendBalance(msg.sender)>=amount,"amount is more than the dividend balance");
        _holderPaidOUt[msg.sender] += amount;
         Dividendsell(amount);
    }
    
function withdrawPersonalEth(uint256 amount) payable public {
        require(_holderPersonalEth[msg.sender]>=amount,"amount is more than the personal balance");
        _holderPersonalEth[msg.sender] -= amount;
         payable(msg.sender).transfer(amount);
    }
    
    
function balanceOf() public view returns(uint256,uint256,uint256,uint256){
        return (TotalSupply,_holderBalances[I_Referer],_holderBalances[_Referer],_holderBalances[_admin]);
    }


function getTValues (uint256 tamount) public view returns (uint256,uint256,uint256,uint256,uint256){
        uint256 tfee = tamount/100*commission;
        uint256 dist = tamount/100*redistribution;
        uint256 drc = tamount/100*direcREferCommission;
        uint256 Idrc = tamount/100*inDirecREferCommission;
        uint256 afee = tamount/100*adminFee;
        uint256 tTransfer = tamount-tfee;
        return ( tTransfer,dist,drc,Idrc,afee);
    }
    
    
    function getSValues (uint256 tamount) public view returns (uint256,uint256){
        uint256 tfee = tamount/100*SellingCommission;
        uint256 tTransfer = tamount-tfee;
        return ( tTransfer,tfee);
    }
    

    
    
    

function ethereumToTokens_(uint256 _ethereum)
        public
        view
        returns(uint256)
    {
        uint256 _tokenPriceInitial = tokenPriceInitial_ * 1e18;
        uint256 _tokensReceived = 
         (
            (
                // underflow attempts BTFO
                SafeMath.sub(
                    (sqrt
                        (
                            (_tokenPriceInitial**2)
                            +
                            (2*(tokenPriceIncremental_ * 1e18)*(_ethereum * 1e18))
                            +
                            (((tokenPriceIncremental_)**2)*(TotalSupply**2))
                            +
                            (2*(tokenPriceIncremental_)*_tokenPriceInitial*TotalSupply)
                        )
                    ), _tokenPriceInitial
                )
            )/(tokenPriceIncremental_)
        )-(TotalSupply)
        ;
        
            return _tokensReceived;
    }
    
    
            function sqrt(uint x) internal pure returns (uint y) {
        uint z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }
    
    
}





library SafeMath {

   
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

   
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

   
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

/**
* Also in memory of JPK, miss you Dad.
*/
    
}













