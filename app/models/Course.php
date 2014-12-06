<?php

// Model:'Course' - Database Table: 'classes'

Class Course extends Eloquent
{

    protected $table='classes';

    public function enrollments()
    {
        return $this->hasMany('Enrollment');
    }

    public function grades()
    {
        return $this->hasMany('Grade');
    }

    public function semesters()
    {
        return $this->belongsTo('Semester');
    }

    public function professors()
    {
        return $this->belongsTo('Professor', 'prof_id');
    }

}