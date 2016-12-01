---
title: "Blockchains: A brief introduction"
author: michald
cover_photo: cover.png
---

This post begins a series about the blockchain technology wherein I will try to answer the common questions like what it is, how it works and where blockchains are used. However, I will not go into technical details, I will only focus on a general overview.

READMORE

### Genesis
I am pretty sure you heard about Bitcoin, a cryptocurrency that has its own electronic payment infrastructure which allows transferring money between parties. Bitcoin compared with traditional payment systems does not have a centralised authority like banks where all transactions are stored. In contrast, all computers in Bitcoin network running a special software carry out this function. Also, Bitcoin has no physical value like coins or bills, it only has a digital value. Main goals of Bitcoin are to decentralise payments around the world, keep them safer and uncheatable by applying cryptographic methodologies.

When first bitcoins were spent in 2009, a new technology called the blockchain was introduced. It provided a security layer and allowed broadcasting bitcoins without a trusted intermediary. The blockchain is the main technology which stands behind Bitcoin.

### What is the blockchain?
Technically, the blockchain is a database that stores all records (blocks) since its inception joining them into an inseparable chain. The blockchain is distributed through a peer-to-peer network. The network enables communication without a centralised server and all machines (nodes) have the same privileges. In other words, they are clients and servers at the same time. Each node in the network stores a copy of the blockchain and once it gets updated all other nodes are kept in sync. This approach helps to decentralise a system and reduces the risk of data loss as long as at least one node holds the blockchain. The only way to delete it permanently is to erase the blockchain from all the nodes what is virtually impossible for such huge systems like Bitcoin.

### How does the blockchain work?
There are many implementations of the blockchain concept, but let us focus on the most popular network, Bitcoin.

Before I explain more about the process, you need to know what is a block and a transaction.

A block is a group of valid transactions identified by a hash, a unique, random value determined by a proof-of-work (I will describe it later on). A transaction contains information about bitcoins transferred between people. Let me explain it with an example. Let’s say, we have three users: Tom, Alice and Bob. Alice gets 15 bitcoins from Tom and it is her total amount of funds. Next, Alice sends 5 bitcoins to Bob. The transaction stores these steps individually both as an input and an output. It also contains a change between all Alice’s funds and the amount of bitcoins that she is going to spend, in our case it would be 10 bitcoins. Furthermore, the change is reduced by a transaction fee that Alice pays for verifying the transaction. I will describe a transaction verification closer soon.

Before any transaction can be sent to the network it has to be signed cryptographically using a unique private key (which can be identified with a very long unique password) of a person who is going to make this transaction. The signature is required to unlock a number of assets that the person wants to spend and ensures that resources can be transferred only by their owner.

