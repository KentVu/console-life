#!perl 
use v5.14;
use List::Util qw(sum);
use warnings;

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
my $focus_pid=$ARGV[0];

sub tidChar {
	my $tid=$_[0];
	my $sum=sum split //, $tid;
	chr $sum % 64 + ord 'A';
}

sub colorize {
    my $color = $_[0];
    $color . $_[1] . $colors{n}
}

while(<STDIN>) {
    my $thr;
    my $line=$.;
    if (m/(?<DATE>$dateTime)\s+(?<PID>\d+)\s+(?<TID>\d+) (?<LVL>$logLvl) (?<TAG>.*?): (?<CONTENT>.*)$/) {
        my %h=%+;
        $thr = $h{PID} == $h{TID} ? "UI" : "W" . tidChar $h{TID};
        my $color = $colors{$h{LVL}};
        if ($focus_pid && $h{PID} != $focus_pid) {
            $color = $colors{V}
        }
        say qq[$color$h{DATE}:$thr:] . colorize($colors{b}, "$h{TAG}|") . colorize($color, "$h{CONTENT}");
    } else {
        say
    }
}
