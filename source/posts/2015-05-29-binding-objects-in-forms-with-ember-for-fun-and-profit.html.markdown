---
title: Binding Objects in Forms With Ember For Fun And Profit
author: karol
---

Ever run into the situation where you had to perform some operation based on the value from select field? How did you handle it? Maybe multiple case / switch statements? Or if you are lucky enough and code in language with good support for metaprogramming like Ruby you can write some magic code like this one:

```ruby
value = "#{params[:calculation_type].classify.constantize}Calculation".new.calculate(params)
```

which in fact can be treated as hidden case statement, but much easier to handle.

Are there any cleaner solutions to such problems which would be more readable? Fortunately, the answer is yes - some frameworks like Ember give possibility to use cool patterns that are not possible in other cases.

## Binding Objects In Forms

The great thing about Ember is that you can easily bind objects in e.g. select fields instead of raw strings. Check the example below:

```handlebars
{{view "select" content=calculationStrategies selection=currentCalculationStrategy optionValuePath="content" optionLabelPath="content.name" multiple=false}}
```

In most cases you would probably use something like `content.type` for `optionValuePath` or even use just an array of strings as `calculationStrategies` and not using `optionValuePath` and `optionLabelPath` at all. But here we are going to do something fancier - bind object directly.  So what is the `calculationStrategies` in this case?  It's an array of objects, let's call them Option Value Objects. Our component (or controller) could look like this:

```javascript
import Ember from 'ember';

export default Ember.Component.extend({
  init: function() {
    this.set('currentCalculationStrategy', null);

    var someCalculationStrategy = Ember.Object.extend({
      calculate: function(propertyA, propertyB, propertyC) {
        // some complex logic
      }
    }).create();
    var evenBetterCalculationStrategy = Ember.Object.extend({
      calculate: function(propertyA, propertyB, propertyC) {
        // super complex calculations go here
      }
    }).create();

    var t = this.get('container').lookup('utils:t');

    var someStrategy = Ember.Object.extend({
      name: function() {
        return t('calculation_strategies.some_strategy');
      }.property(),

      strategy: function() {
        return someCalculationStrategy;
      }.property()
    }).create();
    var evenBetterStrategy = Ember.Object.extend({
      name: function() {
        return t('calculation_strategies.even_better_strategy');
      }.property(),

      strategy: function() {
        return evenBetterCalculationStrategy;
      }.property()
    }).create();

    this.set('calculationStrategies',
      Ember.A([someStrategy, evenBetterStrategy]));
    return this._super();
  },

  actions: {
    perform: function() {
      var value = this.get('currentCalculationStrategy.strategy').calculate(this.get('propertyA'), this.get('propertyB'), this.get('yetAnotherProperty'));
      // do something here with the value
    }
  }
});
```

What happens in our component? Firstly, we initialize some properties and service objects, which need to respond to the same method (`calculate` in this case) and then there's a key part: instantiating some option value objects implementing the same interface: `name` and `strategy` methods. In `strategy` we just return the service object responsible for some kind of calculations and in name we take advantage of internationalization. Lastly, we set `calculationStrategies` to be an array of our option value objects.

The setup may seem a bit complex. Was it worth it? Looking at the `perform` action it was definitely worth doing. No switch / if statements based on selected value - we simply take the selected object and its strategy and call the `calculate` method on it with some other properties as arguments. Code looks clean and is simple to maintain, it just requires adding more objects implementing the same interface if we want to have more strategies. To avoid validation for checking if any strategy was selected we can just decide on the default one.

## Wrapping Up

Developing Single Page Applications with Ember brings some new ideas and patterns that may not be possible in other cases. By using polymorphism and binding directly to objects in inputs instead of raw values we can write code that is both beautiful and easy to maintain.
