<?php

/*
|--------------------------------------------------------------------------
| Application Routes
|--------------------------------------------------------------------------
|
| Here is where you can register all of the routes for an application.
| It's a breeze. Simply tell Laravel the URIs it should respond to
| and give it the Closure to execute when that URI is requested.
|
*/

/*
 * Base route, protected and requiring authentication
 */
Route::get('/', array('as' => 'home', 'before' => 'auth', function()
{
	return View::make('home.index');
} ) );

/*
 * Home route, auth protected
 */
Route::get('/home', array('as' => 'home', 'before' => 'auth', function()
{
	return View::make('home.index');
} ) );

/*
 * Login page - http get
 */
Route::get('login', array('as' => 'login', function()
{
	if ( Auth::check() )
		return Redirect::to('home');

	return View::make('login.login');
} ) );

/*
 * Login page - http post
 */
Route::post('login', function()
{
	/* Validation rules */
	$rules = array(
		'username'  => 'required',
		'password'	=> 'required',
	);

	/* Save existing validation for retaining field values */
	Input::flash();

	/* Validate */
	$validation = Validator::make(Input::all(), $rules);

	if ( $validation->fails() )
	{
		/* Send them back if failed failed */
		return Redirect::to('login')->withErrors($validation);
	}

	$username =  strtolower(Input::get('username'));

	$user = array(
		'username' => Input::get('username'),
		'password' => Input::get('password')
	);

	/* Authenticate user */
	if ( Auth::attempt($user) )
	{
		if ( Auth::user()->student_id )
			return Redirect::to('students');
		elseif  (Auth::user()->prof_id )
			return Redirect::to('professors');

		return Redirect::to('login')->with('message', 'Invalid user configuration. ');
	}

	/* Failed authentication */
	return Redirect::to('login')->with('message', 'Invalid username or password. ');
});

/* Logout and delete cred storage */
Route::get('logout', array('as' => 'logout', function ()
{
	Auth::logout();
	return Redirect::route('login')->with('message', 'You are successfully logged out.');
}))->before('auth');

/* Following are our content and all auth protected */
Route::group( array('before' => 'auth'), function()
{
	/*
	 * Student Routing Rules
	*/
	Route::get('students', function() { return View::make('home.students')->with('action', ''); } );
	Route::get('students/classes', function() { return View::make('home.students')->with('action', 'classes'); } );
	Route::get('students/grades', function() { return View::make('home.students')->with('action', 'grades'); } );


	/*
	 * Professor Routing Rules
	*/
	Route::get('professors', function() { return View::make('home.professors')->with('action', ''); } );
	Route::get('professors/classes', function() { return View::make('home.professors')->with('action', 'classes'); } );
	Route::get('professors/classlist/{id}', function($id) { return View::make('home.professors')->with(array('action' => 'classlist', 'cid'	=> $id)); } );
	Route::get('professors/grades', function() { return View::make('home.professors')->with('action', 'grades'); } );
} );
