# ---- Student Class ----
package JSB::AdminCTL::Command::Student;

use Term::ANSIColor qw(:constants);
use base qw( JSB::AdminCTL CLI::Framework::Command );
use strict;

#
# Specify shorthand aliases to map to the available student commands
#
sub subcommand_alias
{
    s	=> 'show',
    a	=> 'add',
    e	=> 'enroll'
}

#
# Usage and help menu for student commands
#
sub usage_text
{

	{YELLOW .
"Usage:" .
RESET . "
  student [--help] command

" . YELLOW . "COMMAND:
  " . GREEN . "show" . RESET . "		display student enrollment information
  " . GREEN . "add" . RESET . "		add new student
  " . GREEN . "enroll" . RESET . "	enroll student in a class

"	}
}

#
# Rules passed to GetOpt::Long for options validation
#
sub option_spec
{
	[ 'help|h'		=> 'display usage dialog for student commands'],
    [ 'show|s'		=> 'display student enrollment information' ],
    [ 'add|a'		=> 'add a new student' ],
    [ 'enroll|e'		=> 'enroll student in a class' ]
}

#
# Validation performed on student commands prior to running
#
sub validate
{
    my ($self, $cmd_opts, @args) = @_;

    die $self->usage_text() unless @args;
}
1;

#############################################
#### ---- SUBCOMMAND: Student::Add  ---- ####
#############################################
package JSB::AdminCTL::Command::Student::Add;

use Term::ANSIColor qw(:constants);
use base qw( JSB::AdminCTL::Command::Student );

use strict;

#
# Student::Add usage menu
#
sub usage_text
{
	{YELLOW .
"Usage:" .
RESET . "
  student add [--help]			" . YELLOW . "Add new student to virtual college database" . RESET . "

"	}
}

#
# Student::Add option specifications
#
sub option_spec
{
    [ 'help|h'			=> 'display this usage message' ]
}

#
# Student::Add option validation
#
sub validate
{
    my ($self, $cmd_opts, @args) = @_;

    $self->{'count'} = 0 unless $self->{'count'};

    die $self->usage_text() if $cmd_opts->{'help'};
}

#
# Student::Add main functionality subroutine
#
sub run
{
    my ($self, $opts, @args) = @_;

	my ($dberr, $prompts);
	my $search = {};
    my $schema = $self->cache->get( 'model' );

	printf(YELLOW . "\nStarting Interactive Student Maintenance:\n\n" . RESET);

	# Launch the guided prompt with the following steps (1 hash element per step)
	__START__:
	my $retval = $self->guided_prompt( {
		name	=> {
			inc			=> 1,
			key			=> 'name',
			prompt		=> GREEN . "  Student name: " . RESET,
			required	=> 1
		},
		email	=> {
			inc			=> 2,
			key			=> 'email',
			prompt		=> GREEN . "  Primary email: " . RESET,
			required	=> 1,
			validation	=> sub { return $_[0] =~ /^[\w.]+\@(?:[\da-zA-Z\-]{1,}\.){1,}[\da-zA-Z-]{2,6}$/ ? undef : "Invalid email. Please re-enter primary student email address.\n"; }
		},
		address	=> {
			inc			=> 3,
			key			=> 'address',
			prompt		=> GREEN . "  Primary address: " . RESET,
			required	=> 1
		},
		city	=> {
			inc			=> 4,
			key			=> 'city',
			prompt		=> GREEN . "  City: " . RESET,
			required	=> 1
		},
		state	=> {
			inc			=> 5,
			key			=> 'state',
			prompt		=> GREEN . "  State: " . RESET,
			required	=> 1,
			validation	=> sub { return $_[0] =~ /^[A-Za-z]{2}$/ ? undef : "Please enter a valid state abbreviation (i.e. MD, VA, etc). \n"; }
		},
		zip	=> {
			inc			=> 6,
			key			=> 'zip',
			prompt		=> GREEN . "  Zip: " . RESET,
			required	=> 1,
			validation	=> sub { return $_[0] =~ /^[0-9]{5}$/ ? undef : "Please enter a valid 5-digit zip code. \n"; }
		},
		phone1	=> {
			inc			=> 7,
			key			=> 'phone1',
			prompt		=> GREEN . "  Primary phone: " . RESET,
			required	=> 1,
			validation	=> sub { return $_[0] =~ /^[0-9]{3}-?[0-9]{3}-?[0-9]{4}$/ ? undef : "Please enter a valid phone number including area code. \n"; }
		},
		phone2	=> {
			inc			=> 8,
			key			=> 'phone2',
			prompt		=> GREEN . "  Alternate phone 1 []: " . RESET
		},
		phone3	=> {
			inc			=> 9,
			key			=> 'phone3',
			prompt		=> GREEN . "  Alternate phone 2 []: " . RESET
		},
		phone4	=> {
			inc			=> 10,
			key			=> 'phone4',
			prompt		=> GREEN . "  Alternate phone 3 []: " . RESET
		}
	} );

	unless ( $retval == 1 )
	{
		printf(RED . "Error processing user input. Please try again.\n" . RESET);
		goto __NEXT__;
	}

	printf("\nCreating new student record for %s ... ", $self->{'name'});

	# Insert new student using Student ORM from our DBIx::Class schema
	my ($student_id, $login_err);
	eval {
		my $retval = $schema->resultset('Student')->create( {
			'name'		=> $self->{'name'},
			'email'		=> $self->{'email'},
			'address'	=> $self->{'address'},
			'city'		=> $self->{'city'},
			'state'		=> $self->{'state'},
			'zip'		=> $self->{'zip'},
			'phone1'	=> $self->{'phone1'},
			'phone2'	=> $self->{'phone2'} || undef,
			'phone3'	=> $self->{'phone3'} || undef,
			'phone4'	=> $self->{'phone4'} || undef
		} );
		$student_id = $retval->id;
	};

	# Handle any database errors
	if ( $@ )
	{
		printf(RED . "Error: %s \n" . RESET, $@);
		# If we caught an error, skip the user login prompt as their will be no fk to satisfy
		goto __NEXT__;
	}
	else
	{
		printf(GREEN . "OK. Student ID %d added. \n" . RESET, $student_id);
		$self->{'count'}++;
	}

	# Students can access their account via the web interface, prompt use to create web login
	printf("\nCreate user login for %s [y]? ", $self->{'name'});
	chomp( my $login = <STDIN> );

	# Create the login to allow for web access
	if ( !$login || lc $login eq 'y' )
	{
		# Get the authentication hash from laravel's Hash class
		my $hash = `php public/hash.php $self->{email}`;

		printf("Creating user login for %s ... ", $self->{'name'});

		# Insert new user using User model object
		eval {
			$schema->resultset('User')->create( {
				'username'		=> $self->{'email'},
				'password'		=> $hash,
				'student_id'	=> $student_id
			} );
		};

		if ( $@ )
		{
			printf(RED . "Error: %s\n" . RESET, $@);
		}
		else
		{
			printf(GREEN . "OK. User login created w/credentials: U: %s P: %s \n" . RESET, $self->{'email'}, $self->{'email'});
		}

	}

	# Finish or restart the process, depending on user selection
	__NEXT__:
	printf("\nCreate another student [y]? ");

	chomp( my $action = <STDIN> );

	goto __START__ if ( ! $action || lc $action eq 'y' );

	printf("\nCreated %d new students. Goodbye.\n\n", $self->{'count'});
}
1;
################################################
#### ---- SUBCOMMAND: Student::Enroll  ---- ####
################################################
package JSB::AdminCTL::Command::Student::Enroll;

use Term::ANSIColor qw(:constants);
use base qw( JSB::AdminCTL::Command::Student );

use strict;

#
# Usage menu for enrolling students
#
sub usage_text
{
	{YELLOW .
"Usage:" .
RESET . "
  student enroll [--help]			" . YELLOW . "Enroll students in classes" . RESET . "

"	}
}

#
# GetOpt::Long option specifications for automated validation, if needed
#
sub option_spec
{
    [ 'help|h'			=> 'display this usage message' ]
}

#
# Custom option validation prior to running
#
sub validate
{
    my ($self, $cmd_opts, @args) = @_;

    die $self->usage_text() if $cmd_opts->{'help'};
}

#
# Student::Enroll main functionality subroutine
#
sub run
{
    my ($self, $opts, @args) = @_;

	my $schema = $self->cache->get( 'model' );

	printf(YELLOW . "\nStarting Interactive Student Enrollment:\n\n" . RESET);

	__START__:
	# Star the guided prompt
	my $retval = $self->guided_prompt( {
		student	=> {
			inc			=> 1,
			key			=> 'student_id',
			prompt		=> GREEN . "  Search for student to be enrolled: " . RESET,
			post_prompt	=> sub {
				my $input = shift;

				# Run a quick wildcard search for matching students
				my $sth = $schema->resultset('Student')->search(
					{
						name 					=> { 'like' => sprintf("%%%s%%", $input) }
					},
					{
						select	=> [ qw/ id name / ]
					}
				);

				my ($c, $ops, $menu) = JSB::AdminCTL::numbered_menu( $sth );

				# Display results in a numbered menu
				__RESULTS__:
				printf(GREEN . "  Found %d matches. \n%s", $c, $menu);

				# If we came up empty send us back to the student search input prompt to start again
				return $c unless $c > 0;

				# Prompt user with sub-menu selections
				printf(RESET . "    > ");
				chomp( $input = <STDIN> );

				goto __RESULTS__ unless $input =~ /^[0-9]{1,}$/;
				return 0 unless $ops->{ $input-1 };

				# Save selection in a hash with the student's pk and name (for friend dialog message later)
				{
					id		=> $ops->{ $input-1 }->{'id'},
					name	=> $ops->{ $input-1 }->{'name'}
				};
			},
			required	=> 1,
		},
		class	=> {
			inc			=> 1,
			key			=> 'class_id',
			prompt		=> GREEN . "  Search for class: " . RESET,
			post_prompt	=> sub {

				my $input = shift;

				# Search classes by catalog name according to user input
				my $sth = $schema->resultset('Class')->search(
					{
						catalog_name => { 'like' => sprintf("%%%s%%", $input) }
					},
					{
						select 	=> [ 'me.id', 'prof_id', { concat => [ 'catalog_name', '" ("', 'prof.name', '")"' ], -as => 'name' } ],
						join 	=> [ 'prof' ]
					}
				);

				my ($c, $ops, $menu) = JSB::AdminCTL::numbered_menu($sth);

				# Display results in a numbered menu
				__RESULTS__:
				printf(GREEN . "  Found %d matches. \n%s", $c, $menu);

				# If we came up empty send us back to the student search input prompt to start again
				return $c unless $c > 0;

				# Prompt user with sub-menu selections
				printf(RESET . "    > ");
				chomp( $input = <STDIN> );

				goto __RESULTS__ unless $input =~ /^[0-9]{1,}$/;
				return 0 unless $ops->{ $input-1 };

				# Save selection in a hash with the student's pk and name (for friend dialog message later)
				{
					id		=> $ops->{ $input-1 }->{'id'},
					name	=> $ops->{ $input-1 }->{'name'}
				};
			},
			required	=> 1
		},
	} );

	unless ( $retval == 1 )
	{
		printf(RED . "Error processing user input. Please try again.\n" . RESET);
		goto __NEXT__;
	}

	# Friendly dialog message
	printf("\n  Enrolling %s in class %s ... ", $self->{'student_id'}->{'name'}, $self->{'class_id'}->{'name'});

	# Make sure our student isn't already enrolled into this class, if so give user option to select another class
	if ( $schema->resultset('Enrollment')->search( {
		student_id	=> $self->{'student_id'}->{'id'},
		class_id	=> $self->{'class_id'}->{'id'}
	})->all() )
	{
		printf(RED .   "%s is already enrolled in %s.\n" . RESET, $self->{'student_id'}->{'name'}, $self->{'class_id'}->{'name'});
		goto __START__;
	}

	# Use our DBIx::Class schema to save a new enrollment row, making sure to meet both fk requirements
	eval {
		my $retval = $schema->resultset('Enrollment')->create( {
			'student_id'	=> $self->{'student_id'}->{'id'},
			'class_id'		=> $self->{'class_id'}->{'id'}
		} )
	};

	if ( $@ )
	{
		printf(RED . "Error: %s \n" . RESET, $@);
	}
	else
	{
		printf(GREEN . "OK. \n" . RESET);
		$self->{'count'}++;
	}

	# Start over or finish up?
	printf("  Would you like to enroll another student [y]? ");
	chomp( my $input = <STDIN> );

	goto __START__ if ( ! $input || lc $input eq 'y' );

	printf("\nEnrolled %d students. Goodbye\n\n", $self->{'count'});
	return;
}
1;

#############################################
#### ---- SUBCOMMAND: Student::Show ---- ####
#############################################
package JSB::AdminCTL::Command::Student::Show;

use Term::ANSIColor qw(:constants);
use base qw( JSB::AdminCTL::Command::Student );

use strict;

#
# Usage menu for student->show subcommand
#
sub usage_text
{
	{YELLOW .
"Usage:" .
RESET . "
  student show [--help]	display virtual college students

" . YELLOW . "OPTIONS:
  " . GREEN . "--help|h	" . RESET . "display this usage message

"	}
}

#
# Available options for showing students, validated against GetOpt::Long
#
sub option_spec
{
    [ 'help|h'		=> 'display this usage message' ]
}

#
# Validate options and/or arguments and preload a few "session" variables for use when we run
#
sub validate
{
    my ($self, $cmd_opts, @args) = @_;

	$self->{'format'} = ( $cmd_opts->{'verbose'} ? 'detail' : 'sum' );
	$self->{'class'} = $cmd_opts->{'class'};
	$self->{'professor'} = $cmd_opts->{'prof'};

    die $self->usage_text() if $cmd_opts->{'help'};
}

#
# Main functionality block for showing students
#
sub run
{
    my ($self, $opts, @args) = @_;

	my ($sth, $t);
    my $schema = $self->cache->get( 'model' );

	$t = Text::ASCIITable->new({ headingText	=> "Virtual College Students" });
	$t->setCols('Name', 'Email', 'Address', 'Phone', 'Phone 2', 'Phone 3', 'Phone 4', 'Classes');
	$t->setColWidth('Name', 25, 1);

	# Keep it simple, no filters available here so just search all students
	$sth = $schema->resultset('Student')->search(
		undef,
		{
			join		=> [ 'enrollments' ],
			select		=>
			[
				'name',
				'email',
				'address',
				'city',
				'state',
				'zip',
				'phone1',
				'phone2',
				'phone3',
				'phone4',
				{
					count	=> 'enrollments.class_id',
					-as		=> 'class_count'
				}
			],
			group_by	=> [ qw/ me.id / ]
		}
	);

	my $c = 0;
	while( my $row = $sth->next() )
	{
		my $addr = sprintf("%s %s, %s %s", $row->address, $row->city, uc $row->state, $row->zip);

		# Add each result row to our formatted table
		$t->addRow(
			$row->name,
			$row->email,
			$addr,
			JSB::AdminCTL::format_phone($row->phone1),
			JSB::AdminCTL::format_phone($row->phone2),
			JSB::AdminCTL::format_phone($row->phone3),
			JSB::AdminCTL::format_phone($row->phone4),
			$row->get_column('class_count')
		);
		$c++;
	}

	# Output everything and wrap up
	printf("%s %d results displayed\n\n", $t, $c);

    return;
}


1;
