#!/usr/bin/perl


#defines
$log_path="/var/traffic";
$domain="dl-com";
$MAX=64*1024;

print "Content-type: text/html\n\n";

($cgi_bin,$cgi_script) = ($0 =~ m:(.*)[/\\](.*):);
$query = $ENV{QUERY_STRING};
$cgi_url="$cgi_script";
$time=`date`;


#print "$cgi_bin/$cgi_script<BR>";
if(!defined(query)  || $query eq '') {
	error();
}		


($user,$year,$month,$day,$hour)=split(/&/,$query);
#print "$year,$month,$day,$hour<BR>";

if(!defined($year) || !defined($month)) {
	error();
} 

$log_file = "$log_path/$year/$month/$user.log";
#print "$log_file<BR>";
open(LOG,$log_file) || error();

#print "DEBUG: <BR>";

print "<TITLE> $user traffic statistic </TITLE>";

if(defined($day) && defined($hour)) {
	do_hourly();
} elsif (defined($day)) {
	do_daily();
} else {
	do_monthly();
}

 
print <<END;
	<P ALIGN=center> <FONT COLOR=blue1>
		 Result generated at: $time 
	</FONT>	<BR>
	Any comments etc :
	<A HREF="mailto:admin\@savelovo.net.ru"> me </A>
	</P>
END






sub do_hourly 
{
 my($sum_in,$msum_in,$sum_out,$msum_out,$load);
 $bw=$MAX*5*60/100;

	while(defined($line=<LOG>)) {
#		print "$line<BR>";


		($date,$in,$out)=split(/ /,$line);
		($myday,$myhour,$mymin)=split(/:/,$date);
		if($myday==$day && $myhour==$hour) {
print  <<HEAD;			
		<DIV ALIGN=CENTER> <FONT COLOR=blue SIZE=+2> 
			Hourly statistic for $user at $hour hour $day/$month/$year. <BR> 
		</FONT>
		<P>
		<TABLE BORDER=1> <TR> 
		<TD> Minutes </TD> <TD>IN</TD><TD>OUT</TD><TD>Load(%)</TD> </TR>
HEAD
			while(defined($line) && ($myday==$day) && ($myhour==$hour))
			{
				$msum_in=$in;
				$sum_in+=$msum_in;

				$msum_out=$out;
				$sum_out+=$msum_out;
				$load=$msum_in/$bw;
print <<LINE;
		<TR> <TD>$mymin IN</TD><TD> <FONT COLOR=red>$msum_in </FONT></TD> 
	        <TD><FONT COLOR=red>$msum_out </FONT></TD>
LINE
		printf("<TD><FONT COLOR=red>%.2f</TR>",$load);

				$line=<LOG>;
#				print "$line<BR>";
	                        ($date,$in,$out)=split(/ /,$line);
                                ($myday,$myhour,$mymin)=split(/:/,$date);
			}

	$tmp_in=$sum_in/1024/1024;
	print"</TABLE></DIV>";
      	print "<P>";
        print "<DIV ALIGN=center> <TABLE BORDER=1> <TR><TD>";
        printf("TOTAL:</TD><TD> IN: %.3fM",$tmp_in);
        $tmp_out=$sum_out/1024/1024;
        print "</TD><TD>";
        printf("OUT: %.3fM </TD>",$tmp_out);
	print "</TR> </TABLE> </DIV>";
        print"</TABLE></DIV>";
        print "<P>";
        print "<DIV ALIGN=center> <TABLE BORDER=1><TR><TD>";
        printf("SUM: %.3fM",$tmp_in+$tmp_out);
        print "</TD> </TR> </TABLE> </DIV>";
	
	return;
		}
	}
print <<END;
	<DIV ALIGN=center> <FONT COLOR=red SIZE=+3>
	Sorry!!! There is no data for your request!!!
	</FONT></DIV>
END
}


