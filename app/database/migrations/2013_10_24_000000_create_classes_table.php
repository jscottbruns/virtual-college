<?php

use Illuminate\Database\Migrations\Migration;

class CreateClassesTable extends Migration
{
    /**
    * Run the migrations.
    *
    * @return void
    */
    public function up()
    {
        Schema::create('classes', function($table)
        {

            $table->increments('id')->unsigned();
            $table->string('catalog_name', 150);
            $table->string('catalog_no', 50)->unique();
            $table->integer('semester')->unsigned();
            $table->integer('credit_hours')->default(0)->unsigned();
            $table->integer('prof_id')->unsigned();
        });
    }

    /**
    * Reverse the migrations.
    *
    * @return void
    */
    public function down()
    {
        Schema::drop('classes');
    }
}