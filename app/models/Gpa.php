<?php

// Model:'Gpa' - Database Table: 'gpa'

Class Gpa extends Eloquent
{

    protected $table='gpa';

    public function grades()
    {
        return $this->hasMany('Grades');
    }

}