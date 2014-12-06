<?php

use Illuminate\Database\Migrations\Migration;

class CreateUsersTable extends Migration
{
    /**
    * Run the migrations.
    *
    * @return void
    */
    public function up()
    {
        Schema::create('users', function($table)
        {

            $table->increments('id')->unsigned();
            $table->string('username', 150)->unique();
            $table->string('password', 64);
            $table->string('salt', 64);
            $table->integer('student_id')->nullable()->default(NULL)->unsigned();
            $table->integer('prof_id')->nullable()->default(NULL)->unsigned();
            $table->integer('user_banned')->default(0)->unsigned();
        });
    }

    /**
    * Reverse the migrations.
    *
    * @return void
    */
    public function down()
    {
        Schema::drop('users');
    }
}