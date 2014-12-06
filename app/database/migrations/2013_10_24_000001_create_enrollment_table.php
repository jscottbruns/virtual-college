<?php

use Illuminate\Database\Migrations\Migration;

class CreateEnrollmentTable extends Migration
{
    /**
    * Run the migrations.
    *
    * @return void
    */
    public function up()
    {
        Schema::create('enrollment', function($table)
        {

            $table->increments('id')->unsigned();
            $table->integer('class_id')->unsigned();
            $table->integer('student_id')->unsigned();
            $table->integer('confirmed')->default(0)->unsigned();
        });
    }

    /**
    * Reverse the migrations.
    *
    * @return void
    */
    public function down()
    {
        Schema::drop('enrollment');
    }
}