package JSB::AdminCTL::Command::Class;

use Term::ANSIColor qw(:constants);
use base qw( JSB::AdminCTL CLI::Framework::Command );
use strict;

#
# Specify shorthand aliases to map to the available class commands
#
sub subcommand_alias
{
    s	=> 'show',
    a	=> 'add'
}

#
# Usage text for class command
#
sub usage_text
{

	{YELLOW .
"Usage:" .
RESET . "
  class [--help] command

" . YELLOW . "COMMAND:
  " . GREEN . "show" . RESET . "		display classes
  " . GREEN . "add" . RESET . "		add new class

"	}
}

#
# Rules passed to GetOpt::Long for options validation
#

sub option_spec
{
	[ 'help|h'		=> 'display usage dialog for class commands'],
    [ 'show|s'		=> 'display classes' ],
    [ 'add|a'		=> 'add new class' ],
}

#
# Custom validation performed on class command prior to running, if needed
#
sub validate
{
    my ($self, $cmd_opts, @args) = @_;

    die $self->usage_text() unless @args;
}

1;
#############################################
#### ---- SUBCOMMAND: Class::Add  ---- ######
#############################################
package JSB::AdminCTL::Command::Class::Add;

use Term::ANSIColor qw(:constants);
use base qw( JSB::AdminCTL::Command::Class );

use strict;

#
# Usage menu for class->add subcommand
#
sub usage_text
{
	{YELLOW .
"Usage:" .
RESET . "
  class add [--help]			" . YELLOW . "Add new class to virtual college database" . RESET . "

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
# Custom validation performed on class->add subcommand command prior to running, if needed
#
sub validate
{
    my ($self, $cmd_opts, @args) = @_;

    $self->{'count'} = 0 unless $self->{'count'};

    die $self->usage_text() if $cmd_opts->{'help'};
}

#
# Main functionality block for class->add subcommand
#
sub run
{
    my ($self, $opts, @args) = @_;

    my $schema = $self->cache->get( 'model' );

	printf(YELLOW . "\nStarting Interactive Class Maintanance:\n\n" . RESET);

	__START__:
	my $retval = $self->guided_prompt( {
		catalog_name	=> {
			inc			=> 1,
			key			=> 'catalog_name',
			prompt		=> GREEN . "  Enter course name/description: " . RESET,
			required	=> 1
		},
		catalog_no	=> {
			inc			=> 2,
			key			=> 'catalog_no',
			prompt		=> GREEN . "  Enter course catalog number: " . RESET,
			required	=> 1
		},
		credits	=> {
			inc			=> 3,
			key			=> 'credit_hours',
			prompt		=> GREEN . "  Enter total credit hours (2-4): " . RESET,
			validation	=> sub { return $_[0] =~ /^[2-4]$/ ? undef : "Classes can provide between 2 and 4 credit hours. Please retry your input. \n"; },
			required	=> 1
		},
		prof	=> {
			inc			=> 4,
			key			=> 'prof_id',
			prompt		=> GREEN . "  Search for class professor: " . RESET,
			required	=> 1,
			post_prompt	=> sub {

				my $input = shift;

				my $sth = $schema->resultset('Professor')->search(
					{ name => { 'like' => sprintf("%%%s%%", $input) } },
					{ select 	=> [ qw/ id name / ] }
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
		},
		semester	=> {
			inc			=> 5,
			key			=> 'semester_id',
			prompt		=> GREEN . "  Select semester: " . RESET,
			pre_prompt	=> sub {
				my ($prompt) = @_;

				printf("%s\n", $prompt) if $prompt;

				my $sth = $schema->resultset('Semester')->search(undef, { select => [ qw/ id semester / ], as => [ qw/ id name / ] } );

				my ($c, $ops, $menu) = JSB::AdminCTL::numbered_menu( $sth, 1 );

				# Display results in a numbered menu
				__RESULTS__:
				printf(GREEN . "%s", $menu);

				# Prompt user with sub-menu selections
				printf(RESET . "    > ");
				chomp( my $input = <STDIN> );

				goto __RESULTS__ unless $input =~ /^[0-9]{1,}$/ && $ops->{ $input-1 };

				# Return hash w/selection's PK and name for pretty presentation
				{
					id		=> $ops->{ $input-1 }->{'id'},
					name	=> $ops->{ $input-1 }->{'name'}
				};
			}
		}
	} );

	unless ( $retval == 1 )
	{
		printf(RED . "Error processing user input. Please try again.\n" . RESET);
		goto __NEXT__;
	}

	printf("\n  Adding %s to virtual college database ...", $self->{'catalog_name'});

	# Insert new class using Class ORM
	eval {
		my $retval = $schema->resultset('Class')->create( {
			'catalog_name'		=> $self->{'catalog_name'},
			'catalog_no'		=> $self->{'catalog_no'},
			'semester'			=> $self->{'semester_id'}->{'id'},
			'prof_id'			=> $self->{'prof_id'}->{'id'},
			'credit_hours'		=> $self->{'credit_hours'}
		} );
	};

	if ( $@ )
	{
		# Catch any db errors
		printf(RED . "Error: %s \n" . RESET, $@);
	}
	else
	{
		printf(GREEN . "OK. \n" . RESET);
		$self->{'count'}++;
	}

	# Finish up or go for another round?
	__NEXT__:
	printf("  Would you like to add another class [y]? ");
	chomp( my $input = <STDIN> );

	goto __START__ if ( ! $input || lc $input eq 'y' );

	printf("\nAdded %d classes to the virtual college database. Goodbye\n\n", $self->{'count'});
	return;
}
1;

#############################################
#### ---- SUBCOMMAND: Class::Show ---- ####
#############################################
package JSB::AdminCTL::Command::Class::Show;

use Term::ANSIColor qw(:constants);
use base qw( JSB::AdminCTL::Command::Class );

use strict;

#
# Usage menu for class->show subcommand
#
sub usage_text
{
	{YELLOW .
"Usage:" .
RESET . "
  class show [--help] [--verbose] [--class] [--prof] display class and student enrollment information

" . YELLOW . "OPTIONS:
  " . GREEN . "--help|h	" . RESET . "display this usage message
  " . GREEN . "--verbose|v	" . RESET . "display full student output for each class
  " . GREEN . "--class|c	" . RESET . "display students enrolled in a specific class (i.e. ENG101, ENG%)
  " . GREEN . "--prof|p	" . RESET . "display enrolled students by professor (i.e. %smith%)

"	}
}

#
# Validation for options to be passed to GetOpt::Long
#
sub option_spec
{
    [ 'help|h'		=> 'display this usage message' ],
    [ 'verbose|v' 	=> 'display student enrollment for each class'],
    [ 'class|c=s'	=> 'filter by class (i.e. ECON101)'],
    [ 'prof|p=s'   	=> 'filter by professor (i.e. %smith%)']
}

#
# Custom validation for this subcommand, if needed
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
# Main functionality block for this subcommand
#
sub run
{
    my ($self, $opts, @args) = @_;

    my $schema = $self->cache->get( 'model' );
	my $t;
	my $search = {};

	# If we're filtering by class
	if ( $self->{'class'} )
	{
		# We gave the user the option to inject their own wildcard search, if they didn't do an exact match
		$search->{'catalog_no'}	= ( $self->{'class'} =~ /%/ ? { 'like'	=> $self->{'class'} } : $self->{'class'} );
		$search->{'catalog_name'}	= ( $self->{'class'} =~ /%/ ? { 'like'	=> $self->{'class'} } : $self->{'class'} );
	}
	# If we're filtering by professor
	elsif ( $self->{'professor'} )
	{
		# We gave the user the option to inject their own wildcard search, if they didn't do an exact match
		$search->{'prof.name'} = ( $self->{'professor'} =~ /%/ ? { 'like'	=> $self->{'professor'} } : $self->{'professor'} );

	}

	# Are we presenting a summarized display or verbose?
	if ( $self->{'format'} eq 'sum' )
	{
		# Start up our formatted table output module from CPAN
		$t = Text::ASCIITable->new({ headingText	=> "Virtual College Classes (Summary)" } );

		$t->setCols('Catalog No', 'Name', 'Credits', 'Semester', 'Professor', 'Prof Email', 'Prof Phone', 'Prof Office', 'Students');
	}

	# $schema->storage->debug(1); # Debug SQL mode if needed

	# Search our Class ORM for all classes
	my $sth = $schema->resultset('Class')->search(
		$search,
	    {
	    	# Join onto professors and semesters tables according to fk relationships
	        'join'        => [ 'prof', 'semester', 'enrollments' ],
	        # Specify the cols we want
	        'select'      => [
	        	'id',
	        	'catalog_name',
	        	'catalog_no',
	        	'credit_hours',
	        	'semester.semester',
	        	'prof.name',
	        	'prof.email',
	        	'prof.office_phone',
	        	'prof.office_location',
	        	{
	        		# Get a student count per class
	        		count	=> 'enrollments.student_id',
	        		-as		=> 'student_count'
	        	}
			],
			group_by	=> [ qw/ me.id / ]
	    }
	);

	my $c = 0;
	while( my $row = $sth->next() )
	{
		if ( $self->{'format'} eq 'detail' )
		{
			$c = 0;

			# Format the table header
			my $heading = sprintf("Virtual College Class Enrollment\n[%s] %s (%d Credit Hours)\nProfessor: %s %s %s", $row->catalog_no, $row->catalog_name, $row->credit_hours, $row->prof->name, $row->prof->email, JSB::AdminCTL::format_phone($row->prof->office_phone));

			# Start up our formatted table output module from CPAN
			$t = Text::ASCIITable->new({ headingText	=> $heading });

			# If we wanted to get really detailed we could allow user to specify display columns, for now just use these...
			$t->setCols('Student Name', 'Email', 'Address', 'Phone', 'Phone 2', 'Phone 3', 'Phone 4');
			$t->setColWidth('Student Name', 35, 1);
			$t->setColWidth('Email', 15, 1);
			$t->setColWidth('Phone', 15, 1);

			# Search for student enrollment for each class iteration
			my $sth2 = $schema->resultset('Enrollment')->search(
				{
			    	'class_id'  => $row->id
				},
			    {
			    	'join'      => [ 'student' ],
			        'select'    =>
			        	[
			            	'student.name',
			                'student.email',
			                'student.address',
			                'student.city',
			                'student.state',
			                'student.zip',
			                'student.phone1'
						]
				}
			);

			# Since we're in verbose mode, print student information for each class
			while ( my $row2 = $sth2->next )
			{
				my $addr = sprintf("%s %s, %s %s", $row2->student->address, $row2->student->city, uc $row2->student->state, $row2->student->zip);

				$t->addRow(
					$row2->student->name,
					$row2->student->email,
					$addr,
					JSB::AdminCTL::format_phone($row2->student->phone1),
					JSB::AdminCTL::format_phone($row2->student->phone2),
					JSB::AdminCTL::format_phone($row2->student->phone3),
					JSB::AdminCTL::format_phone($row2->student->phone4)
				);

				$c++;
			}

			printf("%s %d results displayed\n\n", $t, $c);
		}
		else
		{
			# Add a row onto our formatted table for each result
			$t->addRow(
				$row->catalog_no,
				$row->catalog_name,
				$row->credit_hours,
				$row->semester->semester,
				$row->prof->name,
				$row->prof->email,
				JSB::AdminCTL::format_phone($row->prof->office_phone),
				$row->prof->office_location,
				$row->get_column('student_count')
			);
		}

		$c++;
	}

	# Output everything and wrap it up
	printf("%s %d results displayed\n\n", $t, $c) unless $self->{'format'} eq 'detail';

    return;
}
1;