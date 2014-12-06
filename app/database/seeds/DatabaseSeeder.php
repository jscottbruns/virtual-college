<?php

class DatabaseSeeder extends Seeder {

	/**
	 * Run the database seeds.
	 *
	 * @return void
	 */


	public function run()
	{
		Eloquent::unguard();

		$this->call('UserTableSeeder');
	}

}

class UserTableSeeder extends Seeder {


	public function run()
    {
        DB::table('users')->delete();
        DB::table('students')->delete();
        DB::table('classes')->delete();
        DB::table('professors')->delete();
        DB::table('semesters')->delete();
        Student::create(array(
            'id'    => 1,
            'name'  => 'Jeff Bruns',
            'email' => 'jscottbruns@gmail.com',
            'address'   => '4601 Linden',
            'city'      => 'Baltimore',
            'state'     => 'MD',
            'zip'       => '21227',
            'phone1'    => '4432501272'
        ));

        Student::create(array(
            'id'    => 2,
            'name'  => 'Paul Gross',
            'email' => 'paul@gmail.com',
            'address'   => '123 My Street',
            'city'      => 'Catonsville',
            'state'     => 'MD',
            'zip'       => '21228',
            'phone1'    => '4431231272'
        ));
        Student::create(array(
            'id'    => 3,
            'name'  => 'Ryan Doyle',
            'email' => 'ryan@gmail.com',
            'address'   => '123 CherryDell Lane',
            'city'      => 'Pikesville',
            'state'     => 'MD',
            'zip'       => '21347',
            'phone1'    => '4431231272'
        ));


        Professor::create(array(
            'id'    => 1,
            'name'  => 'Prof Kim Bruns',
            'email' => 'kwbruns@yahoo.com',
            'office_location'   =>'COMPSCI-122',
            'office_hours'  => 'MWF 3-5',
            'office_phone'  => '410-555-1212'
        ));

        Professor::create(array(
            'id'    => 2,
            'name'  => 'Prof Dave Wilford',
            'email' => 'dave@yahoo.com',
            'office_location'   =>'BLDG-233',
            'office_hours'  => 'T/TH 1-2',
            'office_phone'  => '410-555-3332'
        ));

		User::create(array(
			'id' => 1,
			'username' 		=> 'jsb',
			'password' 		=> Hash::make('123123'),
			'student_id'	=> 1
		));
		User::create(array(
			'id' => 2,
			'username' 		=> 'kwbruns',
			'password' 		=> Hash::make('123123'),
			'prof_id'		=> 1
        ));

        DB::table('semesters')->delete();
        Semester::create(array(
            'id'    => 1,
            'semester'  => 'Fall 2013',
            'calendar_start'    => '2013-09-01',
            'calendar_end'      => '2013-12-15'
        ));

        DB::table('classes')->delete();
        Course::create(array(
            'id'    => 1,
            'catalog_name'  => 'English 101',
            'catalog_no'    => 'ENG101',
            'semester'      => 1,
            'credit_hours'  => 3,
            'prof_id'   => 1
        ));
        Course::create(array(
            'id'    => 2,
            'catalog_name'  => 'English 102',
            'catalog_no'    => 'ENG102',
            'semester'      => 1,
            'credit_hours'  => 3,
            'prof_id'   => 1
        ));  
        Course::create(array(
            'id'=> 3,
            'catalog_name'  => 'Math 101',
            'catalog_no'    => 'MATH101',
            'semester'      => 1,
            'credit_hours'  => 3,
            'prof_id'   => 2
        ));  


	}
}
