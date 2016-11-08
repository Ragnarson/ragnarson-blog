---
title: JavaScript Generators
author: maciej
---

ECMAScript 2015(ES6) brings a lot of new great features and overall language improvements. Among them we will find Generators which seems to be one of the most exciting and enjoyable JS extensions. The primary and the most important thing about them is ability to pause and resume them at a desired moment. Implementation standard by itself opens us two ways of usage. We can think of them as data producers (iterators) and data consumers (observers). Combination of those two allow us to turn them also into coroutines to handle more sophisticated tasks. How all this work and in which situations we can use generators to make our code more readable and maintainable?

READMORE

## Syntax and basics
The most simple approach to define generator function:

```js
function* simpleGeneratorFunction() {
  // (1)
  console.log('1');
  yield //(2)
  console.log('2');
  // (3)
}
```
or

```js
const simpleGeneratorFunction = function* () {
  // (1)
  console.log('1');
  yield; // (2)
  console.log('2');
  // (3)
}
```
Basically we need to pay attention to ``function*`` keyword and ``yield`` operator. With ``yield`` we can force generator to suspend itself and consume, literally yield some data. Generator method definition can contain multiple ``yield``s exepressions. This help us to gain accurate control flow of an execution and allow to pause and resume generator at particular ``yield``.

It can be little surprising that when we try to invoke our ``generatorFunction()`` the body is not executed. Instead we will receive a generator object.


## Generator object and iteration. Producing data.

```js
  const generatorFunction = function* () {
    yield '1';
    yield '2';
    return 'our return value'
  }
  // (3)

  const generatorObject = generatorFunction()
```

Few things we need to know about generator object. It implements few standards by itself: iterator protocol and itearable protocol. Our generator object is ``iterable`` (we can traverse data structure). Iterator protocol on the other hand allow us to use ``next()`` method on it.

According to Iterator specification ``next()`` is zero argument function which returns object with two properties: ``done: booolean`` and ``value`` (it can be any value returned by the iterator).

This dualistic nature allow us to make a handy use of generators as a data producers.

Presence of Iterators ``next()`` allow us to iterate through our generator object.

```js
  generatorObject.next(); // { value: '1', done: false }
  generatorObject.next(); // { value: '2', done: false }
  generatorObject.next(); // { value: 'our return value', done: true }
```

We can think of genarators as data producers. Here is some ``randomNumberGenerator``.

```js
function* randomNumberGenerator(counter = Infinity, topRange = 100) {
  while (counter--) {
    yield Math.floor((Math.random() * topRange) + 1);
    //yield random integer number from 1 to 'range'
  }

  return 'Out of the numbers';
}

const generateTwoRandomNumbers = randomNumberGenerator(2);
//We limit our iteration in this case just for two 'products'
console.log(generateTwoRandomNumbers.next());
//{ value: 53, done: false }
console.log(generateTwoRandomNumbers.next());
//{ value: 37, done: false }
console.log(generateTwoRandomNumbers.next());
//{ value: 'Out of the numbers', done: true }

```
If we want to obtain an array of 6 numbers from a range (1-52) there is an easy way to go:

```js
const sixNumbers = randomNumberGenerator(6, 52);
console.log([...sixNumbers]);

//To iterate we use just ECMAScript2015 spread operator.
//Sample result: [ 31, 16, 40, 6, 2, 41 ].
```

We need to be aware that most of the generic methods designed for iterables will omit our ``value`` for ``done: true``. ``done: true`` is treated rather like a signal for a collection outage and just breaks an interation. This behaviour might be confusing in some cases. To avoid this kind of problems it might be a good practice to treat generator  ``return`` statement only as loop breaker and do not rely on its value. This is the reason why our ``'Out of the numbers'`` statement is not included in the generated array.

According to our previous code infinitive data producer will look like the presented below:

```js
const infitifeNumbersIterator = randomNumberGenerator();
infinitifeNumbersIterator.next().value // 25
```

Here this will always produce a new random number. End will not be reached. As we can see there this approach can be used as a base for a sample ``UUID`` generator.

# Data consumption

Is there a way to stop and terminate our generator? Yes, it is. We can finish it up with ``return()`` method. This method can be executed in any moment of the iteration. It can also take 1 or 0 arguments by itself.

