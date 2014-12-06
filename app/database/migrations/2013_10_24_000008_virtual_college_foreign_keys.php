<?php

class Virtual_collegeForeignKeys
{
    /**
    * Make changes to the database.
    *
    * @return void
    */
    public function up()
    {
        Schema::table('classes', function($table)
        {
            // Foreign Keys for table 'classes'

            $table->foreign('prof_id')->references('id')->on('professors');
            $table->foreign('semester')->references('id')->on('semesters');
        });

        Schema::table('enrollment', function($table)
        {
            // Foreign Keys for table 'enrollment'

            $table->foreign('class_id')->references('id')->on('classes');
            $table->foreign('student_id')->references('id')->on('students');
        });

        Schema::table('grades', function($table)
        {
            // Foreign Keys for table 'grades'

            $table->foreign('class_id')->references('id')->on('classes');
            $table->foreign('student_id')->references('id')->on('students');
            $table->foreign('gpa_id')->references('id')->on('gpa');
        });

        Schema::table('users', function($table)
        {
            // Foreign Keys for table 'users'

            $table->foreign('student_id')->references('id')->on('students');
            $table->foreign('prof_id')->references('id')->on('professors');
        });

    }

    /**
    * Revert the changes to the database.
    *
    * @return void
    */
    public function down()
    {
        Schema::table('classes', function($table)
        {
            // Drop Foreign Keys for table 'classes'

            $table->dropForeign('classes_prof_id_foreign');
            $table->dropForeign('classes_semester_foreign');
        });

        Schema::table('enrollment', function($table)
        {
            // Drop Foreign Keys for table 'enrollment'

            $table->dropForeign('enrollment_class_id_foreign');
            $table->dropForeign('enrollment_student_id_foreign');
        });

        Schema::table('grades', function($table)
        {
            // Drop Foreign Keys for table 'grades'

            $table->dropForeign('grades_class_id_foreign');
            $table->dropForeign('grades_student_id_foreign');
            $table->dropForeign('grades_gpa_id_foreign');
        });

        Schema::table('users', function($table)
        {
            // Drop Foreign Keys for table 'users'

            $table->dropForeign('users_student_id_foreign');
            $table->dropForeign('users_prof_id_foreign');
        });

    }
}