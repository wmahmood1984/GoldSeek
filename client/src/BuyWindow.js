import React, { useState } from 'react'

export default function BuyWindow(props) {

    const [stackID, setStackID] = useState(null)
    const [referral,setReferral] = useState()

    const setValue = () => {
        const { drizzle, drizzleState } = props;
        const contract = drizzle.contracts.GoldSeek2;
        const { transactions, transactionStack } = props.drizzleState;
        // let drizzle know we want to call the `set` method with `value`
        const stackId = contract.methods.Buy.cacheSend( {
          from: drizzleState.accounts[0],
          value: 200000000000000000
        })
         
        // save the `stackId` for later reference
        setStackID( stackId );
        showReferral()
      };

      const showReferral = async ()=>{
        const referral = props.drizzleState.accounts[0]
        setInterval(() => {
          setReferral(referral)
        }, 5000);  

      }

      const getTxStatus = () => {
        // get the transaction states from the drizzle state
        const { transactions, transactionStack } = props.drizzleState;
        console.log("transaction",transactions)    
        // get the transaction hash using our saved `stackId`
        const txHash = transactionStack[stackID];
    
        // if transaction hash does not exist, don't display anything
        if (!txHash) return null;

    
        // otherwise, return the transaction status
        return `Transaction status: ${transactions[txHash] && transactions[txHash].status}`;
      };
    
    
      return (
        <div>
        <button onClick={setValue}>Buy</button>
          <div>{getTxStatus()}</div>
          {referral? <p1>your referral link is : {`http://www.abc.com/${referral}`}</p1>:null}
        </div>
      );
}
