---
title: 8 random Ionic tips
author: pawurb
cover_photo: ionic_cover.jpg
---

[Ionic](ionicframework.com) is a leading hybrid mobile app development framework. With [Ionic 2](http://ionic.io/2) still in its infancy and multitude of production apps that will need maintenance, the current version is not going away any time soon. I've been developing Ionic apps for about a year now. This blogpost presents 8 random tips which I wish I had known when I started to play with it.

READMORE

### 1. Delay splashscreen

Default Ionic app booting time user experience is not the best. The user is presented with a splash screen, then a white flash for a second or two when WebView is initializing the application. Only then is the app ready for use. A simple config can improve the feeling significantly. The first step towards doing this is adding the [cordova splashscreen plugin](https://github.com/apache/cordova-plugin-splashscreen) to your app:

``` bash
cordova plugin add cordova-plugin-splashscreen
```

Just add the following line to `config.xml`:

``` xml
  <preference name="AutoHideSplashScreen" value="false" />
```

then the following code:

```javascript
angular.module('app')
.run(function($ionicPlatform, $timeout) {
  $ionicPlatform.ready(function() {
    if(window.cordova) {
       $timeout(function() {
          navigator.splashscreen.hide()
       } , 500);
    }
  });
});
```

Thanks to these couple of lines of code, the splash screen will only be dismissed after your app has been fully initialized contributing to a significantly improved initial user experience.

### 2. Encapsulate navigation logic into a service

Navigating around the app with custom animation and history behaviour is a common requirement. This `Navigator` service makes it possible for you to handle all this without cluttering up your controllers:

``` javascript
angular.module('app')
.factory('Navigator', function($state, $ionicHistory, $ionicViewSwitcher) {
  return {
    go: function(stateName, opts) {
      if (opts == null) {
        opts = {
          stateParams: {},
          noBack: false,
          animation: 'forward'
        };
      }
      $ionicViewSwitcher.nextDirection(opts.animation);
      $state.go(stateName, opts.stateParams);
      if (opts.noBack) {
        $ionicHistory.nextViewOptions({
          disableBack: true
        });
      }
    },
    goBack: function() {
      $ionicHistory.goBack();
    },
    current: function() {
      return $state.current.name;
    }
  };
});
```

Usage:

* `Navigator.go("products.index")` - standard transition
* `Navigator.go("products.index", animation: 'none')` - custom animation
* `Navigator.go("products.index", noBack: true)` - don't show back button after transition
* `Navigator.go("products.show", stateParams: { product_id: 1 })` - additional UI router params

### 3. Add a default back state

Ionic states transition history mechanism out of the box lets you go back to the previous view. However, when developing an app, you probably use some kind of livereload tool. After reloading the page, all the saved in-memory history state is lost and you are left in a view that you cannot leave as the back button no longer appears. Although users are not affected by this (for them the page never reloads), it does become a hindrance during the development process.

This [directive](https://github.com/driftyco/ionic/issues/1647) lets you provide a default previous state for each route, even when in-memory history has been lost.

``` javascript
angular.module('app')
.directive('defaultNavBackButton', function ($ionicHistory, $state, $stateParams, $ionicConfig, $ionicViewSwitcher, $ionicPlatform) {
  return {
    link: link,
    restrict: 'EA'
  };

  function link(scope, element, attrs) {
    scope.backTitle = function() {
      var defaultBack = getDefaultBack();
      if ($ionicConfig.backButton.previousTitleText() && defaultBack) {
        return $ionicHistory.backTitle() || defaultBack.title;
      }
    };

    scope.goBack = function() {
      if ($ionicHistory.backView()) {
        $ionicHistory.goBack();
      } else {
        goDefaultBack();
      }
    };

    scope.$on('$stateChangeSuccess', function() {
      element.toggleClass('hide', !getDefaultBack());
    });

    $ionicPlatform.registerBackButtonAction(function () {
        if ($ionicHistory.backView()) {
          $ionicHistory.goBack();
        } else if(getDefaultBack()) {
          goDefaultBack();
        } else {
          navigator.app.exitApp();
        }
    }, 100);
  }

  function getDefaultBack() {
    return ($state.current || {}).defaultBack;
  }

  function goDefaultBack() {
    $ionicViewSwitcher.nextDirection('back');
    $ionicHistory.nextViewOptions({
      disableBack: true,
      historyRoot: true
    });

    var params = {};

    if (getDefaultBack().getStateParams) {
      params = getDefaultBack().getStateParams($stateParams);
    }

    $state.go(getDefaultBack().state, params);
  }
});
```

You can use it like this when specifying your routes:

``` javascript
angular.module('app')
.config(function($stateProvider, $urlRouterProvider) {
  $stateProvider.state('hello', {
    url: '/?name',
    templateUrl: 'views/hello.html',
    controller: 'HelloCtrl'
  }).state('about', {
    url: '/about',
    templateUrl: 'views/about.html',
    controller: 'AboutCtrl',
    defaultBack: {
      state: 'hello',
      getStateParams: function() {
        return {
          name: "guest"
        };
      }
    }
  })
  $urlRouterProvider.otherwise('/');
});
```

### 4. Handle timeout errors globally

Mobile network connection quality is not always perfect. You should always handle connection timeout errors in a user-friendly way. Adding custom handling to each API call might work, however, there would be a lot of code repetition. Instead, you can add a custom angular `$http` service interceptor and handle all the timeout errors in one place.

Add the following api service (I always use the [lodash](https://github.com/lodash/lodash) library and I highly recommend that you do so too):

```javascript
angular.module('app')
.factory('Api', function($http) {
  var default_opts = {
    cache: false,
    timeout: 5 * 1000,
    headers: {
      'Content-Type': 'application/json;charset=UTF-8'
    }
  };
  var api_host = window['Settings'].API_HOST;
  return {
    get: function(uri, opts) {
      return $http.get(api_host + uri, _.merge({}, default_opts, (opts || {})));
    },
    put: function(uri, params, opts) {
      return $http.put(api_host + uri, params, _.merge({}, default_opts, (opts || {})));
    },
    post: function(uri, params, opts) {
      return $http.post(api_host + uri, params, _.merge({}, default_opts, (opts || {})));
    }
  };
});
```
Then add the following `$http` service interceptor:

```javascript
angular.module('app')
.config(function($provide, $httpProvider) {
  $provide.factory('timeoutHandler', function($q, $injector) {
    var isTimeout = function(rejection) {
      return rejection.status === 0;
    };
    return {
      responseError: function(rejection) {
        if(isTimeout(rejection)) {
          $injector.invoke(function($ionicPopup) {
            $ionicPopup.alert({
              title: 'Timeout',
              template: 'Connection timeout'
            });
          });
        }
        $q.reject(rejection);
      }
    }
  });
  $httpProvider.interceptors.push('timeoutHandler');
});
```

Now, whenever a timeout error occurs, the user will be presented with an informative pop-up.

### 5. Configure multiple environment settings with gulp-preprocess

The ability to switch easily between production/staging/development environments is usually necessary during the development process. One of the ways to automate it is to use a [gulp-preprocess](https://www.npmjs.com/package/gulp-preprocess) plugin in combination with a separate settings file. To use it, first install the gulp plugin:

```
npm install gulp-preprocess --save
```

Then add the following code to `gulpfile.js`

```javascript
var preprocess = require('gulp-preprocess');
var ENV = process.env.ENV || 'DEVELOPMENT';

gulp.task('settings', function() {
  gulp.src('./settings.js').pipe(preprocess({
    context: {
      ENV: ENV
    }
  })).pipe(gulp.dest('./www/js/'));
});

```

Create the following configuration file in the `config/settings.js` directory:

``` javascript
window.Settings = {
  // @if ENV == 'DEVELOPMENT'
  API_HOST: 'http://localhost:3000'
  // @endif
  // @if ENV == 'PRODUCTION'
  API_HOST: 'https://production.com'
  // @endif
}
```

and require the resulting file in your index.html:

```html
<script src='js/settings.js'></script>
```

Then you can run the gulp task to change the setting for your app:

```
ENV=PRODUCTION gulp settings
```

Current setting values will be available on the `window['Settings']` object. Alternatively, you could preprocess an injectable service, but I found the global singleton approach to be acceptable in this particular case.

### 6. Use gulp-ng-annotate to simplify js code minification

Typical Ionic app files are hosted locally on the phone and minifying them might not be as crucial as it is for online apps. However, if you would like to [update your code without going through the app store review](http://blog.ragnarson.com/2016/02/23/cordova-instant-code-updates.html), you should minify all the assets. Out-of-the-box Angular offers a syntax to support js minification but it is a little clunky. A much better idea is to use standard syntax and preprocess your js code with [gulp-ng-annotate](https://github.com/Kagami/gulp-ng-annotate).

Move your application code to `javascript/app.js` and add the following task to `gulpfile.js`:

```javascript
var swallowErr = function(err) {
  console.log(err.toString());
  this.emit('end');
}

var annotate = require('gulp-ng-annotate');
gulp.task('annotate', function () {
  return gulp.src('javascript/app.js')
    .pipe(annotate())
    .on('error', swallowErr)
    .pipe(gulp.dest('www/js/'));
});
```

### 7. Track js errors

There will be bugs so make sure you monitor when and why they happen. There are a lot of commercial services which allow bugs monitoring and logging. However, rolling a basic custom solution is very simple and it’s also cheaper. You just need to hook up to angular exception handler and send data about error to your api:

```javascript
angular.module('app')
.config(function($provide) {
  return $provide.decorator('$exceptionHandler', function($delegate) {
    return function(exception, cause) {
      var initInjector = angular.injector(['ng']);
      $http = initInjector.get('$http');
      var params = {
        message: exception.message,
        cause: cause,
        stack: exception.stack
      };
      $http.post(window['Settings'].API_HOST + '/js_errors.json', params)
      $delegate(exception, cause);
    };
  });
});
```

### 8. Run gulp tasks on ionic serve

You can hook up any gulp tasks to `ionic serve` command. Triggering `annotate` and `watch` commands is a good way of making sure that you always have the latest version of the app running in the browser.

Edit the `ionic.project` file so it looks like this:

```
{
  "name": "sample_app",
  "app_id": "",
  "gulpStartupTasks": [
    "annotate",
    "watch"
  ]
}
```

Next time you run ionic serve, the project will be built and the watcher started.


### Sample repo

You can find a demo Ionic app with all the tips applied in [this repo](https://github.com/Ragnarson/ionic-tips).
