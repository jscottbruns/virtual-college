<?php

class HomeController extends BaseController {

	/*
	|--------------------------------------------------------------------------
	| Default Home Controller
	|--------------------------------------------------------------------------
	|
	| You may wish to use controllers instead of, or in addition to, Closure
	| based routes. That's great! Here is an example controller method to
	| get you started. To route to this controller, just add the route:
	|
	|	Route::get('/', 'HomeController@showWelcome');
	|
	*/

	public function showWelcome()
	{
		return View::make('hello');
	}


	public function doLogin()
	{
		//$token = Session::token();
		//Input::flash();

		$validation = Validator::make(
			Input::all(),
			array(
				'username'  => 'required',
				'password'	=> 'required',
			)
		);

		if ( $validation->fails() )
		{
			return Redirect::to('login')->with_errors($validation);
		}

		// create our user data for the authentication
		$userdata = array(
				'username' 	=> Input::get('username'),
				'password' 	=> Input::get('password')
		);

		// attempt to do the login
		if ( Auth::attempt($userdata) )
		{
			return "Success";
		} else {
			return "Failed";//Redirect::to('login');
		}
	}
}