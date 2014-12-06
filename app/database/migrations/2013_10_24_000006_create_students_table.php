<?php

use Illuminate\Database\Migrations\Migration;

class CreateStudentsTable extends Migration
{
    /**
    * Run the migrations.
    *
    * @return void
    */
    public function up()
    {
        Schema::create('students', function($table)
        {

            $table->increments('id')->unsigned();
            $table->string('name', 150);
            $table->string('email', 150)->unique();
            $table->string('address', 150);
            $table->string('city', 150);
            $table->string('state', 150);
            $table->string('zip', 30);
            $table->string('phone1', 20);
            $table->string('phone2', 20)->nullable()->default(NULL);
            $table->string('phone3', 20)->nullable()->default(NULL);
            $table->string('phone4', 20)->nullable()->default(NULL);
        });
    }

    /**
    * Reverse the migrations.
    *
    * @return void
    */
    public function down()
    {
        Schema::drop('students');
    }
}