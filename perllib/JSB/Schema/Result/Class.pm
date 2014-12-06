use utf8;
package JSB::Schema::Result::Class;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

JSB::Schema::Result::Class

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<classes>

=cut

__PACKAGE__->table("classes");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 catalog_name

  data_type: 'varchar'
  is_nullable: 0
  size: 150

=head2 catalog_no

  data_type: 'varchar'
  is_nullable: 0
  size: 50

=head2 semester

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 credit_hours

  data_type: 'smallint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 prof_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "catalog_name",
  { data_type => "varchar", is_nullable => 0, size => 150 },
  "catalog_no",
  { data_type => "varchar", is_nullable => 0, size => 50 },
  "semester",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "credit_hours",
  {
    data_type => "smallint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "prof_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<catalog_no>

=over 4

=item * L</catalog_no>

=back

=cut

__PACKAGE__->add_unique_constraint("catalog_no", ["catalog_no"]);

=head1 RELATIONS

=head2 enrollments

Type: has_many

Related object: L<JSB::Schema::Result::Enrollment>

=cut

__PACKAGE__->has_many(
  "enrollments",
  "JSB::Schema::Result::Enrollment",
  { "foreign.class_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 grades

Type: has_many

Related object: L<JSB::Schema::Result::Grade>

=cut

__PACKAGE__->has_many(
  "grades",
  "JSB::Schema::Result::Grade",
  { "foreign.class_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 prof

Type: belongs_to

Related object: L<JSB::Schema::Result::Professor>

=cut

__PACKAGE__->belongs_to(
  "prof",
  "JSB::Schema::Result::Professor",
  { id => "prof_id" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);

=head2 semester

Type: belongs_to

Related object: L<JSB::Schema::Result::Semester>

=cut

__PACKAGE__->belongs_to(
  "semester",
  "JSB::Schema::Result::Semester",
  { id => "semester" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);


# Created by DBIx::Class::Schema::Loader v0.07036 @ 2013-10-25 14:45:05
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:70dVxQo7ULrIiH8GdKHfbQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
