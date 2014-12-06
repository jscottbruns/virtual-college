<?php

use Illuminate\Database\Migrations\Migration;

class CreateSemestersTable extends Migration
{
    /**
    * Run the migrations.
    *
    * @return void
    */
    public function up()
    {
        Schema::create('semesters', function($table)
        {

            $table->increments('id')->unsigned();
            $table->string('semester', 50)->unique();
            $table->('calendar_start');
            $table->('calendar_end');
        });
    }

    /**
    * Reverse the migrations.
    *
    * @return void
    */
    public function down()
    {
        Schema::drop('semesters');
    }
}