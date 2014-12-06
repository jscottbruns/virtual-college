package JSB::AdminCTL::Command::Professor;

use Term::ANSIColor qw(:constants);
use base qw( JSB::AdminCTL CLI::Framework::Command );
use strict;

#
# Specify shorthand aliases to map to the available professor commands
#
sub subcommand_alias
{
    s	=> 'show',
    a	=> 'add'
}

#
# Usage text for professor command
#
sub usage_text
{

	{YELLOW .
"Usage:" .
RESET . "
  professor [--help] command

" . YELLOW . "COMMAND:
  " . GREEN . "show" . RESET . "		display professors
  " . GREEN . "add" . RESET . "		add new professor
  " . GREEN . "postgrades" . RESET . "	post student grades

"	}
}

#
# Rules passed to GetOpt::Long for options validation
#
sub option_spec
{
	[ 'help|h'		=> 'display usage dialog for professor commands'],
    [ 'show|s'		=> 'display professors' ],
    [ 'add|a'		=> 'add new professor' ],
    [ 'postgrades|p'	=> 'post student grades' ],
}

#
# Custom validation performed on professor command prior to running, if needed
#
sub validate
{
    my ($self, $cmd_opts, @args) = @_;

    die $self->usage_text() unless @args;
}

1;
###############################################
#### ---- SUBCOMMAND: Professor::Add  ---- ####
###############################################
package JSB::AdminCTL::Command::Professor::Add;

use Term::ANSIColor qw(:constants);
use base qw( JSB::AdminCTL::Command::Professor );

use strict;

#
# Usage menu for professor->add subcommand
#
sub usage_text
{
	{YELLOW .
"Usage:" .
RESET . "
  student add [--help]			" . YELLOW . "Add new professor to virtual college database" . RESET . "

"	}
}

#
# Rules passed to GetOpt::Long for options validation
#
sub option_spec
{
    [ 'help|h'			=> 'display this usage message' ]
}


#
# Custom validation performed on professor->add subcommand command prior to running, if needed
#
sub validate
{
    my ($self, $cmd_opts, @args) = @_;

    $self->{'count'} = 0 unless $self->{'count'};

    die $self->usage_text() if $cmd_opts->{'help'};
}

#
# Main functionality block for professor->add subcommand
#
sub run
{
    my ($self, $opts, @args) = @_;

	my ($dberr, $prompts);
	my $search = {};
    my $schema = $self->cache->get( 'model' );

	printf(YELLOW . "\nStarting Interactive Professor Maintance:\n\n" . RESET);

	__START__:
	my $retval = $self->guided_prompt( {
		name	=> {
			inc			=> 1,
			key			=> 'name',
			prompt		=> GREEN . "  Professor name: " . RESET,
			required	=> 1
		},
		email	=> {
			inc			=> 2,
			key			=> 'email',
			prompt		=> GREEN . "  Email: " . RESET,
			required	=> 1,
			validation	=> sub { return $_[0] =~ /^[\w.]+\@(?:[\da-zA-Z\-]{1,}\.){1,}[\da-zA-Z-]{2,6}$/ ? undef : "Invalid email. Please re-enter email address.\n"; }
		},
		address	=> {
			inc			=> 3,
			key			=> 'office_location',
			prompt		=> GREEN . "  Office Location []: " . RESET,
			required	=> 1
		},
		city	=> {
			inc			=> 4,
			key			=> 'office_hours',
			prompt		=> GREEN . "  Office Hours []: " . RESET,
		},
		phone1	=> {
			inc			=> 5,
			key			=> 'office_phone',
			prompt		=> GREEN . "  Office phone []: " . RESET,
			validation	=> sub { return $_[0] =~ /^[0-9]{3}-?[0-9]{3}-?[0-9]{4}$/ ? undef : "Please enter a valid phone number including area code. \n"; }
		}
	} );

	unless ( $retval == 1 )
	{
		printf(RED . "Error processing user input. Please try again.\n" . RESET);
		goto __NEXT__;
	}

	printf("\nCreating new professor record for %s ... ", $self->{'name'});

	# Insert new student using Student ORM from our DBIx::Class schema
	my ($prof_id, $login_err);
	eval {
		my $retval = $schema->resultset('Professor')->create( {
			'name'		=> $self->{'name'},
			'email'		=> $self->{'email'},
			'office_location'	=> $self->{'office_location'},
			'office_hours'		=> $self->{'office_hours'},
			'office_phone'		=> $self->{'office_phone'}
		} );
		$prof_id = $retval->id;
	};

	# Handle any database errors
	if ( $@ )
	{
		printf(RED . "Error: %s \n" . RESET, $@);
		# If we caught an error, skip the user login prompt as their will be no fk to satisfy
		goto _NEXT_;
	}
	else
	{
		printf(GREEN . "OK. Professor ID %d added. \n" . RESET, $prof_id);
		$self->{'count'}++;
	}

	# Professors can access their account via the web interface, prompt use to create web login
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
				'prof_id'		=> $prof_id
			} )
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

	# Finish or go another round?
	_NEXT_:
	printf("\nCreate another professor [y]? ");

	chomp( my $action = <STDIN> );

	goto __START__ if ( ! $action || lc $action eq 'y' );

	printf("\nCreated %d professors. Goodbye\n\n", $self->{'count'});
	return;
}

