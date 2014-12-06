<?php

// Model:'Grade' - Database Table: 'grades'

Class Grade extends Eloquent
{

    protected $table='grades';

    public function courses()
    {
        return $this->belongsTo('Course', 'class_id');
    }

    public function students()
    {
        return $this->belongsTo('Student');
    }

    public function gpa()
    {
        return $this->belongsTo('Gpa');
    }

}