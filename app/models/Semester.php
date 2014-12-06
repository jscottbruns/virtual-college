<?php

// Model:'Semester' - Database Table: 'semesters'

Class Semester extends Eloquent
{

    protected $table='semesters';

    public function classes()
    {
        return $this->belongsToMany('Classes');
    }
}