## LessJsRoutes

Have you ever wanted to use named routes in your JavaScript? So have I. Now you can.

LessJsRoutes will generate a javascript file with functions that give you the path to the route
and functions that will call these routes using ajax (uses jQuery or Prototype).



## Features

* Gives you a javascript function that will return the path for any route.
* Gives you a javascript function that will call any route with the proper method (PUT/POST/etc).
* Control which routes get generated with :only, :ignore flags.
* Handles nested routes.



## Installation

NOTE for Rails 2 use branch "rails-2"
NOTE: for Rails versions < 2.3 use version d9cacd51454814cf4268da007c439573418adbcd.

Add to your `Gemfile`:

``` rb
gem 'less-js-routes', :git => "http://github.com/stevenbristol/less-js-routes"
```

Generate the less_routes.js file

``` rb
rake less:js:routes
```

or 

``` rb
Less::Js::Routes.generate!
```

This file should be regenerated anytime the routes change, so it's a good idea to put it into your deploy script or run it any time your app starts.


## Configuration Options

Create an initializer and add this:

``` rb
Less::Js::Routes::Config.configure do |config|
  config.debug = false 													#default is false
  config.ignore = [/devise/, :users, /admin/]		#default is []
  config.only = [:posts, :comments]							#default is []
end
```

# Debug
Adds debugging info to the javascript file.

# Ignore
* Takes and array of regex or symbols. 
* Will not generate a route if symbol or regex matches.
* If symbol is passed the symbol must match the name of the controller without "_controller," so for the users_controller you would just pass :user.
* if regex is passed regex is matched against any part of name (without "_controller"), so /admin/ will match on "admin," "admins," or "administrator." /min/ will match on "min," "admin," etc.
* If both ignore and only are used, generation uses a most restrictive approach.

# Only

* Takes and array of regex or symbols. 
* Will only generate a route if symbol or regex matches.
* If symbol is passed the symbol must match the name of the controller without "_controller," so for the users_controller you would just pass :user.
* if regex is passed regex is matched against any part of name (without "_controller"), so /admin/ will match on "admin," "admins," or "administrator." /min/ will match on "min," "admin," etc.
* If both ignore and only are used, generation uses a most restrictive approach.


## Usage

If you have the following in your routes file:

``` rb
resources :posts do
  resources :comments
end
resources :comments
```

This will be generated for you:

``` js
function post_comments_path(post_id, format){ var _post_id = less_check_parameter(post_id);var _format = less_check_format(format);return '/posts' + '/' + _post_id + '/comments' + _format}
function post_comments_ajax(post_id, format, verb, params, options){ var _post_id = less_check_parameter(post_id);var _format = less_check_format(format);return less_ajax('/posts' + '/' + _post_id + '/comments' + _format, verb, params, options)}
function new_post_comment_path(post_id, format){ var _post_id = less_check_parameter(post_id);var _format = less_check_format(format);return '/posts' + '/' + _post_id + '/comments' + '/new' + _format}
function new_post_comment_ajax(post_id, format, verb, params, options){ var _post_id = less_check_parameter(post_id);var _format = less_check_format(format);return less_ajax('/posts' + '/' + _post_id + '/comments' + '/new' + _format, verb, params, options)}
function edit_post_comment_path(post_id, id, format){ var _post_id = less_check_parameter(post_id);var _id = less_check_parameter(id);var _format = less_check_format(format);return '/posts' + '/' + _post_id + '/comments' + '/' + _id + '/edit' + _format}
function edit_post_comment_ajax(post_id, id, format, verb, params, options){ var _post_id = less_check_parameter(post_id);var _id = less_check_parameter(id);var _format = less_check_format(format);return less_ajax('/posts' + '/' + _post_id + '/comments' + '/' + _id + '/edit' + _format, verb, params, options)}
function post_comment_path(post_id, id, format){ var _post_id = less_check_parameter(post_id);var _id = less_check_parameter(id);var _format = less_check_format(format);return '/posts' + '/' + _post_id + '/comments' + '/' + _id + _format}
function post_comment_ajax(post_id, id, format, verb, params, options){ var _post_id = less_check_parameter(post_id);var _id = less_check_parameter(id);var _format = less_check_format(format);return less_ajax('/posts' + '/' + _post_id + '/comments' + '/' + _id + _format, verb, params, options)}
function posts_path(format){ var _format = less_check_format(format);return '/posts' + _format}
function posts_ajax(format, verb, params, options){ var _format = less_check_format(format);return less_ajax('/posts' + _format, verb, params, options)}
function new_post_path(format){ var _format = less_check_format(format);return '/posts' + '/new' + _format}
function new_post_ajax(format, verb, params, options){ var _format = less_check_format(format);return less_ajax('/posts' + '/new' + _format, verb, params, options)}
function edit_post_path(id, format){ var _id = less_check_parameter(id);var _format = less_check_format(format);return '/posts' + '/' + _id + '/edit' + _format}
function edit_post_ajax(id, format, verb, params, options){ var _id = less_check_parameter(id);var _format = less_check_format(format);return less_ajax('/posts' + '/' + _id + '/edit' + _format, verb, params, options)}
function post_path(id, format){ var _id = less_check_parameter(id);var _format = less_check_format(format);return '/posts' + '/' + _id + _format}
function post_ajax(id, format, verb, params, options){ var _id = less_check_parameter(id);var _format = less_check_format(format);return less_ajax('/posts' + '/' + _id + _format, verb, params, options)}
function comments_path(format){ var _format = less_check_format(format);return '/comments' + _format}
function comments_ajax(format, verb, params, options){ var _format = less_check_format(format);return less_ajax('/comments' + _format, verb, params, options)}
function new_comment_path(format){ var _format = less_check_format(format);return '/comments' + '/new' + _format}
function new_comment_ajax(format, verb, params, options){ var _format = less_check_format(format);return less_ajax('/comments' + '/new' + _format, verb, params, options)}
function edit_comment_path(id, format){ var _id = less_check_parameter(id);var _format = less_check_format(format);return '/comments' + '/' + _id + '/edit' + _format}
function edit_comment_ajax(id, format, verb, params, options){ var _id = less_check_parameter(id);var _format = less_check_format(format);return less_ajax('/comments' + '/' + _id + '/edit' + _format, verb, params, options)}
function comment_path(id, format){ var _id = less_check_parameter(id);var _format = less_check_format(format);return '/comments' + '/' + _id + _format}
function comment_ajax(id, format, verb, params, options){ var _id = less_check_parameter(id);var _format = less_check_format(format);return less_ajax('/comments' + '/' + _id + _format, verb, params, options)}
```