Basically, the ``return(value)`` is responsible for returning the given by us argument and terminating the generator.

Without an argument:

```js
infitifeNumbersIterator.return(); // { value: undefined, done: true }
```

Here we end up with ``{ value: undefined, done: true }``. It's worth to remember that ``return()`` just end the execution of our ``infitifeNumberIterator`` here. It does not care about our ``return`` statement inside generator's body. This can be misleading at the begining due to semantics similiraties.

However there is a possibility to get something different than ``undefined``. As we know, this method can receive an argument (``returns(value)``) so:

```js
  let generatorObjectToTerminate = generatorFunction();
  genaratorObjectToTerminate.return(2) // { value: 2, done: true }
```
Here we have got the first example of generator as a data consumer. ``return`` is not the only available method for processing external input.

Method ``next()`` defined in ``Generator.prototype`` is also capable of doing that and it fits even better. It can receive and send argument to our generator function body. It redefines and extends capabilities of its counterpart method from ``Iterator`` protocol (Iterator ``next()`` which arity is 0).

Treating generator object as data consumer require some understanding how and when our value is delivered. First of all we send values via ``next(value)`` and recieving them via ``yield``. Secondly we need to reach our ``yield`` statement at the very begining. Starting generator is  easy and requires just invocation of ``next()``. This is a mandatory step to reach first ``yield``. Generator Object will be suspended there and prepared for our input value.

```js
function *fooBar() {
  const a = yield;
  const b = yield;
  return a + b;
}

const fooBarGenerator = fooBar();
fooBarGenerator.next();
//Starting out generator
//yield represnted by 'a' const is reached

fooBarGenerator.next('foo');
//Sending a 'foo' value and moving to next yield

fooBarGenerator.next('bar');
//'bar' value is send. No next yield available
//return statetment is resolved
//{ value: 'fooBar', done: true }

```

Another notice must be done here. In this step by definition we are just suppling values to variables, so as a result of calling ``next(value)`` we receive this kind of iterator return value object => ``{ value: undefined, done: false }``.


#Laziness

Due to generators nature we can process data in a ``lazy way``. Operations on demand are not a problem and they could be very useful for processing: streams or large data sets as received chunks.

Here we will try to process randomly generated set of the numbers. We start from generating an array of 10 numbers from range 1 - 100. In the next step, numbers less than 26 will be taken. At the end we convert chosen numbers to alphabet characters.

```js
const lessThan = function(end, value) {
  return function(value) {
    return value < end;
  };
}

const lessThan26 = lessThan(26);
// 25 alphabet character letters

const lazyMap = function* (iterable, callback) {
  for (let value of iterable) {
    yield callback.call(this, value);
  }
};

const numberToAlphabet = function(value) {
  return String.fromCharCode(96 + value);
  //97 in ASCII is 'a'
  //Our min value is 1
};

const lazyMap = function* (iterable, callback) {
  for (let value of iterable) {
    yield callback.call(this, value);
  }
};

const numbers = [...randomNumberGenerator(10)];
console.log(numbers);
//[ 74, 16, 74, 24, 54, 96, 1, 71, 71, 77 ]

let alphabebtCharIterator = lazyMap(filter(numbers), lessThan26), numberToAlphabet);
//Our chained generator object

alphabetCharIterator.next();
//{ value: 'o', done: false }

alphabetCharIterator.next();
//{ value: 'w', done: false }

alphabetCharIterator.next();
//...

```

#Chaining

As we already saw it is possible to chain generators. This pattern can be applied in more elegant way. Usage of a helper function allow us to write modular and cleaner code.

First of all we need to combine our ``generatorsFunctions`` and return one solid ``generatorObject``.
Our function will take ``generatorFunctions`` as set of arguments and return already started ``generatorObject``. This allow us to send data directly.

