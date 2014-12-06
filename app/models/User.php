<?php
use Illuminate\Auth\UserInterface;
use Illuminate\Auth\Reminders\RemindableInterface;

// Model:'User' - Database Table: 'users'

class User extends Eloquent implements UserInterface, RemindableInterface
{

    protected $table = 'users';
    public $timestamps = false;

    protected $hidden = array('password');

    public function getAuthIdentifier()
    {
    	return $this->getKey();
    }

    /**
     * Get the password for the user.
     *
     * @return string
     */
    public function getAuthPassword()
    {
    	return $this->password;
    }

    /**
     * Get the e-mail address where password reminders are sent.
     *
     * @return string
     */
    public function getReminderEmail()
    {
    	return $this->email;
    }

    public function students()
    {
        return $this->belongsTo('Student');
    }

    public function professors()
    {
        return $this->belongsTo('Professor');
    }

}