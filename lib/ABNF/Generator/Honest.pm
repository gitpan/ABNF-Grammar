package ABNF::Generator::Honest;

=pod

=head1 NAME

B<ABNF::Generator::Honest> - class to generate valid messages for ABNF-based generators

=head1 INHERITANCE

B<ABNF::Generator::Honest>
isa B<ABNF::Generator>

=head1 DESCRIPTION

=head1 METHODS

=cut

use 5.014;

use strict;
use warnings;
no warnings "recursion";

use Data::Dumper;

use POSIX;

use base qw(ABNF::Generator Exporter);

use Method::Signatures; #some bug in B<Devel::Declare>...

use ABNF::Generator qw($CONVERTERS $RECURSION_LIMIT);

our @EXPORT_OK = qw(Honest);

=pod

=head1 ABNF::Generator::Honest->C<new>($grammar, $validator?)

Creates a new B<ABNF::Generator::Honest> object.

$grammar isa B<ABNF::Grammar>.

$validator isa B<ABNF::Validator>. 

=cut

method new(ABNF::Grammar $grammar, ABNF::Validator $validator?) {
	$self->SUPER::new($grammar, $validator ? $validator : ());
}

=pod

=head1 $honest->C<generate>($rule, $tail="")

Generates one valid sequence string for command $rule. 

Using cache $self->{_cache}->{$rule} for this rule, that speeds up this call.

$rule is a command name.

$tail is a string added to result if it absent.

dies if there is no command like $rule.

=cut

method _range($rule, $level) {
	my $converter = $CONVERTERS->{$rule->{type}};
	my $min = $converter->($rule->{min});
	my $max = $converter->($rule->{max});
	return {class => "Atom", value => chr($min + int(rand($max - $min + 1)))};
}

method _string($rule, $level) {
	my $converter = $CONVERTERS->{$rule->{type}};
	return {
		class => "Atom",
		value => join("", map { chr($converter->($_)) } @{$rule->{value}})
	};
}

method _literal($rule, $level) {
	return {class => "Atom", value => $rule->{value}};
}

method _repetition($rule, $level) {

	my $min = $rule->{min};
	my $count = ($rule->{max} || LONG_MAX) - $min;
	my @result = ();

	push(@result, $self->_generateChain($rule->{value}, $level + 1)) while $min--;
	if ( $level < $RECURSION_LIMIT ) {
		push(@result, $self->_generateChain($rule->{value}, $level + 1)) while $count-- && int(rand(2));
	}

	return {class => "Sequence", value => \@result};
}

method _proseValue($rule, $level) {
	return $self->_generateChain($rule->{name}, $level + 1);
}

method _reference($rule, $level) {
	return $self->_generateChain($rule->{name}, $level + 1);
}

method _group($rule, $level) {

	my @result = ();
	foreach my $elem ( @{$rule->{value}} ) {
		push(@result, $self->_generateChain($elem, $level + 1));
	}

	return {class => "Sequence", value => \@result};
}

method _choice($rule, $level) {

	my @result = ();
	if ( $level < $RECURSION_LIMIT ) {
		foreach my $choice ( @{$rule->{value}} ) {
			push(@result, $self->_generateChain($choice, $level + 1));
		}
	} else {
		push(@result, $self->_generateChain( $rule->{value}->[ int(rand(@{$rule->{value}})) ], $level + 1 ));
	}

	return {class => "Choice", value => \@result};
}

method _rule($rule, $level) {
	return $self->_generateChain($rule->{value}, $level + 1);
}

=pod

=head1 $honest->C<withoutArguments>($name, $tail="")

Return a string starts like command $name and without arguments if command may have no arguments.

Return an empty string otherwise.

$tail is a string added to result if it absent.

dies if there is no command like $rule.

=cut

method withoutArguments(Str $name, Str $tail="") {
	my $result = $self->SUPER::withoutArguments($name, $tail);
	return $self->{_validator}->validate($name, $result) ? $result : "";
}

=pod

=head1 FUNCTIONS

=head1 C<Honest>()

Return __PACKAGE__ to reduce class name :3

=cut

func Honest() {
	return __PACKAGE__;
}

1;

=pod

=head1 AUTHOR / COPYRIGHT / LICENSE

Copyright (c) 2013 Arseny Krasikov <nyaapa@cpan.org>.

This module is licensed under the same terms as Perl itself.

=cut