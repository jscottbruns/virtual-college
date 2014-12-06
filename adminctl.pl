#!/usr/bin/perl
use strict;

# Specify default library path within our application
use lib './perllib';

# Load required DBIx schema and application modules
use JSB::Schema;
use JSB::AdminCTL;

# Addition required CPAN modules
use Text::ASCIITable;

# Fire up the console application
JSB::AdminCTL->run();