When all the data in the transaction are ready, the transaction is transmitted to all nodes in the network and awaits a verification. After submitting, it becomes irreversible. Special nodes called miners are responsible for verifying transactions. Each miner does the same checks. [Among other things](https://www.cryptocompare.com/coins/guides/how-does-a-bitcoin-node-verify-a-transaction), it verifies if the sender has enough assets to spend (it prevents double-spending). The transaction will be rejected if the person wants to send more than a number of available funds. Once the transaction is valid, it becomes a part of a candidate block (every miner has its own candidate block). It means it is not yet a part of the chain.

Each block includes a hash of the previous block. This combination connects blocks in the chain. At the same time, only one candidate block can get chosen as the next one in the blockchain. In order to determine which candidate block should be merged, the miners have to provide the proof-of-work (POW). The first miner who supplies POW will add its candidate block to the chain.

POW resembles a mathematical puzzle. It boils down to finding a hash of the candidate block with certain characteristics. It is very time-consuming task caused by a high level of randomness and uses a lot of computing power. When a miner finds a solution, it attaches the candidate block to a local chain and propagates the solution to the network. The nodes verify the correctness of the solution and then the miner gets a fixed profit (newly generated bitcoins) for solving the problem. From this moment, the remaining miners will stop solving the proof-of-work of the current candidate block and start working on the next one. This workflow is repeated over and over again.

All the above steps such as verifying transactions, composing the candidate block and providing POW are called Bitcoin mining. The drawing below illustrates the whole process.

<figure>
  ![Mining](2016-12-01-blockchains-a-brief-introduction/mining.png)
</figure>

As you can see the mining is a kind of a race, where each miner tries to be the first to solve the problem for profit (a block reward + transaction fees). However, as long as the proof-of-work is the extremely random operation to perform, the race seems to be fair. Is it right? What if some people had a farm of supercomputers that would solve such problems much faster than computers we have? They would probably have a greater chance to guess the puzzle, but it would still be a gamble and the profit might not be adequate to the processing costs.

### How much time does the mining process take?
Every system might have different requirements regarding a mining time. In Bitcoin network, an average mining time of each block takes about 10 minutes. After every 2016 block, the mining time is adjusted to keep it on the same level. The level of adjustment depends on the increasing computing power in the network. With the growing number of more and more efficient miners, the mining reward decreases twice every 4 years approximately (210,000 blocks).

### Why is the mining process needed?
The problem comes down to three questions:

1. How to verify transactions without a centralised authority?
2. How to produce new digital assets on the market assuming it should not be for free?
3. Would you channel your computer resources for challenging work for free?

All blockchain-based systems that are required to do some work, like transaction confirmations, should implement some sort of a reward to keep miners profitable. In the case of Bitcoin, the block reward reflects the processing costs for verifying transactions and solving POW by the miners. This is also a fair way to introduce new digital resources into circulation and keep the digital market continuously growing. The rate of resources emission depends on rules agreed by a community. For example, a bitcoin emission depends on POW complexity and the reward for each verified block. The bitcoin emission will stop at 21 million bitcoins and it is expected to happen around 2140.

### What will happen when all bitcoins will be mined?
There is no one, true and clear answer what will happen then. However, it is pretty obvious that we have to avoid frauds by verifying transactions. But how to keep verifiers still profitable without the block reward? In my personal opinion, there are a couple of aspects that are worth considering. Firstly, the proof-of-work could be simplified to speed up processing. Secondly, transaction fees could be sufficient to cover the processing costs. Thirdly, around 2140 our computers can be so powerful, that there will not be a reason to care about that. Of course, these are only assumptions and luckily, we have a lot of time to think how the problem could be solved.

### Should transactions be always grouped in blocks?
Not really. For example, [openchain.org](https://www.openchain.org) implements something called a transaction chain where transactions are appended directly to a chain instead of forming a block first. This approach seems to be very interesting for systems where low-level latency is very important. In blockchains, the mining process can take a significant amount of time. Even if some systems can reduce this value to a couple of seconds, it could still be too much for certain applications. [Openchain.org](https://www.openchain.org) performs real-time transaction confirmations where transactions become a part of the chain immediately.

### Where are blockchains used?
Apart from Bitcoin, there is a lot of other cryptocurrencies such as Litecoin or Peercoin. Besides financial systems, the blockchain technology was applied to online voting ([followmyvote.com](https://followmyvote.com)), a data verification system ([tierion.com](https://tierion.com)) or a cloud storage ([storj.io](https://storj.io)). All of them and many others are a proof that the blockchain concept is a viable solution for many problems and, hopefully, other applications will be created using the blockchain in the nearest future.

### Summation
The blockchain solves specific kind of problems where security and reliability are critical. The most valuable feature is performing transactions without any intermediaries and trust between parties. The blockchain is still not super popular and as every new technology requires an adoption process that takes time and needs a lot of experiments. Some people say that the blockchain technology is revolutionary and compare it to the invention of the Internet. Are they right? I do not know, I have just started my adventure with the blockchain and will continue it for sure. I strongly encourage you to try it yourself. We need people like you to keep this community growing and develop the blockchain technology.

Worth reading / watching:

* [https://www.oreilly.com/ideas/understanding-the-blockchain](https://www.oreilly.com/ideas/understanding-the-blockchain)
* [https://www.khanacademy.org/economics-finance-domain/core-finance/money-and-banking/bitcoin](https://www.khanacademy.org/economics-finance-domain/core-finance/money-and-banking/bitcoin)
* [http://www.righto.com/2014/02/bitcoin-mining-hard-way-algorithms.html](http://www.righto.com/2014/02/bitcoin-mining-hard-way-algorithms.html)
* [https://bitcoin.org/bitcoin.pdf](https://bitcoin.org/bitcoin.pdf)
