#!perl 
use v5.14;
use List::Util qw(sum);
use warnings;

my $c_markstart="\e[?7711l";
my $c_markend="\e[?7711h";
my %colors = (
    I => "\e[0;32m",
    W => "\a$c_markstart\e[0;33m$c_markend",
    E => "\a$c_markstart\e[0;31m$c_markend",
    D => "\e[2;37m",
    V => "\e[2;35m",
    N => "\e[0;0m"
);
my $dateTime=q/[\d-]+ [\d:\.]+/;
my $logLvl=q/[VDIWE]/;

sub tidChar {
	my $tid=$_[0];
	my $sum=sum split //, $tid;
	chr $sum % 64 + ord 'A';
}

while(<>) {
    my $thr;
    my $line=$.;
    if (m/(?<DATE>$dateTime)\s+(?<PID>\d+)\s+(?<TID>\d+) (?<LVL>$logLvl) (?<TAG>.*?): (?<CONTENT>.*)$/) {
        my %h=%+;
        $thr = $h{PID} == $h{TID} ? "UI" : "W" . tidChar $h{TID};
        say qq[$colors{$h{LVL}}$h{DATE}:$thr: $h{TAG}|$h{CONTENT}$colors{N}];
    }
}