1;
###############################################
#### ---- SUBCOMMAND: Professor::Show ---- ####
###############################################
package JSB::AdminCTL::Command::Professor::Show;

use Term::ANSIColor qw(:constants);
use base qw( JSB::AdminCTL::Command::Professor );

use strict;

#
# Usage menu for professor->show subcommand
#
sub usage_text
{
	{YELLOW .
"Usage:" .
RESET . "
  professor show [--help] display professor information

" . YELLOW . "OPTIONS:
  " . GREEN . "--help|h	" . RESET . "display this usage message
"	}
}

#
# Validation for options to be passed to GetOpt::Long
#
sub option_spec
{
    [ 'help|h'		=> 'display this usage message' ]
}

#
# Custom validation for this subcommand
#
sub validate
{
    my ($self, $cmd_opts, @args) = @_;

    die $self->usage_text() if $cmd_opts->{'help'};
}

#
# Main functionality block for this subcommand
#
sub run
{
    my ($self, $opts, @args) = @_;

	my ($sth, $t);
    my $schema = $self->cache->get( 'model' );

	$t = Text::ASCIITable->new({ headingText	=> "Virtual College Professors" });
	$t->setCols('Prof Name', 'Email', 'Office Phone', 'Office Location', 'Office Hours');
	$t->setColWidth('Prof Name', 25, 1);

	#$schema->storage->debug(1); # Debug SQL mode if needed

	# Keep it simple, no filters available here so just search all professors
	$sth = $schema->resultset('Professor')->search( undef,
	    {
	    	# Specify the cols we want, or we could have just prefetched everything
	        'select'      => [ qw/ name email office_phone office_hours office_location / ]
	    }
	);

	my $c = 0;
	while( my $row = $sth->next() )
	{
		# Add each result row to our formatted table
		$t->addRow($row->name, $row->email, $row->office_phone, $row->office_hours, $row->office_location);
		$c++;
	}

	# Output everything and wrap up
	printf("%s %d results displayed\n\n", $t, $c);

    return;
}
1;


#####################################################
#### ---- SUBCOMMAND: Professor::Postgrades ---- ####
#####################################################
package JSB::AdminCTL::Command::Professor::Postgrades;

use Term::ANSIColor qw(:constants);
use base qw( JSB::AdminCTL::Command::Professor );

use strict;

#
# Usage menu for professor->postgrades subcommand
#
sub usage_text
{
	{YELLOW .
"Usage:" .
RESET . "
  professor postgrades [--help] post student grades

" . YELLOW . "OPTIONS:
  " . GREEN . "--help|h	" . RESET . "display this usage message
"	}
}

#
# Validation for options to be passed to GetOpt::Long
#
sub option_spec
{
    [ 'help|h'		=> 'display this usage message' ]
}

#
# Custom validation for this subcommand
#
sub validate
{
    my ($self, $cmd_opts, @args) = @_;

    die $self->usage_text() if $cmd_opts->{'help'};
}

#
# Main functionality block for this subcommand
#
sub run
{
    my ($self, $opts, @args) = @_;

	my ($sth, $t);
    my $schema = $self->cache->get( 'model' );

	printf(YELLOW . "\nStarting Interactive Class Grade Posting:\n\n" . RESET);

	__START__:
	my $retval = $self->guided_prompt( {
		class	=> {
			inc			=> 1,
			key			=> 'class_id',
			prompt		=> GREEN . "  Search for class: " . RESET,
			post_prompt	=> sub {

				my $input = shift;

				my $sth = $schema->resultset('Class')->search(
					{ catalog_name => { 'like' => sprintf("%%%s%%", $input) } },
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
		student	=> {
			inc			=> 2,
			key			=> 'student_id',
			prompt		=> GREEN . "  Search for student: " . RESET,
			post_prompt	=> sub {
				my $input = shift;

				# Run a quick wildcard search for matching students
				my $sth = $schema->resultset('Student')->search(
					{
						name 					=> { 'like' => sprintf("%%%s%%", $input) },
						'enrollments.class_id' 	=> $self->{'class_id'}->{'id'}
					},
					{
						select	=> [ qw/ id name / ],
						join	=> [ qw/ enrollments / ]
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
		gpa	=> {
			inc			=> 3,
			key			=> 'gpa_id',
			prompt		=> GREEN . "  Select Grade: " . RESET,
			required	=> 1,
			pre_prompt	=> sub {

				my ($prompt) = @_;

				printf("%s\n", $prompt) if $prompt;

				my $sth = $schema->resultset('Gpa')->search({ credit_hours => $schema->resultset('Class')->find( { id => $self->{'class_id'}->{'id'} }, { select => [ qw/ credit_hours / ] } )->credit_hours }, { select => [ qw/ id grade / ], as => [ qw/ id name / ] } );

				my ($c, $ops, $menu) = JSB::AdminCTL::numbered_menu( $sth, 1 );

				# Display results in a numbered menu
				__RESULTS__:
				printf(GREEN . "%s", $menu);

				# Prompt user with sub-menu selections
				printf(RESET . "    > ");
				chomp( my $input = <STDIN> );

				goto __RESULTS__ unless $input =~ /^[0-9]{1,}$/ && $ops->{ $input-1 };

				# Save selection in a hash with the student's pk and name (for friend dialog message later)
				{
					id		=> $ops->{ $input-1 }->{'id'},
					name	=> $ops->{ $input-1 }->{'name'}
				};
			},
		}
	} );

	unless ( $retval == 1 )
	{
		printf(RED . "Error processing user input. Please try again.\n" . RESET);
		goto __NEXT__;
	}

	printf("\n  Posting grade %s to class %s for student %s ...", $self->{'gpa_id'}->{'name'}, $self->{'class_id'}->{'name'}, $self->{'student_id'}->{'name'});

	eval {
		$schema->resultset('Grade')->create( {
			description	=> 'Course Grade',
			class_id	=> $self->{'class_id'}->{'id'},
			student_id	=> $self->{'student_id'}->{'id'},
			gpa_id		=> $self->{'gpa_id'}->{'id'}
		} )
	};

	if ( $@ )
	{
		printf(RED . " Error: %s\n" . RESET, $@);
	}
	else
	{
		printf(GREEN . "OK\n" . RESET);
		$self->{'count'}++;
	}

	# Start over or finish up?
	__NEXT__:
	printf("  Would you like to post addition grades [y]? ");
	chomp( my $input = <STDIN> );

	goto __START__ if ( ! $input || lc $input eq 'y' );

	printf("\nPosted %d class grades. Goodbye\n\n", $self->{'count'});
    return;
}

1;