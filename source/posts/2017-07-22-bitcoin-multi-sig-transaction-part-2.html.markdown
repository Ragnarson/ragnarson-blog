---
title: Bitcoin multi-sig transaction part 2
author: piotr
cover_photo: cover.png
tags: development
---
Welcome back bitcoin freaks. [In the previous episode](https://blog.ragnarson.com/2017/06/06/bitcoin-multi-sig-transaction-part-1.html), we created a multi-sig transaction. [Go back to that blog post](https://blog.ragnarson.com/2017/06/06/bitcoin-multi-sig-transaction-part-1.html) if you don't know what `multi-sig` means.

Our code works. The transaction was made. The problem is that it handle only a theoretical use case when both private keys owners use the same machine to sign the transaction. We need to handle a real life situation when they use different machines. They have to be able to sign the transaction and send signatures to each other.

READMORE

## Send the signature
Let's assume we already received the `UTXOs` and the transaction is created. The only thing we have to cover is to sign the transaction. To achieve this goal we will use `getSignatures` method:

```
var firstSignatures = tx.getSignatures(privateKeys[0]);
```

We passed the first private key to this method. It means all inputs will be signed with this private key. As a result, we will receive an array of signatures. The number of array elements is equal to inputs that we use in the transaction. The `input` comes from `UTXOs`, so as many `UTXOs` will be used in the transaction as many signatures will be made. One for each input.

Now, the second person can apply signatures of the first person

```
for(var i = 0; i < firstSignatures.length; i++) {
  tx.applySignature(firstSignatures[i]);
}
```

and sign the transaction himself:

```
tx.sign(privateKeys[1]);
```

## Send the signed transaction
The second approach is to sign the transaction, serialize it and sent to the second person.

The first person signs the transaction and serializes it:

```
tx.sign(privateKeys[0]);
var serializedTx = tx.toObject();
```

The second one creates a new transaction based on received serialized transaction and signs it as well:

```
tx = new bitcore.Transaction(serializedTx)
tx.sign(privateKeys[1]);
```

That’s all folks. The transaction is ready to be broadcasted to the bitcoin network.

[Check out entire multi-sig transactions code from this and previous article.](https://github.com/PiotrMisiurek/screw-it-lets-do-it/tree/master/multi-sig)

In the next episode, we will talk about `nLockTime` option. See you soon :)

You are welcome to leave a tip if you like the content:

* BTC: 14DgncjAnqM3Wd2pYyoJTXckSXuVv43cNx
* ETH: 0x3e6bE376ef37D96bd3E7F792098c90B87B84B042
