---
title: Bitcoin multi-sig transaction part 1
author: piotr
cover_photo: cover.png
---
Welcome again. In this episode, we will code a bitcoin multi-sig transaction based on the bitcore library.

A multi-sig transaction means that an output has to be signed by more than one private key. This kind of transactions has a lot of practical use cases. Let’s say we have a company founded by three people. They decided that any outcome has to be confirmed by at least two of them. They create a special bitcoin address where companies bitcoins are stored. The address will require at least two signatures to make any outgoing transaction valid.

READMORE

Let's start with creating this address. We will need public keys of our co-founders. To create them we need to firstly create a private key for each of them. So let's generate three private and public keys:

```
var bitcore = require("bitcore-lib");

var privateKeys = [];
var publicKeys = [];

for (var i = 0; i < 3; i++) {
  privateKeys[i] = new bitcore.PrivateKey;
  publicKeys[i] = bitcore.PublicKey(privateKeys[i]);
  console.log("Private " + i + ": " + privateKeys[i].toWIF());
  console.log("Public " + i + ": " + publicKeys[i]);
}
```

 Print an output and save it aside. We will need those addresses in next scripts.

When we have public keys creating the multi-sig address is easy as that:

```
var address = new bitcore.Address(publicKeys, 2, bitcore.Networks.testnet);

console.log(address);
```

Save this address like you did with your private and public keys. You will need them in the next script.

We created the new `bitcore.Address` by passing following attributes:

* array of public keys
* a number of signatures required to make a transaction valid. In our case, it is 2 of 3 (we have three public keys)
* we want to create a `testnet` address. Change to `bitcore.Networks.livenet` if you want to use it for real bitcoins transactions

The address is ready but empty. We need to transfer to it some test bitcoins. To do this, we just have to make a standard transaction. Like the one we did in the previous post: [Code your own bitcoin transaction](https://blog.ragnarson.com/2017/04/06/code-your-own-bitcoin-transaction.html) !

When we have some test bitcoins at our address we can try to pay with them. You can try to use the code from the regular transaction and sign it with one of the private keys. It won’t work. It will let you know that some inputs are not signed. It is because the transaction has to be signed by at least two private keys.

Let's code it from the scratch.

In the first step, we will import all three public keys and two of private keys as well as our multi-sig address:

```
var bitcore = require("bitcore-lib");

var privateKeys = [
  bitcore.PrivateKey.fromWIF("Kyu2q39avSmjuJbFp9mfh5mh8ZPYpyDxfZvRLSrcosdBiX6xWbG1"),
  bitcore.PrivateKey.fromWIF("KwJ5KYx4fDCNEHG4jmmoQUveGkSxEJ4CqeEpTTDNgP5hmQLt41Ex")
];

var publicKeys = [
  "02284cc8b2717d564d79cae638679ca1afd4a0f84fdc3ddb5fa1fe4698423d836b",
  "03a98271626ff1bdff6dd18393b565e8675124ab43eab24efb6af352a06b56f91a",
  "02d9e82923328f3dc434b8ff796c720321ce4e4874f248a2a8c38c1878717ca9f8"
];

var sourceAddress = "2NCv16HwcaTy2NV3XRSSfUEqmubhYesZfPm";
```

As a `targetAddress` we will use a new one:

```
var targetAddress = (new bitcore.PrivateKey).toAddress(bitcore.Networks.testnet);
```

Now, we have to ask  bitcoin blockchain about `UTXOs` for our multi-sig address.
As we don't have a bitcoin full-node we will use `Insight` library to read the blockchain for us and broadcast our transactions to the network.

```
var Insight = require("bitcore-explorers").Insight;
var insight = new Insight("testnet");

insight.getUnspentUtxos(sourceAddress, function(error, utxos){
  if (error) {
    console.log(error);
  } else {
    // we will create our transaction here
  }
```

When we know the `UTXOs` we can create a transaction.

```
var tx = new bitcore.Transaction();
```

The object for the transaction was created.

```
tx.from(utxos, publicKeys, 2);
```

Bitcoins we want to spend are included in `UTXOs` we have just received. Because they belong to the multi-sign address we also have to pass an array of all public keys that were used to create the `address`. In the last argument, we will require signatures of two of private keys.

```
tx.to(targetAddress, 48792);
```

We set up the receiver and the amount we want to transfer.

```
tx.change(sourceAddress);
```

The change should go back to us.

It is time to sign the transaction with two private keys:

```
tx.sign(privateKeys[0]); // first signature
tx.sign(privateKeys[1]); // second signature
```

The transaction is signed. It can be broadcasted to network:

```
insight.broadcast(tx, function(error, transactionId) {
  if (error) {
    console.log(error)
  } else {
    console.log(transactionId);
  }
});
```

As a result, you will receive the transaction id. You can copy & paste it to any testnet blockchain explorer to confirm that it works.

Yes, it works but our implementation is still far from being a reality. We used `Transaction#sign` where owners of both private keys use the same computer to sign the transaction. In real live, they will use different machines and they will need to somehow export/import transaction signatures. We will take care of it in the next blog post. See ya!

You are welcome to leave a tip if you like the content:

* BTC: 14DgncjAnqM3Wd2pYyoJTXckSXuVv43cNx
* ETH: 0x3e6bE376ef37D96bd3E7F792098c90B87B84B042
