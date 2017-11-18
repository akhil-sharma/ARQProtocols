#user input for determining packet size
puts "enter the decided number"
gets stdin a
set b [expr $a / 2];
set d [expr $a % 2]
if {$d != 0} {
	set b [expr $b + 1];
}
set c [expr $b + 500];
puts "Calculated packet is $c"

set ns [new Simulator]

set nf [open out.nam w]
$ns namtrace-all $nf

proc finish {} {
	global ns nf
	$ns flush-trace
	close $nf
	exec nam out.nam &
	exit 0
}

#creating the nodes
set n1 [$ns node]
set n2 [$ns node]
set S1 [$ns node]
set S2 [$ns node]
set R1 [$ns node]
set R2 [$ns node]
set S3 [$ns node]
set S4 [$ns node]
set n3 [$ns node]
set n4 [$ns node]

#labels
$n1 label "n1"
$n2 label "n2"
$n3 label "n3"
$n4 label "n4"
$S1 label "S1"
$S2 label "S2"
$S3 label "S3"
$S4 label "S4"
$R1 label "R1"
$R2 label "R2"

#creating links
$ns duplex-link $n1 $S1 1Mb 10ms SFQ
$ns duplex-link $n2 $S2 1Mb 10ms SFQ
$ns duplex-link $S1 $R1 1Mb 10ms SFQ
$ns duplex-link $S2 $R1 1Mb 10ms SFQ
$ns duplex-link $R1 $R2 0.2Mb 10ms SFQ
$ns duplex-link $R2 $S3 1Mb 10ms SFQ
$ns duplex-link $R2 $S4 1Mb 10ms SFQ
$ns duplex-link $S3 $n3 1Mb 10ms SFQ
$ns duplex-link $S4 $n4 1Mb 10ms SFQ

#orientation
$ns duplex-link-op $n1 $S1 orient right
$ns duplex-link-op $n2 $S2 orient right
$ns duplex-link-op $S1 $R1 orient right-down
$ns duplex-link-op $S2 $R1 orient right-up
$ns duplex-link-op $R1 $R2 orient right
$ns duplex-link-op $R2 $S3 orient right-up
$ns duplex-link-op $R2 $S4 orient right-down
$ns duplex-link-op $S3 $n3 orient right
$ns duplex-link-op $S4 $n4 orient right

#Protocol plus traffic sources
set tcp0 [new Agent/TCP]
$tcp0 set class_ 0
set sink0 [new Agent/TCPSink]
$ns attach-agent $n1 $tcp0
$ns attach-agent $n3 $sink0
$ns connect $tcp0 $sink0
#cbr0
set cbr0 [new Application/Traffic/CBR]
$cbr0 set packetSize_ $c
$cbr0 set interval_ 0.005
$cbr0 attach-agent $tcp0

set tcp1 [new Agent/TCP]
$tcp1 set class_ 1
set sink1 [new Agent/TCPSink]
$ns attach-agent $n2 $tcp1
$ns attach-agent $n4 $sink1
$ns connect $tcp1 $sink1
#cbr1
set cbr1 [new Application/Traffic/CBR]
$cbr1 set packetSize_ $c
$cbr1 set interval_ 0.005
$cbr1 attach-agent $tcp1

set tcp2 [new Agent/TCP]
$tcp2 set class_ 2
set sink2 [new Agent/TCPSink]
$ns attach-agent $n3 $tcp2
$ns attach-agent $n1 $sink2
$ns connect $tcp2 $sink2
#cbr2
set cbr2 [new Application/Traffic/CBR]
$cbr2 set packetSize_ $c
$cbr2 set interval_ 0.005
$cbr2 attach-agent $tcp2

#color
$ns color 0 Blue
$ns color 1 Red
$ns color 2 Green

$ns at 0.5 "$cbr0 start"
$ns at 0.5 "$cbr1 start"
$ns at 0.5 "$cbr2 start"

$ns at 3.5 "$cbr0 stop"
$ns at 3.5 "$cbr1 stop"
$ns at 3.5 "$cbr2 stop"

$ns at 4.0 "finish"
$ns run