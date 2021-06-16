//1) buyer will give us tron and we will issue them credit
// 2) upon every buy, 25% commission will be deducted from buyer and 10% will be re-distributed among existing credit holders as dividend, 7% will be given to direct referrer, and 3% will be given to indirect referrer, 5% admin fee will go to admins.
// 4) upon every buy and sale, price of credits will be re-calculated
// 5) upon withdrawal, credit holder will receive tron back in their wallet
// 6) a referral code will be generated for every purchasing.
// 7) at every sale 7% will be deducted and distributed among all the existing credit holders

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0; 

contract GoldSeek2 {
    address public owner;
    uint256 constant internal tokenPriceInitial_ = 0.0000001 ether;
    uint256 constant internal tokenPriceIncremental_ = 0.00000001 ether;
    uint256 constant internal magnitude = 2**64;
    mapping (address => uint256) public _holderBalances;
    mapping (address => address) public _referrerMapping;

    uint256 public TotalSupply;
    uint256 public RSupply;
    uint256 public TotalEthStaked;
    address public _admin = 0x0000000000000000A0D000000000000000000000;
    address public _Referer = 0x412fc8F58D2c68D5C1c7A011660aefA5f261d862;
    address public I_Referer = 0x7cfa8CD3DA48dE9D86aD221662f38A1295D177eC;
    uint256 public commission = 25;
    uint256 public redistribution = 10;
    uint256 public direcREferCommission = 7;
    uint256 public inDirecREferCommission = 3;
    uint256 public adminFee = 5;
    uint256 public DividendPool;
    uint256 public DividendPerToken;
    
    constructor (){
        owner = msg.sender;
    }
    
    event BuyInt (address buyer, uint256 token);
    
    function Buy ()public payable returns(uint256){
        address referrer = _Referer;
        require(msg.value>=0,"amount must not be zero");
        require(msg.value>= 0.01 ether,"amount must not be less than 0.01 ehter");
        uint256 tokengeneration = ethereumToTokens_(msg.value);
         (
          uint256 tTransfer, 
         uint256 tfee, 
         uint256 dist,
         uint256 drc,
         uint256 Idrc,
         uint256 afee) = getTValues(tokengeneration);
        
        address indirecReferrer = _referrerMapping[referrer];
        _holderBalances[msg.sender] += tTransfer;
        _holderBalances[_admin] += afee;
        if(referrer == 0x0000000000000000000000000000000000000000){
            _holderBalances[_admin] += drc;
            _holderBalances[_admin] += Idrc;

            }
        
        else if(referrer != 0x0000000000000000000000000000000000000000){
                _holderBalances[referrer] += drc;
                if(indirecReferrer!=0x0000000000000000000000000000000000000000){_holderBalances[indirecReferrer] += Idrc;} else{_holderBalances[_admin] += Idrc;}
                
                if(_referrerMapping[msg.sender]!=referrer){_referrerMapping[msg.sender]=referrer;}}
                                          
                    
        
        TotalSupply += tokengeneration;
        TotalEthStaked += msg.value;
        
        processBuySideDiv(dist);
        check();
        emit BuyInt(msg.sender, tTransfer);
        return tTransfer;
        
    
    }
    
    function check ()public returns(uint256,uint256,uint256,uint256,uint256,uint256) {
        uint256 supply = TotalSupply;
        uint256 rate = Rate_();
        uint256 buyershare = _holderBalances[msg.sender];
        uint256 referrershare = _holderBalances[_Referer];
        uint256 indReferrerShare = _holderBalances[I_Referer];
        uint256 adminShare = _holderBalances[_admin];
        
    return (supply,rate,buyershare,referrershare,indReferrerShare,adminShare
        );    
        
    }
    
    function processBuySideDiv(uint256 amount) internal {
        uint256 tokensDiv = valuetoToken(amount);
        DividendPool += amount;
        DividendPerToken = DividendPool / TotalSupply;
        
    }
    
    function getTValues (uint256 tamount) public returns (uint256,uint256,uint256,uint256,uint256,uint256){
        uint256 tfee = tamount/100*commission;
        uint256 dist = tamount/100*redistribution;
        uint256 drc = tamount/100*direcREferCommission;
        uint256 Idrc = tamount/100*inDirecREferCommission;
        uint256 afee = tamount/100*adminFee;
        uint256 tTransfer = tamount-tfee;
        return ( tTransfer,tfee,dist,drc,Idrc,afee);
    }
    
    
    
    function valuetoToken(uint256 amount) internal returns(uint256){
        
        uint256 BuyPrice = PurchasePrice();
        uint256 tokenQty = amount / BuyPrice;
        return tokenQty;
    }
    
    
    function PurchasePrice() public returns(uint256){
        if(TotalSupply==0){return tokenPriceInitial_;}
        else
            {return Rate_() + tokenPriceIncremental_;}
    }
    
    function SalePrice() public returns(uint256){
    if(TotalSupply==0){return 0;}
        else
            {return Rate_() - tokenPriceIncremental_;}
    }
    
    
    function initialPrice2() public view virtual returns (uint256) {
        return tokenPriceInitial_;
    }
    
     function balanceOf(address account) public view virtual returns (uint256) {
        return _holderBalances[account];
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
    
    
    
    
    function Rate_()
        public
        view
        returns(uint256)
    
    {    
        return 1e18 / ethereumToTokens_(1e18);
  
    
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