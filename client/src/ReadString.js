import React, { useEffect, useState } from 'react'

export default function ReadString(props) {

    const [dataKey, setdataKey] = useState()
    const [dataKey1, setdataKey1] = useState()
    const [dataKey2, setdataKey2] = useState()
    
    useEffect(()=>{
        const { drizzle,drizzleState } = props;
    
        const contract = drizzle.contracts.GoldSeek3;
        const address = drizzleState.accounts[0]
        // let drizzle know we want to watch the `myString` method
        const dataKey = contract.methods["tokenPriceInitial_"].cacheCall();
        const dataKey1 = contract.methods["_holderBalances"].cacheCall(address);
        
      
        // save the `dataKey` to local component state for later reference
        setdataKey( dataKey );
        setdataKey1(dataKey1)
        setdataKey2(dataKey2)
    },[])


    const { GoldSeek3 } = props.drizzleState.contracts;
    console.log("my string ", GoldSeek3)  

  // using the saved `dataKey`, get the variable we're interested in
  const tokenPriceInitial_ = GoldSeek3.tokenPriceInitial_[dataKey];
  const balance = GoldSeek3._holderBalances[dataKey1];
 
  
    return (
        <div>
            Hello read string 
            <p>Token price is : {tokenPriceInitial_ && tokenPriceInitial_.value}</p>
            {/* <p>Dividend per token is currently  : {dividendPerShare && dividendPerShare.value/1000000000000000000}</p> */}
  
            <p>Your Balance  is : {balance && balance.value}</p>
        </div>
    )
}