* Nested routes are generated.
* new and edit routes are generated.
* Singular and plural routes are generated.
* For each route two functions are generated: 




```*_path``` Functions:

* Params: id(s), format
	* id(s): The integer ids for the resource you're accessing. Default is ''.
	* format: The format you would like returned for the resource, example: "js", "json," "xml," etc. Default is ''.
* Returns: string that is the path to the resource. 

Example:

``` js
//function comments_path(format)
comments_path()
"/comments"
//function comments_path(format)
comments_path('json')
"/comments.json"
//function comment_path(id, format)
comment_path(1)
"/comments/1"
//function comment_path(id, format)
comment_path(1, 'js')
"/comments/1.js"
//function edit_comment_path(id, format)
edit_comment_path(17, 'json')
"/comments/17/edit.json"
//function post_comments_path(post_id, format)
post_comments_path(1)
"/posts/1/comments"
//function post_comment_path(post_id, id, format)
post_comment_path(1, 2)
"/posts/1/comments/2"
//function post_comment_path(post_id, id, format)
post_comment_path(1, 2, 'xml')
"/posts/1/comments/2.xml"
```



```*_ajax``` Functions:

* Params: id(s), format, verb, params, options
	* id(s): The integer ids for the resource you're accessing. Default is ''.
	* format: The format you would like returned for the resource, example: "js", "json," "xml," etc. Default is ''.
	* verb: The HTTP verb you'd like to use, 'get,' 'post,' 'put,' or 'delete.'  Default is 'get'.
	* params: Additional params you'd like to pass to the ajax request. Example: {name: 'steve'}
	* options: Additional ajax options you'd like to pass to the javascript library ajax function. 
		*	If no "error" ("onFailure") option is supplied the following will be executed if an error occurs:
	
``` js
function(r, status, error_thrown){alert(status + ": " + error_thrown)}
```

		* If neither "success" ("onSuccess") or "complete" ("onComplete") options are supplied the following will be executed when the request completes with no error:

``` js
function(r){eval(r.responseText)};
```
		* This means rjs or any javascript that your app returns will be eval'd.
*Returns: string that is the path to the resource. 

Example:

``` js
//function post_comments_ajax(post_id, format, verb, params, options)
post_comments_ajax(1, 'js')
post_comments_ajax(1, 'json', null, null, {success: function(r){console.log(r)}}))
//function posts_ajax(format, verb, params, options)
post_ajax('js', 'post', {post_title: "title", post_body: "body"})
```






