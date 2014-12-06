<?php

use Illuminate\Database\Migrations\Migration;

class CreateProfessorsTable extends Migration
{
    /**
    * Run the migrations.
    *
    * @return void
    */
    public function up()
    {
        Schema::create('professors', function($table)
        {

            $table->increments('id')->unsigned();
            $table->string('name', 150);
            $table->string('email', 50)->unique();
            $table->string('office_location', 100)->nullable()->default(NULL);
            $table->string('office_hours', 100)->nullable()->default(NULL);
            $table->string('office_phone', 20)->nullable()->default(NULL);
        });
    }

    /**
    * Reverse the migrations.
    *
    * @return void
    */
    public function down()
    {
        Schema::drop('professors');
    }
}