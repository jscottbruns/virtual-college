<?php

// Model:'Enrollment' - Database Table: 'enrollment'

Class Enrollment extends Eloquent
{

    protected $table='enrollment';

    public function courses()
    {
        return $this->belongsTo('Course', 'class_id');
    }

    public function students()
    {
        return $this->belongsTo('Student');
    }

    public function class_grade()
    {
    	$g = Grade::with('gpa')->whereRaw('student_id = ? and class_id = ?', array($this->student_id, $this->class_id))->first();
    	if ( $g )
    		return $g->gpa->grade;
    }

}