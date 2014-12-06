# ---- APPLICATION CLASS ----
package JSB::AdminCTL;

use Term::ANSIColor qw(:constants);
use base qw( CLI::Framework );
use strict;

#
# Usage menu for base application (i.e. adminctl --help) to show available commands
#
sub usage_text
{
	{YELLOW .
"Usage:" .
RESET . "
  adminctl [options] command [arguments]

" . YELLOW . "OPTIONS:
  " . GREEN . "--help	" . RESET . "Display help generic or command-specific help dialog
  " . GREEN . "--verbose	" . RESET . "Increase vebosity of output

" . YELLOW . "COMMANDS:
  " . GREEN . "student	" . RESET . "student administration
  " . GREEN . "professor	" . RESET . "professor administration
  " . GREEN . "class		" . RESET . "class administration

"	}
}

#
# Specify available options specific to base application command
#
sub option_spec
{
    [ 'verbose|v'	=> 'Increase vebosity of output' ],
    [ 'help|h'		=> 'Display help generic or command-specific help dialog' ]
}


#
# Set base exception handler to output (and log if needed) errors and warnings to the console
#
sub handle_exception
{
	my ($app, $e) = @_;

	# Do logging here if needed #
	warn $e->error;
	return;
}

#
# Perform validation on base application options, if needed
#
sub validate_options
{
    my ($self, $opts) = @_;
}

#
# Map our application commands to their respective class objects
#
sub command_map
{
	my ($app) = @_;

	my $map = {
		help		=> 'CLI::Framework::Command::Help',
	    student     => 'JSB::AdminCTL::Command::Student',
	    professor   => 'JSB::AdminCTL::Command::Professor',
	    class       => 'JSB::AdminCTL::Command::Class',
	};

	return %{$map};
}


#
# Use the init subroutine in our base application to connect and cache our
# DBIx schema database for use within our application modules.
#
sub init
{
    my ($self, $opts) = @_;

	my $schema = JSB::Schema->connect(
		"dbi:mysql:virtual_college",
		'jsb',
		'',
		{
        	PrintError	=> 0,
        	RaiseError	=> 1,
		}
	);

    # Store model object in shared cache...
    $self->cache->set( 'model' => $schema );

    return 1;
}

#
# Function to standardize output formatting for telephone numbers
#
sub format_phone
{
	my $phone = shift;
	$phone = "($1) $2-$3" if $phone =~ /^([0-9]{3})-?([0-9]{3})-?([0-9]{4})$/;

	return $phone;
}

#
# Takes an ORM result and iterates each row into a numbered menu item the user can choose from.
# Dependant on "name" and "id" columns in ORM result.
# @arg1 - $sth ORM result handler generated from DBIx::Class
# @arg2 - $pre_menu boolean flag indicating if sub-prompt is a pre-prompt message
#
sub numbered_menu
{
	my $sth = shift;
	my $pre_menu = shift;

	my $c = 0;
	my $ops = {};
	my $menu;

	# Preload results with name and pk
	while ( my $row = $sth->next )
	{
		$ops->{$c} = {
			id		=> $row->get_column('id'),
			name	=> $row->get_column('name'),
		};

		$menu = sprintf("%s" . GREEN . "    [%d] %s \n" . RESET, $menu, ++$c, $row->get_column('name'));
	}

	# Only present the "search again" option w/post-prompt sub prompts
	$menu = sprintf("%s" . GREEN . "    [%d] %s \n" . RESET, $menu, ++$c, "Search again") unless $pre_menu;

	( --$c, $ops, $menu );
}

#
# Interactive guided prompt
# @arg1 - $self Current class object
# @arg2 - $prompts Hash ref containing elements corresponding to each step in prompting process. Hash can optionally
# 			contain (1) required boolean, (2) validation subroutine and pre/post_prompt subroutines for including nested
# 			menu dialogs within the prompt
#
sub guided_prompt
{
	my ($self, $prompts) = @_;

	# For each prompt, display it and collect input
	__START_:
	foreach my $elem ( sort { $a->{'inc'} <=> $b->{'inc'} } values %{ $prompts } )
	{
		_RETRY_:
		# If pre-prompt subroutine exists, skip user-invoked searching, just dump all results (i.e. semesters, grades)
		if ( $elem->{'pre_prompt'} )
		{
	    	$self->{ $elem->{'key'} } = $elem->{'pre_prompt'}->( $elem->{'prompt'} );
	    	goto _RETRY_ unless $self->{ $elem->{'key'} };
		}
		# Present the standard prompt
		else
		{
			printf($elem->{'prompt'});
		    chomp( $self->{ $elem->{'key'} } = <STDIN> );
		}

		# If post prompt subroutine exists use input collected above as argument to post-prompt subroutine for user-invoked search sub-dialog (i.e. search for professor)
	    if ( $elem->{'post_prompt'} )
	    {
	    	$self->{ $elem->{'key'} } = $elem->{'post_prompt'}->( $self->{ $elem->{'key'} } );
	    	goto _RETRY_ unless $self->{ $elem->{'key'} };
	    }

	    # If validation subroutine and/or required boolean exist
	    if ( ( $elem->{'required'} && ! $self->{ $elem->{'key'} } ) || ( $elem->{'validation'} && ( my $err = $elem->{'validation'}->( $self->{ $elem->{'key'} } ) ) ) )
		{
			printf(RED . ( $err ? $err : "Required Input. Please try again. \n" ) );
		    goto _RETRY_;
		}
	}

	return 1;
}



#
# Any type of shutdown requirements, if neede
#
END { }

1