use utf8;
package JSB::Schema::Result::Gpa;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

JSB::Schema::Result::Gpa

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<gpa>

=cut

__PACKAGE__->table("gpa");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 grade

  data_type: 'char'
  is_nullable: 0
  size: 2

=head2 credit_hours

  data_type: 'tinyint'
  is_nullable: 0

=head2 quality_points

  data_type: 'decimal'
  is_nullable: 1
  size: [4,1]

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "grade",
  { data_type => "char", is_nullable => 0, size => 2 },
  "credit_hours",
  { data_type => "tinyint", is_nullable => 0 },
  "quality_points",
  { data_type => "decimal", is_nullable => 1, size => [4, 1] },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<grade>

=over 4

=item * L</grade>

=item * L</credit_hours>

=back

=cut

__PACKAGE__->add_unique_constraint("grade", ["grade", "credit_hours"]);

=head1 RELATIONS

=head2 grades

Type: has_many

Related object: L<JSB::Schema::Result::Grade>

=cut

__PACKAGE__->has_many(
  "grades",
  "JSB::Schema::Result::Grade",
  { "foreign.gpa_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07036 @ 2013-10-25 14:45:05
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:0mRH4pEP+DJ8keqABsrubw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
