<?php

// Model:'Professor' - Database Table: 'professors'

Class Professor extends Eloquent
{

    protected $table='professors';

    public function courses()
    {
        return $this->hasMany('Course', 'prof_id');
    }
    public function users()
    {
        return $this->belongsToMany('User');
    }

    public function total_students($cid)
    {
    	return Enrollment::where('class_id', '=', $cid)->count();
    }
}