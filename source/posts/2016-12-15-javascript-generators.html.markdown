---
title: "JavaScript Generators"
author: maciej
cover_photo: cover.png
---

# Introduction

ECMAScript 2015(ES6) brings a lot of new great features and overall language improvements. Among them we will find Generators which seems to be one of the most exciting and enjoyable JS extensions. The primary and the most important thing about them is ability to pause and resume them at a desired moment. Implementation standard by itself allows us to use it in two ways. We can think of them as data producers (iterators) and data consumers (observers). Combination of those two allow us to turn them also into coroutines to handle more sophisticated tasks. How does all this work and in which situations we can use generators to make our code more readable and maintainable?

READMORE

# Syntax and basics

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

Basically we need to pay attention to ``function*`` keyword and ``yield`` operator. With ``yield`` we can force generator to suspend itself and consume, literally yield, some data. Generator method definition can contain multiple ``yield`` expressions. This helps us to gain accurate control flow of an execution and allows to pause and resume generator at particular ``yield``.

It can be a little surprising that when we try to invoke our ``generatorFunction()``, the body is not executed. Instead, we will receive a generator object.

# Generator object and iteration. Producing data.

```js
  const generatorFunction = function* () {
    yield '1';
    yield '2';
    return 'our return value'
  }

  const generatorObject = generatorFunction()
```

Here are a few things we need to know about generator object. It implements few standards by itself: iterator protocol and iterable protocol. Our generator object is ``iterable`` (we can traverse data structure). Iterator protocol on the other hand allows us to use ``next()`` method on it.

According to Iterator specification ``next()`` is zero argument function which returns object with two properties: ``done: booolean`` and ``value`` (it can be any value returned by the iterator).

This dualistic nature allows us to make a handy use of generators as a data producers.

Presence of Iterators ``next()`` allows us to iterate through our generator object.

```js
  generatorObject.next(); // { value: '1', done: false }
  generatorObject.next(); // { value: '2', done: false }
  generatorObject.next(); // { value: 'our return value', done: true }
```

We can think of generators as data producers. Here is a ``randomNumberGenerator``.

```js
function* randomNumberGenerator(counter = Infinity, topRange = 100) {
  while (counter--) {
    yield Math.floor((Math.random() * topRange) + 1);
    //yield random integer number from 1 to 'range'
  }

  return 'Out of the numbers';
}
//We limit our iteration in this case just for two 'products'
const generateTwoRandomNumbers = randomNumberGenerator(2);

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

We need to be aware that most of the generic methods designed for iterables will omit our ``value`` for ``done: true``. ``done: true`` is treated rather like a signal for the end of a collection and just breaks an interation. This behaviour might be confusing in some cases. To avoid this kind of problems it might be a good practice to treat generator  ``return`` statement only as a loop breaker and do not rely on its value. This is the reason why our ``'Out of the numbers'`` statement is not included in the generated array.

According to our previous code, infinitive data producer will look like this:

```js
const infiniteNumbersIterator = randomNumberGenerator();
infiniteNumbersIterator.next().value // 25
```

Here this will always produce a new random number. End will not be reached. As we can see there, this approach can be used as a base for a sample ``UUID`` generator.

# Data consumption

Is there a way to stop and terminate our generator? Yes, there is. We can finish it up with a ``return()`` method. This method can be executed at any moment of the iteration. It can also take 1 or 0 arguments by itself.

Basically, the ``return(value)`` is responsible for returning the argument given by us and terminating the generator.

Without an argument:

```js
infiniteNumbersIterator.return(); // { value: undefined, done: true }
```

Here we end up with ``{ value: undefined, done: true }``. It's worth remembering that ``return()`` just ends the execution of our ``infiniteNumberIterator`` here. It does not care about our ``return`` statement inside generator's body. This can be misleading at the beginning due to the semantics similarities.

However, there is a possibility to get something different than ``undefined``. As we know, this method can receive an argument (``returns(value)``) so:

```js
  let generatorObjectToTerminate = generatorFunction();
  genaratorObjectToTerminate.return(2) // { value: 2, done: true }
```

Here we have the first example of generator as a data consumer. ``return`` is not the only available method for processing external input.

Method ``next()`` defined in ``Generator.prototype`` is also capable of doing that and it fits even better. It can receive and send argument to our generator function body. It redefines and extends capabilities of its counterpart method from ``Iterator`` protocol (Iterator ``next()`` which arity is 0).

Treating generator object as a data consumer requires some understanding of how and when our value is delivered. First of all, we send values via ``next(value)`` and receiving them via ``yield``. Secondly, we need to reach our ``yield`` statement at the very beginning. Starting the generator is easy and requires just invocation of ``next()``. This is a mandatory step to reach first ``yield``. Generator Object will be suspended there and prepared for our input value.

```js
function *fooBar() {
  const a = yield;
  const b = yield;
  return a + b;
}

//Starting out generator
//yield represnted by 'a' const is reached
const fooBarGenerator = fooBar();
fooBarGenerator.next();

//Sending a 'foo' value and moving to next yield
fooBarGenerator.next('foo');

//'bar' value is send. No next yield available
//return statement is resolved
fooBarGenerator.next('bar');
//{ value: 'fooBar', done: true }
```

Note that in this step by definition we are just supplying values to variables, so as a result of calling ``next(value)`` we receive this kind of iterator return value object => ``{ value: undefined, done: false }``.

# Laziness

Due to the generators’ nature we can process data in a ``lazy way``. On-demand operations are not a problem and they could be very useful for processing: streams or large data sets as received chunks.

Here we will try to process randomly generated set of the numbers. We start from generating an array of 10 numbers in range 1 - 100. In the next step, numbers less than 26 will be taken out. At the end, we will convert chosen numbers to alphabet characters.

```js
const lessThan = function(end, value) {
  return function(value) {
    return value < end;
  };
}

