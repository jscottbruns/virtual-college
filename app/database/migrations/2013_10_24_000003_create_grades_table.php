<?php

use Illuminate\Database\Migrations\Migration;

class CreateGradesTable extends Migration
{
    /**
    * Run the migrations.
    *
    * @return void
    */
    public function up()
    {
        Schema::create('grades', function($table)
        {

            $table->increments('id')->unsigned();
            $table->string('description', 100);
            $table->integer('class_id')->unsigned();
            $table->integer('student_id')->unsigned();
            $table->integer('gpa_id')->unsigned();
        });
    }

    /**
    * Reverse the migrations.
    *
    * @return void
    */
    public function down()
    {
        Schema::drop('grades');
    }
}