<?php

// Model:'Student' - Database Table: 'students'

Class Student extends Eloquent
{

    protected $table='students';

    public function enrollments()
    {
        return $this->hasMany('Enrollment');
    }

    public function grades()
    {
        return $this->hasMany('Grades');
    }

    public function users()
    {
        return $this->belongsTo('User');
    }

    public function calculate_gpa()
    {
    	$gpa = DB::table('enrollment')
    		->leftJoin('grades', function($join)
    		{
    			$join->on('grades.class_id', '=', 'enrollment.class_id');
    			$join->on('grades.student_id', '=', 'enrollment.student_id');
    		})
    		->leftJoin('gpa', 'gpa.id', '=', 'grades.gpa_id')
    		->select( DB::raw(' ROUND( SUM(gpa.quality_points) / SUM(gpa.credit_hours), 2) AS gpa') )
    		->where('enrollment.student_id', '=', $this->id)
    		->first();

    	if ( $gpa->gpa && $gpa->gpa > 0 )
    		return $gpa->gpa;
    }
}