---
title: Code your own bitcoin transaction
author: piotr
cover_photo: cover.png
tags: development, blockchain
---

Today we will code our first bitcoin transaction. To achieve this goal we will use JavaScript library called [bitcore](https://github.com/bitpay/bitcore-lib). JavaScript is the most popular, modern programming language and almost every developer knows it, so it makes this article universal and useful for the wider audience.

READMORE

Before you continue to read the article, you should have at least basic technical knowledge about how bitcoin blockchain works. If not please dedicate a few minutes to read [brief introduction to blockchain](https://blog.ragnarson.com/2016/12/01/blockchains-a-brief-introduction.html). If you have more time, like a few hours, I recommend you to read [Mastering Bitcoin](https://github.com/bitcoinbook/bitcoinbook/tree/develop).

[Let's start with a new NPM project](https://docs.npmjs.com/cli/init) with following dependencies:

```
[...]
"dependencies": {
    "bitcore-explorers": "^1.0.1",
    "bitcore-lib": "^0.13.19"
}
[...]
```

Open `index.js` file and import `bitcore` library:

```
var bitcore = require("bitcore-lib");
```

To spend bitcoins we need an address that contains bitcoins and a private key that allows us to spend it. We will import the private key in `WIF` version. `WIF` is an abbreviation of `Wallet Import Format`. It is in use to easily import keys between bitcoin wallets.
Then we will create a testnet address from that private key:

```
var privateKeyWIF = 'cQN511BWtc2dSUMWySmZpr6ShY1un4WK42JegGwkSFX5a8n9GWr3';
var privateKey = bitcore.PrivateKey.fromWIF(privateKeyWIF);
var sourceAddress = privateKey.toAddress(bitcore.Networks.testnet);
```

WARNING! In that example, I share with you my private key. You shouldn't do that in real life. The one who has the private key is the owner of the bitcoins allocated to address made from this key. It is a sign of the ownership.

In this case, I just shared with you the key used to create a testnet address. Testnet is a bitcoin network created for software and scripts testing. It doesn't contain real bitcoins, only the test ones. You can gain them for free. Even if someone steals them it is not a big deal. I can take that risk to provide you a working out of the box example.

If someone used/stole all test bitcoins from this address you can recharge it. Copy the address `mibK5jk9eP7EkLH175RSPGTLR27zphvvxa` and [paste it in the form](http://tpfaucet.appspot.com/)

It is time to create our `targetAddress` where we want to sent our test bitcoins.

```
var targetAddress = (new bitcore.PrivateKey).toAddress(bitcore.Networks.testnet);
```

Let's check our source address if any bitcoins remained there. Bitcoin network use `UTXO` to store that information. `UTXO` is an abbreviation of [Unspent Transaction Output](https://bitcoin.org/en/glossary/unspent-transaction-output).

Houston, we have a problem. We don't have a bitcoin network client. The full node requires at least 125 GB of hard drive space which is too much for my poor MacBook Air. We have to find a workaround. We have to ask someone to read the Bitcoin network for us. And to broadcast our transaction as well.

In this case, we are losing the biggest advantage of bitcoin blockchain. The architecture of the system makes us don't have to trust any parties. The network consensus, the math and the encryption make the data stored in blockchain trusted. But now we are asking middleman to read this data for us. He might provide us fake or outdated data.

We will use `Insight` from `bitcore-explorers` library. As it is quite popular and we are only learning here we can assume it can be trusted. The final solution should be to have our own Bitcoin full node.

Ok, let's use `Insight` to check how many Bitcoins we have to spend.

```
var Insight = require("bitcore-explorers").Insight;
var insight = new Insight("testnet");

insight.getUnspentUtxos(sourceAddress, function(error, utxos) {
  if (error) {
    console.log(error);
  } else {
    console.log(utxos);
    // transaction code goes here
}
```
The output of `UTXOs` is an array. Each of its element contains info about the address that is a owner of `UTXO` and an amount of Satoshis (`1 Satoshi = 0.00000001 Bitcoin`). It looks like this:

```
[ <UnspentOutput: dbe9ce2ae27d7ffcba40195e7ee628e9165568115931386b27b0c0674fa019c5:1, satoshis: 5047177248, address: mibK5jk9eP7EkLH175RSPGTLR27zphvvxa> ]
```

It is time to create our transaction:

```
var tx = new bitcore.Transaction();

```
Let's set the received `UTXOs` as an `input` of the transaction. An important thing to notice: we are not getting bitcoins from `address` but from `UTXOs`

```
tx.from(utxos);
```

Let's set the receiver of our transaction and amount we want to deliver to him. The amount is given in `Satoshis`, the smallest unit of Bitcoin: `1 Satoshi = 0.00000001 Bitcoin`. This is the `output` of our transaction:

```
tx.to(targetAddress, 10000);
```

It is time to talk about `the change`. `UTXOs` are the output from transactions that point to our address and have not been spent yet. `UTXOs` are like a bank note. If you have 5 dollar note in your pocket and want to buy 2$ beer you don't cut a part of the bill and give it to a cashier. You give the 5$ note and receive 3$ change. It works exactly the same with `UTXOs`. You have to use entire `UTXO` in a transaction and specify the `change` value and `address` then the `change` should be returned.

WTF? Do I have to specify the `change` value? In shop when I buy 2$ dollar beer with 5$ note then I receive 3$ change in return. It is obvious. Nothing to be calculated.

In Bitcoin, there is a little difference. In reality, the `change` is just another output of a transaction. And the sum of `outputs` should be a little smaller than the sum of `input`. The difference is called `mining fee`. You pay it to the miners to be included in the transactions block. The wallets or libraries like `bitcore.io` estimate the `mining fee` for us. So in our case, we just specify the `address` where `change` should be returned.

```
tx.change(sourceAddress);
```

You can notice that we use our `sourceAddress`. As a result, some of existing `UTXOs` for this address disappear (they will be spent already), but there will also be a new one created(the one from the `change`).

In real life, the wallets are using a new address for each of your transactions. The goal of that is to improve anonymity. How is it possible that from one `private key` the wallet is able to create many `public keys` and `addresses`? [Read about Deterministic wallet to find the answer](https://en.bitcoin.it/wiki/Deterministic_wallet)

Great! Everything is set! The only thing we have to do right now is to sign the transaction with our `private key` and send it to the Bitcoin blockchain. As I mentioned before we don't have our own bitcoin client. We use external tool to communicate with the blockchain. The question is: can we put trust in it.  When we broadcast transaction there is no risk that the tool will capture  private key or manipulate the transaction (change `targetAddress` for example). If the tool makes any changes listed above, then the signature will not be valid any more and transaction will be rejected. The only risk is that the tool won't sent the transaction at all. But we can verify it in a second with any blockchain explorer. So without fear, we can use `Insight` again:

```
tx.sign(privateKey);
tx.serialize();

insight.broadcast(tx, function(error, transactionId) {
  if (error) {
    console.log(error);
  } else {
    console.log(transactionId);
  }
});
```
That's all folks! The transaction is broadcasted to the network. If everything goes well we will receive transaction id. Then copy and paste it in [bitcoin blockchain explorer](http://tbtc.blockr.io/) to see if it really works.


[The entire code is available on GitHub](https://github.com/PiotrMisiurek/screw-it-lets-do-it/blob/829ae579c52112e216ed348cda15ed555744eccf/index.js)

### What is next
In the next bitcoin episode, we will code the [multi-sig transaction](https://en.bitcoin.it/wiki/Multisignature)

You are welcome to leave a tip, if you like the content:

* BTC: 14DgncjAnqM3Wd2pYyoJTXckSXuVv43cNx
* ETH: 0x3e6bE376ef37D96bd3E7F792098c90B87B84B042
