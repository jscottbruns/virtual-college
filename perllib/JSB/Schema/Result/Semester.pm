use utf8;
package JSB::Schema::Result::Semester;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

JSB::Schema::Result::Semester

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<semesters>

=cut

__PACKAGE__->table("semesters");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 semester

  data_type: 'varchar'
  is_nullable: 0
  size: 50

=head2 calendar_start

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 0

=head2 calendar_end

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
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
  "semester",
  { data_type => "varchar", is_nullable => 0, size => 50 },
  "calendar_start",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 0,
  },
  "calendar_end",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
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

=head2 C<semester>

=over 4

=item * L</semester>

=back

=cut

__PACKAGE__->add_unique_constraint("semester", ["semester"]);

=head1 RELATIONS

=head2 classes

Type: has_many

Related object: L<JSB::Schema::Result::Class>

=cut

__PACKAGE__->has_many(
  "classes",
  "JSB::Schema::Result::Class",
  { "foreign.semester" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07036 @ 2013-10-25 14:45:05
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:qF2ZvnzYqgWDfw0Cx/PXtg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
