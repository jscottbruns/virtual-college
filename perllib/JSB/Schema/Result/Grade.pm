use utf8;
package JSB::Schema::Result::Grade;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

JSB::Schema::Result::Grade

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<grades>

=cut

__PACKAGE__->table("grades");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 description

  data_type: 'varchar'
  is_nullable: 0
  size: 100

=head2 class_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 student_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 gpa_id

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
  "description",
  { data_type => "varchar", is_nullable => 0, size => 100 },
  "class_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "student_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "gpa_id",
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

=head1 RELATIONS

=head2 class

Type: belongs_to

Related object: L<JSB::Schema::Result::Class>

=cut

__PACKAGE__->belongs_to(
  "class",
  "JSB::Schema::Result::Class",
  { id => "class_id" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);

=head2 gpa

Type: belongs_to

Related object: L<JSB::Schema::Result::Gpa>

=cut

__PACKAGE__->belongs_to(
  "gpa",
  "JSB::Schema::Result::Gpa",
  { id => "gpa_id" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);

=head2 student

Type: belongs_to

Related object: L<JSB::Schema::Result::Student>

=cut

__PACKAGE__->belongs_to(
  "student",
  "JSB::Schema::Result::Student",
  { id => "student_id" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);


# Created by DBIx::Class::Schema::Loader v0.07036 @ 2013-10-25 14:45:05
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:fpbzD6l5tDQSZynk3v63NA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
