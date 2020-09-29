#!/usr/bin/perl

use strict;
use warnings;
use XML::SAX::Writer    qw();
use File::Slurp         qw(read_file write_file);

### @@@ TODO
#
# - skip "valuetype DOMString sequence<unsigned short>;"



# CLM (2008-07-10):
#   Take input and output from arguments.
die "Syntax: idl2xml.pl INPUT OUTPUT\n" unless @ARGV == 2;
my ($input, $output) = @ARGV;
# my $input = '../spec/mobile/1.2/IDL/udom.idl';
# my $output = './udom-idl.xml';

my $result;
my $xsw = XML::SAX::Writer->new(Output => \$result);
my $drv = IDL2SAX->new(Handler => $xsw);

my $idl = read_file($input);
$drv->parseString($idl);
write_file($output, $result);

my $indent = `xmllint --format $output`;
write_file($output, $indent);

package IDL2SAX;
use base qw(XML::SAX::Base);
use Text::Balanced qw(extract_bracketed);

use constant NS => 'http://berjon.com/ns/svg-idl/';

sub new {
    my $class = shift;
    my $self = $class->SUPER::new(@_);
    $self->{curStr} = '';
    return bless $self, $class;
}

sub parseString {
    my $self = shift;
    $self->{curStr} = shift;
    $self->parseIDL;
}

sub parseIDL {
    my $self = shift;
    $self->start_document;
    $self->start_prefix_mapping({Prefix => '', NamespaceURI => NS});
    $self->start_element(makeElement('idl'));
    $self->removeComments;
    $self->removeHeaders;
    $self->removeValueTypes;
    $self->parseModules;
    $self->end_element(makeElement('idl'));
    $self->end_prefix_mapping({Prefix => ''});
    $self->end_document;
}

sub removeComments {
    my $self = shift;
    # there aren't any right now
}

sub removeHeaders {
    my $self = shift;
    $self->{curStr} =~ s/pragmas.*?\]\s*//sm;
}

sub removeValueTypes {
    my $self = shift;
    $self->{curStr} =~ s/valuetype.*?;\s*//sm;
}

sub parseModules {
    my $self = shift;
    my $str = $self->{curStr};
    while (length $str) {
        next if $str =~ s/^\s+//m;
        if ($str =~ s/^module\s+(\w+)\s*//m) {
            my $module = $1;
            my ($cnt, $rest) = extract_bracketed($str, "{}");
            die "Failed to parse module $module" unless $cnt;
            $cnt =~ s/^{//;
            $cnt =~ s/}$//;
            $self->start_element(makeElement('module', {name => $module}));
            $self->parseModuleContent($cnt);
            $self->end_element(makeElement('module'));
            $str = $rest;
            $str =~ s/^\s*;\s*//m;
        }
        else {
            die "Unknown token while looking for module:\n$str\n";
        }
    }
}

sub parseModuleContent {
    my $self = shift;
    my $str = shift;
    
    # hey ho let's go!
    while (length $str) {
        next if $str =~ s/^\s+//m;
        # typedef
        if ($str =~ s/^typedef\s+([\w:]+)\s+([\w:]+)\s*;\s*//s) {
            $self->start_element(makeElement('typedef', {alias => $1, to => $2}));
            $self->end_element(makeElement('typedef'));
        }
        # interface pre-declaration
        elsif ($str =~ s/^interface\s+(\w+)\s*;\s*//s) {
            $self->start_element(makeElement('interface-stub', {name => $1}));
            $self->end_element(makeElement('interface-stub'));
        }
        # const
        elsif ($str =~ s/^const\s+([\w ]+)\s+(\w+)\s*=\s*(\w+);\s*//s) {
            $self->start_element(makeElement('const', {type => $1, name => $2, value => $3}));
            $self->end_element(makeElement('const'));
        }
        # exception
        elsif ($str =~ s/^exception\s+([\w]+)\s*//s) {
            my $ex = $1;
            my ($cnt, $rest) = extract_bracketed($str, "{}");
            die "Failed to parse exception $ex\nString:\n$str\nRest:\n$rest" unless $cnt;
            $cnt =~ s/^{//;
            $cnt =~ s/}$//;
            $self->start_element(makeElement('exception', {name => $ex}));
            #$self->parseExceptionContent($cnt);
            $self->start_element(makeElement('field', 
                            {name => 'code', type => 'unsigned short', readonly => 'false'}));
            $self->end_element(makeElement('field'));
            $self->end_element(makeElement('exception'));
            $str = $rest;
            $str =~ s/^\s*;\s*//m;
        }
        # interface
        elsif ($str =~ s/^interface\s+([\w]+)(?:\s*\:\s*([\w:,\s]+))?\s*//s) {
            my $if = $1;
            my @inh = split /[\s,]+/, ($2 || '');
            my ($cnt, $rest) = extract_bracketed($str, "{}");
            die "Failed to parse interface $if" unless $cnt;
            $cnt =~ s/^{//;
            $cnt =~ s/}$//;
            $self->start_element(makeElement('interface', {name => $if}));
            for my $inh (@inh) {
                $self->start_element(makeElement('inherits', {from => $inh}));
                $self->end_element(makeElement('inherits'));
            }
            $self->parseInterfaceContent($cnt);
            $self->end_element(makeElement('interface'));
            $str = $rest;
            $str =~ s/^\s*;\s*//m;
        }
        # error
        else {
            die "Unknown token in module content:\n$str\n";
        }
    }
}

sub parseInterfaceContent {
    my $self = shift;
    my $str = shift;

    my @items = split /\s*;\s*/, $str;
    for my $item (@items) {
        next if $item =~ m/^\s*$/;
        $item =~ s/^\s+|\s+$//g;
        # attribute
        if ($item =~ m/^(readonly)?\s*attribute\s+([\w:<> ]+)\s+(\w+)$/) {
            $self->start_element(makeElement('field', 
                            {name => $3, type => $2, readonly => ($1?'true':'false')}));
            $self->end_element(makeElement('field'));
        }
        # const
        elsif ($item =~ m/^const\s+([\w ]+)\s+(\w+)\s*=\s*(\w+)\s*/) {
            $self->start_element(makeElement('const', {type => $1, name => $2, value => $3}));
            $self->end_element(makeElement('const'));
        }
        # method
        # DOMString getTraitNS(in DOMString namespaceURI, in DOMString name) raises(DOMException);
        elsif ($item =~ m/^([\w:<> ]+?)\s+(\w+)\s*\(([^\)]*?)\)(?:\s+raises\(([\w:]+)\))?$/) {
            my $arg = $3;
            $self->start_element(makeElement('method', {returns => $1, name => $2, raises => $4}));
            my @param = split /\s*,\s*/, $arg;
            for my $p (@param) {
                $p =~ s/^in\s+//;
                $p =~ m/^([\w:<> ]+)\s+(\w+)$/;
                $self->start_element(makeElement('param', {type => $1, name => $2}));
                $self->end_element(makeElement('param'));
            }
            $self->end_element(makeElement('method'));
        }
        # error
        else {
            die "Unrecognized item in interface definition: '$item'\n";
        }
    }
}

# helpers
sub makeElement {
    my $ln = shift;
    my $attr = shift || {};
    my $ats = {};
    while (my ($k,$v) = each %$attr) {
        $ats->{"{}$k"} = {
            Name        => $k,
            LocalName   => $k,
            NamespaceURI=> '',
            Prefix      => '',
            Value       => $v,
        }
    }
    return {
        NamespaceURI    => NS,
        LocalName       => $ln,
        Prefix          => '',
        Name            => $ln,    
        Attributes      => $ats,
    };
}

