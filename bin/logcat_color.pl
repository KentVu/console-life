#!/usr/bin/perl 
use v5.14;
use List::Util qw(sum);
use warnings;
use Getopt::Std;

my $c_markstart="\e[?7711l";
my $c_markend="\e[?7711h";
my %colors = (
    I => "\e[32m",
    W => "$c_markstart\e[0;33m$c_markend",
    E => "$c_markstart\e[0;31m$c_markend",
    D => "",
    V => "\e[2;37m",
    n => "\e[0;0m",
    b => "\e[2m",
);
my $dateTime=q/[\d-]+ [\d:\.]+/;
my $logLvl=q/[VDIWE]/;

sub tidChar {
	my $tid=$_[0];
	my $sum=sum split //, $tid;
	chr $sum % 64 + ord 'A';
}

sub colorize {
    my $color = $_[0];
    $color . $_[1] . $colors{n}
}

my $focus_pid;

#Getopt::Mixed::init('f=i focuspid>f');
#while( my( $option, $value, $pretty ) = Getopt::Mixed::nextOption() ) {
#    OPTION: {
#      $option eq 'f' and do {
#        $focus_pid = $value if $value;
#
#        last OPTION;
#      };
#    }
#  }
#Getopt::Mixed::cleanup();
#die "No project specified via -j.\n" unless $Project;
my %opts;
getopts('f:s:g:c:', \%opts);
#sub HELP_MESSAGE {}

$focus_pid=$opts{f};
my $startr = $opts{s};
my $grep = $opts{g};
my $capture = $opts{c};
my $started = !$startr;
my $grep2 = '';

say "[grep = $grep][start = $startr]";

while(<STDIN>) {
    my $thr;
    my $line=$_;
    my $lineno=$.;
    if (!$started && $line =~ m/$startr/) {
        say "started";
        $started = 'true';
    }
    my $print = !($grep || $grep2); #print if none of grep given
    #$print = ($grep || $grep2) && $line =~ m/($grep)|($grep2)/;
    $print = $line =~ m/$grep/ if ($grep);
    $print = $line =~ m/$grep2/ if (!$print && $grep2);
    #say "print = $print";
    if ($started && $print
     && $line =~ m/(?<DATE>$dateTime)\s+(?<PID>\d+)\s+(?<TID>\d+) (?<LVL>$logLvl) (?<TAG>.*?): (?<CONTENT>.*)$/) {
        my %h=%+;
        my $color = $colors{$h{LVL}};
        if ($focus_pid && $h{PID} != $focus_pid) {
            $color = $colors{V}
        }
        $thr = $h{PID} == $h{TID} ? "$colors{b}$h{PID}$color" : "$h{PID}" . tidChar $h{TID};
        say qq[$color$h{LVL}:$h{DATE}:$thr:] . colorize($colors{b}, "$h{TAG}|") . colorize($color, "$h{CONTENT}");
    }# else {
    #    say
    #}
    if ($line =~ m/$capture/) {
        if ($1) {
            if ($grep2) {
                $grep2 = "$grep2|$1";
            } else {
                $grep2 = "$1";
            }
            say "grep2 = $grep2";
        }
    }
}
