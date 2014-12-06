<?php

use Illuminate\Database\Migrations\Migration;

class CreateGpaTable extends Migration
{
    /**
    * Run the migrations.
    *
    * @return void
    */
    public function up()
    {
        Schema::create('gpa', function($table)
        {

            $table->increments('id')->unsigned();
            $table->string('grade', 2)->unique();
            $table->integer('credit_hours')->unique();
            $table->decimal('quality_points', 4, 1)->nullable()->default(NULL);
        });
    }

    /**
    * Reverse the migrations.
    *
    * @return void
    */
    public function down()
    {
        Schema::drop('gpa');
    }
}