// 25 alphabet character letters
const lessThan26 = lessThan(26);

const lazyMap = function* (iterable, callback) {
  for (let value of iterable) {
    yield callback.call(this, value);
  }
};

const numberToAlphabet = function(value) {
  //97 in ASCII is 'a'
  //Our min value is 1
  return String.fromCharCode(96 + value);
 };

const numbers = [...randomNumberGenerator(10)];
console.log(numbers);
//[ 74, 16, 74, 24, 54, 96, 1, 71, 71, 77 ]

//Our chained generator object
let alphabebtCharIterator = lazyMap(filter(numbers), lessThan26), numberToAlphabet);

alphabetCharIterator.next();
//{ value: 'o', done: false }

alphabetCharIterator.next();
//{ value: 'w', done: false }

alphabetCharIterator.next();
//...
```

# Chaining

As we have already seen, it is possible to chain generators. This pattern can be applied in a more elegant way. The usage of a helper function allows us to write more modular and cleaner code.

First of all, we need to combine our ``generatorsFunctions`` and return one solid ``generatorObject``.
Our function will take ``generatorFunctions`` as a set of arguments and return already started ``generatorObject``. This allows us to send data directly.

```js
function composeGenerator() {
  // Create an array of generatorFunctions
  let generatorFunctions = [...arguments];
  let i = arguments.length - 1;

 // Take last generatorFunction (this is the last argument of our function)
 // Create a starting point for compose chain - generatorObject

  let generatorObject = generatorFunctions[i]();

 // Start our generator object.
 // Allow to receive data via next(value))

  generatorObject.next();
   while (i--) {
    // Link current generator next one from an end of the list
    let generatorFunction = generatorFunctions[i];

    // Our generatorFunction by design take one argument - generatorObject
    generatorObject = generatorFunction(generatorObject);

    // We need to start our extended generatorObject
    generatorObject.next();
    // We iterate till the end of generatorFunctions
  }

  // Return generatorObject composed of all our generatorFunctions
  return generatorObject;
}
```
Before we proceed to our ``generatorsFunctions`` we need to stop for a while.

For demonstration purposes we supply our ``generatorObject`` with some sample data. The idea is to simulate some asynchronous behaviours and processes similarly to a stream.

Function below allows to send chunks of data to our composed ``generatorObject``.

As usual this done via ``next(chunk)`` and here some time interval (1000ms) is set.

```js
// Our sample data set
const arr = [1, 'm', 3, 'b', 'e', 10];

function sendChunk(arr, mainGeneratorObject) {
  // Yield each element of our 'arr'
  // chunksGenerator function is defined at the bottom

  let chunkIterator = chunksGenerator(arr);

  const asyncSend = setInterval(() => {
    let { value, done } = chunkIterator.next();
    // Iterate via next() in 1s interval

    done ? clearInterval(asyncSend) : mainGeneratorObject.next(value);
    // Collection outage: done: true -> cancel interval action (asyncSend)
    // done: false -> fullfill mainGeneratoObject with a 'chunk' of data

  //Interval is set to 1s
  }, 1000);

  function* chunksGenerator(arr) {
    //Iterate over 'arr' yieliding each time an element of it
    yield* arr;
  }
```

Inside ``chunksGenerator`` we will find ``yield*``. This operator allow us to do some special things. Here this is just a shortcut for

```js
for (let element of arr) {
  yield element;
}
```

it can also yield another ``generator`` but this is out of the scope of this article.

Now we need to take care of some logic defined by ``sub-generator``'s functions.

Each generator function must take generator object as an argument. This allow us to chain them nicely. As we can see below, logic inside each generator function is very simple.

Flow of the transformation is the following: take only integer number from our stream of data; double its value; display the output. ``yield`` is wrapped by infinite loop. This action prevents our iteration from breaking after the first chunk of data was processed.

```js
function* pickInteger(target) {
  while(true) {
    let chunk = yield;

    if(Number.isInteger(chunk)) {
      //Target is our generatorObject
      target.next(chunk);
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

Sample usage:

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

We need to be aware that this is only an example usage and there are a few things missing there, for example: error handling.

# Wrapping up

Generators are something definitely new in the JavaScript world. They have been present with us for some time bringing new opportunities to tackle certain kind of problems. They might be tricky or confusing at the beginning but learning them is a lot of fun.  This blogpost contains only some basic stuff and examples of usage.

Native support should not also be a concern. Generators are supported by all modern desktop browsers and node since 4.x.

Great libraries are built on top of them. Check out [KoaJs](http://koajs.com/) and a great EmberJS addon ([ember-concurency](http://ember-concurrency.com/#/docs)).

I must admit that this topic is so large that it can easily be turned into a series of blog posts about ``Generators``.

There are a lot of interesting materials and code samples about generators around the Web:

1. [Dr. Axel Rauschmayer blogpost] (http://www.2ality.com/2015/03/es6-generators.html) I encourage you to check Dr. Axel's books
1. [Chaining generators (gist) by Brandon Benvie] (https://gist.github.com/Benvie/7478257)
1. [Chapter 5 of Practical ES6 book] (https://github.com/mjavascript/practical-es6/blob/master/chapters/ch05.asciidoc)

This blogpost could not have been created without those resources.
