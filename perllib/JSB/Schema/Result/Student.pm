use utf8;
package JSB::Schema::Result::Student;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

JSB::Schema::Result::Student

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<students>

=cut

__PACKAGE__->table("students");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 150

=head2 email

  data_type: 'varchar'
  is_nullable: 0
  size: 150

=head2 address

  data_type: 'varchar'
  is_nullable: 0
  size: 150

=head2 city

  data_type: 'varchar'
  is_nullable: 0
  size: 150

=head2 state

  data_type: 'varchar'
  is_nullable: 0
  size: 150

=head2 zip

  data_type: 'varchar'
  is_nullable: 0
  size: 30

=head2 phone1

  data_type: 'varchar'
  is_nullable: 0
  size: 20

=head2 phone2

  data_type: 'varchar'
  is_nullable: 1
  size: 20

=head2 phone3

  data_type: 'varchar'
  is_nullable: 1
  size: 20

=head2 phone4

  data_type: 'varchar'
  is_nullable: 1
  size: 20

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 150 },
  "email",
  { data_type => "varchar", is_nullable => 0, size => 150 },
  "address",
  { data_type => "varchar", is_nullable => 0, size => 150 },
  "city",
  { data_type => "varchar", is_nullable => 0, size => 150 },
  "state",
  { data_type => "varchar", is_nullable => 0, size => 150 },
  "zip",
  { data_type => "varchar", is_nullable => 0, size => 30 },
  "phone1",
  { data_type => "varchar", is_nullable => 0, size => 20 },
  "phone2",
  { data_type => "varchar", is_nullable => 1, size => 20 },
  "phone3",
  { data_type => "varchar", is_nullable => 1, size => 20 },
  "phone4",
  { data_type => "varchar", is_nullable => 1, size => 20 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<email>

=over 4

=item * L</email>

=back

=cut

__PACKAGE__->add_unique_constraint("email", ["email"]);

=head1 RELATIONS

=head2 enrollments

Type: has_many

Related object: L<JSB::Schema::Result::Enrollment>

=cut

__PACKAGE__->has_many(
  "enrollments",
  "JSB::Schema::Result::Enrollment",
  { "foreign.student_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 grades

Type: has_many

Related object: L<JSB::Schema::Result::Grade>

=cut

__PACKAGE__->has_many(
  "grades",
  "JSB::Schema::Result::Grade",
  { "foreign.student_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 users

Type: has_many

Related object: L<JSB::Schema::Result::User>

=cut

__PACKAGE__->has_many(
  "users",
  "JSB::Schema::Result::User",
  { "foreign.student_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07036 @ 2013-10-25 14:45:05
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:nAD4QfLebzNwz6MXSPRP/g


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