sub do_daily()
{
 my($sum_in,$sum_out,$hsum_in,$hsum_out,$msum_in,$msum_out,$tmp_hour,$load);
	$tmp_hour=0; $hsum_in=0;$hsum_out=0;
 	
	while(defined($line=<LOG>)) {
#		print "$line<BR>";
                ($date,$in,$out)=split(/ /,$line);
		($myday,$myhour,$mymin)=split(':',$date);
		if($myday==$day ) {
print <<HEAD;
		<DIV ALIGN=CENTER> <FONT COLOR=blue SIZE=+2>
                        Hourly statistic for $user at $hour hour $day/$month/$year
                </FONT><P>
		<TABLE BORDER=1> <TR> <TD> </TD>
		<TD>HOURS </TD> <TD>IN</TD> </TD><TD>OUT</TD>
		</TR>
HEAD
			while(defined($line) && ($myday==$day))
			{
				$msum_in=$in;
				$msum_out=$out;

				while($tmp_hour<$myhour) {
print <<LINE;
					<TR><TD>
					<a href="$cgi_url?$user&$year&$month&$day&$tmp_hour"> MORE </a>
					</TD><TD>$tmp_hour</TD><TD>
					$hsum_in</TD><TD>$hsum_out</TD></TR>
LINE
					$tmp_hour++;
					$hsum_in=0;
					$hsum_out=0;		
				}
				$sum_in+=$msum_in;
				$hsum_in+=$msum_in;
				$sum_out+=$msum_out;
				$hsum_out+=$msum_out;
			
				$line=<LOG>;
#				print "$line<BR>";
                       		($date,$in,$out)=split(/ /,$line);
                                ($myday,$myhour,$mymin)=split(/:/,$date);

			}
print <<LINE;
			<TD>
			<a href="$cgi_url?$user&$year&$month&$day&$tmp_hour"> MORE </a>
			</TD><TD>$tmp_hour</TD><TD> 
			$hsum_in</TD><TD>$hsum_out</TD></TR>
			</TABLE>
LINE
        $tmp_in=$sum_in/1024/1024;
        print"</TABLE></DIV>";
        print "<P>";
        print "<DIV ALIGN=center> <TABLE BORDER=1> <TR><TD>";
        printf("TOTAL:</TD><TD> IN: %.3fM",$tmp_in);
        $tmp_out=$sum_out/1024/1024;
        print "</TD><TD>";
        printf("OUT: %.3fM",$tmp_out);
        print "</TD> </TR> </TABLE> </DIV>";
        print"</TABLE></DIV>";
        print "<P>";
        print "<DIV ALIGN=center> <TABLE BORDER=1><TR><TD>";
        printf("SUM: %.3fM",$tmp_in+$tmp_out);
        print "</TD> </TR> </TABLE> </DIV>";

			return;
		}
	}
print <<END;
	<DIV ALIGN=center> <FONT COLOR=red SIZE=+3>
        Sorry!!! There is no data for your request!!!      
        </FONT></DIV>

END
}

sub do_monthly()
{
	my($sum_in,$sum_out,$dsum_in,$dsum_out,$msum_in,$msum_out,$tmp_day);

print <<HEAD;
	<DIV ALIGN=CENTER> <FONT COLOR=blue SIZE=+2>
        Monthly statistic for $user at $month/$year. <BR>
        </FONT><P>  
        <TABLE BORDER=1> <TR> <TD> </TD>
        <TD>DAYS</TD> <TD>IN</TD><TD>OUT</TD> </TR>
HEAD
	$tmp_day=1;$dsum_in=0;$dsum_out=0;
	while(defined($line=<LOG>)) {
#		print "$line<BR>";

                ($date,$in,$out)=split(/ /,$line);
		($myday,$myhour,$mymin)=split(/:/,$date);

 		$msum_in=$in;
		$msum_out=$out;

		while($tmp_day<$myday) {
print <<LINE;
		  	<TR><TD>
			<a href="$cgi_url?$user&$year&$month&$tmp_day"> MORE </a>
			</TD><TD>$tmp_day</TD><TD>
			$dsum_in</TD><TD>$dsum_out </TD></TR>
LINE
			$dsum_in=0;
			$dsum_out=0;		
			$tmp_day++;
		}
				$sum_in+=$msum_in;
				$sum_out+=$msum_out;
				$dsum_in+=$msum_in;
				$dsum_out+=$msum_out;
	}
print <<LINE;
	<TD>
        <a href="$cgi_url?$user&$year&$month&$tmp_day"> MORE </a>
        </TD><TD>$tmp_day</TD><TD> $dsum_in</TD><TD>$dsum_out </TD></TR>
	</TABLE>
LINE
        $tmp_in=$sum_in/1024/1024;
        print"</TABLE></DIV>";
        print "<P>";
        print "<DIV ALIGN=center> <TABLE BORDER=1> <TR><TD>";
        printf("TOTAL:</TD><TD> IN: %.3fM",$tmp_in);
        $tmp_out=$sum_out/1024/1024;
        print "</TD><TD>";
        printf("OUT: %.3fM",$tmp_out);
        print "</TD> </TR> </TABLE> </DIV>";
        print"</TABLE></DIV>";
        print "<P>";
        print "<DIV ALIGN=center> <TABLE BORDER=1><TR><TD>";
        printf("SUM: %.3fM",$tmp_in+$tmp_out);
        print "</TD> </TR> </TABLE> </DIV>";

}



sub error {
print <<ERROR;
	<DIV ALIGN=center> <FONT COLOR=red SIZE=+3>	
	Wrong parameters!!!
	</FONT> </DIV>
        <P ALIGN=center> <FONT COLOR=blue1>
                 Answer generated at: $time
        </FONT> <BR>
        Any comments etc :
        <A HREF="mailto:admin\@savelovo.net.ru"> me </A>
        </P>
ERROR
exit;
}