```js
function composeGenerator() {
  let generatorFunctions = [...arguments];
  // Create an array of generatorFunctions
  let i = arguments.length - 1;

  let generatorObject = generatorFunctions[i]();
  // Take last generatorFunction (this is the last argument of our function)
  // Create a starting point for compose chain - generatorObject

  generatorObject.next();
  // Start our generator object.
  // Allow to receive data via next(value))
  while (i--) {
    let generatorFunction = generatorFunctions[i];
    // Link current generator next one from an end of the list

    generatorObject = generatorFunction(generatorObject);
    // Our generatorFunction by design take one argument - generatorObject

    generatorObject.next();

    // We need to start our extended generatorObject

    // We itarate till the end of generatorFunctions
  }

  return generatorObject;
  // Return generatorObject composed of all our generatorFunctions
}
```

Before we proceed to our ``generatorsFunctions`` we need to stop for a while.

For demonstration purposes we supply our ``generatorObject`` with some sample data. The idea is to simulate some asynchronuos behaviours and proceses something similiar to a stream.

Function below allows to send chunks of data to our composed ``generatorObject``.

As usual this done via ``next(chunk)`` and here some time interval (1000ms) is set.

```js
const arr = [1, 'm', 3, 'b', 'e', 10];
// Our sample data set

function sendChunk(arr, mainGeneratorObject) {
  let chunkIterator = chunksGenerator(arr);
  // Yield each element of our 'arr'
  // chunksGenerator function is defined at the bottom

  const asyncSend = setInterval(() => {
    let { value, done } = chunkIterator.next();
    // Iterate via next() in 1s interval

    done ? clearInterval(asyncSend) : mainGeneratorObject.next(value);
    // Collection outage done: true -> cancel interval action (asyncSend)
    // done: false -> fullfill mainGeneratoObject with a 'chunk' of data

  }, 1000);
  //Interval is set to 1s

  function* chunksGenerator(arr) {
    yield* arr;
    //Iterate over 'arr' yieliding each time an element of it
  }
```
Inside ``chunksGenerator`` we will find ``yield*``. This operator allow us to do some special things. Here this is just a shortcut for

```js
for (let element of arr) {
  yield element;
}
```
it can also yield anoter ``generator`` but this is behind the scope of this article.


Now we need to take care of some logic defined by ``sub-generator``'s functions.

Each generator function must take generator object as an argument. This allow us to chain them nicely. As we can see below, logic inside each generator function is very simple.

Flow of the transformation: take only integer number from our stream of data; double its value; display the output. ``yield`` is wrapped by infitive loop. This action prevent breaking our iteration after first chunk of data was proccessed.

```js
function* pickInteger(target) {
  while(true) {
    let chunk = yield;

    if(Number.isInteger(chunk)) {
      target.next(chunk);
      //Target is our generatorObject
    }
  }
}

function* doubleInt(target) {
  while (true) {
    let intNumber = yield;

    target.next(2 * intNumber);
  }
}

function* printOut(target) {
  while (true) {
    let line = yield;
    console.log(line);
  }
```

Sample of usage:

```js
const arr = [1, 'm', 3, 'b', 'e', 10];
const combinedGeneratorObject = composeGenerator(
  pickInteger,
  doubleInt,
  printOut
);

sendChunk(arr, combinedGeneratorObject);
// Time interval
// 2
// Time interval
// 6
// Time interval
// 20
```

We need to be aware that this is only an example usage and there are few things missing there for example: error handling.

#Wrapping up

Generators are something definetely new in JavaScript world. Present with us for some time brought new opportunities to tackle some certain problems. They might be tricky or confusing at the begining but learning them is a lot of fun.  This blogpost contains only some basic stuff and examples of usage.

Native support should not also be a concern. Generators are supported by all modern desktop browsers and node since 4.x.

Great libraries are built on top of them. Check out [KoaJs](https://www.google.com).

I must admit that this topic is so large that it can easly be turned into some series of blogposts about ``Generators``.

There are a lot of intereseting materials and samples of codes about generators around the Web:

1. [Dr. Axel Rauschmayer blogpost] (http://www.2ality.com/2015/03/es6-generators.html) I encourage you to check Dr. Axel's books
2. [Chaining generators (gist) by Brandon Benvie] (https://gist.github.com/Benvie/7478257)
3. [Chapter 5 of Practical ES6 book] (https://github.com/mjavascript/practical-es6/blob/master/chapters/ch05.asciidoc)

Thanks to those resources this blogpost could be created!
